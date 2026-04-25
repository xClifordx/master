import grequests # Necesitarás instalar: pip install grequests
import re

def check_m3u(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    urls = []
    url_to_line = {}
    

    for i, line in enumerate(lines):
        if line.startswith("http"):
            urls.append(line.strip())
            url_to_line[line.strip()] = i - 1 


    rs = (grequests.head(u, timeout=5) for u in urls)
    responses = grequests.map(rs, size=20)


    for url, response in zip(urls, responses):
        status = "ONLINE" if response is not None and response.status_code == 200 else "OFFLINE"
        idx = url_to_line[url]

        lines[idx] = lines[idx].replace("#EXTGRP:ONLINE", "").replace("#EXTGRP:OFFLINE", "")
        lines.insert(idx + 1, f"#EXTGRP:{status}\n")

    with open(file_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

check_m3u('IPSACL.m3u')
