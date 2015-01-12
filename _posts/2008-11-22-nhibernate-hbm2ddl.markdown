---
layout: post
title: "NHibernate hbm2ddl"
date: 2008-11-22 22:04:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: 
  - "/blogs/nhibernate/archive/2008/11/23/nhibernate-hbm2ddl.aspx/"
  - "/blogs/nhibernate/archive/2008/11/23/nhibernate-hbm2ddl.html"
  - "/blogs/nhibernate/archive/2008/11/22/nhibernate-hbm2ddl.html"
author: tehlike
gravatar: c9c2937ea2b0d5472a33a23b5df78814
---
{% include imported_disclaimer.html %}

<p>NHibernate has a number of configuration options: Enabling statistics, Caching etc. You can check more from <a href="http://nhibernate.svn.sourceforge.net/viewvc/nhibernate/trunk/nhibernate/src/NHibernate/Cfg/Settings.cs?revision=3870&amp;view=markup" target="_blank">here</a></p>
<p>I will now talk about an unknown feature(well, at least I didn&rsquo;t know until I implement SchemaValidator): <b>hbm2ddl.auto</b></p>
<p>Hbm2ddl.auto
is declarative way to use SchemaExport / SchemaUpdate / SchemaValidator
(well the latter sounds odd, maybe it would be better to call it
SchemaValidate, what do you think?). If you add </p>
<p>&lt;property name="<b>hbm2ddl.auto</b>"&gt;create&lt;/property&gt;</p>
<p>for example, it will run</p>
<p><b>new SchemaExport(cfg).Create(false, true);</b></p>
<p>during SessionFactory initialization, with which you probably are familiar.</p>
<p>There are several options for hbm2ddl.auto.</p>
<ol>
<li><b>update</b> executes <b>SchemaUpdate</b> which will modify your existing table with new mapping, without dropping any columns.</li>
<li><b>create-drop </b>executes SchemaExport when SessionFactory initializes and drops the schema at the end of the life of the factory.</li>
<li><b>validate</b> executes SchemaValidator which I blogged about <a href="http://www.tunatoksoz.com/post/NHibernate-SchemaValidator.aspx" target="_blank">here</a></li>
</ol>
<p> If you prefer not to use programatic way, configuration is just here. </p>
