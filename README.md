# ipblocking
script(s) to block IP-addresses against blackliststs



This is my first contribution to github and and consists of 2 different shell scripts;
I wrote it as an addition to my fail2ban setup, so an "attcker" coming from the blacklisted IP-addresses won't have a single try to connect to my server(s).
You should (like i do) know basics about iptables and linux:

- Both scripts make use of two lists from https://www.blocklist.de, but can easily be modified to use more / other sources.
- Everything ist "coded" and tested under Ubuntu 20.04 with standard-sources, so it should also run seamlessly on Debian itself or other debian-based distros.

The first one 'ipblocking.sh' just uses iptables, 


.... will complete the readme within shotr term ;-)
