---
layout: post
title: "Tuning NHibernate: Tolerant QueryCache"
date: 2009-04-18 00:05:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["caches", "NHibernate"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/17/tuning-nhibernate-tolerant-querycache.aspx"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>[From <a href="http://fabiomaulo.blogspot.com/">My Blog</a>]</p>
<p>Before reading this post you should know something about <a href="/doc/nh/en/index.html#performance-querycache">QueryCache</a> and its imply tuning NH.</p>
<p>Resuming:</p>
<ul>
<li>Using <strong><span style="color: #2b91af">IQuery</span>.SetCacheable(<span style="color: #0000ff">true</span>)</strong> you can put/get the entirely result of a query from the cache. </li>
<li>The cache is automatically invalidated when the <em>query-space</em> change (mean that the cache will be throw when an Insert/Update/Delete is executed for one of the Tables involved in the query). </li>
<li>Using <strong><span style="color: #2b91af">IQuery</span>.SetCacheMode(<span style="color: #2b91af">CacheMode</span>.Refresh)</strong> you can force the cache refresh (for example if you need to refresh the cache after a Delete/Insert). </li>
</ul>
<h4>The Case</h4>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/eBayShot_5F00_5611DE5B.png"><img border="0" width="688" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/eBayShot_5F00_thumb_5F00_73AB6B6D.png" alt="eBayShot" height="505" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" title="eBayShot" /></a> </p>
<p>(the picture is a <a href="http://www.ebay.com/">e-Bay</a> snapshot)</p>
<p>Take a look to the left side. Near each option you can see a number and I&rsquo;m pretty sure that it not reflect exactly the state in the DB. That number is only <em>&ldquo;an orientation&rdquo;</em> for the user probably calculated few minutes before. </p>
<p>Now, think about the SQLs, behind the scene, and how many and how much heavy they are. A possible example for <em>&ldquo;Album Type&rdquo;, </em>using HQL, could look like:</p>
<p><em>select musicCD.AlbumType.Name, count(*) from MusicCD musicCD where musicCD.Genre = &lsquo;Classical&rsquo; group by musicCD.AlbumType.Name</em></p>
<p>How much time need each &ldquo;Refine search&rdquo; ?</p>
<p>Ah&hellip; but there is no problem, I&rsquo;m using NHibernate and its QueryCache&hellip; hmmmm&hellip;</p>
<p>Now, suppose that each time you click an article you are incrementing the number of visits of that article. What happen to your <em>QueryCache</em> ? yes, each click the <em>QueryCache</em> will be invalidated and thrown (the same if some users in the world insert/update/delete something in the tables involved).</p>
<h4>The Tolerant QueryCache abstract</h4>
<p>The Tolerant QueryCache should be an implementation of <span style="color: #2b91af">IQueryCache</span> which understands, through its configuration properties, that updates, to certain tables, should not invalidate the cache of queries based on those tables.</p>
<p>Taken the above example mean that an update to <em>MusicCD </em>does not invalidate all &ldquo;<em>Refine search</em>&rdquo; queries, if we are caching those statistics heavy queries.</p>
<h4>The integration point</h4>
<p>Well&hellip; at this point you should know how much NHibernate is extensible and &ldquo;injectable&rdquo;.</p>
<p>For each <em>cache-region</em> NHibernate create an instance of <span style="color: #2b91af">IQueryCache</span> trough an implementation of <span style="color: #2b91af">IQueryCacheFactory</span> and, as you could imagine, the <span style="color: #2b91af">IQueryCacheFactory</span> concrete implementation can be injected trough session-factory configuration.</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">cache.query_cache_factory</span>"<span style="color: blue">&gt;</span>YourQueryCacheFactory<span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;</span></pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>At this point we know all we should do to have our <span style="color: #2b91af">TolerantQueryCache</span> :</p>
<ol>
  <br />
<li>Some configuration classes to configure tolerated tables for certain regions. </li>
<li>An implementation of <span style="color: #2b91af">IQueryCacheFactory</span> to use the <span style="color: #2b91af">TolerantQueryCache</span> for certain regions. </li>
<li>The implementation of <span style="color: #2b91af">TolerantQueryCache</span>. </li>
</ol>
<h4>The Test</h4>
<p>Here is only the integration test; all implementations are available in <a href="http://code.google.com/p/unhaddins/">uNhAddIns</a>.</p>
<h5>Domain</h5>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">MusicCD<br /></span>{<br /> <span style="color: blue">public virtual string </span>Name { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br />}<br /><br /><span style="color: blue">public class </span><span style="color: #2b91af">Antique<br /></span>{<br /> <span style="color: blue">public virtual string </span>Name { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">MusicCD</span>" <span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">MusicCDs</span>"<span style="color: blue">&gt;<br /> &lt;</span><span style="color: #a31515">id </span><span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">int</span>"<span style="color: blue">&gt;<br />     &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">hilo</span>"<span style="color: blue">/&gt;<br /> &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;<br /> &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Name</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;<br /><br />&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Antique</span>" <span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">Antiques</span>"<span style="color: blue">&gt;<br /> &lt;</span><span style="color: #a31515">id </span><span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">int</span>"<span style="color: blue">&gt;<br />     &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">hilo</span>"<span style="color: blue">/&gt;<br /> &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;<br /> &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Name</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;</span></pre>
<h5>Configuration</h5>
<pre class="code"><span style="color: blue">public override void </span>Configure(NHibernate.Cfg.<span style="color: #2b91af">Configuration </span>configuration)<br />{<br /> <span style="color: blue">base</span>.Configure(configuration);<br /> configuration.SetProperty(<span style="color: #2b91af">Environment</span>.GenerateStatistics, <span style="color: #a31515">"true"</span>);<br /> configuration.SetProperty(<span style="color: #2b91af">Environment</span>.CacheProvider,<br />     <span style="color: blue">typeof</span>(<span style="color: #2b91af">HashtableCacheProvider</span>).AssemblyQualifiedName);<br /><br /> configuration.QueryCache()<br />     .ResolveRegion(<span style="color: #a31515">"SearchStatistics"</span>)<br />     .Using&lt;<span style="color: #2b91af">TolerantQueryCache</span>&gt;()<br />     .TolerantWith(<span style="color: #a31515">"MusicCDs"</span>);<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>The configuration is only for the <em>&ldquo;SearchStatistics&rdquo;</em> region so others regions will work with the default NHibernate implementation. <strong>NOTE</strong>: the <span style="color: #2b91af">HashtableCacheProvider</span> is valid only for tests.</p>
<h5>The test</h5>
<pre class="code"><span style="color: green">// Fill DB<br /></span>SessionFactory.EncloseInTransaction(session =&gt;<br />{<br /> <span style="color: blue">for </span>(<span style="color: blue">int </span>i = 0; i &lt; 10; i++)<br /> {<br />     session.Save(<span style="color: blue">new </span><span style="color: #2b91af">MusicCD </span>{ Name = <span style="color: #a31515">"Music" </span>+ (i / 2) });<br />     session.Save(<span style="color: blue">new </span><span style="color: #2b91af">Antique </span>{ Name = <span style="color: #a31515">"Antique" </span>+ (i / 2) });<br /> }<br />});<br /><br /><span style="color: green">// Queries<br /></span><span style="color: blue">var </span>musicQuery =<br /> <span style="color: blue">new </span><span style="color: #2b91af">DetachedQuery</span>(<span style="color: #a31515">"select m.Name, count(*) from MusicCD m group by m.Name"</span>)<br /> .SetCacheable(<span style="color: blue">true</span>)<br /> .SetCacheRegion(<span style="color: #a31515">"SearchStatistics"</span>);<br /><br /><span style="color: blue">var </span>antiquesQuery =<br /> <span style="color: blue">new </span><span style="color: #2b91af">DetachedQuery</span>(<span style="color: #a31515">"select a.Name, count(*) from Antique a group by a.Name"</span>)<br /> .SetCacheable(<span style="color: blue">true</span>)<br /> .SetCacheRegion(<span style="color: #a31515">"SearchStatistics"</span>);<br /><br /><span style="color: green">// Clear SessionFactory Statistics<br /></span>SessionFactory.Statistics.Clear();<br /><br /><span style="color: green">// Put in second-level-cache<br /></span>SessionFactory.EncloseInTransaction(session =&gt;<br />{<br /> musicQuery.GetExecutableQuery(session).List();<br /> antiquesQuery.GetExecutableQuery(session).List();<br />});<br /><br /><span style="color: green">// Asserts after execution<br /></span>SessionFactory.Statistics.QueryCacheHitCount<br /> .Should(<span style="color: #a31515">"not hit the query cache"</span>).Be.Equal(0);<br /><br />SessionFactory.Statistics.QueryExecutionCount<br /> .Should(<span style="color: #a31515">"execute both queries"</span>).Be.Equal(2);<br /><br /><span style="color: green">// Update both tables<br /></span>SessionFactory.EncloseInTransaction(session =&gt;<br />{<br /> session.Save(<span style="color: blue">new </span><span style="color: #2b91af">MusicCD </span>{ Name = <span style="color: #a31515">"New Music" </span>});<br /> session.Save(<span style="color: blue">new </span><span style="color: #2b91af">Antique </span>{ Name = <span style="color: #a31515">"New Antique" </span>});<br />});<br /><br /><span style="color: green">// Clear SessionFactory Statistics again<br /></span>SessionFactory.Statistics.Clear();<br /><br /><span style="color: green">// Execute both queries again<br /></span>SessionFactory.EncloseInTransaction(session =&gt;<br />{<br /> musicQuery.GetExecutableQuery(session).List();<br /> antiquesQuery.GetExecutableQuery(session).List();<br />});<br /><br /><span style="color: green">// Asserts after execution<br /></span>SessionFactory.Statistics.QueryCacheHitCount<br /> .Should(<span style="color: #a31515">"Hit the query cache"</span>).Be.Equal(1);<br /><br />SessionFactory.Statistics.QueryExecutionCount<br /> .Should(<span style="color: #a31515">"execute only the query for Antiques"</span>).Be.Equal(1);</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>Fine! I have changed both tables but in the second execution the result for MusicCD come from the Cache.</p>
<p>&nbsp;</p>
<p>Code available <a href="http://code.google.com/p/unhaddins/">here</a>.</p>
