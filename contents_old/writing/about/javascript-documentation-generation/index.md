---
title: Javascript Documentation Generation
author: Brett Langdon
date: 2015-02-03
template: article.jade
---

I have always been trying to find a good Javascript documentation generator and
I have never really been very happy with any that I have found. So I've decided
to just write my own, DocAST.

---

The problem I have always had with any documentation generators is they are
either hard to theme or are sometimes very strict with the way doc strings are
suppose to be written, making them potentially difficult to switch between
documentation generators if you had to. So for a fun exercise I've decided to
just try writting one myself, [DocAST](https://github.com/brettlangdon/docast).

What is different about DocAST? I've seen a few documentation parsers which use
regular expressions to parse out the comment blocks, which works perfectly well,
except I've decided to have some fun and use
[AST](http://en.wikipedia.org/wiki/Abstract_syntax_tree) parsing to grab the
code blocks from the scripts. As well, DocAST doesn't try to force you in to any
specific theme or display, instead it is used simply to extract documentation
from scripts. Lastly, DocAST, doesn't use any specific documentation format for
signifying parameters, returns or exceptions, it will traverse the AST of the
code block to find them for you, so most of the time you just need to add a
simple block comment describing the function above it.

Lets just get to an example:

```javascript
// script.js

/*
 * This is my super cool function that does all sorts of cool stuff
 **/
function superCool(arg1, arg2){
    if(arg1 === arg2){
        throw new Exception("arg1 and arg2 cant be the same");
    }

    var sum = arg1 + arg2;
    return sum;
}
```

```shell
$ docast extract ./script.js
$ cat out.json
```

```javascript
[
    {
        "name": "superCool",
        "params": [
            "arg1",
            "arg2"
        ],
        "returns": [
            "sum"
        ],
        "raises": [
            "Exception"
        ],
        "doc": " This is my super cool function that does all sorts of cool stuff\n"
    }
]
```

For more information check out the github page for
[DocAST](https://github.com/brettlangdon/docast).

The other benefit I have found with a documentation parser (something that just
extracts the documentation information as opposed to trying to build it) is that
you can get fun and creative with how you use the information parsed. For
example, I've had someone suggest creating your doc strings as
[yaml](http://www.yaml.org/). When you parse out the string just parse the yaml
to get an object which is then easy to pass on to [jade](http://jade-lang.com/)
or some other templating engine to generate your documentation. If you want to
see an example of this, just check out the documentation for DocAST
https://github.com/brettlangdon/docast/blob/master/lib/index.js#L127 and the
code used to generate the docs at http://brettlangdon.github.io/docast/
https://github.com/brettlangdon/docast/tree/master/docs
