#!/bin/bash

## block public reported IP's with ipchains.
## inspired by other peoples thoughts.
## but not on my older script ipblocking.sh
## this is the more elegant way to achieve our goal
## using ipset and only a few rules in iptables filter
## i left out the step with iptable-dumps

## you need to have the following additional packages installed:
## ipset
## ipset-persistent

## still i'm not working with ip6tables because i don't need it
## feel free to contribute and extend the script(s) for ip-v6



datadir=[your directory for the downloaded and temp files]

# /etc/iptables/ipsets
# is the default-file when installing ipset-persistent under debian or ubuntu
ipsetSaveFile=/etc/iptables/ipsets


# create the lists for ipset, it's not a problem if they already exists
# ipset seems to increase the hash-size automatically
ipset create blocklist48 hash:ip hashsize 4096
ipset create blocklistLT hash:ip hashsize 4096


# quick and dirty preparation of iptables
# next step will be: find out if the rule exists
iptables -D INPUT -m set --match-set blocklist48 src -j DROP
iptables -D INPUT -m set --match-set blocklistLT src -j DROP

iptables -I INPUT -m set --match-set blocklist48 src -j DROP
iptables -I INPUT -m set --match-set blocklistLT src -j DROP



# if datadir not there switch to temp-folder
# we could also create the directory
[[ -d "$datadir" ]] || datadir=/tmp

#[[ -f "$ipsetSaveFile" ]] || exit

# access to the newly created files for everyone
umask 000
# Local filname and URL for all IP's reported within last 48 hrs
fblacklist48h=$datadir/all.blocklist.de.txt
url48h="https://lists.blocklist.de/lists/all.txt"
# Local filname for all IP's known for ~ 2 month and >=5000 reports
# lt means: long term ;-)
fblacklistlt=$datadir/strongips.blocklist.de.txt
urllt="https://lists.blocklist.de/lists/strongips.txt"

mv -vf  $fblacklist48h  $fblacklist48h.last
mv -vf  $fblacklistlt  $fblacklistlt.last

# if tere was no "old" file, then create an empty one
# so we can create the "add-file" with all contents of the new downloaded file
# !!! first time adding https://lists.blocklist.de/lists/all.txt takes some time
# !!! and may disturb some IP-traffic on your machine
[[ -f "$fblacklist48h.last" ]] || touch $fblacklist48h.last
[[ -f "$fblacklistlt.last" ]] || touch $fblacklistlt.last


# fetch lists from www
curl $url48h -o $fblacklist48h
curl $urllt -o $fblacklistlt

# remove IP-v6 adresses
sed -i '/:/d' $fblacklist48h
sed -i '/:/d' $fblacklistlt

# simply flushing the lists within ipset and re-fill them with our fetched files
# is not a very good option, because it takes much longer than the way we do it...
#ipset flush blocklist48
#ipset flush blocklistLT

rm $fblacklist48h.remove
rm $fblacklist48h.add

# create input-files for addition and removal to IPtables
grep -Fvx -f $fblacklist48h.last $fblacklist48h  > $fblacklist48h.add
grep -Fvx -f $fblacklist48h $fblacklist48h.last  > $fblacklist48h.remove

echo "remove delisted IP's last 48 hrs"
echo "---------------------------------------"
while read IP; do echo $IP; ipset del blocklist48 $IP; done < $fblacklist48h.remove

echo "add new listed IP's last 48 hrs"
echo "---------------------------------------"
while read IP; do echo $IP; ipset add blocklist48 $IP; done < $fblacklist48h.add

rm $fblacklistlt.remove
rm $fblacklistlt.add

# create input-files for addition and removal to IPtables
grep -Fvx -f $fblacklistlt.last $fblacklistlt  > $fblacklistlt.add
grep -Fvx -f $fblacklistlt $fblacklistlt.last  > $fblacklistlt.remove

echo "remove delisted IP's LONG-TERM"
echo "---------------------------------------"
while read IP; do echo $IP; ipset del blocklistLT $IP; done < $fblacklistlt.remove

echo "add new listed IP's LONG-TERM"
echo "---------------------------------------"
while read IP; do echo $IP; ipset add blocklistLT $IP; done < $fblacklistlt.add

# only make ipsets persistent (after reboot) if the save-file exists
# otherwise we have to do it ourself by a cronjob @reboot or similar
[[ -f "$ipsetSaveFile" ]] | ipset save > $ipsetSaveFile
exit
