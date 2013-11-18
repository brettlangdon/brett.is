---
title: Generator Pipelines in Python
author: Brett Langdon
date: 2012-12-18
template: article.jade
---

A brief look into what a generator pipeline is and how to write one in Python.

---

Generator pipelines are a great way to break apart complex processing into
smaller pieces when processing lists of items (like lines in a file). For those
who are not familiar with <a href="http://www.python.org" target="_blank">Python</a>
generators or the concept behind generator pipelines, I strongly recommend
reading this article first:
<a href="http://www.dabeaz.com/generators-uk/index.html" target="_blank">Generator Tricks for Systems Programmers</a>
by <a href="http://www.dabeaz.com/" target="_blank">David M. Beazley</a>.
It will surely take you more in-depth than I am going to go.

A brief introduction on generators. There are two types of generators,
generator expressions and generator functions. A
<a href="http://www.python.org/dev/peps/pep-0289/" target="_blank">generator expression</a>
looks similar to a
<a href="http://www.python.org/dev/peps/pep-0202/" target="_blank">list comprehension</a>
but the simple difference is that it uses parenthesis over square brackets.
A <a href="http://www.python.org/dev/peps/pep-0255/" target="_blank">generator function</a>
is a function which contains the keyword
<a href="http://docs.python.org/2/reference/simple_stmts.html#grammar-token-yield_stmt" target="_blank">yield</a>;
yield is used to pass a value from within the function to the calling expression
without exiting the function (unlike a return statement).


## Generator Expression

```python
nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
print sum(num for num in nums)
num_gen = (num for num in nums)
for num in num_gen:
    print num
```

Line 2 of the above, when passing a generator into a function the extra parenthesis
are not needed. Otherwise you can create a stand alone generator, like in line 3;
this expression simply creates the generator, it does not iterate over the list of
numbers until it is passed into the for loop on line 4.


## Generator Function

```python
def nums():
    nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    for num in nums:
        yield num
print sum(nums())
for num in nums():
    print num
```

This block of code does the exact same as the example above but uses a generator
function instead of a generator expression. When the function nums is called it
will loop through the list of numbers and one by one pass them back up to either
the function call for sum or for the for loop.

Generators (either expressions or functions) are not the same as returning a list
of items (lets say numbers). They do not wait for all possible items to be yielded
before the items are returned. Each item is returned as it is yielded. For example,
with the generator function code above, the number 1 is being printed on line 7
before the number 2 is being yielded on line 4.

So, cool, alright, generators are nice, but what about generator pipelines? A
generator pipeline is taking these generators (expressions or functions) and
chaining them together. Lets try to look at a case where they might be useful.


## Example: Without Generators

```python
def process(num):
    # filter out non-evens
    if num % 2 != 0:
        return
    num = num * 3
    num = 'The Number: %s' % num
    return num
nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
for num in nums:
    print process(num)
```

This code is fairly simple and may not seem like the best example for creating a
generator pipeline, but it is nice because we can break it down into small parts.
For starters we need to filter out any non-even numbers, then we need to multiple
the num by 3, then finally we convert the number to a string. Lets see what this
looks like as a pipeline.


## Generator Pipeline

```python
def even_filter(nums):
    for num in nums:
        if num % 2 == 0:
            yield num
def multiply_by_three(nums):
    for num in nums:
        yield num * 3
def convert_to_string(nums):
    for num in nums:
        yield 'The Number: %s' % num

nums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
pipeline = convert_to_string(multiply_by_three(even_filter(nums)))
for num in pipeline:
    print num
```

This code example might look more complex that the previous example, but it
provides a good example of how (with generators) you can chain together a set of
very small and concise processes over a set of items. So, how does this example
really work? Each number in the list nums passes through each of the three
functions and is printed before the next items has it’s chance to make it through.

1. The Number 1 is checked for even, it is not so processing for that number stops
2. The Number 2 is checked for even, it is so it is yielded to `multiply_by_three`
3. The Number 2 is multiplied by 3 and yielded to `convert_to_string`
4. The Number 2 is formatted into the string and yielded to the for loop on line 14
5. The Number 2 is printed as _“The Number: 2″_
6. The Number 3 is checked for even, it is not so processing for that number stops
7. The Number 4 is checked for even, it is so it is yielded to `multiply_by_three`
8. … etc…

