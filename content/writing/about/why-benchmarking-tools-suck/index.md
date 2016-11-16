---
title: Why Benchmarking Tools Suck
author: Brett Langdon
date: 2012-10-22
template: article.jade
---

A brief aside into why I think no benchmarking tool is exactly correct
and why I wrote my own.

---

Benchmarking is (or should be) a fairly important part of most developers job or
duty. To determine the load that the systems that they build can withstand. We are
currently at a point in our development lifecycle at work where load testing is a
fairly high priority. We need to be able to answer questions like, what kind of
load can our servers currently handle as a whole?, what kind of load can a single
server handle?, how much throughput can we gain by adding X more servers?, what
happens when we overload our servers?, what happens when our concurrency doubles?
These are all questions that most have probably been asked at some point in their
career. Luckily enough there is a plethora of HTTP benchmarking tools to help try
to answer these questions. Tools like,
<a href="http://httpd.apache.org/docs/2.2/programs/ab.html" target="_blank">ab</a>,
<a href="http://www.joedog.org/siege-home/" target="_blank">siege</a>,
<a href="https://github.com/newsapps/beeswithmachineguns" target="_blank">beeswithmachineguns</a>,
<a href="http://curl-loader.sourceforge.net/" target="_blank">curl-loader</a>
and one I wrote recently (today),
<a href="https://github.com/brettlangdon/tommygun" target="_blank">tommygun</a>.

Every single one of those tools suck, including the one I wrote (and will
probably keep using/maintaining). Why? Don’t a lot of people use them? Yes,
almost everyone I know has used ab (most of you probably have) and I know a
decent handful of people who use siege, but that does not mean that they are
the most useful for all use cases. In fact they tend to only be useful for a
limited set of testing. Ab is great if you want to test a single web page, but
what if you need to test multiple pages at once? or in a sequence? I’ve also
personally experienced huge performance issues with running ab from a mac. These
scope issues of ab make way for other tools such as siege and curl-loader which
can test multiple pages at a time or in a sequence, but at what cost? Currently at
work we are having issues getting siege to properly parse and test a few hundred
thousand urls, some of which contain binary post data.

On top of only really having a limited set of use cases, each benchmarking tool
also introduces overhead to the machine that you are benchmarking from. Ab might
be able to test your servers faster and with more concurrency than curl-loader
can, but if curl-loader can test your specific use case, which do you use?
Curl-loader can probably benchmark exactly what your trying to test but if it
cannot supply the source load of what you are looking for, then how useful of a
tool is it? What if you need to scale your benchmarking tool? How do you scale
your benchmarking tool? What if you are running the test from the same machine as
your development environment? What kind of effect will running the benchmarking
tool itself have on your application?

So, what is the solution then? I think instead of trying to develop these command
line tools to fit each scenario we should try to develop a benchmarking framework
with all of the right pieces that we need. For example, develop a platform that
has the functionality to run a given task concurrently but where you supply the
task for it to run. This way the benchmarking tool does not become obsolete and
useless as your application evolves. This will also pave the way for the tool to
be protocol agnostic. Allowing people to write tests easily for HTTP web
applications or even services that do not interpret HTTP, such as message queues
or in memory stores. This framework should also provide a way to scale the tool
to allow more throughput and overload on your system. Lastly, but not least, this
platform should be lightweight and try to introduce as little overhead as
possible, for those who do not have EC2 available to them for testing, or who do
not have spare servers lying around for them to test from.

I am not saying that up until now load testing has been nothing but a pain and
the tools that we have available to us (for free) are the worst things out there
and should not be trusted. I just feel that they do not and cannot meet every use
case and that I have been plighted by this issue in the past. How can you properly
load test your application if you do not have the right load testing tool for
the job?

So, I know what some might be thinking, “sounds neat, when will your framework
be ready for me to use?” That is a nice idea, but if the past few months are any
indication of how much free time I have, I might not be able to get anything done
right away (seeing how I was able to write my load testing tool while on vacation).
I am however, more than willing to contribute to anyone else’s attempt at this
framework and I am especially more than willing to help test anyone else’s
framework.

**Side Note:** If anyone knows of any tool or framework currently that tries to
achieve my “goal” please let me know. I was unable to find any tools out there
that worked as I described or that even got close, but I might not of searched for
the right thing or maybe skipped over the right link, etc.
