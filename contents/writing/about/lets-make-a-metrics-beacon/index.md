---
title: Lets Make a Metrics Beacon
author: Brett Langdon
date: 2014-06-22
template: article.jade
---

Recently I wrote a simple javascript metrics beacon
library. Let me show you what I came up with and how it works.

---

So, what do I mean by "javascript metrics beacon library"? Think
[RUM (Real User Monitoring)](http://en.wikipedia.org/wiki/Real_user_monitoring) or
[Google Analytics](http://www.google.com/analytics/),
it is a javascript library used to capture/aggregate metrics/data
from the client side and send that data to a server either in one
big batch or in small increments.

For those who do not like reading articles and just want the code you
can find the current state of my library on github: https://github.com/brettlangdon/sleuth

Before we get into anything technical, lets just take a quick look at an
example usage:

```html
<script type="text/javascript" src="//raw.githubusercontent.com/brettlangdon/sleuth/master/sleuth.min.js"></script>
<script type="text/javascript">
Sleuth.init({
  url: "/track",
});

// static tags to identify the browser/user
// these are sent with each call to `url`
Sleuth.tag('uid', userId);
Sleuth.tag('productId', productId);
Sleuth.tag('lang', navigator.language);

// set some metrics to be sent with the next sync
Sleuth.track('clicks', buttonClicks);
Sleuth.track('images', imagesLoaded);

// manually sync all data
Sleuth.sendAllData();
</script>
```

Alright, so lets cover a few concepts from above, `tags`, `metrics` and `syncing`.

### Tags
Tags are meant to be a way to uniquely identify the metrics that are being sent
to the server and are generally used to break apart metrics. For example, you might
have a metric to track whether or not someone clicks an "add to cart" button, using tags
you can then break out that metric to see how many times the button has been pressed
for each `productId` or browser or language or any other piece of data you find
applicable to segment your metrics. Tags can also be used when tracking data for
[A/B Tests](http://en.wikipedia.org/wiki/A/B_testing) where you want to segment your
data based on which part of the test the user was included.

### Metrics
Metrics are simply data points to track for a given request. Good metrics to record
are things like load times, elements loaded on the page, time spent on the page,
number of times buttons are clicked or other user interactions with the page.

### Syncing
Syncing refers to sending the data from the client to the server. I refer to it as
"syncing" since we want to try and aggregate as much data on the client side and send
fewer, but larger, requests rather than having to make a request to the server for
each metric we mean to track. We do not want to overload the Client if we mean to
track a lot of user interactions on the site.

## How To Do It
Alright, enough of the simple examples/explanations, lets dig into the source a bit
to find out how to aggregate the data on the client side and how to sync that data
to the server.

### Aggregating Data
Collecting the data we want to send to the server isn't too bad. We are just going
to take any specific calls to `Sleuth.track(key, value)` and store either in
[LocalStorage](http://diveintohtml5.info/storage.html) or in an object until we need
to sync. For example this is the `track` method of `Sleuth`:

```javascript
Sleuth.prototype.track = function(key, value){
  if(this.config.useLocalStorage && window.localStorage !== undefined){
    window.localStorage.setItem('Sleuth:' + key, value);
  } else {
    this.data[key] = value;
  }
};
```

The only thing of note above is that it will fall back to storing in `this.data`
if LocalStorage is not available as well we are namespacing all data stored in
LocalStorage with the prefix "Sleuth:" to ensure there is no name collision with
anyone else using LocalStorage.

Also `Sleuth` will be kind enough to capture data from `window.performance` if it
is available and enabled (it is by default). And it simply grabs everything it can
to sync up to the server:

```javascript
Sleuth.prototype.captureWindowPerformance = function(){
  if(this.config.performance && window.performance !== undefined){
    if(window.performance.timing !== undefined){
      this.data.timing = window.performance.timing;
    }
    if(window.performance.navigation !== undefined){
      this.data.navigation = {
        redirectCount: window.performance.navigation.redirectCount,
        type: window.performance.navigation.type,
      };
    }
  }
};
```

For an idea on what is store in `window.performance.timing` check out
[Navigation Timing](https://developer.mozilla.org/en-US/docs/Navigation_timing).

### Syncing Data
Ok, so this is really the important part of this library. Collecting the data isn't
hard. In fact, no one probably really needs a library to do that for them, when you
just as easily store a global object to aggregate the data. But why am I making a
"big deal" about syncing the data either? It really isn't too hard when you can just
make a simple AJAX call using jQuery `$.ajax(...)` to ship up a JSON string to some
server side listener.

The approach I wanted to take was a little different, yes, by default `Sleuth` will
try to send the data using AJAX to a server side url "/track", but what about when
the server which collects the data lives on another hostname?
[CORS](http://en.wikipedia.org/wiki/Cross-origin_resource_sharing) can be less than
fun to deal with, and rather than worrying about any domain security I just wanted
a method that can send the data from anywhere I want back to whatever server I want
regardless of where it lives. So, how? Simple, javascript pixels.

A javascript pixel is simply a `script` tag which is written to the page with
`document.write` whose `src` attribute points to the url that you want to make the
call to. The browser will then call that url without using AJAX just like it would
with a normal `script` tag loading javascript. For a more in-depth look at tracking
pixels you can read a previous article of mine:
[Third Party Tracking Pixels](http://brett.is/writing/about/third-party-tracking-pixels/).

The point of going with this method is that we get CORS-free GET requests from any
client to any server. But some people are probably thinking, "wait, a GET request
doesn't help us send data from the client to server"? This is why we will encode
our JSON string of data for the url and simply send in the url as a query string
parameter. Enough talk, lets see what this looks like:

```javascript
var encodeObject = function(data){
  var query = [];
  for(var key in data){
    query.push(encodeURIComponent(key) + '=' + encodeURIComponent(data[key]));
  };

  return query.join('&');
};

var drop = function(url, data, tags){
  // base64 encode( stringify(data) )
  tags.d = window.btoa(JSON.stringify(data));

  // these parameters are used for cache busting
  tags.n = new Date().getTime();
  tags.r = Math.random() * 99999999;

  // make sure we url encode all parameters
  url += '?' + encodeObject(tags);
  document.write('<sc' + 'ript type="text/javascript" src="' + url + '"></scri' + 'pt>');
};
```

That is basically it. We simply base64 encode a JSON string version of the data and send
as a query string parameter. There might be a few odd things that stand out above, mainly
url length limitations of base64 encoded JSON string, the "cache busting" and the weird
breaking up of the tag "script". A safe url length limit to live under is around
[2000](http://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-a-url-in-different-browsers)
to accommodate internet explorer, which from some very crude testing means each reqyest
can hold around 50 or so separate metrics each containing a string value. Cache busting
can be read about more in-depth in my article again about tracking pixels
(http://brett.is/writing/about/third-party-tracking-pixels/#cache-busting), but the short
version is, we add random numbers and the current timestamp the query string to ensure that
the browser or cdn or anyone in between doesn't cache the request being made to the server,
this way you will not get any missed metrics calls. Lastly, breaking up the `script` tag
into "sc + ript" and "scri + pt" makes it harder for anyone blocking scripts from writing
`script` tags to detect that a script tag is being written to the DOM (also an `img` or
`iframe` tag could be used instead of a `script` tag).

### Unload
How do we know when to send the data? If someone is trying to time and see how much time
someone is spending on each page or wants to make sure they are collecting as much data
as they want on the client side then you want to wait until the last second before
syncing the data to the server. By using LocalStorage to store the data you can ensure
that you will be able to access that data the next time you see that user, but who wants
to wait? And what if the user never comes back? I want my data now dammit!

Simple, lets bind an event to `window.onunload`! Woot, done... wait... why isn't my data
being sent to me? Initially I was trying to use `window.onunload` to sync data back, but
found that it didn't always work with pixel dropping, AJAX requests worked most of the time.
After some digging I found that with `window.onunload` I was hitting a race condition on
whether or not the DOM was still available or not, meaning I couldn't use `document.write`
or even query the DOM on unload for more metrics to sync on `window.onunload`.

In come `window.onbeforeunload` to the rescue! For those who don't know about it (I
didn't before this project), `window.onbeforeunload` is exactly what it sounds like
an event that gets called before `window.onunload` which also happens before the DOM
gets unloaded. So you can reliably use it to write to the DOM (like the pixels) or
to query the DOM for any extra information you want to sync up.

## Conclusion
So what do you think? There really isn't too much to it is there? Especially since we
only covered the client side of the piece and haven't touched on how to collect and
interpret this data on the server (maybe that'll be a follow up post). Again this is mostly
a simple implementation of a RUM library, but hopefully it sparks an interest to build
one yourself or even just to give you some insight into how Google Analytics or other
RUM libraries collect/send data from the client.

I think this project that I undertook was neat because I do not always do client side
javascript and every time I do I tend to learn something pretty cool. In this case
learning the differences between `window.onunload` and `window.onbeforeunload` as well
as some of the cool things that are tracked by default in `window.performance` I
definitely urge people to check out the documentation on `window.performance`.

### TODO
What is next for [Sleuth](https://github.com/brettlangdon/sleuth)? I am not sure yet,
I am thinking of implementing more ways of tracking data, like adding counter support,
rate limiting, automatic incremental data syncs. I am open to ideas of how other people
would use a library like this, so please leave a comment here or open an issue on the
projects github page with any thoughts you have.


## Links
* [Sleuth](https://github.com/brettlangdon/sleuth)
* [Third Party Tracking Pixels](http://brett.is/writing/about/third-party-tracking-pixels/)
* [LocalStorage](http://diveintohtml5.info/storage.html)
* [Navigation Timing](https://developer.mozilla.org/en-US/docs/Navigation_timing)
* [window.onbeforeunload](https://developer.mozilla.org/en-US/docs/Web/API/Window.onbeforeunload)
* [window.onunload](https://developer.mozilla.org/en-US/docs/Web/API/Window.onunload)
* [RUM](http://en.wikipedia.org/wiki/Real_user_monitoring)
* [Google Analytics](http://www.google.com/analytics/)
* [A/B Testing](http://en.wikipedia.org/wiki/A/B_testing)
