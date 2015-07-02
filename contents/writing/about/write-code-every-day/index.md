---
title: Write code every day
author: Brett Langdon
date: 2015-07-02
template: article.jade
---

Just like a poet or an athlete practicing code every day will only make you better.

---

Lately I have been trying to get into blogging more and any article I read always says, "you need to write every day".
It doesn't matter if what I write down gets published, but forming the habit of trying to write something every day
is what counts. The more I write the easier it will become, the more natural it will feel and the better I will get at it.

This really isn't just true of writing or blogging, it is something that can be said of anything at all. Riding a bike,
playing basketball, reading, cooking or absolutely anything at all. The more you do it, the easier it will become and
the better you will get.

As the title of the post will allude you to, this is also true of programming. If you want to be really good at programming
you have to write code every day. The more code you write the easier it'll be to write and the better you will be at programming.
Just like any other task I've listed in this article, trying to write code every day, even if you are used to it, can be really
hard to do and a really hard habit to keep.

"What should I write?" The answer to this question is going to be different for everyone, but it is the hurdle which
you must first overcome to work your way towards writing code every day. Usually people write code to solve problems
that they have, but not everyone has problems to solve. There is usually a chicken and the egg problem. You need to
write code to have coding problems, and you need to have coding problems to have something to write. So, where should
you start?

For myself, one of the things I like doing is to rewrite things that already exist. Sometimes it can be hard to come up with a
new and different idea or even a new approach to an existing idea. However, there are millions of existing projects out
there to copy. The idea I go for is to try and replicate the overall goal of the project, but in my own way. That might
mean writing it in a different language, or changing the API for it or just taking some wacky new approach to solving the same issue.

More times than not the above exercise leads me to a problem that I then can go off and solve. For example, a few weeks ago
I sat down and decided I wanted to write a web server in `go` (think `nginx`/`apache`). I knew going into the project I wanted
a really nice and easy to use configuration file to define the settings. So, I did what most people do these days I and
used `json`, but that didn't really feel right to me. I then tried `yaml`, but yet again didn't feel like what I wanted. I
probably could have used `ini` format and made custom rules for the keys and values, but again, this is hacky. This spawned
a new project in order to solve the problem I was having and ended up being [forge](https://github.com/brettlangdon/forge),
which is a hand coded configuration file syntax and parser for `go` which ended up being a neat mix between `json` and `nginx`
configuration file syntax.

Anywho, enough of me trying to self promote projects. The main point is that by trying to replicate something that
already exists, without really trying to do anything new, I came up with an idea which spawned another project and
for at least a week (and continuing now) gave me a reason to write code every day. Not only did I write something
useful that I can now use in any future project of mine, I also learned something I did not know before. I learned
how to hand code a syntax parser in `go`. I like using this approach for learning new tools as well. Want to learn
`python`, `go`, `c`, `erlang`, `react`, `web components`, `angular`, `ember`, `express`, `<any other technology here>`,
then write something you already know about first.

Ultimately, try to take "coding every day" not as a challenge to write something useful every day, but to learn
something new every day. Learn part of a new language, a new framework, learn how to take something apart or put
it back together. Write code every day and learn something new every day. The more you do this, the more you will
learn and the better you will become.

Go forth and happy coding. :)
