---
title: Sharing Data from PHP to JavaScript
author: Brett Langdon
date: 2014-03-16
template: article.jade
---

A quick example of how I decided to share dynamic content from PHP with my JavaScript.

---

So the other day I was refactoring some of the client side code I was working on and
came across something like the following:

### page.php
```php
<html>
...

<script type="text/javascript">
var modelTitle = "<?=$myModel->getTitle()?>";

// do something with modelTitle
</script>
</html>
```

There isn't really anything wrong here, in fact this seems to be a fairly common practice
(from the little research I did). So... whats the big deal? Why write an article about it?

My issue with the above is, what if the JavaScript gets fairly large (as mine was). The
ideal thing to do is to move the js into it's own file, minify/compress it and serve it
from a CDN so it doesn't effect page load time. But, now we have content that needs to be
added dynamically from the PHP script in order for the js to run. How do we solve it? The
approach that I took, which probably isn't original at all, but I think neat enough to
share, was to let PHP make the data available to the script through `window.data`.

### page.php
```php
<html>
...
<?php
$pageData = array(
    'modelTitle' => $myModel->getTitle(),
);
?>
<script type="text/javascript">
window.data = <?=json_encode($pageData)?>;
</script>
<script type="text/javascript" src="//my-cdn.com/scripts/page-script.min.js"></script>
</html>
```

### page-script.js
```javascript
// window.data.modelTitle is available for me to use
console.log("My Model Title: " + window.data.modelTitle);
```

Nothing really fancy, shocking, new or different here, just passing data from PHP to js.
Something to note is that we have to have our PHP code set `window.data` before we load
our external script so that `window.data` will be available when the script loads. Which
this shouldn't be too much of an issue since most web developers are used to putting all
of their `script` tags at the end of the page.

Some might wonder why I decided to use `window.data`, why not just set
`var modelTitle = "<?=$myModel->getTitle()?>";`? I think it is better to try and have a
convention for where the data from the page will come from. Having to rely on a bunch of
global variables being set isn't really a safe way to write this. What if you overwrite
an existing variable or if some other script overwrites your data from the PHP script?
This is still a cause for concern with `window.data`, but at least you only have to keep
track of a single variable. As well, I think organizationally it is easier and more concise
to have `window.data = <?=json_encode($pageData)?>;` as opposed to:

```php
var modelTitle = "<?=$myModel->getTitle()?>";
var modelId = "<?=$myModel->getId()?>";
var username = "<?=getCurrentUser()?>";
...
```

I am sure there are other ways to do this sort of thing, like with AJAX or having an
initialization function that PHP calls with the correct variables it needs to pass, etc.
This was just what I came up with and the approach I decided to take.

If anyone has other methods of sharing dynamic content between PHP and js, please leave a
comment and let me know, I am curious as to what most other devs are doing to handle this.
