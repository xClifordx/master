import requests
import re
import os

ARCHIVOS_M3U = ['PELICLIF.m3u', 'CLIFISERI.m3u', 'IPSACL.m3u', 'RADICLIF.m3u'] 

def check_url(url):
    try:
        response = requests.get(url, stream=True, timeout=5)
        response.close()
        return response.status_code == 200
    except:
        return False

def procesar_m3u(archivo):
    if not os.path.exists(archivo):
        print(f"Archivo {archivo} no encontrado.")
        return

    with open(archivo, 'r', encoding='utf-8') as f:
        lineas = f.readlines()

    nuevas_lineas = []
    i = 0
    while i < len(lineas):
        linea = lineas[i]
        
        if linea.startswith('#EXTINF'):
            url = lineas[i+1].strip() if i+1 < len(lineas) else ""
            
            linea_limpia = re.sub(r'\s*tvg-status="[^"]*"', '', linea.strip())
            
            if url and url.startswith('http'):
                print(f"Revisando: {url}")
                is_online = check_url(url)
                status = "online" if is_online else "offline"
                
                linea_final = re.sub(r'^(#EXTINF:\s*[-]?\d+)', rf'\1 tvg-status="{status}"', linea_limpia)
                nuevas_lineas.append(linea_final + '\n')
            else:
                nuevas_lineas.append(linea)
        else:
            if not linea.startswith('http'):
                nuevas_lineas.append(linea)
            elif i > 0 and lineas[i-1].startswith('#EXTINF'):
                 nuevas_lineas.append(linea)

        i += 1

    with open(archivo, 'w', encoding='utf-8') as f:
        f.writelines(nuevas_lineas)
    print(f"✅ {archivo} actualizado correctamente.")

for lista in ARCHIVOS_M3U:
    procesar_m3u(lista)
