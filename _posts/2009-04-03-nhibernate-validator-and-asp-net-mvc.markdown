---
layout: post
title: "NHibernate Validator and Asp.Net MVC"
date: 2009-04-03 00:07:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["validation", "Validator", "MVC", "Asp.Net"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/02/nhibernate-validator-and-asp-net-mvc.aspx"]
author: darioquintana
gravatar: f436801727b13a5c4c4a38380fc17290
---
{% include imported_disclaimer.html %}
<h4>&nbsp;<a href="http://darioquintana.googlecode.com/files/MvcNhvExample.zip">Download the example here.</a></h4>
<p>Asp.Net MVC has a cool way to add validation errors from the model and display them all into the View. It&rsquo;s actually using the ModelState. As you may know NHibernate Validator (NHV) is a framework to validate entities, so what about if we let the validation to the framework that can manage it? So the integration of NHV to Asp.Net MVC is easy. I created a new Asp.Net MVC project and added some files to my solution to make they look like this: <img src="http://darioquintana.com.ar/files/MvcNhv00.png" style="display: block; float: none; margin-left: auto; margin-right: auto" /></p>
<p>First I added the libraries needed to NHV (this libraries we need in case to use NHibernate too, otherwise you don&rsquo;t need Linfu stuff to get proxies working). The libraries are: </p>
<p><img src="http://darioquintana.com.ar/files/MvcNhv05.png" /> </p>
<p>Once the libraries are referenced, NHV need to be initialized, actually in this example that initialization will consist in a Validator Engine provider, capable to be accessed from everywhere into our web-application. A good point do this, is in the Global.asax. The next method <i>InitializeValidator</i> it&rsquo;s called from the <i>Application_Start</i>.</p>
<p><img src="http://darioquintana.com.ar/files/MvcNhv03.jpg" /></p>
<p>Then I created a new View Manage.aspx, actually the view is a copy, with modifications, of Register.aspx View. Such View should looks like this one. As you may see, seems like there are some messages of validation, means, a validation that didn&rsquo;t pass.&nbsp; Now let&rsquo;s see the code to explore the minimal code to introduce NHibernate Validator as a Framework to Validate our MVC application.</p>
<p><img src="http://darioquintana.com.ar/files/MvcNhv01.jpg" /></p>
<p>First of all, our entity Customer, which reflex the view with a Name and a Email properties, should looks like this with the NHV attributes. Remember that NHV can be configured using Attributes (default), Xml or Fluent-Interfaces, and accept mix configurations too.</p>
<p><img src="http://darioquintana.com.ar/files/MvcNhv04.png" /></p>
<p>Second, we need the integration point between NHibernate Validator and Asp.Net MVC, and that point consist just in a little piece of code that make the validation and modifies the current state of the model. We need just a few lines:</p>
<p><img src="http://darioquintana.com.ar/files/MvcNhv01.png" /></p>
<p>The picture shows an extension method which first of all, get a new ValidatorEngine instance, which is a singleton in whole web application. Actually, to use a ValidatorEngine we need just one instance, because NHV make a lot of useful caching and it configure itself in the way we are using it. Then we validate the entity and get all the InvalidValues of the object. If the entity is in invalid state (break one rule defined), NHV we well generate a InvalidValue array with all errors we should show to the user. Iterate through all the items and we add them all to the ModelState. Once we add one model error, the model is no longer valid.</p>
<p>Once we have our extension, let&rsquo;s use it.</p>
<p><img src="http://darioquintana.com.ar/files/MvcNhv02.png" /></p>
<p>Validate Method is the extension we made before, and that method is going to modify the ModelState if it&rsquo;s needed.</p>
<p>And that&rsquo;s all folks, hope this helps.</p>
