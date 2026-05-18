sub init()
    m.top.setFocus(true)
    m.radioBackground = m.top.FindNode("radioBackground")
    m.top.backgroundURI = "pkg:/images/background-controls.jpg"
    
    m.save_feed_url = m.top.FindNode("save_feed_url")
    m.get_channel_list = m.top.FindNode("get_channel_list")
    m.get_channel_list.ObserveField("content", "SetContent")

    m.video = m.top.FindNode("Video")
    m.video.enableUI = false 
    m.video.ObserveField("state", "checkState")
    m.video.ObserveField("streamInfo", "onStreamInfoChange")
    
    m.menu = m.top.FindNode("menuContainer")
    m.list = m.top.FindNode("list")
    m.list.ObserveField("itemSelected", "setChannel")
    m.list.ObserveField("itemFocused", "onItemFocused")
    
    m.videoBanner = m.top.FindNode("videoBanner")
    m.topTitleImage = m.top.FindNode("topTitleImage")    
    m.topTitleImage2 = m.top.FindNode("topTitleImage2")
    m.itemTitleLabel = m.top.FindNode("itemTitleLabel")
    m.itemPreviewPoster = m.top.FindNode("itemPreviewPoster")

    m.focusedMenuIndex = 0 
    m.isFullScreen = false 
    
    for each child in m.menu.getChildren(-1, 0)
        child.ObserveField("focusedChild", "onMenuFocusChange")
    end for
    
    m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
    
    m.seriesDetailsContainer = m.top.FindNode("seriesDetailsContainer")
    m.seriesDetailPoster = m.top.FindNode("seriesDetailPoster")
    m.seriesDetailTitle = m.top.FindNode("seriesDetailTitle")
    m.episodeList = m.top.FindNode("episodeList")
    
    m.currentPlayingNode = invalid
    m.originalPlayingTitle = ""
    m.currentPlayingUrl = ""
    
    m.episodeList.ObserveField("itemSelected", "playEpisode")
    
    m.isSeriesDetailOpen = false
    
    m.initialSplashScreen = m.top.FindNode("initialSplashScreen")
    
    if m.initialSplashScreen <> invalid
        m.initialSplashScreen.visible = true 
    end if
    
    m.isInitialSplashOpen = true 
    
    m.top.setFocus(true)

    m.videoUI = m.top.FindNode("videoUI")
    m.uiBackground = m.top.FindNode("uiBackground")
    m.currentTimeLabel = m.top.FindNode("currentTimeLabel")
    m.totalTimeLabel = m.top.FindNode("totalTimeLabel")
    m.progressTrack = m.top.FindNode("progressTrack")
    m.progressFill = m.top.FindNode("progressFill")
    m.uiHideTimer = m.top.FindNode("uiHideTimer")

    if m.uiHideTimer <> invalid then m.uiHideTimer.ObserveField("fire", "hideVideoUI")
    if m.video <> invalid then m.video.ObserveField("position", "updateProgressBar")
	
	m.fullScreenFocusHolder = m.top.FindNode("fullScreenFocusHolder")
end sub

sub onItemFocused()
    if not m.list.hasFocus() or m.list.content = invalid or m.list.content.getChildCount() = 0
        return
    end if

    contentNode = invalid
    
    if m.list.content.getChild(0).getChild(0) = invalid
        contentNode = m.list.content.getChild(m.list.itemFocused)
    else
        itemSelected = m.list.itemFocused
        for i = 0 to m.list.currFocusSection - 1
            itemSelected = itemSelected - m.list.content.getChild(i).getChildCount()
        end for
        if itemSelected >= 0 and m.list.content.getChild(m.list.currFocusSection) <> invalid
            contentNode = m.list.content.getChild(m.list.currFocusSection).getChild(itemSelected)
        end if
    end if
    
    if contentNode <> invalid
        
        if m.itemPreviewPoster <> invalid
            posterUrl = contentNode.HDPosterUrl
            
            if posterUrl <> "" and posterUrl <> invalid
                m.itemPreviewPoster.uri = posterUrl
            else
                m.itemPreviewPoster.uri = "https://raw.githubusercontent.com/xClifordx/misc/refs/heads/main/CARGANDO.png"
            end if
            
            if not m.isFullScreen 
                m.itemPreviewPoster.visible = true
            else
                m.itemPreviewPoster.visible = false
            end if
        end if

        if m.itemTitleLabel <> invalid
            if m.focusedMenuIndex = 1
                m.itemTitleLabel.text = contentNode.title
                m.itemTitleLabel.visible = true
            else
                m.itemTitleLabel.visible = false
            end if
        end if
        
    end if
