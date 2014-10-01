---
layout: post
title: "NHibernate Tidbit – using &lt;set/&gt; without referencing Iesi.Collections"
date: 2009-04-23 04:11:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["collections"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/23/nhibernate-tidbit-using-lt-set-gt-without-referencing-iesi-collections.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>Some people don’t like having to reference Iesi.Collections in order to use NHibernate &lt;set/&gt; mapping. With NHibernate 2.1, this is possible, since we finally have a set type in the actual BCL. We still don’t have an ISet&lt;T&gt; interface, unfortunately, but that is all right, we can get by with ICollection&lt;T&gt;.</p>  <p>In other words, any ISet&lt;T&gt; association that you have can be replaced with an ICollection&lt;T&gt; and instead of initializing it with Iesi.Collections.Generic.HashedSet&lt;T&gt;, you can initialize it with System.Collections.Generic.HashSet&lt;T&gt;.</p>  <p>Note that you still need to deploy Iesi.Collections with your NHibernate application, but that is all, you can remove the association to Iesi.Collections and use only BCL types in your domain model, with not external references.</p>
