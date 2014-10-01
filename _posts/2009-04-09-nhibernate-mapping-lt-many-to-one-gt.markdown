---
layout: post
title: "NHibernate Mapping - &lt;many-to-one/&gt;"
date: 2009-04-09 03:22:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/04/09/nhibernate-mapping-lt-many-to-one-gt.aspx/"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>Next up for inspection is the &lt;many-to-one/&gt; element. This element is defined as:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">many</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span>
        <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PropertyName&quot;</span>                                (<span style="color: #ff0000">1</span>)
        <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;column_name&quot;</span>                               (<span style="color: #ff0000">2</span>)
        <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;ClassName&quot;</span>                                  (<span style="color: #ff0000">3</span>)
        <span style="color: #ff0000">cascade</span>=<span style="color: #0000ff">&quot;all|none|save-update|delete&quot;</span>              (<span style="color: #ff0000">4</span>)
        <span style="color: #ff0000">fetch</span>=<span style="color: #0000ff">&quot;join|select&quot;</span>                                (<span style="color: #ff0000">5</span>)
        <span style="color: #ff0000">update</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                                (<span style="color: #ff0000">6</span>)
        <span style="color: #ff0000">insert</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                                (<font color="#ff0000">7</font>)
        <span style="color: #ff0000">property</span>-<span style="color: #ff0000">ref</span>=<span style="color: #0000ff">&quot;PropertyNameFromAssociatedClass&quot;</span>     (<font color="#ff0000">8</font>)
        <span style="color: #ff0000">access</span>=<span style="color: #0000ff">&quot;field|property|nosetter|ClassName&quot;</span>         (<font color="#ff0000">9</font>)
        <span style="color: #ff0000">unique</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                                (<font color="#ff0000">10</font>)
        <span style="color: #ff0000">optimistic</span>-<span style="color: #ff0000">lock</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                       (<span style="color: #ff0000">11</span>)
        <span style="color: #ff0000">not</span>-<span style="color: #ff0000">found</span>=<span style="color: #0000ff">&quot;ignore|exception&quot;</span>                       (<span style="color: #ff0000">12</span>)
<span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>Much of the attributes on this element are identical to the ones that I outlined in the post about <a href="http://ayende.com/Blog/archive/2009/04/07/nhibernate-mapping-ltpropertygt.aspx">&lt;property/&gt;</a>. 1, 2, 3, 6, 7, 9 and 11 are identical, and I am not going to cover them.</p>

<p>4) cascade is interesting, it controls one of the more interesting NHibernate features, persistence by reachability.I outlined all the possible options in 2006, so I <a href="http://ayende.com/Blog/archive/2006/12/02/NHibernateCascadesTheDifferentBetweenAllAlldeleteorphansAndSaveupdate.aspx">wouldn’t repeat them</a> again.</p>

<p>5) fetch is <em>really </em>interesting. Let us take a look at an entity definition, and explore how modifying it can alter NHibernate’s behavior.</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Post&quot;</span>
		 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span><span style="color: #0000ff">&gt;</span>
  
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;identity&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Title&quot;</span> <span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">many</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Blog&quot;</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And we have the following code to exercise NHibernate:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var post = session.Get&lt;Post&gt;(1);
	Console.WriteLine(post.Title);
	tx.Commit();
}</pre>
</blockquote>

<p>This would result in the following SQL.</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_128440AF.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="109" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_71FF91AD.png" width="281" border="0" /></a>&#160;</p>

<p>But interesting things happen when we start playing with the fetch attribute. Note that by default the fetch attribute is defaulting to “select”, so setting it to that value is merely making things explicit, but setting it to fetch=”join”, like this:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">many</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Blog&quot;</span> 
	<span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span>
	<span style="color: #ff0000">fetch</span>=<span style="color: #0000ff">&quot;join&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>Would result in the following SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0A91BFAF.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="260" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_4BC259B7.png" width="371" border="0" /></a> </p>

<p></p>

<p>We eagerly load the Blog association, in this case.</p>

<p>8) property-ref is a legacy feature, it is meant to allow you to create many-to-one associations when the association is not done on the primary key of the association. In general, I would strongly suggest avoiding it.</p>

<p>9) unique is relevant only if you use NHibernate to specify your schema. This would generate a unique constraint when we generate the DDL.</p>

<p>12) not-found is another legacy feature, it controls how NHibernate behaves when it finds an invalid foreign key. That is, a value that points to an entity that doesn’t exist. By default, this would trigger an error, as this generally indicate a problem with the database, but with legacy database, you can tell it to set the property value to null instead.</p>
