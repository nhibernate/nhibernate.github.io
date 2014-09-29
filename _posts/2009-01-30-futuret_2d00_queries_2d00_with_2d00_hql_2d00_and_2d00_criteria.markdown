---
layout: post
title: "Future&lt;T&gt; Queries with HQL and Criteria"
date: 2009-01-30 16:10:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NH2.1", "querying", "HQL", "Criteria", "Future"]
alias: ["/blogs/nhibernate/archive/2009/01/30/futuret_2D00_queries_2D00_with_2D00_hql_2D00_and_2D00_criteria.aspx", "/blogs/nhibernate/archive/2009/01/30/futuret_2d00_queries_2d00_with_2d00_hql_2d00_and_2d00_criteria.aspx"]
author: darioquintana
gravatar: f436801727b13a5c4c4a38380fc17290
---
{% include imported_disclaimer.html %}
<p>A few days ago Oren Eini and Davy Brion were working in a new feature for NH 2.1 (no a release yet) called Future, in the <i>ICriteria</i> API. You can see and explanation of the job <a href="/blogs/nhibernate/archive/2009/01/25/nhibernate-and-future-queries.aspx">here</a>. Now I&rsquo;ve committed a complement to enable that use into the <i>IQuery</i> API, for those who prefer to use HQL.</p>
<p>What is Future Query anyway? Future are queries that are kept, waiting to be executed as a group in just one roundtrip, making use of an underlying NHibernate feature: <i>MultiCriteria/MultiQuery</i>.</p>
<p>Let&rsquo;s have a look to this simple piece of code. You can see both queries sentences, and both are executed in that sentence point against the database producing 2 roundtrips to the database. Nothing weird about this, but what if we can just execute the queries in just one roundtrip?</p>
<p><img src="http://darioquintana.com.ar/files/future01.png" /> </p>
<p>And now, using Future we can hold the execution, in this case just two, but we can hold how many queries we need. </p>
<p>Where is the trick? <i>Future</i> method is returning a delayed enumerable implementation, that&rsquo;s all. When you iterate the enumerable (with a <i>foreach</i> for example), it detects and execute all the queries using a NHibernate-MultiQuery command (could be a MultiCriteria, it depends what we are using). But we don&rsquo;t need to know nothing about the underlying implementation, just the concept.</p>
<p><img src="http://darioquintana.com.ar/files/future02.png" /> </p>
<p>In other terms, this is what happens behind the scenes:</p>
<p><img src="http://darioquintana.com.ar/files/future03.png" /> </p>
<p>But what if we want to retrieve an entity or a scalar ? This is too simple for an IEnumerable. Thanks to Davy Brion we have another feature called FutureValue. The mechanism is the same as Future, but instead of expect a IEnumerable, we obtain a single value (an entity or a scalar).</p>
<p><img src="http://darioquintana.com.ar/files/future04.png" /></p>
<p><b>Note</b>: examples adapted from Davy Brion posts <a href="http://davybrion.com/blog/2009/01/nhibernate-and-future-queries/">[1]</a> and <a href="http://davybrion.com/blog/2009/01/nhibernate-and-future-queries-part-2/">[2]</a>.</p>
