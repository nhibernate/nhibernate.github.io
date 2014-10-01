---
layout: post
title: "NHibernate and Future Queries"
date: 2009-01-25 12:08:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NH2.1", "Future"]
redirect_from: ["/blogs/nhibernate/archive/2009/01/25/nhibernate-and-future-queries.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>As some of you already know, i'm a big fan of avoiding excessive roundtrips by batching queries and/or service calls.  For NHibernate, i wrote the <a href="http://davybrion.com/blog/2008/06/the-query-batcher/">QueryBatcher</a> class which makes this pretty easy to do.  Ayende recently added a much easier approach for this to NHibernate.  
</p>
<p>Take a look at the following code:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #2b91af; }
.cb3 { color: green; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">using</span> (<span class="cb2">ISession</span> session = sessionFactory.OpenSession())</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// this executes the first query</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">var</span> categories = session.CreateCriteria(<span class="cb1">typeof</span>(<span class="cb2">ProductCategory</span>)).List();&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; </p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// this executes the second query</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">var</span> suppliers = session.CreateCriteria(<span class="cb1">typeof</span>(<span class="cb2">Supplier</span>)).List();</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">foreach</span> (<span class="cb1">var</span> category <span class="cb1">in</span> categories)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// do something</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">foreach</span> (<span class="cb1">var</span> supplier <span class="cb1">in</span> suppliers)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// do something</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

This is a really trivial example, but it should be more than sufficient.  It simply executes two very simple queries and loops through the results to do something with each returned entity.  The problem, obviously, is that this hits the database twice while there really is no good reason for doing so.
</p>
<p>With the new Future feature we can rewrite that code like this:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #2b91af; }
.cb3 { color: green; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">using</span> (<span class="cb2">ISession</span> session = sessionFactory.OpenSession())</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// this creates the first query</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">var</span> categories = session.CreateCriteria(<span class="cb1">typeof</span>(<span class="cb2">ProductCategory</span>)).Future&lt;<span class="cb2">ProductCategory</span>&gt;();</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// this creates the second query</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">var</span> suppliers = session.CreateCriteria(<span class="cb1">typeof</span>(<span class="cb2">Supplier</span>)).Future&lt;<span class="cb2">Supplier</span>&gt;();</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// this causes both queries to be sent in ONE roundtrip</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">foreach</span> (<span class="cb1">var</span> category <span class="cb1">in</span> categories)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// do something</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// this doesn't do anything because the suppliers have already been loaded</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">foreach</span> (<span class="cb1">var</span> supplier <span class="cb1">in</span> suppliers)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">// do something</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Apart from the comments, did you spot the difference? Instead of calling ICriteria's List method (which causes the query to be executed immediately), we call ICriteria's Future method.  This returns an IEnumerable of the type you provided to the Future method.  And this is where it gets interesting.  Instead of executing the queries immediately, the queries are added to an instance of NHibernate's already existing MultiCriteria class.  Only once you enumerate through one of the retrieved IEnumerables will all the (queued) Future queries be executed, in a single roundtrip.  Once they are executed, their result is final (as in: enumerating through the IEnumerable will not cause the query to be executed again).
</p>
<p>The example used here is obviously very trivial, but you can use this with any ICriteria so you can very easily start batching your complex queries as well.  The kind of query doesn't really matter, as long as it's an ICriteria instance.
</p>
<p>
This feature will be available in NHibernate 2.1, or if you're using the trunk you can use it starting with revision 3999.</p>
