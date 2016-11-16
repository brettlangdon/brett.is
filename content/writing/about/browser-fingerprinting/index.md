---
title: Browser Fingerprinting
author: Brett Langdon
date: 2013-06-05
template: article.jade
---

Ever want to know what browser fingerprinting is or how it is done?

---

## What is Browser Fingerprinting?

A browser or <a href="http://en.wikipedia.org/wiki/Device_fingerprint" target="_blank">device fingerprint</a>
is a term used to describe an identifier generated from information retrieved from
a single given device that can be used to identify that single device only.
For example, as you will see below, browser fingerprinting can be used to generate
an identifier for the browser you are currently viewing this website with.
Regardless of you clearing your cookies (which is how most third party companies
track your browser) the identifier should be the same every time it is generated
for your specific device/browser. A browser fingerprint is usually generated from
the browsers <a href="https://en.wikipedia.org/wiki/User_agent" target="_blank">user agent</a>,
timezone offset, list of installed plugins, available fonts, screen resolution,
language and more. The <a href="https://www.eff.org/" target"_blank">EFF</a> did
a <a href="https://panopticlick.eff.org/browser-uniqueness.pdf" target="_blank">study</a>
on how unique a browser fingerprint for a given client can be and which browser
information provides the most entropy. To see how unique your browser is please
check out their demo application
<a href="https://panopticlick.eff.org/" target="_blank">Panopticlick</a>.

## What can it used for?

Ok, so great, but who cares? How can browser fingerprinting be used? Right now
the majority of <a href="http://kb.mozillazine.org/User_tracking" target="_blank">user tracking</a>
is done by the use of cookies. For example, when you go to a website that has
[tracking pixels](http://brett.is/writing/about/third-party-tracking-pixels/)
(which are “invisible” scripts or images loaded in the background of the web page)
the third party company receiving these tracking calls will inject a cookie into
your browser which has a unique, usually randomly generated, identifier that is
used to associate stored data about you like collected
<a href="http://searchengineland.com/what-is-retargeting-160407" target="_blank">site or search retargeting</a>
data. This way when you visit them again with the same cookie they can lookup
previously associated data for you.

So, if this is how it is usually done why do we care about browser fingerprints?
Well, the main problem with cookies is they can be volatile, if you manually delete
your cookies then the company that put that cookie there loses all association with
you and any data they have on your is no longer useful. As well, if a client does
not allow third party cookies (or any cookies) on their browser then the company
will be unable to track the client at all.

A browser fingerprint on the other hand is a more constant way to identify a given
client, as long as they have javascript enabled (which seems to be a thing which
most websites cannot properly function without), which allows the client to be
identified even if they do not allow cookies for their browser.

##How do we do it?

Like I mentioned before to generate a browser fingerprint you must have javascript
enabled as it is the easiest way to gather the most information about a browser.
Javascript gives us access to things like your screen size, language, installed
plugins, user agent, timezone offset, and other points of interest. This
information is basically smooshed together in a string and then hashed to generate
the identifier, the more information you can gather about a single browser the more
unique of a fingerprint you can generate and the less collision you will have.

Collision? Yes, if you end up with two laptops each of the same make, model, year,
os version, browser version with the exact same features and plugins enabled then
the hashes will be the exact same and anyone relying on their fingerprint will
treat both of those devices as the same. But, if you read the white paper by EFF
listed above then you will see that their method for generating browser fingerprints
is usually unique for almost 3 million different devices. There may be some cases
for companies where that much uniqueness is more than enough to use and rely on
fingerprints to identify devices and others where they have more than 3
million users.

Where does this really come into play? Most websites usually have their users
create and account and log in before allowing them access to portions of the site or
to be able to lookup stored information, maybe their credit card payment
information, home address, e-mail address, etc. Where browser fingerprints are
useful is for trying to identify anonymous visitors to a web application. For
example, [third party trackers](/writing/about/third-party-tracking-pixels/)
who are collecting search or other kinds of data.

## Some Code

Their is a project on <a href="https://www.github.com/" target="_blank">github</a>
by user <a href="https://github.com/Valve" target="_blank">Valentin Vasilyev (Valve)</a>
called <a href="https://github.com/Valve/fingerprintjs" target="_blank">fingerprintjs</a>
which is a client side javascript library for generating browser fingerprints.
If you are interested in seeing some production worthy code of how to generate
browser fingerprints please take a look at that project, it uses information like
useragent, language, color depth, timezone offset, whether session or local storage
is available, a listing of all installed plugins and it hashes everything using
<a href="https://sites.google.com/site/murmurhash/" target="_blank">murmurhash3</a>.

## Your <a href="" target="_blank">fingerprintjs</a> Fingerprint: *<span id="fingerprint">Could not generate fingerprint</span>*

<script type="text/javascript" src="/js/fingerprint.js"></script>
<script type="text/javascript">
var fingerprint = new Fingerprint().get();
document.getElementById("fingerprint").innerHTML = fingerprint;
</script>

**Resources:**
* <a href="http://panopticlick.eff.org/" target="_blank">panopticlick.eff.org</a> - find out how rare your browser fingerprint is.
* <a href="https://github.com/Valve/fingerprintjs" target="_blank">github.com/Valve/fingerprintjs</a> - client side browser fingerprinting library.
