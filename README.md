# ipblocking
script(s) to block IP-addresses against blackliststs



This is my first contribution to github and and consists of 2 different shell scripts;
I wrote them as an addition to my fail2ban setup, so an "attcker" coming from the blacklisted IP-addresses won't have a single try to connect to my server(s).
Contrary to my habit, I've tried to comment the scripts somewhat so that they should be self-explanatory. 
One should (like i do) know basics about iptables, ipset and linux:

- Both scripts make use of two lists from https://www.blocklist.de, but can easily be modified to use more / other sources.
- Everything ist "coded" and tested under Ubuntu 20.04 with standard-sources, so it SHOULD also run seamlessly on Debian itself or other debian-based distros.
- One has to take care of cronjobs her / himself

The first one 'ipblocking.sh' just uses iptables.
i found it somekind of confusing when (for example) using 'iptables -L' and furthermore i had some little concerns about the performance.

Therfore there's a second one:

'ipblocking-ipset.sh' wich uses ipset (https://ipset.netfilter.org/) out of the Ubuntu-sources.

I'd be happy to help someone with my work, but for sure there are several todos.
If you like to collaborate and (maybe) extend the scripts with IP6 (or other improvements), i'll gladly add you as a collaborator.

Cheers Kai


Fixed:
2022-03-04: Check if downloaded files are there and have content, if not: Just exit

ToDo:
Maybe refine error-handling
