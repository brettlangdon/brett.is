---
title: Managing Go dependencies with git-subtree
author: Brett Langdon
date: 2016-02-03
template: article.jade
---

Recently I have decided to make the switch to using `git-subtree` for managing dependencies of my Go projects.

---

For a while now I have been searching for a good way to manage dependencies for my [Go](https://golang.org/)
projects. I think I have finally found a work flow that I really like that uses
[git-subtree](http://git.kernel.org/cgit/git/git.git/plain/contrib/subtree/git-subtree.txt).

When I began investigating different ways to manage dependencies I had a few small goals or concepts I wanted to follow.

### Keep it simple
I have always been drawn to the simplicity of Go and the tools that surround it.
I didn't want to add a lot of overhead or complexity into my work flow when programming in Go.

### Vendor dependencies
I decided right away that I wanted to vendor my dependencies, that is, where all of my dependencies
live under a top level `vendor/` directory in each repository.

This also means that I wanted to use the `GO15VENDOREXPERIMENT="1"` flag.

### Maintain the full source code of each dependency in each repository
The idea here is that each project will maintain the source code for each of its dependencies
instead of having a dependency manifest file, like `package.json` or `Godeps.json`, to manage the dependencies.

This was more of an acceptance than a decision. It wasn't a hard requirement that
each repository maintains the full source code for each of its dependencies, but
I was willing to accept that as a by product of a good work flow.

## In come git-subtree
When researching methods of managing dependencies with `git`, I came across a great article
from Atlassian, [The power of Git subtree](https://developer.atlassian.com/blog/2015/05/the-power-of-git-subtree/).
Which outlined how to use `git-subtree` for managing repository dependencies... exactly what I was looking for!

The main idea with `git-subtree` is that it is able to fetch a full repository and place
it inside of your repository. However, it differs from `git-submodule` because it does not
create a link/reference to a remote repository, instead it will fetch all the files from that
remote repository and place them under a directory in your repository and then treats them as
though they are part of your repository (there is no additional `.git` directory).

If you pair `git-subtree` with its `--squash` option, it will squash the remote repository
down to a single commit before pulling it into your repository.

As well, `git-subtree` has ability to issue a `pull` to update a child repository.

Lets just take a look at how using `git-subtree` would work.

### Adding a new dependency
We want to add a new dependency, [github.com/miekg/dns](https://github.com/miekg/dns)
to our project.

```
git subtree add --prefix vendor/github.com/miekg/dns https://github.com/miekg/dns.git master --squash
```

This command will pull in the full repository for `github.com/miekg/dns` at `master` to `vendor/github.com/miekg/dns`.

And that is it, `git-subtree` will have created two commits for you, one for the squash of `github.com/miekg/dns`
and another for adding it as a child repository.

### Updating an existing dependency
If you want to then update `github.com/miekg/dns` you can just run the following:

```
git subtree pull --prefix vendor/github.com/miekg/dns https://github.com/miekg/dns.git master --squash
```

This command will again pull down the latest version of `master` from `github.com/miekg/dns` (assuming it has changed)
and create two commits for you.

### Using tags/branches/commits
`git-subtree` also works with tags, branches, or commit hashes.

Say we want to pull in a specific version of `github.com/brettlangdon/forge` which uses tags to manage versions.

```
git subtree add --prefix vendor/github.com/brettlangdon/forge https://github.com/brettlangdon/forge.git v0.1.5 --squash
```

And then, if we want to update to a later version, `v0.1.7`, we can just run the following:

```
git subtree pull --prefix vendor/github.com/brettlangdon/forge https://github.com/brettlangdon/forge.git v0.1.7 --squash
```

## Making it all easier
I really like using `git-subtree`, a lot, but the syntax is a little cumbersome.
The previous article I mentioned from Atlassian ([here](ttps://developer.atlassian.com/blog/2015/05/the-power-of-git-subtree/))
suggests adding in `git` aliases to make using `git-subtree` easier.

I decided to take this one step further and write a `git` command, [git-vendor](https://github.com/brettlangdon/git-vendor)
to help manage subtree dependencies.

I won't go into much details here since it is outlined in the repository as well as at https://brettlangdon.github.io/git-vendor/,
but the project's goal was to make working with `git-subtree` easier for managing Go dependencies.
Mainly, to be able to add subtrees and give them a name, to be able to list all current subtrees,
and to be able to update a subtree by name rather than repo + prefix path.

Here is a quick preview:

```
$ git vendor add forge https://github.com/brettlangdon/forge v0.1.5
$ git vendor list
forge@v0.1.5:
    name:   forge
    dir:    vendor/github.com/brettlangdon/forge
    repo:   https://github.com/brettlangdon/forge
    ref:    v0.1.5
    commit: 4c620b835a2617f3af91474875fc7dc84a7ea820
$ git vendor update forge v0.1.7
$ git vendor list
forge@v0.1.7:
    name:   forge
    dir:    vendor/github.com/brettlangdon/forge
    repo:   https://github.com/brettlangdon/forge
    ref:    v0.1.7
    commit: 0b2bf8e484ce01c15b87bbb170b0a18f25b446d9
```

## Why not...
### Godep/&lt;package manager here&gt;
I decided early on that I did not want to "deal" with a package manager unless I had to.
This is not to say that there is anything wrong with [godep](https://github.com/tools/godep)
or any of the other currently available package managers out there, I just wanted to keep
the work flow simple and as close to what Go supports with respect to vendored dependencies
as possible.

### git-submodule
I have been asked why not `git-submodule`, and I think anyone that has had to work
with `git-submodule` will agree that it isn't really the best option out there.
It isn't as though it cannot get the job done, but the extra work flow needed
when working with them is a bit of a pain. Mostly when working on a project with
multiple contributors, or with contributors who are either not aware that the project
is using submodules or who has never worked with them before.

### Something else?
This isn't the end of my search, I will always be keeping a look out for new and
different ways to manage my dependencies. However, this is by far my favorite as of yet.
If anyone has any suggestions, please feel free to leave a comment.
