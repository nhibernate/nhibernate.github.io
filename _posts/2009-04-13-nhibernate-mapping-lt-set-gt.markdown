---
layout: post
title: "NHibernate Mapping - &lt;set/&gt;"
date: 2009-04-13 20:00:18 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2009/04/13/nhibernate-mapping-lt-set-gt.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>And now it is time to go to the &lt;set/&gt; and explore it. Most of the collections in NHibernate follow much the same rules, so I am not going to go over them in details:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span>
    <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;propertyName&quot;</span>                                         (<span style="color: #ff0000">1</span>)
    <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;table_name&quot;</span>                                          (<span style="color: #ff0000">2</span>)
    <span style="color: #ff0000">schema</span>=<span style="color: #0000ff">&quot;schema_name&quot;</span>                                        (<span style="color: #ff0000">3</span>)
    <span style="color: #ff0000">lazy</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                                           (<span style="color: #ff0000">4</span>)
    <span style="color: #ff0000">inverse</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                                        (<span style="color: #ff0000">5</span>)
    <span style="color: #ff0000">cascade</span>=<span style="color: #0000ff">&quot;all|none|save-update|delete|all-delete-orphan&quot;</span>     (<span style="color: #ff0000">6</span>)
    <span style="color: #ff0000">sort</span>=<span style="color: #0000ff">&quot;unsorted|natural|comparatorClass&quot;</span>                     (<span style="color: #ff0000">7</span>)
    <span style="color: #ff0000">order</span>-<span style="color: #ff0000">by</span>=<span style="color: #0000ff">&quot;column_name asc|desc&quot;</span>                             (<span style="color: #ff0000">8</span>)
    <span style="color: #ff0000">where</span>=<span style="color: #0000ff">&quot;arbitrary sql where condition&quot;</span>                       (<span style="color: #ff0000">9</span>)
    <span style="color: #ff0000">fetch</span>=<span style="color: #0000ff">&quot;select|join|subselect&quot;    </span>                           (<span style="color: #ff0000">10</span>)
    <span style="color: #ff0000">batch</span>-<span style="color: #ff0000">size</span>=<span style="color: #0000ff">&quot;N&quot;</span>                                              (<span style="color: #ff0000">11</span>)
    <span style="color: #ff0000">access</span>=<span style="color: #0000ff">&quot;field|property|ClassName&quot;</span>                           (<span style="color: #ff0000">12</span>)
    <span style="color: #ff0000">optimistic</span>-<span style="color: #ff0000">lock</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                                (<span style="color: #ff0000">13</span>)
    <span style="color: #ff0000">outer-join</span>=<span style="color: #0000ff">&quot;auto|true|false&quot;</span>                                (<span style="color: #ff0000">14</span>)
<span style="color: #0000ff">&gt;</span>

    <span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> .... <span style="color: #0000ff">/&gt;</span>
    <span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> .... <span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>1) is the collection property name, just like &lt;property/&gt; or &lt;many-to-one/&gt; are the value property names.</p>

<p>2) table is obviously the table name in which the values for this association exists.</p>

<p>3) schema is the schema in which that table lives.</p>

<p>4) lazy controls whatever this collection will be lazy loaded or not. By default it is set to true. Let us see how this work:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>With the following code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var blog = session.Get&lt;Blog&gt;(1);
	<span style="color: #0000ff">foreach</span> (var post <span style="color: #0000ff">in</span> blog.Posts)
	{
		Console.WriteLine(post.Title);
	}
	tx.Commit();
}</pre>
</blockquote>

<p>This produces the following statements:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_14392DB0.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="195" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_19431D72.png" width="373" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_660974B9.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="138" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_37D72B12.png" width="262" border="0" /></a> </p>

<p>We need two select statements to load the data.</p>

<p>However, if we change the set definition to:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">lazy</span>=<span style="color: #0000ff">&quot;false&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>We… would get the exact same output. Why <em>is </em>that? </p>

<p>The answer is quite simple, lazy only control whatever the collection will be loaded lazily or not. It does <em>not</em> control <em>how </em>we load it. The default is to use a second select for that, because that tend to be more efficient in the general case, since this avoid the possibility of a Cartesian product. There are other options, of course.</p>

<p>If we just set lazy to false, it means that when we load the entity, we load the collection. The reason that we see the same output from SQL perspective is that we don’t have a time perspective of that. With lazy set to true, the collection will only be loaded in the foreach. With lazy set to true, the collection will be loaded on the Get call.</p>

<p>You are probably interested in outer-join, which we can set to true, which will give us:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">outer</span>-<span style="color: #ff0000">join</span>=<span style="color: #0000ff">&quot;true&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And would result in the following SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_1E058594.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="291" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5F361F9C.png" width="384" border="0" /></a> </p>

<p>Here we get both the blog and its posts in a single query to the server. </p>

<p>The reason that lazy is somewhat complicated is that there are quite a bit of options to select from when choosing the fetching strategy for the collection, and in general, it is suggested that you would not set this in the mapping, because that is usually too generic. It is preferred to control this at a higher level, when you are actually making use of the entities.</p>

