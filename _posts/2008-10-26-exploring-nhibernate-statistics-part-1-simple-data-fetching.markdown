---
layout: post
title: "Exploring NHibernate Statistics, Part 1: Simple Data Fetching"
date: 2008-10-26 18:52:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["statistics"]
redirect_from: ["/blogs/nhibernate/archive/2008/10/26/exploring-nhibernate-statistics-part-1-simple-data-fetching.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>Note: this was originally posted on my <a target="_blank" href="http://davybrion.com/blog/2008/10/exploring-nhibernate-statistics-part-1-simple-data-fetching/">own blog</a></p>
<p>One of the new features that NHibernate 2.0 introduced is NHibernate Statistics. This feature can be pretty useful during development (or while debugging) to keep an eye on what NHibernate is doing.  Not a lot of people know about this feature, so i've decided to write a short series of posts about it.  In this first episode, we'll explore some stats which can show you some useful information regarding the efficiency of your (simple) data fetching strategies.  Later episodes will cover insert/update/delete statistics, query specific statistics and caching statistics.  I don't know yet when the other episodes will be posted, but they are definitely on my TODO list so they will get written eventually ;)
</p>
<p>First of all, here's how you can enable this feature. In your hibernate.cfg.xml file, you can add the following setting within the session-factory element.
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">property</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">generate_statistics</span>"<span style="color: blue;">&gt;</span>true<span style="color: blue;">&lt;/</span><span style="color: #a31515;">property</span><span style="color: blue;">&gt;</span></p>
</div>
<p>

Now, there are two levels of statistics. The first is at the level of the SessionFactory. These statistics basically keep count of everything that happens for each Session that was created by the SessionFactory.  You can access these stats through the Statistics property of the SessionFactory instance, which you can access from your Session instance if you don't have a reference to the SessionFactory, for instance:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> count = Session.SessionFactory.Statistics.EntityFetchCount;</p>
</div>
<p>
 
To give you an idea of what kind of stats are available on the SessionFactory level, here's a quick listing of most of the available properties: </p>
<p>EntityDeleteCount, EntityInsertCount, EntityLoadCount, EntityFetchCount, EntityUpdateCount, QueryExecutionCount, QueryExecutionMaxTime, QueryCacheHitCount, QueryCacheMissCount, QueryCachePutCount, FlushCount, ConnectCount, SecondLevelCacheHitCount, SecondLevelCacheMissCount, SecondLevelCachePutCount, SessionCloseCount, SessionOpenCount, CollectionLoadCount, CollectionFetchCount, CollectionUpdateCount, CollectionRemoveCount, CollectionRecreateCount, SuccessfulTransactionCount, TransactionCount, PrepareStatementCount, CloseStatementCount, OptimisticFailureCount.
</p>
<p>There are even more properties and methods available. For instance to retrieve the executed queries, statistics for a specific query, statistics for a specific entity type, for a specific collection role, and to get the second level cache statistics for a specific cache region. 
As you can see, lots of useful properties to help you examine where your NHibernate usage might not be the way it should be. Or just useful in case you're tying to figure out what kind of stuff NHibernate is doing behind the scenes for features you don't fully understand and want to experiment with.  There's also a useful LogSummary() method which (obviously) logs a summary of these stats to NHibernate's logger.
</p>
<p>Let's get into a couple of examples that will tell us more about the efficiency of our simple data access strategies. We'll start with some really simple stuff, and then move to some more interesting statistics.
</p>
<p>
For brevity, i'm using the following simple property to quickly access the SessionFactory's statistics:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: #2b91af;">IStatistics</span> GlobalStats</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">get</span> { <span style="color: blue;">return</span> Session.SessionFactory.Statistics; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

For the first example, we'll retrieve all of the records in the Product table. After fetching this result, the EntityLoadCount statistic will reflect the number of entities we've loaded:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Test</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> TestEntityLoadCount()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">long</span> entityLoadCountBefore = GlobalStats.EntityLoadCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> allProducts = Session.CreateCriteria(<span style="color: blue;">typeof</span>(<span style="color: #2b91af;">Product</span>)).List&lt;<span style="color: #2b91af;">Product</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(entityLoadCountBefore + allProducts.Count, GlobalStats.EntityLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

What happens if we start using NHibernate's lazy loading features? For instance, if we access a Product's Category reference NHibernate has to retrieve that record from the database if it's not already loaded. Does this count as an EntityLoad, or an EntityFetch?  It counts as both an EntityLoad and an EntityFetch actually:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Test</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> TestEntityFetchCountForManyToOnePropertiesWithLazyLoading()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">long</span> entityLoadCountBefore = GlobalStats.EntityLoadCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">long</span> entityFetchCountBefore = GlobalStats.EntityFetchCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> allProducts = Session.CreateCriteria(<span style="color: blue;">typeof</span>(<span style="color: #2b91af;">Product</span>)).List&lt;<span style="color: #2b91af;">Product</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> product <span style="color: blue;">in</span> allProducts)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// this makes NHibernate fetch the Category from the database</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> categoryName = product.Category.Name;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> entitiesFetched = GlobalStats.EntityFetchCount - entityFetchCountBefore;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(entityLoadCountBefore + allProducts.Count + entitiesFetched, GlobalStats.EntityLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.That(entitiesFetched != 0);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

With the data in my database, this test loads 77 Product entities, and fetches 8 Categories for a total of 85 loaded entities.  The Product entities are loaded in one roundtrip, but for each Category another roundtrip is performed which is not ideal from a performance perspective.  The stats actually reflect that through the PrepareStatementCount property.  Let's modify the previous test to highlight this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> entitiesFetched = GlobalStats.EntityFetchCount - entityFetchCountBefore;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(entityLoadCountBefore + allProducts.Count + entitiesFetched, GlobalStats.EntityLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(entitiesFetched + 1, GlobalStats.PrepareStatementCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.That(entitiesFetched != 0);</p>
</div>
<p>

We get the count of the fetched entities, and add 1 to it to reflect the roundtrip to fetch all the products. This total equals the value of the PrepareStatementCount property.
This example shows that it can be pretty important to try to keep the EntityFetchCount and PrepareStatementCount property values as low as possible when you need to fix a performance problem.  Let's give it a shot:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Test</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> TestEntityFetchCountForManyToOnePropertiesWithoutLazyLoading()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">long</span> entityFetchCountBefore = GlobalStats.EntityFetchCount;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> allProducts = Session.CreateCriteria(<span style="color: blue;">typeof</span>(<span style="color: #2b91af;">Product</span>))</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .CreateCriteria(<span style="color: #a31515;">"Category"</span>, <span style="color: #2b91af;">JoinType</span>.InnerJoin)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .List&lt;<span style="color: #2b91af;">Product</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> product <span style="color: blue;">in</span> allProducts)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// the Categories have already been retrieved, so this doesn't cause a db roundtrip</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> categoryName = product.Category.Name;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> entitiesFetched = GlobalStats.EntityFetchCount - entityFetchCountBefore;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(1, GlobalStats.PrepareStatementCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(0, entitiesFetched);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Instead of fetching all of the Products and then relying on NHibernate's lazy loading to fetch the Categories, we fetch all of them in one go. The result is that NHibernate only performs one DB statement and it still loads all 85 records. 
</p>
<p>These statistics are nice if you just want to get information about loading entities, but what about collections? Well, we can use the CollectionLoadCount and CollectionFetchCount properties for this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Test</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> TestCountsForOneToManyPropertyWithLazyLoading()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> loadCountBefore = GlobalStats.EntityLoadCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> collectionLoadCountBefore = GlobalStats.CollectionLoadCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> collectionFetchCountBefore = GlobalStats.CollectionFetchCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> prepareStatementCountBefore = GlobalStats.PrepareStatementCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> allRegions = Session.CreateCriteria(<span style="color: blue;">typeof</span>(<span style="color: #2b91af;">Region</span>)).List&lt;<span style="color: #2b91af;">Region</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> territoryCount = 0;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> region <span style="color: blue;">in</span> allRegions)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// uses lazy-loading to fetch the Territories for this region</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; territoryCount += region.Territories.Count();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(loadCountBefore + allRegions.Count + territoryCount, GlobalStats.EntityLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(collectionLoadCountBefore + allRegions.Count, GlobalStats.CollectionLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(collectionFetchCountBefore + allRegions.Count, GlobalStats.CollectionFetchCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(prepareStatementCountBefore + allRegions.Count + 1, GlobalStats.PrepareStatementCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Btw, using the Count() result of the Territories property is something i'd never do, but i'm just using it here to illustrate these stats. In this case, we have 4 Regions, which we retrieve in one roundtrip, and then we fetch each Region's Territories in seperate trips which brings the total of PrepareStatementCount up to 5.  As you can see, the CollectionLoadCount is equal to the CollectionFetchCount.  In some cases, it can be better to retrieve the Territories while we're also retrieving the Regions:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Test</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> TestCountsForManyToOnePropertyWithoutLazyLoading()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> loadCountBefore = GlobalStats.EntityLoadCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> collectionLoadCountBefore = GlobalStats.CollectionLoadCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> collectionFetchCountBefore = GlobalStats.CollectionFetchCount;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> prepareStatementCountBefore = GlobalStats.PrepareStatementCount;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> allRegions = Session.CreateCriteria(<span style="color: blue;">typeof</span>(<span style="color: #2b91af;">Region</span>))</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetFetchMode(<span style="color: #a31515;">"Territories"</span>, <span style="color: #2b91af;">FetchMode</span>.Join)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetResultTransformer(<span style="color: #2b91af;">CriteriaUtil</span>.DistinctRootEntity)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .List&lt;<span style="color: #2b91af;">Region</span>&gt;();</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> territoryCount = 0;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> region <span style="color: blue;">in</span> allRegions)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// the Territories have already been retrieved, so this doesn't use lazy-loading</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; territoryCount += region.Territories.Count();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(loadCountBefore + allRegions.Count + territoryCount, GlobalStats.EntityLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(collectionLoadCountBefore + allRegions.Count, GlobalStats.CollectionLoadCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(collectionFetchCountBefore, GlobalStats.CollectionFetchCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">Assert</span>.AreEqual(prepareStatementCountBefore + 1, GlobalStats.PrepareStatementCount);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

With this code, there's only one roundtrip, yet all of the Regions and their Territories are loaded.  This approach won't always be better than retrieving the collections seperately though... it kinda depends on the size and shape of the resultset of the joined query compared to the size and shapes of the resultsets of retrieving the root entities and their child collections seperately.
</p>
<p>This post only showed a couple of the (many) interesting statistics that NHibernate can give you, but it could already help you troubleshoot bad-performing parts of your application.  Keep an eye on those EntityFetchCount and PrepareStatementCount values... If the EntityFetchCount is rather low compared to the total EntityLoadCount, then there's probably nothing bad going on.  If the EntityFetchCount is a rather large percentage of the total EntityLoadCount value, then you can be pretty sure that you can get some solid performance improvements in the code that drives up the EntityFetchCount value.</p>
