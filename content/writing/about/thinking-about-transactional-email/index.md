---
title: Thinking about transactional email
author: Brett Langdon
date: 2017-09-14
template: article.jade
---

I have recently started working on a new project, <a href="https://mailchemy.com" target="_blank">Mailchemy</a>, for managing all of your transactional email integrations behind one easy to use API.

---

For awhile now I have been thinking about the complications of transactional email.
In the past I have found myself wanting to change email service providers, either for pricing or reliability reasons, but I've found myself stuck.
I had integrated my application so heavily into their product that making any kind of move away from their platform becomes difficult.
You can't fault me for making this choice-- email applications require deep integration in order to truly leverage all of the benefits of these services.

When integrating with an email service provider it would have been preferable to have abstracted out as much of the integration as possible, making it easier to swap out email providers.
Since we had not abstracted away the API calls in our code, we found ourselves having to track down every use of that specific API and update for it the new provider.
Given how tightly coupled sending transactional email is with our core application, these calls are spread throughout the code base and checking to be sure we had all usages removed and tested was both time consuming and risky. What if we missed a spot and weren’t sending an important message to our customers?

In addition to deep integration with an email service provider for when we send emails we were also storing a bunch of our email templates on the provider's platform.
This was a nice feature to ensure we didn't have to deploy a code change to update the copy in an email, enabling non-technical team members to make changes to our emails easily.
However, this nice feature also locked us into the provider further and made it harder for us to extract and move all of those templates to another platform.
To have more ownership of our email templates across platforms, we started moving some of the templates into our code base, but this introduced its own set of problems: shuffling templates around between providers and code is time consuming and means there is another part of the email pipeline you have to manage yourself.
We also lost the ability for our non-technical team members to update templates without a code change.

Since we were a small team, we couldn’t justify the loss of flexibility and increased effort that making these changes would incur-- we were bootstrapped, we had more important things to work on.
So we were stuck with the initial email provider we picked.

This work problem got me thinking more about transactional email.
It seems most people follow a similar basic process:

* Generate the email body from a template
* Optimize the email (inline CSS, minify HTML, etc)
* Send the email
* Create analytics or reports about the emails being sent
* Track open/click rates for emails
<br /><br />

There are a lot of really good transactional email providers, most of which offer some form of all of these steps.
However, they don't all necessarily offer the same features as other platforms or the exact features or configurations that someone will want.
As I discussed above, sometimes you find yourself in a position where you don't want to lock yourself into any given platform because of features so you abstract and manage the features you want anyways.

In software we talk a lot about DRY- don't repeat yourself.
We use abstraction and open source to leverage the time of our community to not re-invent the wheel, so why aren't we doing this more for transactional emails?

I have started working on a new project, <a href="https://mailchemy.com" target="_blank">Mailchemy</a>, which aims to help simplify transactional email.
Configure and manage all of your favorite email integrations in one place and utilize with one simple API call.

Mailchemy is the product that I wish I had when I was configuring transactional email at previous companies.
By using Mailchemy to handle all of your email integrations and calls to your email provider your initial integration along with any changes are easier to manage.
Changing an email provider can happen in just a few clicks instead of the countless hours spent hunting down that one last usage.

Mailchemy allows users to define their own custom transactional email pipelines full of your favorite integrations and utilize the email provider of your choice.
You will no longer have to make a decision on which email provider to use based on the features they offer.

No support for [Pug](https://pugjs.org)?
No problem, if Mailchemy supports it, you can use it.

Want to change email providers?
Take all of your favorite integrations with you.

As of the writing of this article Mailchemy is still under active development, please visit <a href="https://mailchemy.com" target="_blank">https://mailchemy.com/</a> for more information and to subscribe for product updates.
