---
title: Forge configuration parser
author: Brett Langdon
date: 2015-06-19
template: article.jade
---


---

## TODO: Fix this starting paragraph
Ok, job is great, lets talk about code! I have always had the aspiration of writing my own
programming language. It is something I never went through as part of my "higher"
education and it has always greatly interested me. I have always made attempts here and
there to learn what I can about how they work and try to deconstruct existing languages or
build what I can of new ones. I have never been very successful, but I am always learning.

I finally feel that I am making a bit of progress in my learning. Recently I was working
on a project in [go](http://golang.org/) and where I started was trying to determine what
configuration language I wanted to use and whether I tested out
[YAML](https://en.wikipedia.org/wiki/YAML) or [JSON](https://en.wikipedia.org/wiki/JSON)
or [ini](https://en.wikipedia.org/wiki/INI_file), nothing really felt right. What I really
wanted was a format similar to [nginx]() but I couldn't find any existing packages for go
which supported this syntax. A-ha, I smell an opportunity. The project I started is
[forge](https://github.com/brettlangdon/forge). Currently it is still nothing too
impressive, but I feel like it marks a step in my quest for creating a programming
language.

**Example config file:**
```cfg
# Top comment
global = "value";
section {
  a_float = 50.67;
  sub_section {
    a_null = null;
    a_bool = true;
    a_reference = section.a_float;  # Gets replaced with `50.67`
  }
}
```

Effectively what I wrote was a programming language. A very very simple one, but one none
the less a programming language. Basically what this library does is take a configuration
file in the specific format and parses it into an intermediate format. In this case it
ends up being a `map[string]interface{}` but if it were a programming language it could
end up being an [Abstract Syntax Tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
(AST) which is the intermediate representation that some languages use before compiling
the source into machine code or [bytecode](https://en.wikipedia.org/wiki/Bytecode).

The code itself is comprised of two main parts, the tokenizer (or scanner) and the
parser. The tokenizer turns the raw source code (like above) into a stream of tokens. If
you printed the token representation of the code above, it could look like:

```
(COMMENT, "Top comment")
(IDENTIFIER, "global")
(EQUAL, "=")
(STRING, "value")
(SEMICOLON, ";"
(IDENTIFIER, "section")
(LBRACKET, "{")
(IDENTIFIER, "a_float")
(EQUAL, "=")
(FLOAT, "50.67")
(SEMICOLON, ";")
....
```

Then the parser takes in this stream of tokens and tries to parse them based on some known
grammar. For example, a directive is in the form `<IDENTIFIER> <EQUAL> <VALUE>
<SEMICOLON>` (where `<VALUE>` can be `<STRING>`, `<BOOL>`, `<INTEGER>`, `<FLOAT>`,
`<NULL>`, `<REFERENCE>`). When the parser sees `<IDENTIFIER>` it'll look ahead to the next
token to try and match it to this rule, if it matches then it knows to add this setting to
the internal `map[string]interface{}` for that identifier. If it doesn't match anything
then it has a syntax error and will throw an exception.
