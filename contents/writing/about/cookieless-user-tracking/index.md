---
title: Cookieless User Tracking
author: Brett Langdon
date: 2013-11-30
template: article.jade
---

A look into various methods of online user tracking without cookies.

---

Over the past few months, in my free time, I have been researching various
methods for cookieless user tracking. I have a previous article that talks
on how to write a
<a href="/writing/about/third-party-tracking-pixels/" target="_blank">tracking server</a>
which uses cookies to follow people between requests. However, recently
browsers are beginning to disallow third party cookies by default which means
developers have to come up with other ways of tracking users.


## Browser Fingerprinting

You can use client side javascript to generate a
<a href="/writing/about/browser-fingerprinting/" target="_blank">browser fingerprint</a>,
or, a unique identifier for a specific users browser (since that is what cookies
are actually tracking). Once you have the browser's fingerprint you can then
send that id along with any other requests you make.

```javascript
var user_id = generateBrowserFingerprint();
document.write(
    '<script type="text/javascript" src="/track/user/"' + user_id + '></ sc' + 'ript>'
);
```


## Local Storage

Newer browsers come equipped with a feature called
<a href="http://diveintohtml5.info/storage.html" target="_blank">local storage</a>
, which is used as a simple key-value store accessible through javascript.
So instead of relying on cookies as your persistent storage, you can store the
user id in local storage instead.

```javascript
var user_id = localStorage.getItem("user_id");
if(user_id == null){
    user_id = generateNewId();
    localStorage.setItem("user_id", user_id);
}
document.write(
    '<script type="text/javascript" src="/track/user/"' + user_id + '></ sc' + 'ript>'
);
```

This can also be combined with a browser fingerprinting library for generating
the new id.


## ETag Header

There is a feature of HTTP requests called an
<a href="http://en.wikipedia.org/wiki/HTTP_ETag" target="_blank">ETag Header</a>
which can be exploited for the sake of user tracking. The way an ETag works is
simply when a request is made the server will respond with an ETag header with
a given value (usually it is an id for the requested document, or maybe a hash
of it), whenever the bowser then makes another request for that document it will
send an _If-None-Match_ header with the value of _ETag_ provided by the server
last time. The server can then make a decision as to whether or not new content
needs to be served based on the id/hash provided by the browser.

As you may have figured out, instead we can assign a unique user id as the ETag
header for a response, then when the browser makes a request for that page again
it will send us the user id.

This is useful, except for the fact that we can only provide a single id per
user per endpoint. For example, if I use the urls `/track/user` and
`/collect/data` there is no way for me to get the browser to send the same
_If-None-Match_ header for both urls.

### Example Server

```python
from uuid import uuid4
from wsgiref.simple_server import make_server


def tracking_server(environ, start_response):
    user_id = environ.get("HTTP_IF_NONE_MATCH")
    if not user_id:
        user_id = uuid4().hex

    start_response("200 Ok", [
        ("ETag", user_id),
    ])
    return [user_id]


if __name__ == "__main__":
    try:
        httpd = make_server("", 8000, tracking_server)
        print "Tracking Server Listening on Port 8000..."
        httpd.serve_forever()
    except KeyboardInterrupt:
        print "Exiting..."
```


## Redirect Caching

Redirect caching works in a similar matter to using ETag headers,
you end up relying on browser caches to store your user ids.


## Ever Cookie

A project worth noting is Samy Kamkar's
<a href="http://samy.pl/evercookie/" target="_blank">Evercookie</a>
which uses standard cookies, flash objects, silverlight isolated storage,
web history, etags, web cache, local storage, global storage... and more.


## Other Methods

I am sure there are other methods out there, these are just the few that I
decided to focus on. If anyone has any other methods or ideas please leave a comment.