This continues until all of the numbers have either been ignored (by even_filter)
or have been yielded. If you wanted to, you can change the order in which the
chain is created to change the order in which each process runs (try swapping
even_filter and multiply_by_three).

So, how about a more practical example? What if we needed to process an
<a href="http://httpd.apache.org/" target="_blank">Apache</a> log file? We can use
a generator pipeline to break the processing into very small functions for
filtering and parsing. We will use the following example line format for our
processing:

```
127.0.0.1 [10/Oct/2000:13:55:36 -0700] "GET /apache_pb.gif HTTP/1.0" 200 2326
```


## Processing Apache Logs

```python
class LogProcessor(object):
    def __init__(self, file):
        self._file = file
        self._filters = []
    def add_filter(self, new_filter):
        if callable(new_filter):
            self._filters.append(new_filter)
    def process(self):
        # this is the pattern for creating a generator
        # pipeline, we start with a generator then wrap
        # each consecutive generator with the pipeline itself
        pipeline = self._file
        for new_filter in self._filters:
            pipeline = new_filter(pipeline)
        return pipeline

def parser(lines):
    """Split each line based on spaces and
    yield the resulting list.
    """
    for line in lines:
        yield [part.strip('"[]') for part in line.split(' ')]

def mapper(lines):
    """Convert each line to a dict
    """
    for line in lines:
        tmp = {}
        tmp['ip_address'] = line[0]
        tmp['timestamp'] = line[1]
        tmp['timezone'] = line[2]
        tmp['method'] = line[3]
        tmp['request'] = line[4]
        tmp['version'] = line[5]
        tmp['status'] = int(line[6])
        tmp['size'] = int(line[7])
        yield tmp

def status_filter(lines):
    """Filter out lines whose status
    code is not 200
    """
    for line in lines:
        # is the status is not 200
        # then the line is ignored
        # and does not make it through
        # the pipeline to the end
        if line['status'] == 200:
            yield line

def method_filter(lines):
    """Filter out lines whose method
    is not 'GET'
    """
    for line in lines:
        # all lines with method not equal
        # to 'get' are dropped
        if line['method'].lower() == 'get':
            yield line

def size_converter(lines):
    """Convert the size (in bytes)
    into megabytes
    """
    mb = 9.53674e-7
    for line in lines:
        line['size'] = line['size'] * mb
        yield line

# setup the processor
log = open('./sample.log')
processor = LogProcessor(log)

# this is the order we want the functions to run
processor.add_filter(parser)
processor.add_filter(mapper)
processor.add_filter(status_filter)
processor.add_filter(method_filter)
processor.add_filter(size_converter)

# process() returns the generator pipeline
for line in processor.process():
    # line with be a dict whose status is
    # 200 and method is 'GET' and whose
    # size is expressed in megabytes
    print line

log.close()
```

So there you have it. A more practical example of how to use generator pipelines.
We have setup a simple class that is used to iterate through a log file of a
specific format and perform a set of operations on each log line in a specified
order. By having each operation a very small generator function we now have modular
line processing, meaning we can move our filters, parsers and converters around in
any order we want. We can swap the order of the method and status filters and move
the size converters before the filters. It would not make sense, but we could move
the parser and mapper functions around as well (this might break things).

This generator pipeline will do the following:

1. yield a single line in from the log file
2. Split that line based on spaces and yield the resulting list
3. yield a dict from the single line list
4. check the line’s status code, yield if 200, goto step 1 otherwise
5. check the line’s method, yield if ‘get’, goto step 1 otherwise
6. convert the line’s size to megabytes, yield the line
7. the line is printed in the for loop, goto step 1 (repeat for all other lines)

Do you use generators and generator pipelines differently in your Python code?
Please feel free to share any tips/tricks or anything I may have missed in
the above. Enjoy.
