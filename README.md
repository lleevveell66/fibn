# FIBN (Firewall Ipset Blacklist Network)
by Raymond Spangle

---------------------------------------------

### Theory of Operation:
- - - - - - - - - - 

FIBN will automatically block malicious IP addresses, once every minute.  Doing this is considered a "bad idea" by 
most, since it opens you up to DoS attacks.  The capability to whitelist has been included to help minimize this 
risk.  Obviously, not bragging about running it will help, as well.   This is where a little "security-through-obscurity" 
sprinkled into your blue teaming is actually a "good idea".  You are ultimately responsible for proper configuration 
and use of this tool, and any damage doing so may lead to.

FIBN will compile a total list of IPs to block from three sources:
- A Master Blacklist, kept somewhere on a web server
- A Local Blacklist, generated each run on the local machine
- A Manual Blacklist, generated by hand on the local machine

FIBN will then remove any IPs from this list which are whitelisted, build an ipset, and insert that ipset into
firewalld or iptables.  If the host you are running FIBN on is considered the "Master", then a new Master Blacklist
will also be created and placed in the web directories so other instances can download it.

It is not difficult to see how this could easily be massaged into a sort of mesh network, where every host is its
own Master and Slave to another.  Multiple URLs are not yet supported, but are planned for a future release, thus 
allowing a true FIBN mesh network, where every host could potentially instruct every other host about malicious IP
addresses it has found locally.


### Pre-requisites:
- - - - - - - -

- python
- firewalld (iptables will be supported in the near future)
- ipset


### Installation:
- - - - - - -

1) Make a super syslog, with:
```
echo "*.* /var/log/all_messages">>/etc/rsyslog.conf
service rsyslog restart
```
(NOTE: You can skip this step if you don't like it.  It could be troublesome on smaller devices with limited space 
and improper log rotation configured, for example.  But, if you skip this, make sure to edit the fibn_BuildLocal 
script to change how you gather local malicious IP addresses.  Mine all come out of /var/log/all_messages)

2) `cat install.sh # because you always audit code from GitHub, right?`
3) `./install.sh`
4) If this is a master, edit /etc/fibn/fibn.conf and change MASTER=1 then make sure the MASTERBLACKLIST file location is correct
5) Edit /etc/fibn/fibn.conf and make sure the MASTERURL location is correct
6) Build any of the rich rules for logging hits to ports people should not be hitting.  For example, if you have moved SSH
off of port 22, do not run an FTP daemon, and do not allow telnet, you would run this:

```
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" port protocol="tcp" port="21" log prefix="firewalld-port-attempt" level="info" accept"
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" port protocol="tcp" port="22" log prefix="firewalld-port-attempt" level="info" accept"
firewall-cmd --permanent --zone=public --add-rich-rule="rule family="ipv4" port protocol="tcp" port="23" log prefix="firewalld-port-attempt" level="info" accept"
firewall-cmd --reload
```
All that is important is that the prefix is "firewalld-port-attempt" for now.  You can always choose your own prefix and edit the
fibn_BuildLocal script to look for those, later.

7) `fibn_BuildLocal`
8) `fibn_Apply`
9) `fibn_Stats`
10) `crontab -e` and add the following:

```
# * * * * * command to be executed
# - - - - -
# | | | | |
# | | | | +----- day of week (0 - 6) (Sunday=0)
# | | | +------- month (1 - 12)
# | | +--------- day of month (1 - 31)
# | +----------- hour (0 - 23)
# +------------- min (0 - 59)

* * * * * /usr/local/bin/fibn_BuildLocal && /usr/local/bin/fibn_Apply
0 * * * * /usr/local/bin/fibn_Stats
```

11) Manually edit /etc/local.txt to add any malicious IP addresses you find, manually
12) Manually edit /etc/whitelist.txt to whitelist any more important IP addresses you need (multiple gateways, DNS, etc.)


