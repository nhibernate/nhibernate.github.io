---
layout: post
title: "NHibernate’s Future Queries And Their Fallback Behavior"
date: 2009-04-13 18:09:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/04/13/nhibernate-s-future-queries-and-their-fallback-behavior.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>I've blogged about NHibernate's Future queries a <a href="http://davybrion.com/blog/2009/01/nhibernate-and-future-queries/">couple</a> <a href="http://davybrion.com/blog/2009/01/nhibernate-and-future-queries-part-2/">of</a> <a href="http://davybrion.com/blog/2009/04/transparent-query-batching-through-your-repository/">times</a> already.  But as you know, NHibernate aims to offer you a way to write your code completely independent of the actual database you're using.  So what happens if you run your code, which is using the Future and FutureValue features, on a database that doesn't support batched queries?  Previously, this would fail with a NotSupportedException being thrown.
</p>
<p>As of today, (revision 4177 if you want to be specific) this is no longer the case.  If you use the Future or FutureValue methods of either ICriteria or IQuery, and the database doesn't support batching queries, NHibernate will fall back to simply executing the queries immediately, as the following tests show:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: #2b91af; }
.cb2 { color: blue; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span class="cb1">Test</span>]</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">public</span> <span class="cb2">void</span> FutureOfCriteriaFallsBackToListImplementationWhenQueryBatchingIsNotSupported()</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">using</span> (<span class="cb2">var</span> session = sessions.OpenSession())</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">var</span> results = session.CreateCriteria&lt;<span class="cb1">Person</span>&gt;().Future&lt;<span class="cb1">Person</span>&gt;();</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; results.GetEnumerator().MoveNext();</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: #2b91af; }
.cb2 { color: blue; }
.cb3 { color: #a31515; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span class="cb1">Test</span>]</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">public</span> <span class="cb2">void</span> FutureValueOfCriteriaCanGetSingleEntityWhenQueryBatchingIsNotSupported()</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">int</span> personId = CreatePerson();</p>
<p class="cl">&nbsp;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">using</span> (<span class="cb2">var</span> session = sessions.OpenSession())</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb2">var</span> futurePerson = session.CreateCriteria&lt;<span class="cb1">Person</span>&gt;()</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span class="cb1">Restrictions</span>.Eq(<span class="cb3">"Id"</span>, personId))</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .FutureValue&lt;<span class="cb1">Person</span>&gt;();</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">Assert</span>.IsNotNull(futurePerson.Value);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>
There are more tests obviously, but you get the point.  The interesting part about these tests is how i disabled query batching support.  I only have Sql Server and MySQL running on this machine, and they both support query batching.  I didn't really feel like installing a database that doesn't support it, so i just took advantage of NHibernate's extensibility.  Since most of us run the NHibernate tests on Sql Server, i inherited from the Sql Server Driver and made sure that it would report to NHibernate that it didn't support query batching:
<code>
<style type="text/css"><!--
.cf { font-family: Consolas; font-size: 9pt; color: black; background: white; }
.cl { margin: 0px; }
.cb1 { color: blue; }
.cb2 { color: #2b91af; }
--></style>
</code></p>
<div class="cf">
<p class="cl">&nbsp;&nbsp;&nbsp; <span class="cb1">public</span> <span class="cb1">class</span> <span class="cb2">TestDriverThatDoesntSupportQueryBatching</span> : <span class="cb2">SqlClientDriver</span></p>
<p class="cl">&nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">public</span> <span class="cb1">override</span> <span class="cb1">bool</span> SupportsMultipleQueries</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">get</span> { <span class="cb1">return</span> <span class="cb1">false</span>; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p class="cl">&nbsp;&nbsp;&nbsp; }</p>
</div>
<p>
Easy huh? Then i just inherited from the TestCase class we have in the NHibernate.Tests project which offers a virtual method where you can modify the NHibernate configuration for the current fixture:
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
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">protected</span> <span class="cb1">override</span> <span class="cb1">void</span> Configure(<span class="cb2">Configuration</span> configuration)</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; configuration.Properties[<span class="cb2">Environment</span>.ConnectionDriver] = </p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb3">"NHibernate.Test.NHSpecificTest.Futures.TestDriverThatDoesntSupportQueryBatching, NHibernate.Test"</span>;</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span class="cb1">base</span>.Configure(configuration);</p>
<p class="cl">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>
Now NHibernate thinks that query batching isn't supported, yet the above tests still work.  Mission accomplished :)</p>
