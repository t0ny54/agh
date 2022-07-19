cd "C:\Users\Beelink\Downloads\New folder"
DEL .\adultfilter.txt
timeout 1
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/t0ny54/adultfilter/main/blocklist.txt', 'C:\Users\Beelink\Downloads\New folder\adultfilter.txt')"
timeout 1
copy "adultfilter.txt" "C:\Users\Beelink\Downloads\hostsz\"
timeout 1
cd "C:\Users\Beelink\Downloads\New folder"
DEL .\whitelist.txt
timeout 1
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/t0ny54/blocklist/main/domains-allowlist.txt', 'C:\Users\Beelink\Downloads\New folder\whitelist.txt')"
timeout 1
copy "whitelist.txt" "C:\Users\Beelink\Downloads\hostsz\"
timeout 1
cd "C:\Users\Beelink\Downloads\New folder"
DEL .\blocklist.txt
timeout 1
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://raw.githubusercontent.com/t0ny54/blocklist/main/blocklist.txt', 'C:\Users\Beelink\Downloads\New folder\blocklist.txt')"
timeout 1
copy "blocklist.txt" "C:\Users\Beelink\Downloads\hostsz\"
timeout 1
goto :EOF
Exit /b #
