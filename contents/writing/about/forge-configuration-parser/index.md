---
title: Forge configuration parser
author: Brett Langdon
date: 2015-06-27
template: article.jade
---

An overview of how I wrote a configuration file format and parser.

---

Recently I have finished the initial work on a project,
[forge](https://github.com/brettlangdon/forge), which is a
configuration file syntax and parser written in go. Recently I was working
on a project where I was trying to determine what configuration
language I wanted to use and whether I tested out
[YAML](https://en.wikipedia.org/wiki/YAML) or
[JSON](https://en.wikipedia.org/wiki/JSON) or
[ini](https://en.wikipedia.org/wiki/INI_file), nothing really felt
right. What I really wanted was a format similar to
[nginx](http://wiki.nginx.org/FullExample)
but I couldn't find any existing packages for go which supported this
syntax. A-ha, I smell an opportunity.

I have always been interested by programming languages, by their
design and implementation. I have always wanted to write my own
programming language, but since I have never had any formal education
around the subject I have always gone about it on my own. I bring it
up because this project has some similarities. You have a defined
syntax that gets parsed into some sort of intermediate format. The
part that is missing is where the intermediate format is then
translated into machine or byte code and actually executed. Since this
is just a configuration language, that is not necessary.


## Project overview

You can see the repository for
[forge](https://github.com/brettlangdon/forge) for current usage and
documentation.

Forge syntax is a file which is made up of _directives_. There are 3
kinds of _directives_:

* _settings_: Which are in the form `<KEY> = <VALUE>`
* _sections_: Which are used to group more _directives_ `<SECTION-NAME> { <DIRECTIVES> }`
* _includes_: Used to pull in settings from other forge config files `include <FILENAME/GLOB>`

Forge also supports various types of _setting_ values:

* _string_: `key = "some value";`
* _bool_: `key = true;`
* _integer_: `key = 5;`
* _float_: `key = 5.5;`
* _null_: `key = null;`
* _reference_: `key = some_section.key;`

Most of these setting types are probably fairly self explanatory
except for _reference_. A _reference_ in forge is a way to have the
value of one _setting_ be a pointer to another _setting_. For example:

```config
global = "value";
some_section {
  key = "some_section.value";
  global_ref = global;
  local_ref = .key;
  ref_key = ref_section.ref_key;
}
ref_section {
  ref_key = "hello";
}
```

In this example we see 3 examples of _references_. A _reference_ value
is one which is an identifier (`global`) possibly multiple identifiers separated
with a period (`ref_section.ref_key`) as well _references_ can begin
with a perod (`.key`). Every _reference_ which is not prefixed with a period
is resolved from the global section (most outer level). So in this
example a _reference_ to `global` will point to the value of
`"value"` and `ref_section.ref_key` will point to the value of
`"hello"`. A _local reference_ is one which is prefixed with a period,
those are resolved starting from the current section that the
_setting_ is defined in. So in this case, `local_ref` will point to
the value of `"some_section.value"`.

That is a rough idea of how forge files are defined, so lets see a
quick example of how you can use it from go.

```go
package main

import (
    "github.com/brettlangdon/forge"
)

func main() {
    settings, _ := forge.ParseFile("example.cfg")
    if settings.Exists("global") {
    	value, _ := settings.GetString("global");
    	fmt.Println(value);
    }
    settings.SetString("new_key", "new_value");

    settingsMap := settings.ToMap();
    fmt.Println(settingsMaps["new_key"]);

    jsonBytes, _ := settings.ToJSON();
    fmt.Println(string(jsonBytes));
}
```

## How it works

Lets dive in and take a quick look at the parts that make forge
capable of working.

**Example config file:**
```config
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

Basically what forge does is take a configuration file in defined
format and parses it into what is essentially a `map[string]interface{}`.
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
grammar. For example, a directive is in the form
`<IDENTIFIER> <EQUAL> <VALUE> <SEMICOLON>` (where `<VALUE>` can be
`<STRING>`, `<BOOL>`, `<INTEGER>`, `<FLOAT>`, `<NULL>`,
`<REFERENCE>`). When the parser sees `<IDENTIFIER>` it'll look ahead
to the next token to try and match it to this rule, if it matches then
it knows to add this setting to the internal `map[string]interface{}`
for that identifier. If it doesn't match anything then it has a syntax
error and will throw an exception.

The part that I think is interesting is that I opted to just write the
tokenizer and parser by hand rather than using a library that converts
a language grammar into a tokenizer (like flex/bison). I have done
this before and was inspired to do so after learning that that is how
the go programming language is written, you can see here
[parser.go](https://github.com/golang/go/blob/258bf65d8b157bfe311ce70c93dd854022a25c9d/src/go/parser/parser.go)
(not a light read at 2500 lines). The
[scanner.go](https://github.com/brettlangdon/forge/blob/1c8c6f315b078622b7264b702b76c6407ec0f264/scanner.go)
and
[parser.go](https://github.com/brettlangdon/forge/blob/1c8c6f315b078622b7264b702b76c6407ec0f264/parser.go)
might proof to be slightly easier reads for those who are interested.

## Conclusion

There is just a brief overview of the project and just a slight dip
into the inner workings of it. I am extremely interested in continuing
to learn as much as I can about programming languages and
parsers/compilers. I am going to put together a series of blog posts
that walk through what I have learned so far and which might help
guide the reader through creating something similar to forge.

Enjoy.