end sub

sub onMenuFocusChange()
    for each child in m.menu.getChildren(-1, 0)
        if child.hasFocus()
            child.scale = [1.2, 1.2] 
            child.opacity = 1.0
        else
            child.scale = [1.0, 1.0]
            child.opacity = 0.5
        end if
    end for
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    handled = false

    if m.isInitialSplashOpen = true
        if key = "OK"
            if m.initialSplashScreen <> invalid 
                m.initialSplashScreen.visible = false
            end if

            m.isInitialSplashOpen = false

            if m.menu <> invalid and m.menu.getChild(m.focusedMenuIndex) <> invalid
                m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
            end if

            return true
        end if

        return true
    end if
    
    menuHasFocus = false
    if m.menu <> invalid
        menuHasFocus = (m.menu.getChild(0).hasFocus() or m.menu.getChild(1).hasFocus() or m.menu.getChild(2).hasFocus() or m.menu.getChild(3).hasFocus())
    end if

    if key = "back" and menuHasFocus = false and m.list.hasFocus() = false
        if m.episodeList = invalid or m.episodeList.hasFocus() = false
            if m.video <> invalid then m.video.SetFocus(false) 
            if m.seriesDetailsContainer <> invalid then m.seriesDetailsContainer.visible = false
            m.isSeriesDetailOpen = false
            if m.list <> invalid then m.list.visible = true
            if m.menu <> invalid and m.menu.getChild(m.focusedMenuIndex) <> invalid
                m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
            end if
            return true
        end if
    end if

    if m.isFullScreen = true
        if key = "left" or key = "right" or key = "up" or key = "down" or key = "back"
            exitFullscreen()
            return true
        end if
        
        if m.focusedMenuIndex = 1 or m.focusedMenuIndex = 2 
            if key = "fastforward"
                if m.Video <> invalid 
                    m.Video.seek = m.Video.position + 30 
                    m.Video.control = "resume"
                    showVideoUI()
                end if
                return true
            else if key = "rewind"
                if m.Video <> invalid 
                    newPos = m.Video.position - 30
                    if newPos < 0 then newPos = 0
                    m.Video.seek = newPos 
                    m.Video.control = "resume"
                    showVideoUI()
                end if
                return true
            else if key = "play"
                if m.Video <> invalid
                    if m.Video.state = "playing"
                        m.Video.control = "pause"
                    else
                        m.Video.control = "resume"
                    end if
                    showVideoUI()
                end if
                return true
            end if
        end if
        return true
    end if

    if key = "options"
        showSearchDialog()
        return true
    end if

    if key = "back" and menuHasFocus
        return true 
    end if

    if menuHasFocus
        if key = "right"
            if m.focusedMenuIndex < 3
                m.focusedMenuIndex = m.focusedMenuIndex + 1
                m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
            end if
            return true
        else if key = "left"
            if m.focusedMenuIndex > 0
                m.focusedMenuIndex = m.focusedMenuIndex - 1
                m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
            end if
            return true
        else if key = "OK"
            executeSelection(m.focusedMenuIndex)
            return true
        else if key = "down"
            if m.list.visible
                m.list.SetFocus(true)
                return true
            end if
        end if

    else if m.list.hasFocus()
        if key = "back" 
            m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
            return true
        else if key = "right"
            goFullscreen()
            return true
        end if

    else if m.episodeList <> invalid and m.episodeList.hasFocus()
        if key = "back"
            m.seriesDetailsContainer.visible = false
            m.isSeriesDetailOpen = false
            m.list.visible = true
            m.list.SetFocus(true)
            return true
            
        else if key = "left" or key = "up"
            m.seriesDetailsContainer.visible = false
            m.isSeriesDetailOpen = false
            m.list.visible = true
            m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
            return true
            
        else if key = "right"
            goFullscreen()
            return true
        end if
    end if

    return handled
end function

