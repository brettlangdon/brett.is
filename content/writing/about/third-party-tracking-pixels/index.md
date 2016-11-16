---
title: Third Party Tracking Pixels
author: Brett Langdon
date: 2013-05-03
template: article.jade
---

An overview of what a third party tracking pixel is and how to create/use them.

---

So, what exactly do we mean by “third party tracking pixel” anyways?
Lets try to break it down piece by piece:

### Tracking Pixel:
A pixel referes to a tag that is placed on a site that offers no merit other than
calling out to a web page or script that is not the current page you are visiting.
These pixels are usually an html script tag that point to a javascript file with
no content or an img tag with a empty or transparent 1 pixel by 1 pixel gif image
(hence the term “pixel”). A tracking pixel is the term used to describe a pixel
that calls to another page or script in order to provide it information about the
users visit to the page.

### Third Party:
Third party just means the pixel points to a website that is not the current
website. For example,
<a href="http://www.google.com/analytics/" target="_blank">Google Analytics</a>
is a third party tracking tool because you place scripts on your website
that calls and sends data to Google.


## What is the point?

Why do people do this? In the case of Google Analytics people do not wish to track
and follow their own analytics for their website, instead they want a third party
host to do it for them, but they need a way of sending their user’s data to Google.
Using pixels and javascript to send the data to Google offers the company a few
benefits. For starters, they do not require any more overhead on their servers for
a service to send data directly to Google, instead by using pixels and scripts they
get to off load this overhead onto their users (thats right, we are using our
personal computers resources to send analytical data about ourselves to Google for
websites that use Google analytics). Secondly, the benefit of using a tracking
pixel that runs client side (in the user’s browser) we are allowed to gather more
information about the user. The information that is made available to us through
the use of javascript is far greater than what is given to our servers via
HTTP Headers.


## How do we do it?

Next we will walk through the basics of how to create third party tracking pixels.
Code examples for the following discussion can be found
<a href="https://github.com/brettlangdon/tracking-server-examples" target="_blank">here</a>.
We will walk through four examples of tracking pixels accompanied by the server
code needed to serve and receive the pixels. The server is written in
<a href="http://python.org/" target="_blank">Python</a> and some basic
understanding of Python is required to follow along. The server examples are
written using only standard Python wsgi modules, so no extra installation is
needed. We will start off with a very simple example of using a tracking pixel and
then each example afterwards we will begin to add features to the pixel.

## Simple Example

For this example all we want to accomplish is to have a web server that returns
HTML containing our tracking pixel as well as a handler to receive the call from
our tracking pixel. Our end goal is to serve this HTML content:

```html
<html>
  <head></head>
  <body>
    <h2>Welcome</h2>
    <script src="/track.js"></script>
  </body>
</html>
```

As you can see, this is fairly simple HTML; the important part is the script tag
pointing to “/track.js”, this is our tracking pixel. When the user’s browser loads
the page this script will  make a call to our server, our server can then log
information about that user. So we start with a wsgi handler for the HTML code:

```python
def html_content(environ, respond):
    headers = [('Content-Type', 'text/html')]
    respond('200 OK', headers)
    return [
        """
        <html><head></head><body>
        <h2>Welcome</h2><script src="/track.js"></script>
        </body></html>
        """
    ]
```

Next we want to make sure that we have a handler for the calls to “/track.js”
from the script tag:

```python
def track_user(environ, respond):
    headers = [('Content-Type', 'application/javascript')]
    respond('200 OK', headers)
    prefixes = ['PATH_', 'HTTP', 'REQUEST', 'QUERY']
    for key, value in environ.iteritems():
        if any(key.startswith(prefix) for prefix in prefixes):
            print '%s: %s' % (key, value)
    return ['']
```

In this handler we are taking various information about the request from the user
and simply printing it to the screen. The end point “/track.js” is not meant to
point to actual javascript so instead we return back an empty string. When this
code runs you should see something like the following:

```
brett$ python tracking_server.py
Tracking Server Listening on Port 8000...
1.0.0.127.in-addr.arpa - - [24/Apr/2013 20:03:21] "GET / HTTP/1.1" 200 89
HTTP_REFERER: http://localhost:8000/
REQUEST_METHOD: GET
QUERY_STRING:
HTTP_ACCEPT_CHARSET: ISO-8859-1,utf-8;q=0.7,*;q=0.3
HTTP_CONNECTION: keep-alive
PATH_INFO: /track.js
HTTP_HOST: localhost:8000
HTTP_ACCEPT: */*
HTTP_USER_AGENT: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31
HTTP_ACCEPT_LANGUAGE: en-US,en;q=0.8
HTTP_DNT: 1
HTTP_ACCEPT_ENCODING: gzip,deflate,sdch
1.0.0.127.in-addr.arpa - - [24/Apr/2013 20:03:21] "GET /track.js HTTP/1.1" 200 0
1.0.0.127.in-addr.arpa - - [24/Apr/2013 20:03:21] "GET /favicon.ico HTTP/1.1" 204 0
```

