---
layout: post
title: "NHibernate mapping - &lt;database-object/&gt;"
date: 2009-04-15 22:47:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/16/nhibernate-mapping-lt-database-object-gt.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>I, like many, have grown used to NHibernate’s schema generation capabilities. Those make working with databases such a pleasure that I cannot imagine trying without them.</p>  <p>However, at some point, even NHibernate’s smarts reach an end, and such an occasion requires the use of direct SQL to manipulate the database directly. A good example of that would be:</p>  <blockquote>   <pre><span style="color: #008000">&lt;!-- SQL Server need this index --&gt;</span>
<span style="color: #0000ff">&lt;</span><span style="color: #800000">database</span>-<span style="color: #ff0000">object</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">create</span><span style="color: #0000ff">&gt;</span>
	CREATE INDEX PeopleByCityAndLastName ...
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">create</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">drop</span><span style="color: #0000ff">&gt;</span>
	DROP INDEX PeopleByCityAndLastName 
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">drop</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">dialect</span>-<span style="color: #ff0000">scope</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;NHibernate.Dialect.MsSql2000Dialect&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">dialect</span>-<span style="color: #ff0000">scope</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;NHibernate.Dialect.MsSql2005Dialect&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">dialect</span>-<span style="color: #ff0000">scope</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;NHibernate.Dialect.MsSql2008Dialect&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">database</span>-object<span style="color: #0000ff">&gt;</span>

<span style="color: #008000">&lt;!-- Oracle need this stats only --&gt;</span>
<span style="color: #0000ff">&lt;</span><span style="color: #800000">database</span>-<span style="color: #ff0000">object</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">create</span><span style="color: #0000ff">&gt;</span>
	CREATE STATISTICS PeopleByCityAndLastName ...
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">create</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">drop</span><span style="color: #0000ff">&gt;</span>
	DROP STATISTICS PeopleByCityAndLastName 
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">drop</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">dialect</span>-<span style="color: #ff0000">scope</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;NHibernate.Dialect.OracleDialect&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">dialect</span>-<span style="color: #ff0000">scope</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;NHibernate.Dialect.Oracle9Dialect&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">database</span>-object<span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>As you can see, this allows us to execute database specific SQL, using the dialect scope. It is not a common feature, but it can be incredibly useful.</p>
