---
layout: post
title: "Hibernate Query Language in Visual Studio"
date: 2010-07-28 21:57:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["Named Query", "HQL", "Tooling"]
redirect_from: ["/blogs/nhibernate/archive/2010/07/28/hibernate-query-language-in-visual-studio.aspx/"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>I started to work in an HQL addin for Visual Studio two weeks ago. As described in the <a href="http://hqladdin.codeplex.com/">project site</a>:</p>
<blockquote>
<p>This Visual Studio addin will provide the following features for the HQL file extension:      <br />-syntax highlighting (done),       <br />-syntax checking (done)       <br />-intellisense (<strong>not yet</strong>)</p>
</blockquote>
<p>Currently the addin support syntax highlighting and checking as you can see in the following screenshot:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/20100725_5F00_1011_5F00_778952B4.png"><img height="326" width="669" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/20100725_5F00_1011_5F00_thumb_5F00_22BDC3EF.png" alt="2010-07-25_1011" border="0" title="2010-07-25_1011" style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> </p>
<p>One of the more interesting part of this, is that I have not implemented a parser or anything. I have only used the lexer and the parser inside NHibernate 3, so these features will be up to date <span style="text-decoration: underline;">always</span>. In fact you can see the error &ldquo;No viable alternative&rdquo; that is common for most of the ANTLR parsers.</p>
<p>My idea is to support Intellisense as well, so I have reached Felice Pollano. He already has done a lot of work for other application named <a href="http://www.felicepollano.com/CategoryView,category,NHWorkBench.aspx">NHWorkBench</a> and we are willing to cooperate for the intellisense part.</p>
<p>There is a step by step guid on how to use &ldquo;hql&rdquo; files with nhibernate <a href="http://hqladdin.codeplex.com/wikipage?title=HowTo%20register%20queries%20from%20HQL%20files">here</a>.</p>
<p>I have published an alpha release in the <a href="http://visualstudiogallery.msdn.microsoft.com/es-ar/05d1c749-8352-4323-bdba-bc7253d26372">Visual Studio Online Gallery</a>, so is very easy to install it:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/20100727_5F00_0845_5F00_490F816D.png"><img height="454" width="656" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/20100727_5F00_0845_5F00_thumb_5F00_280BE8F9.png" alt="2010-07-27_0845" border="0" title="2010-07-27_0845" style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> </p>
<p>&nbsp;</p>
<p>If you are doing HQL have a look to my pluggin and let me know your comments!</p>
