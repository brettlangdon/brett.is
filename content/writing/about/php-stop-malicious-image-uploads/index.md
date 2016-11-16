---
title: PHP - Stop Malicious Image Uploads
author: Brett Langdon
date: 2012-02-01
template: article.jade
---

Quick and easy trick for detecting and stopping malicious image uploads to PHP.

---

Recently I have been practicing for the upcoming NECCDC competition and have
come across a few issues that will need to be overcome, including how to stop
malicious image uploads.

I was reading
<a href="http://www.acunetix.com/websitesecurity/upload-forms-threat.htm" target="_blank">this</a>
article on
<a href="http://www.acunetix.com/" target="_blank">Acunetix.com</a>
about the threats of having upload forms in PHP.

The general idea behind this exploit for Apache and PHP is when a user can
upload an image whose content contains PHP code and the extension includes
‘php’ for example an image ‘new-house.php.jpg’ that contains:

```
... (image contents)
<?php phpinfo(); ?>
... (image contents)
```

When uploaded and then viewed Apache, if improperly setup, will process the
image as PHP, because of the ‘.php’ in the extension and then when accessed
will execute malicious code on your server.

## My Solution

I was trying to find a good way to remove this issue quickly without opening
more security holes. I have seen some solutions that use the function
<a href="http://us2.php.net/manual/en/function.getimagesize.php" target="_blank">getimagesize</a>
to try and determine if the file is an image, but if the malicious code is
injected into the middle of an actual image this function will still return
the actual image size and the file will validate as an image. The solution I
came up with is to explicitly convert each uploaded image to a jpeg using
<a href="http://us2.php.net/manual/en/function.imagecreatefromjpeg.php" target="_blank">imagecreatefromjpeg</a>
and
<a href="http://us2.php.net/manual/en/function.imagejpeg.php" target="_blank">imagejpeg</a>
functions.

```php
<?php
$image = imagecreatefromjpeg( './new-house.php.jpeg' );
imagejpeg( $image, './new-house.php.jpeg' );
```

If the original image contains malicious code an error will be thrown and
`$image` will not contain an image. This is a way to try and sanitize the
image. This code can also be embellished where if the image is invalid then
an image is still created and uploaded.

```php
<?php
//@ to quite the possible error from this.
$image = @imagecreatefromjpeg( './new-house.php.jpg' );

if( !$image ):
    $image = imagecreate(100,20);
    $greenish = imagecolorallocate( $image, 180,200,180 );
    imagefill( $image, 0, 0, $greenish );
    $black = imagecolorallocate( $image, 0,0,0 );
    imagestring( $image, 1, 5, 5, 'No.. No..', $black );
endif;

imagejpeg( $image, './new-house.php.jpg' );
```

Enjoy.