You can see in the above that first the browser makes the request “GET /” which
returns our HTML containing the tracking pixel, then directly afterwards makes a
request for “GET /track.js” which prints out various information about the incoming
request. This example is not very useful as is, but helps to illustrate the key
point of a tracking pixel. We are having the browser make a request on behalf of
the user without the user’s knowledge. In this case we are making a call back to
our own server, but our script tag could easily point to a third party server.


## Add Some Search Data

Our previous, simple, example does not really provide us with any particularly
useful information other than allow us to track that a user’s browser made the
call to our server. For this next example we want to build upon the previous by
sending some data along with the tracking pixel; in this case, some search data.
Let us make an assumption that our web page allows users to make searches; searches
are given to the page through a url query string parameter “search”. We want to
pass that query string parameter on to our tracking pixel, which we will use the
query string parameter “s”. So our requests will look as follows:

* http://localhost:8000?search=my cool search
* http://localhost:8000/track.js?s=my cool search

To do this, we simply append the query string parameter “search” onto our track.js
script tag in our HTML:

```python
def html_content(environ, respond):
    query = parse_qs(environ['QUERY_STRING'])
    search = quote(query.get('search', [''])[0])
    headers = [('Content-Type', 'text/html')]
    respond('200 OK', headers)
    return [
        """
        <html><head></head><body>
        <h2>Welcome</h2><script src="/track.js?s=%s"></script>
        </body></html>
        """ % search
    ]
```

For our tracking pixel handler we will simply print the value of the query string
parameter “s” and again return an empty string.

```python
def track_user(environ, respond):
    query = parse_qs(environ['QUERY_STRING'])
    search = query.get('s', [''])[0]
    print 'User Searched For: %s' % search
    headers = [('Content-Type', 'application/javascript')]
    respond('200 OK', headers)
    return ['']
```

When run the output will look similar to:

```
brett$ python tracking_server.py
Tracking Server Listening on Port 8000...
1.0.0.127.in-addr.arpa - - [24/Apr/2013 21:35:24] "GET /?search=my%20cool%20search HTTP/1.1" 200 110
User Searched For: my cool search
1.0.0.127.in-addr.arpa - - [24/Apr/2013 21:35:24] "GET /track.js?s=my%20cool%20search HTTP/1.1" 200 0
1.0.0.127.in-addr.arpa - - [24/Apr/2013 21:35:24] "GET /favicon.ico HTTP/1.1" 204 0
1.0.0.127.in-addr.arpa - - [24/Apr/2013 21:35:34] "GET /?search=another%20search HTTP/1.1" 200 108
User Searched For: another search
1.0.0.127.in-addr.arpa - - [24/Apr/2013 21:35:34] "GET /track.js?s=another%20search HTTP/1.1" 200 0
1.0.0.127.in-addr.arpa - - [24/Apr/2013 21:35:34] "GET /favicon.ico HTTP/1.1" 204 0
```

Here we can see the two search requests made to our web page and the similar
resulting requests to track.js. Again, this example might not seem like much but
it proves a way of being able to pass values from our web page along with to the
tracking server. In this case we are passing search terms, but we could also pass
any other information along we needed.


## Track User’s with Cookies

So now we are getting somewhere, our tracking server is able to receive some
search data  about the requests made to our web page. The problem now is we have
no way of associating this information with a specific user; how can we know when
a specific user searches for multiple things. Cookies to the rescue. In this
example we are going to add the support of using cookies to assign each visiting
user a specific and unique id, this will allow us to associate all the search data
we receive with “specific” users. Yes, I say “specific” with quotes because we can
only associate the data with a given cookie, if multiple people share a computer
then we will probably think they are a single person. As well, if someone clears
the cookies for their browser then we lose all association with that user and have
to start all over again with a new cookie. Lastly, if a user does not allow cookies
for their browser then we will be unable to associate any data with them as every
time they visit our tracking server we will see them as a new user. So, how do we
do this? When receive a request from a user we want to look and see if we have
given them a cookie with a user id, if so then we will associate the incoming data
with that user id and if there is no user cookie then we will generate a new user
id and give it to the user.

