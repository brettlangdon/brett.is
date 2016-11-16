---
title: How Ads are Delivered
author: Brett Langdon
date: 2012-09-02
template: article.jade
---

A really brief look into how online advertising works.

---

For the last 6 months or so I have been working in the ad tech industry for a
search re-targeting company,
<a href="http://www.magnetic.com" target="_blank">Magnetic</a>,
as a software engineer working on software to deliver ads online and I wanted
share some of the things I have learned.

When I started working for them I did not realize how online ads are delivered.
I thought that web sites offer up space to advertisers and then they show various
ads based on what the web site wants them to show. Well, this isn’t really wrong
but not quite right. There are a few more pieces to the puzzle.

### Advertiser

An advertiser is the person, or agency, that wishes to deliver ads to the internet.

### Publisher

A publisher is a person, or organization, that has online ad space that they
wish to fill.

### Ad Exchange

An ad exchange is a company that allows various advertisers to bid on available
ad space provided by publishers.


## How It Works

This is the part I never fully understood until I started working in the industry
(there are still parts I do not know). The magic for most online ads is in the ad
exchange. When a user goes to a website there are various iframes on the page which
the publisher has pointed to the ad exchange. This lets the exchange know that
there is space currently available.

So the exchange then compiles a bid request which contains as much information
about the ad space and user as possible. This information can contain simple
things like the size of the ad and location of the add (above or below fold), to
various information about the user, geo location, window size, etc.

The bid request is sent out to all of the advertisers to let them know about the
potential ad space available. The advertisers must then make a decision whether or
not they want to bid on that ad space, based on the information provided. If they
have an ad that meets the criteria then they will return a bid response to the ad
exchange telling them of their bid. The bid price for an ad is provided in micro
dollars or one one millionth of a dollar. Another common unit for ad tech is CPM
or cost per mile which denotes the price for every one thousand ads.

Once the ad exchange has all the bids they take the ad with the highest bid to
deliver. The cost you pay is not the price you bid, but one bidding unit above
the next highest bid. Lastly, the ad is delivered to the user.

One thing to note, which I find very cool, is this all happens in real time for
every page request that a user makes. Next time you go to a website which contains
ads, stop to think about what had happened for that ad to become available to you.


## Why Is This Cool?

Some might not find this topic very interesting, others might hold a grunge to the
fact that ads are being shown on websites or to the fact that some companies are
maintaining search information about them on their systems (in order to make
future ad decisions based on available ad space for you specifically). To me this
is interesting because of the scale that these systems need to be in. Our company
does not make a few hundred bids per day or even hour, this can happen in seconds.
We also do not make any “static” decisions based on the bids that we receive,
instead we are trying to make informed, real time decisions as to which ads we
want to show.

Our systems need to not only be scalable, for an increase in available bids, but
they also need to be fast. If we waited for a SQL query to finish we would lose
out on hundreds of bids before we got our response. Our system is based heavily
on caching and rebuilding useful information for bidding. The fact that our
company works under these constraints requires our developers (that includes me)
to have to think outside the box and about the bigger picture.
