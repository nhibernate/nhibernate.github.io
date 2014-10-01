---
layout: post
title: "Documentation Project Launch"
date: 2009-06-02 16:52:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate Documentation"]
redirect_from: ["/blogs/nhibernate/archive/2009/06/02/documentation-project-launch.aspx"]
author: ssteinegger
gravatar: 5d9c48ac94a9376f1b7bccdd13c4d987
---
{% include imported_disclaimer.html %}
<p>I started to restructure and enhance the NHibernate documentation. I want to move from a "Reference Documentation" to a "Programmers Manual". The difference is, that when you read a reference documentation you already know the concepts and only need to know details like xml elements or HQL syntax. A manual should explain the concepts in detail and you should be able to understand it even if you are new to NHibernate.</p>
<p>The current documentation is explaining quite a lot - it is not only a reference. Most of the documentation is already there. But in my opinion it is sometimes on the wrong place.</p>
<p>Let me demonstrate this with some randomly picked examples:</p>
<ul>
<li>Chapter 2.3 "Contextual Sessions": We don't even know, what a session actually is at this point and what it is used for.</li>
<li>Chapter 3.3 "User Provided ADO.NET connection": It is the first chapter about how to optain a connection and it appears to be the easiest and recommended way. This chapter should be last option and there should be a hint that some things won't work with user provided connections (eg. Hi-Lo identities afaik).</li>
<li>Chapter 3.5 "Optional configuration properties": There is a list of all optional properties. This is a "reference" kind of documentation. For instance, all the hibernate.cache.* parameters should be explained in a chapter about NH second level caches, unless the reader can't do anything with the information.</li>
<li>By the way, the possible values for each parameter is documented as "eg: ...". It should be a complete list.</li>
</ul>
<p>And so on.</p>
<p>The new structure how I propose it is available as <a target="_self" title="NHibernate Documentation Structure Proposal" href="/wikis/reference2-0en/nhibernate-documentation-structure-proposal.aspx">draft in the wiki</a>. Please read it and comment to it if you think it should be different. Now it is still easy to change.</p>
<p>It will be quite a bit of work, and I will need some help. Now stop moving the mouse towards the "return" or "close tab" button and keep reading. Thanks. You can even help if you don't have much time and if you are not the Great Master of NHibernate. This is how you can help:</p>
<ul>
<li>Give me some feedback to my plans, on this blog and on the <a title="NHibernate Documentation Structure Proposal" href="/wikis/reference2-0en/nhibernate-documentation-structure-proposal.aspx">structure proposal</a>. This is important to me.</li>
<li>Tell me what you miss in the documentation, or what you would like be changed. Also tell me what you like and should be kept as it is.</li>
<li>I will ask specific questions in further blogs. So please keep reading them :-)</li>
</ul>
<p>Later, I will need some people to:</p>
<ul>
<li>review the docs. For instance, a native English speaker to turn my (and probably others) <a title="Wikipedia on Pidgin" href="http://en.wikipedia.org/wiki/Pidgin">Pidgin</a> English into real English. Or a NH developer who checks if it is actually true.</li>
<li>develop the tools. We are using <a title="DocBook.org" href="/controlpanel/blogs/posteditor.aspx/DocBook.org">DocBook</a>, if you know about XSL:FO or how to configure HTML output, your help will be much appreciated.</li>
<li>develop examples and diagrams. But before we start writing such things, we need to know what has to be demonstrated with it.</li>
</ul>