```python
def track_user(environ, respond):
    cookies = SimpleCookie()
    cookies.load(environ.get('HTTP_COOKIE', ''))

    user_id = cookies.get('id')
    if not user_id:
        user_id = uuid4()
        print 'User did not have id, giving: %s' % user_id

    query = parse_qs(environ['QUERY_STRING'])
    search = query.get('s', [''])[0]
    print 'User %s Searched For: %s' % (user_id, search)
    headers = [
        ('Content-Type', 'application/javascript'),
        ('Set-Cookie', 'id=%s' % user_id)
    ]
    respond('200 OK', headers)
    return ['']
```

This is great! Not only can we now obtain search data from a third party website
but we can also do our best to associate that data with a given user. In this
instance a single user is anyone who shares the same user id in their
browsers cookies.


## Cache Busting

So what exactly is cache busting? Our browsers are smart, they know that we do not
like to wait a long time for a web page to load, they have also learned that they
do not need to refetch content that they have seen before if they cache it. For
example, an image on a web site might get cached by your web browser so every time
you reload the page the image can be loaded locally as opposed to being fetched
from the remote server. Cache busting is a way to ensure that the browser does not
cache the content of our tracking pixel. We want the user’s browser to follow the
tracking pixel to our server for every page request they make because we want to
follow everything that that user does. When the browser caches our tracking
pixel’s content (an empty string) then we lose out on data. Cache busting is the
term used when we programmatically generate query string parameters to make calls
to our tracking pixel look unique and therefore ensure that the browser follows
the pixel rather than load from it’s cache. To do this we need to add an extra end
point to our server. We need the HTML for the web page, along with a cache busting
script and finally our track.js handler. A cache busting script will use javascript
to add our track.js script tag to the web page. This means that after the web page
is loaded javascript will run to manipulate the
<a href="http://en.wikipedia.org/wiki/Document_Object_Model" target="_blank">DOM</a>
to add our cache busted track.js script tag to the HTML. So, what does this
look like?

```javascript
var now = new Date().getTime();
var random = Math.random() * 99999999999;
document.write('<script type="text/javascript" src="/track.js?t=' + now + '&r=' + random + '"></script>
```

This script adds the extra query string parameters ”r” which is a random number
and “t” which is the current timestamp in milliseconds. This will give us a unique
enough request that will trick our browsers into ignoring anything that is has in
it’s cache for track.js and forces it to make the request anyways. Using a cache
buster requires us to modify the html we server slightly to server up the cache
busting javascript as opposed to our track.js pixel.

```html
<html>
  <head></head>
  <body>
    <h2>Welcome</h2>
    <script src="/buster.js"></script>
  </body>
</html>
```

And we need the following to serve up the cache buster script buster.js:

```python
def cache_buster(environ, respond):
    headers = [('Content-Type', 'application/javascript')]
    respond('200 OK', headers)
    cb_js = """
            function getParameterByName(name){
                name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
                var regexS = "[\\?&]" + name + "=([^&#]*)";
                var regex = new RegExp(regexS);
                var results = regex.exec(window.location.search);
                if(results == null){
                    return "";
                }
                return decodeURIComponent(results[1].replace(/\+/g, " "));
            }

            var now = new Date().getTime();
            var random = Math.random() * 99999999999;
            var search = getParameterByName('search');
            document.write('<script src="/track.js?t=' + now + '&r=' + random + '&s=' + search + '"></script>');
            """
    return [cb_js]
```

We do not care very much if the browser caches our cache buster script because
it will always generate a new unique track.js url every time it is run.


## Conclusion

There is a lot of stuff going on here and probably a lot to digest so lets review
quick what we have learned. For starters we learned that companies use tracking
pixels or tags on web pages whose sole purpose is to make your browser call our to
external third party sites in order to track information about your internet
usage (usually, they can be used for other things as well). We also looked into
some very simplistic ways of implementing a server whose job it is to accept
tracking pixels calls in various forms.

We learned that these tracking servers can use cookies stored on your browser to
store a unique id for you in order to help associate the data collected to you.
That you can remove this association by clearing your cookies or by not allowing
them at all. Lastly, we learned that browsers can cause issues for our tracking
pixels and data collection and that we can get around them using a cache busting
javascript.

As a reminder the full working code examples can be located at
<a href="https://github.com/brettlangdon/tracking-server-examples" target="_blank">"https://github.com/brettlangdon/tracking-server-examples</a>.
