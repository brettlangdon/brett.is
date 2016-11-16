---
title: Continuous NodeJS Module
author: Brett Langdon
date: 2012-04-28
template: article.jade
---

A look into my new NodeJS module called Continuous.

---

Greetings everyone. I wanted to take a moment to mention the new NodeJS module
that I just published called Continuous.

Continuous is a fairly simply plugin that is aimed to aid in running blocks of
code consistently; it is an event based interface for setTimeout and setInterval.
With Continuous you can choose to run code at a set or random interval and
can also hook into events.

## Installation
```bash
npm install continuous
```

## Continuous Usage

```javascript
var continuous = require('continuous');

var run = new continuous({
    minTime: 1000,
    maxTime: 3000,
    random: true,
    callback: function(){
        return Math.round( new Date().getTime()/1000.0 );
    },
    limit: 5
});

run.on(‘complete’, function(count, result){
    console.log(‘I have run ‘ + count + ‘ times’);
    console.log(‘Results:’);
    console.dir(result);
});

run.on(‘started’, function(){
    console.log(‘I Started’);
});

run.on(‘stopped’, function(){
    console.log(‘I am Done’);
});

run.start();

setTimeout( function(){
    run.stop();
}, 5000 );
```

For more information check out Continuous on
<a href="https://github.com/brettlangdon/continuous" target="_blank">GitHub</a>.
