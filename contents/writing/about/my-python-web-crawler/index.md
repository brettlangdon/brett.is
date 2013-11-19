---
title: My Python Web Crawler
author: Brett Langdon
date: 2012-09-09
template: article.jade
---

How to write a very simplistic Web Crawler in Python for fun.

---

Recently I decided to take on a new project, a Python based
<a href="http://en.wikipedia.org/wiki/Web_crawler" target="_blank">web crawler</a>
that I am dubbing Breakdown. Why? I have always been interested in web crawlers
and have written a few in the past, one previously in Python and another before
that as a class project in C++. So what makes this project different?
For starters I want to try and store and expose different information about the
web pages it is visiting. Instead of trying to analyze web pages and develop a
ranking system (like
<a href="http://en.wikipedia.org/wiki/PageRank" target="_blank">PageRank</a>)
that allows people to easily search for pages based on keywords, I instead want to
just store the information that is used to make those decisions and allow people
to use them how they wish.

For example, I want to provide an API for people to be able to search for specific
web pages. If the page is found in the system, it will return back an easy to use
data structure that contain the pages
<a href="http://en.wikipedia.org/wiki/Meta_element" target="_blank">meta data</a>,
keyword histogram, list of links to other pages and more.

## Overview of Web Crawlers

What is a web crawler? We can start with the simplest definition of a web crawler.
It is a program that, starting from a single web page, moves from web page to web
page by only using urls that are given in each page, starting with only those
provided in the original page. This is how search engines like
<a href="http://www.google.com/" target="_blank">Google</a>,
<a href="http://www.bing.com/" target="_blank">Bing</a> and
<a href="http://www.yahoo.com/" target="_blank">Yahoo</a>
obtain the content they need for their search sites.

But a web crawler is not just about moving from site to site (even though this
can be fun to watch). Most web crawlers have a higher purpose, like (in the case
of search engines) to rank the relativity of a web page based on the content
provided within the pages content and html meta data to allow people easier
searching of content on the internet. Other web crawlers are used for more
invasive purposes like to obtain e-mail addresses to use for marketing or spam.

So what goes into making a web crawler? A web crawler, again, is not just about
moving from place to place how ever it feels. Web sites can actually dictate how
web crawlers access the content on their sites and how they should move around on
their site. This information is provided in the
<a href="http://www.robotstxt.org/" target="_blank">robots.txt</a>
file that can be found on most websites
(<a href="http://en.wikipedia.org/robots.txt" target="_blank">here is wikipedia’s</a>).
A rookie mistaken when building a web crawler is to ignore this file. These
robots.txt files are provided as a set of guidelines and rules that web crawlers
must adhere by for a given domain, otherwise you are liable to get your IP and/or
User Agent banned. Robots.txt files tell crawlers which pages or directories to
ignore or even which ones they should consider.

Along with ensuring that you follow along with robots.txt please be sure to
provide a useful and unique
<a href="http://en.wikipedia.org/wiki/User_agent" target="_blank">User Agent</a>.
This is so that sites can identify that you are a robot and not a human.
For example, if you see a User Agent of *“breakdown”* on your website, hi, it’s me.
Do not use know User Agents like:
*“Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.19 (KHTML, like Gecko) Ubuntu/12.04 Chromium/18.0.1025.168 Chrome/18.0.1025.168 Safari/535.19″*,
this is, again, an easy way for you to get your IP address banned on many sites.

Lastly, it is important to consider adding in rate limiting to your crawler. It is
wonderful to be able to crawl websites and between them very quickly (no one likes
to wait for results), but this is another sure fire way of getting your IP banned
by websites. Net admins do not like bots to tie up all of their networks
resources, making it difficult for actual users to use their site.


## Prototype of Web Crawler

So this afternoon I decided to take around an hour or so and prototype out the
code to crawl from page to page extracting links and storing them in the database.
All this code does at the moment is download the content of a url, parse out all
of the urls, find the new urls that it has not seen before, append them to a queue
for further processing and also inserting them into the database.This process has
2 queues and 2 different thread types for processing each link.

