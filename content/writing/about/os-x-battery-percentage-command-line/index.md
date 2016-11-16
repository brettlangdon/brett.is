---
title: OS X Battery Percentage Command Line
author: Brett Langdon
date: 2012-03-18
template: article.jade
---

Quick and easy utility to get OS X battery usage from the command line.

---

Recently I learned how to enable full screen console mode for OS X but the first
issue I ran into was trying to determine how far gone the battery in my laptop was.
Yes of course I could use the fancy little button on the side that lights up and
shows me but that would be way too easy for a programmer, so of course instead I
wrote this scripts. The script will gather the battery current and max capacity
and simply divide them to give you a percentage of battery life left.

Just create this script, I named mine “battery”, make sure to enable execution
“chmod +x battery” and I moved mine into “/usr/sbin/”. Then to use simply run the
command “battery” and you’ll get an output similar to “3.900%”
(yes as of the writing of this my battery needs a charging).

```bash
#!/bin/bash
current=`ioreg -l | grep CurrentCapacity | awk ‘{print %5}’`
max=`ioreg -l | grep MaxCapacity| awk ‘{print %5}’`
echo `echo “scale=3;$current/$max*100″|bc -l`’%’
```

Enjoy!
