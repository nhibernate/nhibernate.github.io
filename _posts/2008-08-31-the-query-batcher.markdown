---
layout: post
title: "The Query Batcher"
date: 2008-08-31 15:05:00 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: ["query", "batcher"]
alias: ["/blogs/nhibernate/archive/2008/08/31/the-query-batcher.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>NOTE: this post was originally published on <a href="http://davybrion.com/blog/2008/06/the-query-batcher/">June 14, 2008</a></p>
<p>One of my favorite NHibernate features must be the MultiCriteria/MultiQuery support. This basically allows you to execute a set of queries in one database call. In case you don't know, an ICriteria instance is basically a programmatic query. If you use MultiCriteria, you can batch either ICriteria or DetachedCriteria instances. And if you use MultiQuery, you can batch regular HQL strings, IQuery instances (which are in fact also HQL queries) or references to named queries.
That gives you quite a few options to batch your queries. The only downside to using MultiCriteria and/or MultiQuery is that you have to retrieve the results with an index, based on the order in which you added the criteria or queries. Using index values in your code often reduces readability, so if i can i try to avoid using them.
So i wrote a little QueryBatcher class which allows me to retrieve the results based on a key value.  The class supports MultiCriteria as well as MultiQuery so you can use it to batch all kinds of queries. I didn't find a way to combine the batched criteria and the batched HQL queries in one database call, so if you mix criteria with hql queries, it will use one database call to execute all the criteria, and one database call to execute the hql queries.
</p>
<p>And now i can write code like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Test</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> ReturnsProperResultsWhenUsingMultipleQueries()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryBatcher.AddCriteria(<span style="color: #a31515;">"Products"</span>, session.CreateCriteria(<span style="color: blue;">typeof</span>(<span style="color: #2b91af;">Product</span>)));</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryBatcher.AddCriteria(<span style="color: #a31515;">"Suppliers"</span>, <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">Supplier</span>&gt;());</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryBatcher.AddHqlQuery(<span style="color: #a31515;">"ProductCategories"</span>, <span style="color: #a31515;">"from ProductCategory"</span>);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryBatcher.AddHqlQuery(<span style="color: #a31515;">"SomeProducts"</span>, </p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; session.CreateQuery(<span style="color: #a31515;">"from Product where Discontinued = :discontinued"</span>)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetBoolean(<span style="color: #a31515;">"discontinued"</span>, <span style="color: blue;">false</span>));</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.That(queryBatcher.GetEnumerableResult&lt;<span style="color: #2b91af;">Product</span>&gt;(<span style="color: #a31515;">"Products"</span>).Count() &gt; 0);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.That(queryBatcher.GetEnumerableResult&lt;<span style="color: #2b91af;">Supplier</span>&gt;(<span style="color: #a31515;">"Suppliers"</span>).Count() &gt; 0);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.That(queryBatcher.GetEnumerableResult&lt;<span style="color: #2b91af;">ProductCategory</span>&gt;(<span style="color: #a31515;">"ProductCategories"</span>).Count() &gt; 0);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.That(queryBatcher.GetEnumerableResult&lt;<span style="color: #2b91af;">Product</span>&gt;(<span style="color: #a31515;">"SomeProducts"</span>).Count() &gt; 0);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Obviously, this is a very simple example with extremely simple queries... but you can of course batch very complex queries with this as well.  You can also add queries that return scalar values so you could for instance do do something like queryBatcher.GetSingleResult&lt;long&gt;("TotalOutstandingAmount") and it would return that scalar value.
</p>
<p>This is the code of the QueryBatcher class:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: #2b91af;">QueryBatcher</span> : <span style="color: #2b91af;">IQueryBatcher</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: #2b91af;">Dictionary</span>&lt;<span style="color: blue;">string</span>, <span style="color: blue;">int</span>&gt; criteriaResultPositions;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: #2b91af;">List</span>&lt;<span style="color: #2b91af;">ICriteria</span>&gt; criteriaList;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: #2b91af;">List</span>&lt;<span style="color: #2b91af;">IQuery</span>&gt; hqlQueryList;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: #2b91af;">Dictionary</span>&lt;<span style="color: blue;">string</span>, <span style="color: blue;">int</span>&gt; queryResultPositions;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: #2b91af;">ISession</span> session;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: #2b91af;">IList</span> criteriaResults;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: #2b91af;">IList</span> queryResults;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> QueryBatcher(<span style="color: #2b91af;">IActiveSessionManager</span> activeSessionManager)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; session = activeSessionManager.GetActiveSession();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaList = <span style="color: blue;">new</span> <span style="color: #2b91af;">List</span>&lt;<span style="color: #2b91af;">ICriteria</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; hqlQueryList = <span style="color: blue;">new</span> <span style="color: #2b91af;">List</span>&lt;<span style="color: #2b91af;">IQuery</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaResultPositions = <span style="color: blue;">new</span> <span style="color: #2b91af;">Dictionary</span>&lt;<span style="color: blue;">string</span>, <span style="color: blue;">int</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryResultPositions = <span style="color: blue;">new</span> <span style="color: #2b91af;">Dictionary</span>&lt;<span style="color: blue;">string</span>, <span style="color: blue;">int</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> AddCriteria(<span style="color: blue;">string</span> key, <span style="color: #2b91af;">ICriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaList.Add(criteria);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaResultPositions.Add(key, criteriaList.Count - 1);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> AddCriteria(<span style="color: blue;">string</span> key, <span style="color: #2b91af;">DetachedCriteria</span> detachedCriteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; AddCriteria(key, detachedCriteria.GetExecutableCriteria(session));</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">object</span> GetResult(<span style="color: blue;">string</span> key)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; ExecuteQueriesIfNecessary();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">object</span> result = GetResultFromList(key, criteriaResults, criteriaResultPositions);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (result != <span style="color: blue;">null</span>) <span style="color: blue;">return</span> result;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; result = GetResultFromList(key, queryResults, queryResultPositions);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (result != <span style="color: blue;">null</span>) <span style="color: blue;">return</span> result;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> <span style="color: blue;">null</span>;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: #2b91af;">IEnumerable</span>&lt;T&gt; GetEnumerableResult&lt;T&gt;(<span style="color: blue;">string</span> key)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> list = GetResult&lt;<span style="color: #2b91af;">IList</span>&gt;(key);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> list.Cast&lt;T&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> T GetSingleResult&lt;T&gt;(<span style="color: blue;">string</span> key)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> result = GetResult&lt;<span style="color: #2b91af;">IList</span>&gt;(key);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> (T)result[0];</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> AddHqlQuery(<span style="color: blue;">string</span> key, <span style="color: #2b91af;">IQuery</span> query)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; hqlQueryList.Add(query);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryResultPositions.Add(key, hqlQueryList.Count - 1);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> AddHqlQuery(<span style="color: blue;">string</span> key, <span style="color: blue;">string</span> query)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; AddHqlQuery(key, session.CreateQuery(query));</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> ExecuteQueriesIfNecessary()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; ExecuteCriteriaIfNecessary();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; ExecuteHqlIfNecessary();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">void</span> ExecuteCriteriaIfNecessary()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (criteriaList.Count &gt; 0 &amp;&amp; criteriaResults == <span style="color: blue;">null</span>)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (criteriaList.Count == 1)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaResults = <span style="color: blue;">new</span> <span style="color: #2b91af;">ArrayList</span> { criteriaList[0].List() };</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">else</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> multiCriteria = session.CreateMultiCriteria();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaList.ForEach(c =&gt; multiCriteria.Add(c));</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteriaResults = multiCriteria.List();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">void</span> ExecuteHqlIfNecessary()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (hqlQueryList.Count &gt; 0 &amp;&amp; queryResults == <span style="color: blue;">null</span>)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (hqlQueryList.Count == 1)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryResults = <span style="color: blue;">new</span> <span style="color: #2b91af;">ArrayList</span> { hqlQueryList[0].List() };</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">else</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> multiQuery = session.CreateMultiQuery();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; hqlQueryList.ForEach(q =&gt; multiQuery.Add(q));</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; queryResults = multiQuery.List();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> T GetResult&lt;T&gt;(<span style="color: blue;">string</span> key)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> (T)GetResult(key);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">static</span> <span style="color: blue;">object</span> GetResultFromList(<span style="color: blue;">string</span> key, <span style="color: #2b91af;">IList</span> list, <span style="color: #2b91af;">IDictionary</span>&lt;<span style="color: blue;">string</span>, <span style="color: blue;">int</span>&gt; positions)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (positions.ContainsKey(key)) <span style="color: blue;">return</span> list[positions[key]];</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> <span style="color: blue;">null</span>;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; }</p>
</div>