<p>5) inverse is something that I talk about extensively <a href="http://nhprof.com/Learn/Alert?name=SuperfluousManyToOneUpdate">here</a>, so I’ll not repeat this.</p>

<p>6) cascade is also something that I already <a href="http://ayende.com/Blog/archive/2006/12/02/NHibernateCascadesTheDifferentBetweenAllAlldeleteorphansAndSaveupdate.aspx">talked about</a></p>

<p>7) sort gives you a way to sort the values in the collection, by providing a comparator. Note that this is done <em>in memory, </em>not in the database. The advantage is that it will keep thing sorted even for values that you add to the collection in memory.</p>

<p>8) order-by gives you the ability to sort the values directly from the database. </p>

<p>Note that both 7 &amp; 8 does not work with generic sets and that in general, you don’t want to rely on those ordering properties, you want to use the natural properties of the selected collection. Sets are, by definition, unordered set of unique elements. But generic sorted bags does work:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">bag</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">order</span>-<span style="color: #ff0000">by</span>=<span style="color: #0000ff">&quot;Title ASC&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">bag</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And would produce in the following SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_4734CFE5.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="153" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_465EFAAC.png" width="290" border="0" /></a>&#160;</p>

<p>9) where allow us to use some arbitrary SQL expression to limit the values in the collection. Usually this is used to filter out things like logically deleted rows. Here is a silly example:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span>
		  <span style="color: #ff0000">where</span>=<span style="color: #0000ff">&quot;(len(Title) &gt; 6)&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>Which would result in:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_7376782B.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="152" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_00DF1BE3.png" width="295" border="0" /></a> </p>

<p>Note that there is important subtlety here, if you intend to use this collection with eager loading, you must make sure that your where clause can handle null values appropriately (in the case of an outer join).</p>

<p>10) fetch controls how we get the values from the database. There are three values, select, join and subselect. The default is select, and you are already familiar with it. Setting it to join would result in:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">fetch</span>=<span style="color: #0000ff">&quot;join&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And the following code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var blog = session.CreateCriteria(<span style="color: #0000ff">typeof</span>(Blog))
		.SetMaxResults(5)
		.List&lt;Blog&gt;()[0];
	<span style="color: #0000ff">foreach</span> (var post <span style="color: #0000ff">in</span> blog.Posts)
	{
		Console.WriteLine(post.Title);
	}
	tx.Commit();
}</pre>
</blockquote>

<p>Will give us:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_723700AE.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="224" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5F1864B3.png" width="378" border="0" /></a> </p>

<p>Setting it to subselect will show something quite a bit more interesting:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_64F598FD.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="54" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5DD8ED36.png" width="483" border="0" /></a> </p>

<p>We have two queries, the first to load the blogs, and the second one:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_4F9D04F7.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="150" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_610FF680.png" width="352" border="0" /></a> </p>

<p>In this case, we load all the related posts using a subselect. This is probably one of the more efficient ways of doing this. We load all the posts for all the blogs in a single query. That assumes, of course, that we actually want to use all those posts. In the code seen above, this is actually a waste, since we only ever access the first blog Posts collection.</p>

<p>11) batch-size is another way of controlling how we load data from the database. It is similar to fetch, but it gives us more control. Let us see how it actually work in action before we discuss it.</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Posts&quot;</span> <span style="color: #ff0000">batch</span>-<span style="color: #ff0000">size</span>=<span style="color: #0000ff">&quot;5&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;BlogId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Post&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And this code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var blogs = session.CreateCriteria(<span style="color: #0000ff">typeof</span>(Blog))
		.SetMaxResults(30)
		.List&lt;Blog&gt;();
	<span style="color: #0000ff">foreach</span> (var post <span style="color: #0000ff">in</span> blogs.SelectMany(x=&gt;x.Posts))
	{
		Console.WriteLine(post.Title);
	}
	tx.Commit();
}</pre>
</blockquote>

<p>Produces:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_44959551.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="146" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_310D5712.png" width="651" border="0" /></a> </p>

<p></p>

<p></p>

<p></p>

<p></p>

<p>Fist we load the blogs, and we load 30 of them. Now, when we access any of the unloaded collections, something very interesting is going to happen. NHibernate is going to search for up to batch-size unloaded collections of the same type and try to load them all in a single query. The idea is that we take a SELECT N+1 situation and turn that into a SELECT N/batch-size + 1 situation.</p>

<p>In this case, it will turn a 31 queries situation into a 7 queries situation. And we can increase the batch size a bit to reduce this even further. As usual, we have to balance the difference between local and global optimizations. If we make batch-size too large, we load too much data, if we make it too small, we still have too many queries.</p>

<p>This is one of the reasons that I consider those fancy options important, but not as important as setting the fetching strategy for each scenario independently. That is usually a much better strategy overall.</p>

<p>12) access was already discussed <a href="http://ayende.com/Blog/archive/2009/04/07/nhibernate-mapping-ltpropertygt.aspx">elsewhere</a>.</p>

<p>13) optimistic-lock was already discussed <a href="http://ayende.com/Blog/archive/2009/04/07/nhibernate-mapping-ltpropertygt.aspx">elsewhere</a>.</p>

<p>14) outer-join was discussed above, when we talked about lazy.</p>
