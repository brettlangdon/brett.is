---
title: Fail2Ban Honeypot
author: Brett Langdon
date: 2012-02-04
template: article.jade
---

How to use Python and Fail2Ban to write an auto-blocking honeypot.

---

I have been practicing for the upcoming NECCDC competition and have been playing
around with various security concepts and one that I thought of trying was
creating a honeypot that automagically blocks ips when trapped. So what I have is
a honeypot script written in python that logs intruders to a log file and then a
<a href="http://fail2ban.org/" target="_blank">Fail2Ban</a>
definition that will block the ip address. So I will show you the Fail2Ban
honeypot that I have thrown together.

## Installation

We first need to install
<a href="http://python.org/" target="_blank">python</a> and
<a href="http://fail2ban.org/" target="_blank">fail2ban</a>.
Installation process might be different depending which linux distribution
you are using.

```bash
sudo apt-get install python fail2ban
```

## Honeypot

Copy the following python script and create a file `honeypot.py`.

```python
import socket
import threading
import sys


class HoneyThread(threading.Thread):
    def __init__(self, logfile, port):
        self.logfile = logfile
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.bind( ('', port) )
        self.sock.listen( 1 )
        print 'Listening on: ', port
        super(HoneyThread, self).__init__()

    def run(self):
        while True:
            channel, details = self.sock.accept()
            logstr = (
                'Connection from %s:%s on port %s\r\n' %
                (details[0], details[1], self.port)
            )
            self.logfile.write('%s\r\n' % logstr)
            print logstr
            self.logfile.flush()
            channel.send('You Just Got Stuck In Some Honey')
            channel.close()

ports = []

for arg in sys.argv[1:]:
     ports.append(int(arg))
     threads = []
     logfile = open('/var/log/honeypot.log', 'a')

for p in ports:
    threads.append(HoneyThread(logfile, p))

for thread in threads:
    thread.start()

print 'Bring it on!'
```

Some may notice a slight issue, this script is meant to run 24/7 and never be
stopped. There is no particular way of stopping the threads unless the machine
is restarted.


## Running Honeypot

To run the honeypot simply issue the following command:
```bash
python honeypot.py 22 25 80 443
```

Replace the ports shown with the ports that you want the honeypot to run on.
When someone tries to connect to one of the supplied ports this script will
display on the screen the ip address that connected, the port they connected from
and the port they were trying to reach. It will also log the incident to
the `/var/log/honeypot.log` file.


## Fail2Ban

Now to setup fail2ban to block the ip address when it is captured.
A new filter definition needs to be created in `/etc/fail2ban/filter.d/honeypot.conf`.

```ini
[Definition]
failregex =
```

And the filter has to be set in `/etc/fail2ban/jail.conf`.

```ini
...
[honeypot]
enabled = true
filter = honeypot
logpath = /var/log/honeypot.log
action = iptables-allports[name=Honeypot, protocol=all]
maxretry = 1
...
```

Please make sure to read up on fail2ban’s various actions, the ‘iptables-allports’
one is used here with ‘protocol: all’, meaning that the ip address is banned from
making all connections on any port using any protocol (tcp, udp, icmp, etc). Also
change ‘maxretry’ as you see fit, with it set to 1 then any single access to the
honeypot will ban the ip for the configured amount of time (600 seconds by
default), if you want this can be changed to 2 or 3 so if someone is persistent
with trying to access the false service.

And that is it, just start Fail2Ban and test by trying to access the one of the
honeypot ports. This can be done from a second machine and using telnet.

```bash
telnet 192.168.1.11 80
```

Replace ’192.168.1.11′ with the ip address of the machine running the honeypot
and ’80′ with the port you wish to test.

And there you have it, a Fail2Ban honeypot written in Python. Deploy and Enjoy.
