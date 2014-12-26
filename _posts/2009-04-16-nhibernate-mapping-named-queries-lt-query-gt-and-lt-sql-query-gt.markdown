---
layout: post
title: "NHibernate Mapping – Named queries &lt;query/&gt; and &lt;sql-query/&gt;"
date: 2009-04-16 22:55:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/17/nhibernate-mapping-named-queries-lt-query-gt-and-lt-sql-query-gt.aspx/"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>Queries are <a href="http://ayende.com/Blog/archive/2007/03/09/Querying-is-a-business-concern.aspx">business</a> <a href="http://ayende.com/Blog/archive/2007/03/12/Querying-Is-A-Business-Concern-Sample.aspx">logic</a>, as such, they can be pretty complex, and they also tend to be pretty perf sensitive. As such, you usually want to have a good control over any complex queries. You can do that by extracting your queries to the mapping, so they don’t reside, hardcoded, in the code:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">query</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PeopleByName&quot;</span><span style="color: #0000ff">&gt;</span>
	from Person p
	where p.Name like :name
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">query</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And you can execute it with:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	session.GetNamedQuery(&quot;<span style="color: #8b0000">PeopleByName</span>&quot;)
		.SetParameter(&quot;<span style="color: #8b0000">name</span>&quot;, &quot;<span style="color: #8b0000">ayende</span>&quot;)
		.List();
	tx.Commit();
}</pre>
</blockquote>

<p>PeopleByName is a pretty standard query, and executing this code will result in:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_736FFE74.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="190" alt="image" src="/images/posts/2009/04/16/image_5F00_thumb_5F00_31494399.png" width="340" border="0" /></a> </p>

<p>Now, let us say that we discovered some performance problem in this query, and we want to optimize it. But the optimization is beyond what we can do with HQL, we have to drop to a database specific SQL for that. Well, that is not a problem, &lt;sql-query/&gt; is coming to the rescue.</p>

<p>All you need is to replace the query above with:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">sql</span>-<span style="color: #ff0000">query</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PeopleByName&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">return</span> <span style="color: #ff0000">alias</span>=<span style="color: #0000ff">&quot;person&quot;</span>
					<span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Person&quot;</span><span style="color: #0000ff">/&gt;</span>
	SELECT {person.*}
	FROM People {person} WITH(nolock)
	WHERE {person}.Name LIKE :name
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">sql</span>-query<span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And you are set. You don’t need to make any changes to the code, but the resulting SQL would be:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_13FB9DE2.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="189" alt="image" src="/images/posts/2009/04/16/image_5F00_thumb_5F00_72377763.png" width="323" border="0" /></a> </p>

<p>Fun, isn’t it?</p>
