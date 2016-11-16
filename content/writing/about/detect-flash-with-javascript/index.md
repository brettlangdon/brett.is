---
title: Detect Flash with JavaScript
author: Brett Langdon
date: 2013-06-05
template: article.jade
---

Quick, easy and lightweight way to detecting flash support in clients.

---

Recently I had to find a a good way of detecting if <a href="http://www.adobe.com/products/flashplayer.html" target="_blank">Flash</a>
is enabled in the browser, there are the two main libraries
<a href="http://solutionpartners.adobe.com/products/flashplayer/download/detection_kit/" target="_blank">Adobe Flash Detection Kit</a>
and <a href="https://code.google.com/p/swfobject/" target="_blank">SWFObject</a>
which are both very good at detecting whether Flash is enabled as well as getting
the version of Flash installed and useful for dynamically embedding and manipulating
<a href="http://en.wikipedia.org/wiki/SWF" target="_blank">swf</a> files
in your web application. But all I needed was a **yes** or a **no** to whether
Flash was there or not without the added overhead of unneeded code.
My goal was to wrote the least amount of JavaScript while still being able
to detect cross browser for Flash.

```javascript
function detectflash(){
    if (navigator.plugins != null && navigator.plugins.length > 0){
        return navigator.plugins["Shockwave Flash"] && true;
    }
    if(~navigator.userAgent.toLowerCase().indexOf("webtv")){
        return true;
    }
    if(~navigator.appVersion.indexOf("MSIE") && !~navigator.userAgent.indexOf("Opera")){
        try{
            return new ActiveXObject("ShockwaveFlash.ShockwaveFlash") && true;
        } catch(e){}
    }
    return false;
}
```

For those unfamiliar with the tilde (~) operator in javascript, please read
<a href="http://dreaminginjavascript.wordpress.com/2008/07/04/28/" target="_blank">this article</a>,
but the short version is, used with indexOf these two lines are equivalent:

```javascript
~navigator.appVersion.indexOf("MSIE")
navigator.appVersion.indexOf("MSIE") != -1
```

To use the above function:

```javascript
if(detectflash()){
    alert("Flash is enabled");
} else{
    alert("Flash is not available");
}
```

And that is it. Pretty simple and a much shorter version that the alternatives,
compressed and mangled I have gotten this code to under 400 Bytes.
I tested this code with IE 5.5+, Firefox and Chrome without any issues.
