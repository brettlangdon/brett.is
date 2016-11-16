---
title: The Fastest Python JSON Library
author: Brett Langdon
date: 2013-09-22
template: article.jade
---

My results from benchmarking a handfull of Python JSON parsing libraries.

---

Most who know me well know that I am usually not one for benchmarks.
Especially blindly posted benchmark results in blog posts (like how this one is going to be).
So, instead of trying to say that “this library is better than that library” or to try and convince you that you are going to end up with the same results as me.
Instead remember to take these results with a grain of salt.
You might end up with different results than me.
Take these results as interesting findings which help supplement your own experiments.

Ok, now that that diatribe is over with LETS GET TO THE COOL STUFF!
We use JSON for a bunch of stuff at work, whether it is a third party system that uses JSON to communicate or storing JSON blobs in the database.
We have done some naive benchmarking in the past and came to the conclusion that [jsonlib2](https://pypi.python.org/pypi/jsonlib2/) is the library for us.
Well, I started a personal project that also uses JSON and I decided to revisit benchmarking Python JSON libraries to see if there are any “better” ones out there.

I ended up with the following libraries to test:
[standard lib json](http://docs.python.org/2/library/json.html), [jsonlib2](https://pypi.python.org/pypi/jsonlib2/), [simplejson](https://pypi.python.org/pypi/simplejson/), [yajl](https://pypi.python.org/pypi/yajl) (yet another json library) and lastly [ujson](https://pypi.python.org/pypi/ujson) (ultrajson).
For the test, I wanted to test parsing and serializing a large json blob, in this case, I simply took a snapshot of data from the [Twitter API Console](https://dev.twitter.com/console).
Ok, enough with this context b.s. lets see some code and some results.

```python
import json
import timeit

# json data as a str
json_data = open("./fixture.json").read()
# json data as a list
data = json.loads(json_data)

number = 500
repeat = 4
print "Average run time over %s executions repeated %s times" % (number, repeat)

# we still store the fastest run times here
fastest_dumps = (None, -1)
fastest_loads = (None, -1)

for library in ("ujson", "simplejson", "jsonlib2", "json", "yajl"):
    print "-" * 20
    # thanks yajl for not setting __version__
    exec("""
try:
    from %s import __version__
except Exception:
    __version__ = None
         """ % library)
    print "Library: %s" % library
    # for jsonlib2 this is a tuple... thanks guys
    print "Version: %s" % (__version__, )

    # time to time json.dumps
    timer = timeit.Timer(
        "json.dumps(data)",
        setup="""
import %s as json
data = %r
              """ % (library, data)
    )

    total = sum(timer.repeat(repeat=repeat, number=number))
    per_call = total / (number * repeat)
    print "%s.dumps(data): %s (total) %s (per call)" % (library, total, per_call)
    if fastest_dumps[1] == -1 or total > fastest_dumps[1]:
        fastest_dumps = (library, total)

    # time to time json.loads
    timer = timeit.Timer(
        "json.loads(data)",
        setup="""
import %s as json
data = %r
              """ % (library, json_data)
    )
    total = sum(timer.repeat(repeat=repeat, number=number))
    per_call = total / (number * repeat)
    print "%s.loads(data): %s (total) %s (per call)" % (library, total, per_call)
    if fastest_loads[1] == -1 or total > fastest_loads[1]:
       fastest_loads = (library, total)

    print "-" * 20
    print "Fastest dumps: %s %s (total)" % fastest_dumps
    print "Fastest loads: %s %s (total)" % fastest_loads
```

Ok, we need to talk about this code for a second.
It really is not the cleanest code I have ever written.
We start off by loading the fixture json data as both the raw json text and parse it into a python list of objects.
Then for each of the libraries we want to test, we try to get their version information and finally we use [timeit](http://docs.python.org/2/library/timeit.html) to test how long it takes to serialize the parsed fixture data into a JSON string and then we test parsing the JSON string of the fixture data into a list of objects.
And lastly, we store the name of the library with the fastest total run time for either “dumps” or “loads” and then at the end we print which was fastest.

Here are the results I got when running on my macbook pro:
```text
Average run time over 500 executions repeated 4 times
--------------------
Library: ujson
Version: 1.33
ujson.dumps(data): 1.97361302376 (total) 0.000986806511879 (per call)
ujson.loads(data): 2.05873394012 (total) 0.00102936697006 (per call)
--------------------
Library: simplejson
Version: 3.3.0
simplejson.dumps(data): 3.24183320999 (total) 0.001620916605 (per call)
simplejson.loads(data): 2.20791387558 (total) 0.00110395693779 (per call)
--------------------
Library: jsonlib2
Version: (1, 3, 10)
jsonlib2.dumps(data): 2.211810112 (total) 0.001105905056 (per call)
jsonlib2.loads(data): 2.55381131172 (total) 0.00127690565586 (per call)
--------------------
Library: json
Version: 2.0.9
json.dumps(data): 2.35674309731 (total) 0.00117837154865 (per call)
json.loads(data): 5.23104810715 (total) 0.00261552405357 (per call)
--------------------
Library: yajl
Version: None
yajl.dumps(data): 2.85826969147 (total) 0.00142913484573 (per call)
yajl.loads(data): 3.03867292404 (total) 0.00151933646202 (per call)
--------------------
Fastest dumps: ujson 1.97361302376 (total)
Fastest loads: ujson 2.05873394012 (total)
```

So there we have it.
My tests show that [ujson](https://pypi.python.org/pypi/ujson) is the fastest python json library (when running on my mbp and when parsing or serializing a “large” json dataset).

I have added the test scripts, fixture data and results in [this gist](https://gist.github.com/brettlangdon/6b007ef89fd7d2931a22) if anyone wants to run locally and post their results in the comments below.
I would be curious to see the results of others.
