---
title: Pharos Popup on OSX Lion
author: Brett Langdon
date: 2012-01-28
template: article.jade
---

Fixing Pharos Popup app on OS X Lion.

---

My University uses
<a href="http://www.pharos.com/" target="_blank">Pharos</a>
print servers to manage a few printers on campus and we were running into an
issue of the Pharos popup and notify applications not working properly with OSX
Lion. As I work for the Apple technician on campus I was tasked with finding out
why. The popup installation was setting up the applications to run on startup just
fine, the postflight script was invoking the Popup.app, the drivers we were using
worked perfectly when we mapped the printer by IP but what was going on? Through
some further examination the two applications were in fact not being properly
started either after install or on boot.

I managed to find a work around that caused the applications to run. I manually
ran each of them through command line (as through Finder resulted in failure) and
magically they worked as expected and now whenever my machine starts up they start
on boot without having to manually run them, even if I uninstall the applications
and reinstall them I not longer have to manually run them… but why?

```bash
voltaire:~ brett$ open /Library/Application\ Support/Pharos/Popup.app
voltaire:~ brett$ open /Library/Application\ Support/Pharos/Notify.app
voltaire:~ brett$ ps aux | grep Pharos
brett 600 0.0 0.1 655276 3984 ?? S 2:55PM 0:00.10 /Library/Application Support/Pharos/Popup.app/Contents/MacOS/Popup -psn_0_237626
brett 543 0.0 0.1 655156 3652 ?? S 2:45PM 0:00.08 /Library/Application Support/Pharos/Notify.app/Contents/MacOS/Notify -psn_0_233529
brett 608 0.0 0.0 2434892 436 s001 R+ 2:56PM 0:00.00 grep Pharos
```

I am still not 100% sure why this work around worked, especially when the
postflight script included with the Popup package is set to run Popup.app after
installation. The only explanation I can come up with is OSX keeps a library of
all of the “trusted” applications, you know that popup that asks you if you want
to run a program that was downloaded from the internet, and the Popup.app and
Notify.app are not being properly added to the list, unless run manually.

I am still looking into a solution that can be packaged with the Popup package and
will post more information here when I find out more.
