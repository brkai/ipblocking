#!/bin/bash

## block public reported IP's with ipchains.
## inspired by https://gist.github.com/klepsydra/ecf975984b32b1c8291a.
## the lists can be pretty long, therefore you can disable the DNS-resolution
## when checkip the iptables with:
## iptables -L -n

## this is the slower way to achieve our goal
## next step: preparing a dump-file for simple import with iptables-restore
## .... will be much faster

## currently i'm not working with ip6tables because i don't need it
## feel free to contribute and extend the script(s)

datadir=[your directory for the downloaded and temp files]

# quick and dirty preparation of iptables
iptables -D INPUT -j blocklist48
iptables -D INPUT -j blocklistLT
iptables -vN blocklistLT   # Create the chain if it doesn't exist. Harmless if it does.
iptables -vN blocklist48   # Create the chain if it doesn't exist. Harmless if it does.

# seems to have the same effect as iptables -A .....
iptables -I INPUT 1 -j blocklist48
iptables -I INPUT 1 -j blocklistLT



# if datadir not there switch to temp-folder
# we could also create the directory
[[ -d "$datadir" ]] || datadir=/tmp

echo $datadir
#ls -l $datadir

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

# if something went wrong with the downloads just exit with 1
[[ -f "$fblacklist48h" ]] || exit 1
[[ -f "$fblacklistlt" ]] || exit 1

# if one of the downbloaded files is empty: exit with 1 also
grep -q '[^[:space:]]' "$fblacklist48h" || exit 1
grep -q '[^[:space:]]' "$fblacklistlt" || exit 1

# remove IP-v6 adresses
sed -i '/:/d' $fblacklist48h
sed -i '/:/d' $fblacklistlt

#while read IP; do echo $IP; done < $fblacklist48h

rm $fblacklist48h.remove
rm $fblacklist48h.add

# create input-files for addition and removal to IPtables
grep -Fvx -f $fblacklist48h.last $fblacklist48h  > $fblacklist48h.add
grep -Fvx -f $fblacklist48h $fblacklist48h.last  > $fblacklist48h.remove

echo "remove delisted IP's last 48 hrs"
echo "---------------------------------------"
while read IP; do echo $IP; iptables -w -D blocklist48 -s $IP -j DROP; done < $fblacklist48h.remove

echo "add new listed IP's last 48 hrs"
echo "---------------------------------------"
while read IP; do echo $IP; iptables -I blocklist48 -s $IP -j DROP; done < $fblacklist48h.add

rm $fblacklistlt.remove
rm $fblacklistlt.add

# create input-files for addition and removal to IPtables
grep -Fvx -f $fblacklistlt.last $fblacklistlt  > $fblacklistlt.add
grep -Fvx -f $fblacklistlt $fblacklistlt.last  > $fblacklistlt.remove

echo "remove delisted IP's LONG-TERM"
echo "---------------------------------------"
while read IP; do echo $IP; iptables -w -D blocklistLT -s $IP -j DROP; done < $fblacklistlt.remove

echo "add new listed IP's LONG-TERM"
echo "---------------------------------------"
while read IP; do echo $IP; iptables -I blocklistLT -s $IP -j DROP; done < $fblacklistlt.add


exit