There are two different types of processes within this module, the first is a
Grabber, which is used to take a single url from a queue and download the text
content of that url using the
<a href="http://docs.python-requests.org/en/latest/index.html" target="_blank">Requests</a>
Python module. It then passes the content along to a queue that the Parser uses
to get new content to process. The Parser takes the content from the queue that
has been retrieved from the Grabber process and simply parses out all the links
contained within the sites html content. It then checks MongoDB to see if that
url has been retrieved already or not, if not, it will append the new url to the
queue that the Grabber uses to retrieve new content and also inserts this url
into the database.

The unique thing about using multiple threads per process (X for Grabbers and Y
for Parsers) as well as having two different queues to share information between
the two allows this crawler to be self sufficient once it gets started with a
single url. The Grabbers help feed the queue that the Parsers work off of and the
Parsers feed the queue that the Grabbers work from.

For now, this is all that my prototype does, it only stores links and crawls from
site to site looking for more links. What I have left to do is expand upon the
Parser to parse out more information from the html including things like meta
data, page title, keywords, etc, as well as to incorporate
<a href="http://www.robotstxt.org/" target="_blank">robots.txt</a> into the
processing (to keep from getting banned) and automated rate limiting
(right now I have a 3 second pause between each web request).


## How Did I Do It?

So I assume at this point you want to see some code? The code it not up on
GitHub just yet, I have it hosted on my own private git repo for now and will
gladly open source the code once I have a better prototype.

Lets just take a very quick look at how I am sharing code between the different
threads.

### Parser.py
```python
import threading
class Thread(threading.Thread):
    def __init__(self, content_queue, url_queue):
        self.c_queue = content_queue
        self.u_queue = url_queue
        super(Thread, self).__init__()
    def run(self):
        while True:
            data = self.c_queue.get()
            #process data
            for link in links:
                self.u_queue.put(link)
            self.c_queue.task_done()
```

### Grabber.py
```python
import threading
class Thread(threading.Thread):
    def __init__(self, url_queue, content_queue):
        self.c_queue = content_queue
        self.u_queue = url_queue
        super(Thread, self).__init__()
    def run(self):
        while True:
            next_url = self.u_queue.get()
            #data = requests.get(next_url)
            while self.c_queue.full():
                pass
            self.c_queue.put(data)
            self.u_queue.task_done()
```

### Breakdown
```python
from breakdown import Parser, Grabber
from Queue import Queue

num_threads = 4
max_size = 1000
url_queue = Queue()
content_queue = Queue(maxsize=max_size)

parsers = [Parser.Thread(content_queue, url_queue) for i in xrange(num_threads)]
grabbers = [Grabber.Thread(url_queue, content_queue) for i in xrange(num_threads)]

for thread in parsers+grabbers:
    thread.daemon = True
    thread.start()

url_queue.put('http://brett.is/')
```

Lets talk about this process quick. The Breakdown code is provided as a binary
script to start the crawler. It creates “num_threads” threads for each process
(Grabber and Parser). It starts each thread and then appends the starting point
for the crawler, http://brett.is/. One of the Grabber threads will then pick up on
the single url, make a web request to get the content of that url and append it
to “content_queue”. Then one of the Parser threads will pick up on the content
data from “content_queue”, it will process the data from the web page html,
parsing out all of the links and then appending those links onto “url_queue”. This
will then allow the other Grabber threads an opportunity to make new web requests
to get more content to pass to the Parsers threads. This will continue on and on
until there are no links left (hopefully never).


## My Results

I ran this script for a few minutes, maybe 10-15, and I ended up with over 11,000
links ranging from my domain,
<a href="http://www.pandora.com/" target="_blank">pandora</a>,
<a href="http://www.twitter.com/" target="_blank">twitter</a>,
<a href="http://www.linkedin.com/" target="_blank">linkedin</a>,
<a href="http://www.github.com/" target="_blank">github</a>,
<a href="http://www.sony.com/" target="_blank">sony</a>,
and many many more. Now that I have a decent base prototype I can continue forward
and expand upon the processing and logic that goes into each web request.

Look forward to more posts about this in the future.