sub goFullscreen()
    fullW = 0
    fullH = 0
    
    m.video.translation = [0, 0]
    m.video.width = fullW
    m.video.height = fullH
    
    if m.radioBackground <> invalid
        m.radioBackground.translation = [0, 0]
        m.radioBackground.width = fullW
        m.radioBackground.height = fullH
    end if
    
    m.isFullScreen = true 
   
    if m.videoBanner <> invalid then m.videoBanner.visible = false
    if m.topTitleImage <> invalid then m.topTitleImage.visible = false
    if m.topTitleImage2 <> invalid then m.topTitleImage2.visible = false
    if m.itemPreviewPoster <> invalid then m.itemPreviewPoster.visible = false
    if m.itemTitleLabel <> invalid then m.itemTitleLabel.visible = false
    if m.menu <> invalid then m.menu.visible = false
    if m.list <> invalid then m.list.visible = false   
    if m.seriesDetailsContainer <> invalid then m.seriesDetailsContainer.visible = false
   
    if m.episodeList <> invalid then m.episodeList.focusable = false
    if m.list <> invalid then m.list.focusable = false

        m.fullScreenFocusHolder.SetFocus(true)
    end if
end sub

sub exitFullscreen()
    miniX = 900
    miniY = 40
    miniW = 920
    miniH = 500
    
    m.video.translation = [miniX, miniY]
    m.video.width = miniW
    m.video.height = miniH
    
    if m.radioBackground <> invalid
        m.radioBackground.translation = [miniX, miniY]
        m.radioBackground.width = miniW
        m.radioBackground.height = miniH
    end if
    
    m.isFullScreen = false 
    
    if m.videoBanner <> invalid then m.videoBanner.visible = true
    if m.topTitleImage <> invalid then m.topTitleImage.visible = true
    if m.topTitleImage2 <> invalid then m.topTitleImage2.visible = true
    if m.itemPreviewPoster <> invalid then m.itemPreviewPoster.visible = true
    if m.menu <> invalid then m.menu.visible = true
        
    if m.itemTitleLabel <> invalid
        m.itemTitleLabel.visible = (m.focusedMenuIndex = 1)
    end if

    if m.episodeList <> invalid then m.episodeList.focusable = true
    if m.list <> invalid then m.list.focusable = true

    if m.isSeriesDetailOpen = true
        m.list.visible = false
        m.itemPreviewPoster.visible = false
        if m.seriesDetailsContainer <> invalid then m.seriesDetailsContainer.visible = true
        if m.episodeList <> invalid then m.episodeList.SetFocus(true)
    else
        if m.list <> invalid then m.list.visible = true
        if m.list <> invalid then m.list.SetFocus(true)
    end if
    hideVideoUI()
end sub

sub executeSelection(index as Integer)
    m.focusedMenuIndex = index

    m.isSeriesDetailOpen = false
    if m.seriesDetailsContainer <> invalid 
        m.seriesDetailsContainer.visible = false
    end if
    
    if m.episodeList <> invalid 
        m.episodeList.content = invalid
    end if

    if m.list <> invalid 
        m.list.visible = true
        m.list.jumpToItem = 0 
    end if

    if m.itemTitleLabel <> invalid
        m.itemTitleLabel.visible = (index = 1)
    end if

    if m.itemPreviewPoster <> invalid
        if index = 0 
            m.itemPreviewPoster.width = 500
            m.itemPreviewPoster.height = 500
            m.itemPreviewPoster.translation = [1150, 550] 
            m.itemPreviewPoster.uri = "https://raw.githubusercontent.com/xClifordx/misc/refs/heads/main/CARGANDO.png"
            
            m.list.basePosterSize = [180, 180]
            m.list.numColumns = 4
            m.global.feedurl = "https://raw.githubusercontent.com/xClifordx/master/refs/heads/main/IPSACL.m3u"
            
        else if index = 1 
            m.itemPreviewPoster.width = 360
            m.itemPreviewPoster.height = 500
            m.itemPreviewPoster.translation = [1200, 550] 
            m.itemPreviewPoster.uri = "https://raw.githubusercontent.com/xClifordx/misc/refs/heads/main/CARGANDO.png"
            
            m.list.basePosterSize = [180, 270]
            m.list.numColumns = 4
            m.global.feedurl = "https://raw.githubusercontent.com/xClifordx/master/refs/heads/main/PELICLIF.m3u"
            
        else if index = 2 
            m.itemPreviewPoster.width = 360
            m.itemPreviewPoster.height = 500
            m.itemPreviewPoster.translation = [1200, 550] 
            m.itemPreviewPoster.uri = "https://raw.githubusercontent.com/xClifordx/misc/refs/heads/main/CARGANDO.png"
            
            m.list.basePosterSize = [180, 270]
            m.list.numColumns = 4
            m.global.feedurl = "https://raw.githubusercontent.com/xClifordx/master/refs/heads/main/CLIFISERI.m3u"
            
        else if index = 3 
            m.itemPreviewPoster.width = 500
            m.itemPreviewPoster.height = 500
            m.itemPreviewPoster.translation = [1150, 550] 
            m.itemPreviewPoster.uri = "https://raw.githubusercontent.com/xClifordx/misc/refs/heads/main/CARGANDO.png"
            
            m.list.basePosterSize = [180, 180]
            m.list.numColumns = 4
            m.global.feedurl = "https://raw.githubusercontent.com/xClifordx/master/refs/heads/main/radios.m3u"
        end if
    end if
        
    m.save_feed_url.control = "RUN"
    m.get_channel_list.control = "RUN"
