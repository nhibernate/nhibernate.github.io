---
layout: post
title: "Quickly Setting Up And Using NHibernate's Second Level Cache"
date: 2009-02-09 22:19:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/02/09/quickly-setting-up-and-using-nhibernate-s-second-level-cache.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>The purpose of this post is just to quickly go over what you need to do to get NHibernate's 2nd Level Cache working in your application.  If you want to read how the 1st and 2nd Level Caches work, please read Gabriel Schenker's excellent and thorough <a href="http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/11/09/first-and-second-level-caching-in-nhibernate.aspx">post about it</a>.
Anyways, the first thing you need to do, is to enable the 2nd level cache.  </p>
<p>Add the following 2 properties to your hibernate.cfg.xml file:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #a31515; }
.cb3 { color: red; }
--></style>
</code></p>
<div class="cf">
<p class="cl"><span class="cb1">&nbsp; &nbsp; &lt;</span><span class="cb2">property</span><span class="cb1"> </span><span class="cb3">name</span><span class="cb1">=</span>"<span class="cb1">cache.use_second_level_cache</span>"<span class="cb1">&gt;</span>true<span class="cb1">&lt;/</span><span class="cb2">property</span><span class="cb1">&gt;</span></p>
<p class="cl"><span class="cb1">&nbsp; &nbsp; &lt;</span><span class="cb2">property</span><span class="cb1"> </span><span class="cb3">name</span><span class="cb1">=</span>"<span class="cb1">cache.use_query_cache</span>"<span class="cb1"> &gt;</span>true<span class="cb1">&lt;/</span><span class="cb2">property</span><span class="cb1">&gt;</span></p>
</div>
<p>

The first one (obviously) enables the 2nd level cache, while the second one enables query caching. That basically means that you can (optionally) cache the results of specific queries.  Note that this doesn't mean that the results of all queries will be cached, only the ones where you specify that the results can be cached.
Next, you need to choose a CacheProvider.  There are various options available, although i generally just use SysCache (which makes use of the ASP.NET Cache).  You can download the CacheProviders <a href="http://sourceforge.net/project/showfiles.php?group_id=216446&amp;package_id=286204">here</a>.
</p>
<p>Once you've picked out a CacheProvider, you need to add a property for it to your hibernate.cfg.xml file as well:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #a31515; }
.cb3 { color: red; }
--></style>
</code></p>
<div class="cf">
<p class="cl"><span class="cb1">&nbsp; &nbsp; &lt;</span><span class="cb2">property</span><span class="cb1"> </span><span class="cb3">name</span><span class="cb1">=</span>"<span class="cb1">cache.provider_class</span>"<span class="cb1">&gt;</span>NHibernate.Caches.SysCache.SysCacheProvider, NHibernate.Caches.SysCache<span class="cb1">&lt;/</span><span class="cb2">property</span><span class="cb1">&gt;</span></p>
</div>
<p>

Let's first start with caching the results of a query.  Suppose we have the following query:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #2b91af; }
.cb3 { color: #a31515; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">var</span> products = session.CreateCriteria(<span class="cb1">typeof</span>(<span class="cb2">Product</span>))</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span class="cb2">Restrictions</span>.Eq(<span class="cb3">"Category.Id"</span>, categoryId))</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .List&lt;<span class="cb2">Product</span>&gt;();</p>
</div>
<p>

If we want NHibernate to cache the results of this query, we can make that happen like this:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #2b91af; }
.cb3 { color: #a31515; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">var</span> products = session.CreateCriteria(<span class="cb1">typeof</span>(<span class="cb2">Product</span>))</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetCacheable(<span class="cb1">true</span>)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span class="cb2">Restrictions</span>.Eq(<span class="cb3">"Category.Id"</span>, categoryId))</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .List&lt;<span class="cb2">Product</span>&gt;();</p>
</div>
<p>

When we execute this query, NHibernate will cache the results of this query.  It is very important to know that it won't actually cache all of the values of each row.  Instead, when the results of queries are cached, only the identifiers of the returned rows are cached.
So what happens when we execute the query the first time with categoryId containing the value 1? It sends the correct SQL statement to the database, creates all of the entities, but it only stores the identifiers of those entities in the cache.  The second time you execute this query with categoryId containing the value 1, it will retrieve the previously cached identifiers but then it will go to the database to fetch each row that corresponds with the cached identifiers.
</p>
<p>Obviously, this is bad.  What good is caching if it's actually making us go to the database more often than without caching?  That is where entity caching comes in.  In this case, our query returns Product entities, but because the Product entity hasn't been configured for caching, only the identifiers are cached.  If we enable caching for Product entities, the resulting identifiers of the query will be cached, as well as the actual entities.  In this case, the second time this query is executed with a categoryId with value 1, we won't hit the database at all because both the resulting identifiers as well as the entities are stored in the cache.  
</p>
<p>To enable caching on the entity level, add the following property right below the class definition in the Product.hbm.xml file:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #a31515; }
.cb3 { color: red; }
--></style>
</code></p>
<div class="cf">
<p class="cl"><span class="cb1">&nbsp; &lt;</span><span class="cb2">class</span><span class="cb1"> </span><span class="cb3">name</span><span class="cb1">=</span>"<span class="cb1">Product</span>"<span class="cb1"> </span><span class="cb3">table</span><span class="cb1">=</span>"<span class="cb1">Products</span>"<span class="cb1">&gt;</span></p>
<p class="cl"><span class="cb1">&nbsp; &nbsp; &lt;</span><span class="cb2">cache</span><span class="cb1"> </span><span class="cb3">usage</span><span class="cb1">=</span>"<span class="cb1">read-write</span>"<span class="cb1">/&gt;</span></p>
</div>
<p>

This tells NHibernate to store the data of Product entities in the 2nd level cache, and that any updates that we make to Product entities need to be synchronized in both the database and the cache.
That's pretty much all you need to do to get the 2nd Level Cache working.  But please keep in mind that there is a lot more to caching than what i showed in this post.  Reading Gabriel's post on caching is an absolute must IMO.  Caching is a powerful feature, but with great power comes great responsibility. Learn how to use it wisely :)</p>
<p>If you liked this post, please check out my <a target="_blank" href="http://davybrion.com/">blog</a> where i post about NHibernate and (.NET) development in general.</p>
<p>&nbsp;</p>
