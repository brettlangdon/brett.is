---
title: Goodbye Grunt, Hello Tend
author: Brett Langdon
date: 2014-06-09
template: article.jade
---

Recently decided to give Grunt a try, which caused me to write my
own node.js build system.

---

For the longest time I had refused to move away from [Makefiles](http://mrbook.org/tutorials/make/)
for [Grunt](http://gruntjs.com/) or some other [node.js](https://nodejs.org) build system.
But I finally gave in and decided to take an afternoon to give Grunt a go.
Initially it seemed promising, Grunt had a plugin for everything and ultimately
it supporting watching files and directories (the one feature I really wanted
for my `make` build setup).

I tried to move over a fairly simplistic `Makefile` that I already had written
into a `Gruntfile`. However, after about an hour (or more) of trying to get `grunt`
setup with [grunt-cli](https://github.com/gruntjs/grunt-cli) and all the other
plugins installed and configured to do the right thing I realized that `Grunt`
wasn't for me. I took a simple 10 (ish) line `Makefile` and turned it into a 40+
line `Gruntfile` and it still didn't seem to do exactly what I wanted. What I
had to reflect on was why should I spend all this time trying to learn how to
configure some convoluted plugins when I already known the correct commands to
execute? Then I realized what I really wanted wasn't a new build system but
simply `watch` for a `Makefile`

I have attempted to get some form of watch working with a `Makefile` in the past,
but it usually involves using inotify and I've never gotten it working exactly
like how I wanted. So, I decided to start writing my own system, because, why not
spend more time on perfecting my build system. My requirements were fairly simple,
I wanted a way to watch a directory/files for changes and when they do simply run
a single command (ultimately `make <target>`), I wanted the ability to also run
long running processing like `node server.js` and restart them if certain files
have changed, and lastly unlike other watch based systems I have seen I wanted
a way to run a command as soon as I start up the watch program (so you dont have
to start the watching, then go open/save a newline change to a file to get it to
build for the first time).

What I came up with was [tend](https://github.com/brettlangdon/tend). Which solves
mostly all of my needs, which was simply "watch for make". So how do you use it?

### Installation
```bash
npm install -g tend
```

### Usage

```
Usage:
  tend
  tend <action>
  tend [--restart] [--start] [--ignoreHidden] [--filter <filter>] [<dir> <command>]
  tend (--help | --version)

Options:
  -h --help             Show this help text
  -v --version          Show tend version information
  -r --restart          If <command> is still running when there is a change, stop and re-run it
  -i --ignoreHidden     Ignore changes to files which start with "."
  -f --filter <filter>  Use <filter> regular expression to filter which files trigger the command
  -s --start            Run <command> as soon as tend executes
```

### Example CLI Usage

The following will watch for changes to any `js` files in the directory `./src/`
when any of them change or are added it will run `uglifyjs` to combine them into
a single file.

```bash
tend --ignoreHidden --filter "*.js" ./src "uglifyjs -o ./public/main.min.js ./src/*.js"
```

The following will run a long running process, starting it as soon as `tend` starts
and restarting the program whenever files in `./routes/` has changed.
```bash
tend --restart --start --filter "*.js" ./routes "node server.js"
```

### Config File

Instead of running `tend` commands singly from the command line you can provide
`tend` with a `.tendrc` file of multiple directories/files to watch with commands
to run.

The following `.tendrc` file are setup to run the same commands as shown above.

```ini
; global settings
ignoreHidden=true

[js]
filter=*.js
directory=./src
command=uglifyjs -o ./public/main.min.js ./src/*.js

[app]
filter=*.js
directory=./routes
command=node ./app/server.js
restart=true
start=true
```

You can then simply run `tend` without any arguments to have `tend` watch for
all changes configured in your `.tendrc` file.

Running:
```bash
tend
```

Will basically execute:
```bash
tend --ignoreHidden --filter "*.js" ./src "uglifyjs -o ./public/main.min.js ./src/*.js" \
  & tend --restart --start --filter "*.js" ./routes "node server.js"
```

Along with running multiple targets at once, you can run specific targets from
a `.tendrc` file as well, `tend <target>`.
```bash
tend js
```

Will run the `js` target once.
```bash
tend --ignoreHidden --filter "*.js" ./src "uglifyjs -o ./public/main.min.js ./src/*.js"
```

### With Make

If I haven't beaten a dead horse enough, I am a `Makefile` kind of person and
that is exactly what I wanted to use this new tool with. So below is an example
of a `Makefile` and it's corresponding `.tendrc` file.

```make
js:
    uglifyjs -o ./public/main.min.js ./src/*.js

app:
    node server.js

.PHONY: js app
```

```ini
ignoreHidden=true

[js]
filter=*.js
directory=./src
command=make js

[app]
filter=*.js
directory=./routes
command=make app
restart=true
start=true
```

### Conclusion

So that is mostly it. Nothing overly exciting and nothing really new here, just
another watch/build system written in node to add to the list. For the most part
this tool does exactly what I want for now, but if anyone has any ideas on how
to make this better or even any other better/easier tools which do similar things
please let me know, I am more than willing to continue maintaining this tool.