end sub

sub SetContent()    
    if m.get_channel_list.content <> invalid
        
        if m.isSeriesDetailOpen = true
            m.episodeList.content = m.get_channel_list.content
            
            restorePlayingIndicator()
            
            m.episodeList.setFocus(true)
        else
            m.list.content = m.get_channel_list.content
            m.list.visible = true 
            m.list.SetFocus(true) 
        end if
        
    else
        m.menu.getChild(m.focusedMenuIndex).SetFocus(true)
    end if
end sub

sub checkState()
    if m.video = invalid then return
    
    state = m.video.state
    
    if state = "stopped" or state = "error" or state = "buffering"
        if m.radioBackground <> invalid then m.radioBackground.visible = false 
    end if
    
    if state = "playing" then onStreamInfoChange()
    if state = "finished"
        if m.focusedMenuIndex = 2 and m.episodeList <> invalid and m.episodeList.content <> invalid
            
            totalEpisodes = 0
            
            if m.episodeList.content.getChild(0) <> invalid
                if m.episodeList.content.getChild(0).getChild(0) = invalid
                    totalEpisodes = m.episodeList.content.getChildCount()
                else
                    for i = 0 to m.episodeList.content.getChildCount() - 1
                        section = m.episodeList.content.getChild(i)
                        if section <> invalid
                            totalEpisodes = totalEpisodes + section.getChildCount()
                        end if
                    end for
                end if
            end if
            
            nextIndex = m.episodeList.itemSelected + 1
            
            if nextIndex < totalEpisodes
                m.episodeList.itemSelected = nextIndex
            else
                exitFullscreen()
            end if
            
        else if m.focusedMenuIndex = 1
            exitFullscreen()
        end if
        
    end if
end sub

sub setChannel()
    m.currentPlayingNode = invalid
    m.originalPlayingTitle = ""
    
    if m.list.content <> invalid and m.list.content.getChildCount() > 0
        if m.list.content.getChild(0).getChild(0) = invalid
            contentNode = m.list.content.getChild(m.list.itemSelected)
        else
            itemSelected = m.list.itemSelected
            for i = 0 to m.list.currFocusSection - 1
                itemSelected = itemSelected - m.list.content.getChild(i).getChildCount()
            end for
            contentNode = m.list.content.getChild(m.list.currFocusSection).getChild(itemSelected)
        end if
        
        if m.focusedMenuIndex = 2
            openSeriesDetails(contentNode)
        else
            
            if m.radioBackground <> invalid then m.radioBackground.visible = false
            contentNode.streamFormat = "hls, mp4, mkv, ts"

            if m.focusedMenuIndex = 1
                contentNode.live = false
            end if
            
            m.video.content = contentNode
            m.video.visible = true 
            m.video.control = "play"
            m.list.SetFocus(true)
        end if
    end if
end sub

