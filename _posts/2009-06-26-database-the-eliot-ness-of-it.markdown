---
layout: post
title: "DataBase; The Eliot Ness of IT ?"
date: 2009-06-26 13:23:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate"]
redirect_from: ["/blogs/nhibernate/archive/2009/06/26/database-the-eliot-ness-of-it.aspx/", "/blogs/nhibernate/archive/2009/06/26/database-the-eliot-ness-of-it.html"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>[<a target="_blank" href="http://fabiomaulo.blogspot.com/">My blog</a>]</p>
<p>How many times we heard : </p>
<p>&ldquo;I need to map this situation&hellip;bla&hellip;bla&hellip; Note: I can&rsquo;t touch the DataBase schema.&rdquo;</p>
<p>&ldquo;I don&rsquo;t like composite PK but I can&rsquo;t change the DB schema.&rdquo;</p>
<p>&ldquo;I need to map this situation&hellip;bla&hellip;bla&hellip; Note: legacy DB.&rdquo;</p>
<p>You can see phrases similar to those above in various NHibernate forums in various languages. The fact that questions are sent to a NH&rsquo;s forum mean that somebody are developing a new .NET2.0 or .NET3.5 application using NHibernate with an existing DataBase (I&rsquo;m hoping this is the only possible situation). If a company spent time and money to rewrite an obsolete application for sure is because it is needed.</p>
<p>Let me show another situation: In a new application the first base module was deployed in production. The team now has an existing application with an existing DB and is developing another module. In the second module we realize that some change is needed to the persistence we actually have in production. What the team should do ? Well&hellip;something normal for us is create a &ldquo;migration step&rdquo; for the DB. The same happen again and again in each sprint.</p>
<p>How much different is the situation when the existing DB is five, or more, years old ? (well&hellip; it is different but I&rsquo;m not so sure that the difference is so big).</p>
<p>&ldquo;I can&rsquo;t change the DB because there are other applications using it&rdquo;&hellip; my friend in this case the first step should be write a good service layer to serve &ldquo;externals&rdquo; applications.</p>
<p>Why, write a new .NET3.5 application, shouldn&rsquo;t mean re-think the DB ? The DB is not a part of the old application ?</p>
<p>We are working in software, is the relational DB a piece of granite technology of the past century and nothing more ?</p>
<p>One of my preferred Mentor, illuminate me the way of ORM in these past years, is <a target="_blank" href="http://www.ambysoft.com/scottAmbler.html">Scott W. Ambler</a>. If you want help your DBA to come in the XXI century gives him some of Scott&rsquo;s books. Waiting Christmas point him to <a target="_blank" href="http://www.agiledata.org/essays/databaseRefactoring.html">this article</a> and invite him to follow each singular link; perhaps you will win a friend.</p>
<p><strong><span style="text-decoration: underline;"><span style="font-size: 100%">Dear DBA we are not your enemies, we are both in the same ship.</span></span></strong></p>
