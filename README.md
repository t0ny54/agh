<div align="Center">
  <h1>My Filter List</h1>
</div>

## Usage

Using with <a href="https://pi-hole.net" target="_blank">Pi-Hole</a>, <a href="https://adguard.com/en/adguard-home/overview.html">AdGuard Home</a>, <a href="https://dnscrypt.info">DNSCrypt</a>, etc

## Features

- remove comments
- sort and remove duplicates entries
- occasionally remove dead domains (except whitelist and ips blocklist)

## Notice

<table>
<tr>
<td>
 - Builds updated every 24 hours.
</td>
</tr>
</table>

## Formats

| FORMATS | HOSTS | DOMAINS (Basic) | DOMAINS (Full) | AdGuard Home |
|---------|:----------:|:----------:|:----------:|:----------:|
Blocklist | [Link](https://raw.githubusercontent.com/t0ny54/blocklistwithregex/main/export/blocklist_all_zero.txt) | [Link](https://raw.githubusercontent.com/t0ny54/blocklistwithregex/main/export/blocklist.txt) | [Link](https://raw.githubusercontent.com/t0ny54/agh/main/blocklist.txt) | [Link](https://raw.githubusercontent.com/anT0ny54/adguard/main/blocklist-agh.txt) |
Adult Filter | [Link](https://raw.githubusercontent.com/t0ny54/adultfilterwithregex/main/export/blocklist_all_zero.txt) | [Link](https://raw.githubusercontent.com/t0ny54/adultfilterwithregex/main/export/blocklist.txt) | [Link](https://raw.githubusercontent.com/t0ny54/agh/main/adultfilter.txt) | [Link](https://raw.githubusercontent.com/anT0ny54/adguard/main/adultfilter-agh.txt) |
Blocklist+Adult Filter | [Link](https://raw.githubusercontent.com/t0ny54/blocklistfamilywithregex/main/export/blocklist_all_zero.txt) | [Link](https://raw.githubusercontent.com/t0ny54/blocklistfamilywithregex/main/export/blocklist.txt) | [Link](https://raw.githubusercontent.com/anT0ny54/adguard/main/blocklist.txt) | [Link](https://raw.githubusercontent.com/anT0ny54/adguard/main/familyfilter-agh.txt) |
Whitelist |  |  | [Link](https://raw.githubusercontent.com/t0ny54/agh/main/whitelist.txt) |  |
IPS Blocklist |  |  | [Link](https://raw.githubusercontent.com/t0ny54/agh/main/ipblocklist.txt) |  |

### Regex list (use with Domains Basic)
#### Regex list Pi-hole from [mmotti/pihole-regex](https://github.com/mmotti/pihole-regex)
```
^(.+[_.-])?adse?rv(er?|ice)?s?[0-9]*[_.-]	
^(.+[_.-])?telemetry[_.-]	
^adim(age|g)s?[0-9]*[_.-]	
^adtrack(er|ing)?[0-9]*[_.-]	
^advert(s|is(ing|ements?))?[0-9]*[_.-]	
^aff(iliat(es?|ion))?[_.-]	
^analytics?[_.-]	
^banners?[_.-]	
^beacons?[0-9]*[_.-]	
^count(ers?)?[0-9]*[_.-]	
^mads\.	
^pixels?[-.]	
^stat(s|istics)?[0-9]*[_.-]	
^track(ing)?[0-9]*[_.-]	
^ad([sxv]?[0-9]*|system)[_.-]([^.[:space:]]+\.){1,}|[_.-]ad([sxv]?[0-9]*|system)[_.-]	
```
And
#### Regex list Adguard Home from [mmotti/adguard-home-filters](https://github.com/mmotti/adguard-home-filters)
```
/^(.+[_.-])?adse?rv(er?|ice)?s?[0-9]*[_.-]/
/^(.+[_.-])?telemetry[_.-]/
/^ad([sxv]?[0-9]*|system)[_.-]([^.[:space:]]+\.){1,}|[_.-]ad([sxv]?[0-9]*|system)[_.-]/
/^adim(age|g)s?[0-9]*[_.-]/
/^adtrack(er|ing)?[0-9]*[_.-]/
/^advert(s|is(ing|ements?))?[0-9]*[_.-]/
/^aff(iliat(es?|ion))?[_.-]/
/^analytics?[_.-]/
/^banners?[_.-]/
/^beacons?[0-9]*[_.-]/
/^count(ers?)?[0-9]*[_.-]/
/^mads\./
/^pixels?[-.]/
/^stat(s|istics)?[0-9]*[_.-]/	
```

## My Public DNS Server
* ### Blocks ads, malware, trackers, viruses, ransomware, telemetry and more. No persistent logs. DNSSEC.
  * #### DNS-over-HTTPS: 
     *  https://euroresolver.herokuapp.com/dns-query
     
* ### Safesearch and adult content blocking, blocks ads, malware, trackers, viruses, ransomware, telemetry and more. No persistent logs. DNSSEC.
  * #### DNS-over-HTTPS: 
     *  https://familyprotect.herokuapp.com//dns-query


## Supporting My Filter List

If you are intrested in supporting the project you can:
 - Donate Bitcoin: 1HN34B34i4BifoHJaM9JCqTFf2KpeYxsrq
 - Donate Dogecoin: DPiQcmGMBRFudJ6x9ifAf63qxHsEGo71Ho
 - Donate DigiByte: DUGHdN1e7UDZv9Mhv9C9DGSJD9poQBotyF
 - Donate Zcash: t1c9Gnf3SM2tPuU7DGjBBQiKKmvxmMHV6kZ
 - Donate Solana: G4RbhfKkSmypWuLAiaAZCaMjJwtE3SkDQJGwk2M1dyhd
 - Donate Litecoin: MQsbaz15wn24sd4fyUCDvHbAQpbe5KfF2Q
 - Donate Dash: Xbn144txmSiHBFxsJm86quxnQ2ovZdg86a
 - Donate Tron: TCQhCKDZmHY8ngtyAfH854UssDJTxyTqTc


<div align="center">
  <sub>Project with full of ❤ by <a href=https://bearhero.tk target=_blank style=color:#f6f6f6><b>antonyitunamaku</b>
</div>