sub showSearchDialog()
    m.keyboard = createObject("roSGNode", "KeyboardDialog")
    m.keyboard.title = "Buscar canal, película o serie..."
    m.keyboard.buttons = ["Buscar", "Restaurar Lista", "Cancelar"]
    m.keyboard.ObserveField("buttonSelected", "onSearchOptionSelected")
    m.top.dialog = m.keyboard
end sub

sub onSearchOptionSelected()
    if m.keyboard.buttonSelected = 0 
        searchText = lcase(m.keyboard.text)
        filterContent(searchText)
    else if m.keyboard.buttonSelected = 1 
        m.list.content = m.get_channel_list.content
    end if
    m.top.dialog.close = true
end sub

sub filterContent(query as String)
    if m.get_channel_list.content = invalid then return
    
    filteredContent = createObject("roSGNode", "ContentNode")
    originalContent = m.get_channel_list.content
    
    hasSections = (originalContent.getChildCount() > 0 and originalContent.getChild(0).getChildCount() > 0)
    
    if hasSections
        for i = 0 to originalContent.getChildCount() - 1
            section = originalContent.getChild(i)
            for j = 0 to section.getChildCount() - 1
                item = section.getChild(j)
                if instr(1, lcase(item.title), query) > 0
                    newItem = filteredContent.createChild("ContentNode")
                    newItem.update(item.getFields())
                end if
            end for
        end for
    else
        for i = 0 to originalContent.getChildCount() - 1
            item = originalContent.getChild(i)
            if instr(1, lcase(item.title), query) > 0
                newItem = filteredContent.createChild("ContentNode")
                newItem.update(item.getFields())
            end if
        end for
    end if
    
    m.list.content = filteredContent
end sub

sub onStreamInfoChange()
    if m.radioBackground = invalid then return
    
    if m.focusedMenuIndex <> 3
        m.radioBackground.visible = false
        return 
    end if

    info = m.video.streamInfo
    state = m.video.state
    hasVideo = false 
    
    if info <> invalid
        if (info.DoesExist("videoWidth") and info.videoWidth > 0) or (info.DoesExist("videoFormat") and info.videoFormat <> "")
            hasVideo = true 
        end if
    end if

    if hasVideo
        m.radioBackground.visible = false
    else if state = "playing"
        m.radioBackground.uri = "https://raw.githubusercontent.com/xClifordx/misc/refs/heads/main/radio_placeholder.jpg"
        m.radioBackground.visible = true 
    end if
end sub

sub openSeriesDetails(seriesNode as Object)
    m.isSeriesDetailOpen = true
    
    m.list.visible = false
    m.itemPreviewPoster.visible = false
    m.seriesDetailsContainer.visible = true
    
    m.seriesDetailPoster.uri = seriesNode.HDPosterUrl
    m.seriesDetailTitle.text = seriesNode.title
    
    m.episodeList.content = invalid
    
    if seriesNode.url <> invalid and seriesNode.url <> ""
        m.global.feedurl = seriesNode.url
        m.get_channel_list.control = "RUN"
    end if
end sub

sub playEpisode()
    if m.episodeList.content = invalid or m.episodeList.content.getChildCount() = 0 then return
    
    selectedNode = invalid
    
    if m.episodeList.content.getChild(0).getChild(0) = invalid
        selectedNode = m.episodeList.content.getChild(m.episodeList.itemSelected)
    else
        selectedIndex = m.episodeList.itemSelected
        for i = 0 to m.episodeList.content.getChildCount() - 1
            section = m.episodeList.content.getChild(i)
            if selectedIndex < section.getChildCount()
                selectedNode = section.getChild(selectedIndex)
                exit for
            else
                selectedIndex = selectedIndex - section.getChildCount()
            end if
        end for
    end if
    
    if selectedNode <> invalid
        if m.currentPlayingNode <> invalid and m.originalPlayingTitle <> ""
            m.currentPlayingNode.title = m.originalPlayingTitle
        end if
        if instr(1, selectedNode.title, ">> ") = 0
            m.originalPlayingTitle = selectedNode.title
            selectedNode.title = ">> " + selectedNode.title
        end if
        
        m.currentPlayingNode = selectedNode

        cleanVideoNode = createObject("roSGNode", "ContentNode")
        
        if selectedNode.url <> invalid and selectedNode.url <> ""
            cleanVideoNode.url = selectedNode.url
        else if selectedNode.uri <> invalid
            cleanVideoNode.url = selectedNode.uri
        end if
        
        m.currentPlayingUrl = cleanVideoNode.url
        cleanVideoNode.title = m.originalPlayingTitle
        cleanVideoNode.streamFormat = "hls, mp4, mkv, ts"
        cleanVideoNode.live = false 
        
        m.video.content = cleanVideoNode
        m.video.visible = true
        m.video.control = "play"
        
        m.episodeList.SetFocus(true)
    end if
