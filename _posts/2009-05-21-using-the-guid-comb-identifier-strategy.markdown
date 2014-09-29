---
layout: post
title: "Using The Guid.Comb Identifier Strategy"
date: 2009-05-21 11:48:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/05/21/using-the-guid-comb-identifier-strategy.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>As you may have read by now, it's a good idea to <a href="http://ayende.com/Blog/archive/2009/03/20/nhibernate-avoid-identity-generator-when-possible.aspx">avoid identity-style identifier strategies</a> with ORM's.  One of the better alternatives that i kinda like is the guid.comb strategy.  Using regular guids as a primary key value leads to fragmented indexes (due to the randomness of the guid's value) which leads to bad performance.  This is a problem that the guid.comb strategy can solve quite easily for you.
If you want to learn how the guid.comb strategy really works, be sure to check out <a href="http://www.informit.com/articles/article.aspx?p=25862">Jimmy Nilsson's article on it</a>. Basically, this strategy generates sequential guids which solves the fragmented index issue.  You can generate these sequential guids in your database, but the downside of that is that your ORM would still need to insert each record seperately and fetch the generated primary key value each time.  NHibernate includes the guid.comb strategy which will generate the sequential guids before actually inserting the records in your database.
This obviously has some great benefits: 
</p>
<ul>
<li>you don't have to hit the database immediately whenever a record needs to be inserted</li>
<li>you don't need to retrieve a generated primary key value when a record was inserted</li>
<li>you can batch your insert statements</li>
</ul>
<p>
Let's see how we can use this with NHibernate.  First of all, you need to map the identifier of your entity like this:
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
<p class="cl"><span class="cb1">&nbsp; &nbsp; &lt;</span><span class="cb2">id</span><span class="cb1"> </span><span class="cb3">name</span><span class="cb1">=</span>"<span class="cb1">Id</span>"<span class="cb1"> </span><span class="cb3">column</span><span class="cb1">=</span>"<span class="cb1">Id</span>"<span class="cb1"> </span><span class="cb3">type</span><span class="cb1">=</span>"<span class="cb1">guid</span>"<span class="cb1"> &gt;</span></p>
<p class="cl"><span class="cb1">&nbsp; &nbsp; &nbsp; &lt;</span><span class="cb2">generator</span><span class="cb1"> </span><span class="cb3">class</span><span class="cb1">=</span>"<span class="cb1">guid.comb</span>"<span class="cb1"> /&gt;</span></p>
<p class="cl"><span class="cb1">&nbsp; &nbsp; &lt;/</span><span class="cb2">id</span><span class="cb1">&gt;</span></p>
</div>
<p>

And that's actually all you have to do.  You don't have to assign the primary key values or anything like that.  You don't need to worry about them at all.  
Take a look at the following test:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: #2b91af; }
.cb2 { color: blue; }
.cb3 { color: #a31515; }
.cb4 { color: green; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span class="cb1">Test</span>]</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">public</span> <span class="cb2">void</span> InsertsAreOnlyExecutedAtTransactionCommit()</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">var</span> insertCountBefore = sessionFactory.Statistics.EntityInsertCount;</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">using</span> (<span class="cb2">var</span> session = sessionFactory.OpenSession())</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">using</span> (<span class="cb2">var</span> transaction = session.BeginTransaction())</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">for</span> (<span class="cb2">int</span> i = 0; i &lt; 50; i++)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">var</span> category = <span class="cb2">new</span> <span class="cb1">ProductCategory</span>(<span class="cb2">string</span>.Format(<span class="cb3">"category {0}"</span>, i + 1));</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb4">// at this point, the entity doesn't have an ID value yet</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">Assert</span>.AreEqual(<span class="cb1">Guid</span>.Empty, category.Id);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; session.Save(category);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb4">// now the entity has an ID value, but we still haven't hit the database yet</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">Assert</span>.AreNotEqual(<span class="cb1">Guid</span>.Empty, category.Id);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb4">// just verifying that we haven't hit the database yet to insert the new categories</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">Assert</span>.AreEqual(insertCountBefore, sessionFactory.Statistics.EntityInsertCount);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; transaction.Commit();</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb4">// only now have the recors been inserted</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">Assert</span>.AreEqual(insertCountBefore + 50, sessionFactory.Statistics.EntityInsertCount);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Interesting, no? The entities have an ID value after they have been 'saved' by NHibernate.  But they haven't actually been saved to the database yet though.  NHibernate always tries to wait as long as possible to hit the database, and in this case it only needs to hit the database when the transaction is committed.  If you've enabled <a href="http://davybrion.com/blog/2008/10/batching-nhibernates-dm-statements/">batching of DML statements</a>, you could severly reduce the number of times you need to hit the database in this scenario.
</p>
<p>And in case you're wondering, the generated guids look like this:
</p>
<p>81cdb935-d371-4285-9dcb-9bdb0122f25f
</p>
<p>a44baf99-58e9-4ad7-9a59-9bdb0122f25f
</p>
<p>a88300c2-6d64-4ae3-a55b-9bdb0122f25f
</p>
<p>032c7884-da2f-4568-b505-9bdb0122f25f
</p>
<p>....
</p>
<p>70d7713c-b38d-4341-953d-9bdb0122f25f
</p>
<p>Notice the last part of the guids... this is what prevents the index fragmentation.
Obviously, this particular test is not a realistic scenario but i'm sure you understand how much of an improvement this identifier strategy could provide throughout an entire application.  The only downside (IMO) is that guid's aren't really human readable so if that is important to you, you should probably look into other identifier strategies.  The HiLo strategy would be particularly interesting in that case, but we'll cover that in a later post ;)</p>
