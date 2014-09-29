---
layout: post
title: "NHibernate SchemaValidator"
date: 2008-11-22 21:55:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2008/11/22/nhibernate-schemavalidator.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>This post was originally posted <a href="http://tunatoksoz.com/post/NHibernate-SchemaValidator.aspx">here</a></p>
<p><span style="font-size: small;">NHibernate provides <a href="http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/04/28/create-and-update-database-schema.aspx" target="_blank">a number of tools</a>
for developers to manage their database. I prefer mapping driven
approach in which I let NHibernate generate the schema for database for
me. By that way, I only concentrate on my domain. For me, database is
not the center but only a tool for storage most of the cases.</span></p>
<p><span style="font-size: small;">This
approach is valid only for greenfield projects. If you&rsquo;re using a
legacy database, however, things get more complicated and you write
your mappings according to your database. </span></p>
<p><span style="font-size: small;">NHibernate
now(with revision 3918, which means you have to use trunk until we
release it) provides a way to verify your mappings against your
database.</span></p>
<p><span style="font-size: small;">The usage is similar to <a href="http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/04/28/create-and-update-database-schema.aspx" target="_blank">other tools</a></span></p>
<p><span style="font-size: small;">I won&rsquo;t write a dedicated code for this but rather I am going to copy the tests from the code itself. </span></p>
<p><img src="/cfs-file.ashx/__key/CommunityServer.Components.UserFiles/00.00.00.21.06/schemavalidator_5F00_test.jpg" /></p>
<p>&nbsp;</p>
<p>SchemaValidator has a single method called <b>Validate</b>. You give it the configuration and it validates the schema.</p>