end sub

sub restorePlayingIndicator()
    if m.currentPlayingUrl = "" or m.episodeList.content = invalid then return
    
    content = m.episodeList.content
    hasSections = (content.getChildCount() > 0 and content.getChild(0).getChildCount() > 0)
    
    if hasSections
        for i = 0 to content.getChildCount() - 1
            section = content.getChild(i)
            for j = 0 to section.getChildCount() - 1
                item = section.getChild(j)
                itemUrl = item.url
                if itemUrl = "" or itemUrl = invalid then itemUrl = item.uri
                
                if itemUrl = m.currentPlayingUrl
                    m.originalPlayingTitle = item.title
                    item.title = ">> " + item.title
                    m.currentPlayingNode = item
                    return
                end if
            end for
        end for
    else
        for i = 0 to content.getChildCount() - 1
            item = content.getChild(i)
            itemUrl = item.url
            if itemUrl = "" or itemUrl = invalid then itemUrl = item.uri
            
            if itemUrl = m.currentPlayingUrl
                m.originalPlayingTitle = item.title
                item.title = ">> " + item.title
                m.currentPlayingNode = item
                return
            end if
        end for
    end if
end sub

sub showVideoUI()
    if m.isFullScreen = true and m.videoUI <> invalid

        adjustVideoUIResolution() 
        
        m.videoUI.visible = true
        updateProgressBar()
        
        if m.uiHideTimer <> invalid then m.uiHideTimer.control = "start" 
    end if
end sub

sub hideVideoUI()
    if m.videoUI <> invalid then m.videoUI.visible = false
end sub

sub updateProgressBar()
    if m.videoUI = invalid or m.videoUI.visible = false or m.video = invalid then return
    
    currentPos = m.video.position
    videoDur = m.video.duration
    
    if videoDur > 0
        pct = currentPos / videoDur
        if pct > 1.0 then pct = 1.0

        if m.progressFill <> invalid and m.screenWidth <> invalid
            m.progressFill.width = m.screenWidth * pct
        end if
        
        if m.currentTimeLabel <> invalid then m.currentTimeLabel.text = formatTime(currentPos)
        if m.totalTimeLabel <> invalid then m.totalTimeLabel.text = formatTime(videoDur)
    end if
end sub

function formatTime(totalSeconds as Dynamic) as String
    if totalSeconds = invalid then return "00:00"
    
    totalSecsInt = Int(totalSeconds)
    hours = Int(totalSecsInt / 3600)

    remainder = totalSecsInt mod 3600
    minutes = Int(remainder / 60)
    seconds = remainder mod 60
    
    mStr = minutes.toStr()
    sStr = seconds.toStr()
    
    if minutes < 10 then mStr = "0" + mStr
    if seconds < 10 then sStr = "0" + sStr
    
    if hours > 0
        return hours.toStr() + ":" + mStr + ":" + sStr
    else
        return mStr + ":" + sStr
    end if
end function

sub adjustVideoUIResolution()
    scene = m.top.getScene()
    if scene = invalid then scene = m.top

    if scene <> invalid and scene.hasField("currentDesignResolution")
        res = scene.currentDesignResolution
        m.screenWidth = res.width
        m.screenHeight = res.height
    else
        m.screenWidth = 1280
        m.screenHeight = 720
    end if

    barHeight = 120

    if m.videoUI <> invalid then m.videoUI.translation = [0, m.screenHeight - barHeight]

    if m.uiBackground <> invalid then m.uiBackground.width = m.screenWidth
    if m.progressTrack <> invalid then m.progressTrack.width = m.screenWidth

    if m.totalTimeLabel <> invalid then m.totalTimeLabel.translation = [m.screenWidth - 240, 35]
end sub
