---
layout: post
title: "NHibernate isn't integrated to the compiler, so what?"
date: 2008-09-05 00:23:00 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: ["validation", "Xml", "SessionFactory", "BuildSessionFactory", "Xsd", "Named Query"]
alias: ["/blogs/nhibernate/archive/2008/09/04/nhibernate_2D00_isnt_2D00_integrated_2D00_to_2D00_the_2D00_compiler_2D00_so_2D00_what.aspx", "/blogs/nhibernate/archive/2008/09/04/nhibernate_2d00_isnt_2d00_integrated_2d00_to_2d00_the_2d00_compiler_2d00_so_2d00_what.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>I know, this title sounds like: "hmm?" Let me explain it with more detail.</p>
<p>NHibernate is a framework that use natively Xml in order to configure a mapping between objects and tables, is in charged of join these different worlds. </p>
<p>But now, what is going wrong with this? Many people can say that Xml files are evil, because you should write a lot of lines, and when you build your project, the compiler doesn't know if its ok or not, you have none errors. And this is true, you should run your project and see what happen in runtime, and to get an error in runtime is just annoying.</p>
<p>But now, do we have another alternative to this? Yes of course. Lets go to details. NHibernate has a "compiler" too, and you can guess what it is: <em>BuildSessionFactory()</em> method. You don't have to launch the whole application to know if your mapping is working well. A way to know if everything is ok is create a test like this:</p>
<p><img src="http://darioquintana.com.ar/files/CanBuild.png" /></p>
<p>Then you just need to build the project, and run this simple and dummy test, if your code pass though this, your mappings are ok.</p>
<p>We should remember one thing, you can map into Xml not just entities, you can map queries too (and another stuff that isn't part of this matter). To map queries into Xml it calls: <a href="/doc/nh/en/#manipulatingdata-queryinterface">Named Queries</a>, and in <a href="http://darioquintana.com.ar/blogging/?p=7">this post</a> we talk about this matter. But the main point is, mapping the queries you will know if them are well formed when <em>BuildSessionFactory()</em> is raised, besides another beauties discussed in that post.</p>
<p>Another thing you should remember is you MUST use the Xsd to validate the mapping file. This is mandatory if you're using NHibernate and you want to spend time programming instead of dealing with mapping errors (and here they come even with not-well-formed xmls). But this is topic to an How to or another post.</p>
