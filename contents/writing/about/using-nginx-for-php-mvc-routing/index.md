---
title: Using Nginx for PHP MVC Routing
author: Brett Langdon
date: 2014-03-17
template: article.jade
---

An approach for using Nginx to handle all url routing
for a PHP MVC Framework

---

Last week I was profiling a
<a href="http://www.php.org" target="_blank">PHP</a> application
and noticed the overhead of having the url routing written in
PHP. It is not that the code was poorly written or anything,
but just seemed like a lot of overhead for the application.
So, I had an idea what if I moved the url routing to some other
system that was made for handling url routing? Like,
<a href="http://nginx.org" target="_blank">nginx</a>.

_Warning:_ My prototype makes the assumption that I am right
and that nginx is actually faster than PHP for url routing.
I am yet to do any performance testing, so I may actually be
wrong here, but thought I'd share my musings anyways.

```php
<?php
$controllerName = $_SERVER['HTTP_PHP_CONTROLLER'];
$urlParams = array();
foreach($_SERVER as $name => $value){
    if(substr($name, 0, 9) == 'HTTP_URL_'){
        $urlParams[substr($name, 0, 9)] = $value;
    }
}

$controller = new $controllerName();
$controller->handleRoute($urlParams);
```


```cfg
upstream php {
    server 127.0.0.1:8000;
    }

server {
    listen 80;
    server_name localhost;

    location ~* /model/(?<modelId>[0-9]+)(/.*?\.html)? {
        proxy_set_header PHP_CONTROLLER "ModelViewController";
        proxy_set_header URL_MODELID $modelId;
        proxy_pass http://php;
    }

    location ~* ^(?<url>/.*)$ {
        proxy_set_header PHP_CONTROLLER "DefaultController";
        proxy_set_header URL_URL $url;
        proxy_pass http://php;
    }
}
```
