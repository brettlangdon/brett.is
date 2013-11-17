---
title: The Battle of the Caches
author: Brett Langdon
date: 2013-08-01
template: article.jade
---

A co-worker and I set out to each build our own http proxy cache.
One of them was written in Go and the other as a C++ plugin for
Kyoto Tycoon.

---

So, I know what most people are thinking: “Not another cache benchmark post,
with skewed or biased results.” But luckily that is not what this post is about;
there are no opinionated graphs showing that my favorite caching system happens
to be better than all the other ones. Instead, this post is about why at work we
decided to write our own API caching system rather than use <a href="http://www.varnish-cache.org/" target="_blank">Varnish</a>
(a tested, tried and true HTTP caching system).

Let us discuss the problem we have to solve. The system we have is a simple
request/response HTTP server that needs to have very low latency (a few
milliseconds, usually 2-3 on average) and we are adding a third-party HTTP API
call to almost every request that we see. I am sure some people see the issue
right away, any network call is going to add at least a half to a whole millisecond
to your processing time and that is if the two servers are in the same datacenter,
more if they are not. That is just network traffic, now we must rely on the
performance of the third-party API, hoping that they are able to maintain a
consistent response time under heavy load. If, in total, this third-party API call
is adding more than 2 milliseconds response time to each request that our system
is processing then that greatly reduces the capacity of our system.

THE SOLUTION! Lets use Varnish. This is the logical solution, lets put a caching
system in front of the API. The content we are requesting isn’t changing very often
(every few days, if that) and it can help speed up the added latency from the API
call. So, we tried this but had very little luck; no matter what we tried we could
not get Varnish to respond in under 2 milliseconds per request (which is a main
requirement of solution we were looking for). That means Varnish is out, the next
solution is to write our own caching system.

Now, before people start flooding the comments calling me a troll or yelling at me
for not trying this or that or some other thing, let me try to explain really why
we decided to write our own cache rather than spend extra days investing time into
Varnish or some other known HTTP cache. We have a fairly specific requirement from
our cache, very low and consistent latency. “Consistent” is the key word that really
matters to us. We decided fairly early on that getting no response on a cache miss
is better for our application than blocking and waiting for a response from the
proxy call. This is a very odd requirement and most HTTP caching systems do not
support it since it almost defeats their purpose (be “slow” 1-2 times so you can be
fast all the other times). As well, HTTP is not a requirement for us, that is,
from the cache to the API server HTTP must be used, but it is not a requirement
that our application calls to the cache using HTTP. Headers add extra bandwidth
and processing that are not required for our application.

So we decided that our ideal cache would have 3 main requirements:
1. Must have a consistent response time, returning nothing early over waiting for a proper response
2. Support the <a href="https://github.com/memcached/memcached/blob/master/doc/protocol.txt" target="_blank">Memcached Protocol</a>
3. Support TTLs on the cached data

This behavior works basically like so: Call to cache, if it is a cache miss,
return an empty response and queue the request to a background process to make the
call to the API server, every identical request coming in (until the proxy call
returns a result) will receive an empty response but not add the request to the
queue. As soon as the proxy call returns, update the cache and every identical call
coming in will yield the proper response. After a given TTL consider the data in
the cache to be old and re-fetch.

This was then seen as a challenge between a co-worker,
<a href="http://late.am/" target="_blank">Dan Crosta</a>, and myself to see who
can write the better/faster caching system with these requirements. His solution,
entitled “CacheOrBust”, was a
<a href="http://fallabs.com/kyototycoon/" target="_blank">Kyoto Tycoon</a> plugin
written in C++ which simply used a subset of the memcached protocol as well as some
background workers and a request queue to perform the fetching. My solution,
<a href="https://github.com/brettlangdon/ferrite" target="_blank">Ferrite</a>, is a
custom server written in <a href="http://golang.org/" target="_blank">Go</a>
(originally written in C) that has the same functionality (except using
<a href="http://golang.org/doc/effective_go.html#goroutines" target="_blank">goroutines</a>
rather than background workers and a queue). Both servers used
<a href="http://fallabs.com/kyotocabinet/" target="_blank">Kyoto Cabinet</a>
as the underlying caching data structure.

So… results already! As with most fairly competitive competitions it is always a
sad day when there is a tie. Thats right, two similar solutions, written in two
different programming languages yielded similar results (we probably have
Kyoto Cabinet to thank). Both of our caching systems were able to yield us the
results we wanted, **consistent** sub-millisecond response times, averaging about
.5-.6 millisecond responses (different physical servers, but same datacenter),
regardless of whether the response was a cache hit or a cache miss. Usually the
morale of the story is: “do not re-invent the wheel, use something that already
exists that does what you want,” but realistically sometimes this isn’t an option.
Sometimes you have to bend the rules a little to get exactly what your application
needs, especially when dealing with low latency systems, every millisecond counts.
Just be smart about the decisions you make and make sure you have sound
justification for them, especially if you decide to build it yourself.
