---
layout: post
title: "NHibernate Mapping - &lt;property/&gt;"
date: 2009-04-08 02:07:13 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2009/04/08/nhibernate-mapping-lt-property-gt.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>I am going to post a few things about NHibernate, going in depth into seemingly understood mapping. We will start with the most basic of them all: &lt;property/&gt;</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span>
        <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;propertyName&quot;</span>                 (<span style="color: #ff0000">1</span>)
        <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;column_name&quot;</span>                (<span style="color: #ff0000">2</span>)
        <span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;typename&quot;</span>                     (<span style="color: #ff0000">3</span>)
        <span style="color: #ff0000">update</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                 (<span style="color: #ff0000">4</span>)
        <span style="color: #ff0000">insert</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                 (<span style="color: #ff0000">4</span>)
        <span style="color: #ff0000">formula</span>=<span style="color: #0000ff">&quot;arbitrary SQL expression&quot;</span>  (<span style="color: #ff0000">5</span>)
        <span style="color: #ff0000">access</span>=<span style="color: #0000ff">&quot;field|property|ClassName&quot;</span>   (<span style="color: #ff0000">6</span>)
        <span style="color: #ff0000">optimistic</span>-<span style="color: #ff0000">lock</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>        (<span style="color: #ff0000">7</span>)
        <span style="color: #ff0000">generated</span>=<span style="color: #0000ff">&quot;never|insert|always&quot;</span>     (<span style="color: #ff0000">8</span>)
<span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>1) is pretty obvious, it is the name of the property on the persistent class.</p>

<p>2) should be obvious as well, this is the column name in the database, which by default is the name of the property. This allows us to map a property to a column, and adds a small optimization if you have one to one mapping.</p>

<p>3) type is interesting. This is the CLR type of the property that we map, but it can also be used to customize the way that NHibernate works with our data types by specifying a custom IUserType.</p>

<p>4) should NHibernate update this property in the database when updating the object? Let us look at an example:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Title&quot;</span> <span style="color: #ff0000">update</span>=<span style="color: #0000ff">&quot;false&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>Given this mapping, and the following code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var blog = session.Get&lt;Blog&gt;(6);
	blog.Title = &quot;<span style="color: #8b0000">changed</span>&quot;;

	tx.Commit();
}</pre>
</blockquote>

<p>NHibernate will <em>not</em> try to update the row:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6AEE3708.png"><img height="87" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0380650A.png" width="533" border="0" /></a> </p>

<p>Note that we have no update here, even though we updated the actual property value, and usually NHibernate will save that value.</p>

<p>5) insert behaves in much the same way, disabling inserts for a property. For example:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;AllowsComments&quot;</span> <span style="color: #ff0000">insert</span>=<span style="color: #0000ff">&quot;false&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>And this code:</p>

<blockquote>
  <pre><span style="color: #0000ff">object</span> id;
<span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	id = session.Save(<span style="color: #0000ff">new</span> Blog
	{
		AllowsComments = <span style="color: #0000ff">true</span>,
		CreatedAt = DateTime.Now,
		Subtitle = &quot;<span style="color: #8b0000">test</span>&quot;,
		Title = &quot;<span style="color: #8b0000">test</span>&quot;
	});

	tx.Commit();
}</pre>
</blockquote>

<p>Produces:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3C2D9FC8.png"><img height="110" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_6DBB9E0E.png" width="588" border="0" /></a> </p>

<p>Note that we don't insert the AllowComments column. And if we try to update this entity:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var blog = session.Get&lt;Blog&gt;(id);
	blog.AllowsComments = <span style="color: #0000ff">false</span>;
	blog.Title = &quot;<span style="color: #8b0000">blah</span>&quot;;

	tx.Commit();
}</pre>
</blockquote>

<p>We would get...</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_2D1BE250.png"><img height="110" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_49B85E23.png" width="470" border="0" /></a> </p>

<p>An update of AllowComments, but not of Title.</p>

<p>5) formula is a way to specify any arbitrary SQL that we want to associate with a property. Obviously, this is a read only value, and it is something that we would use on fairly rare occasions. Nevertheless, it can be pretty useful at times. Let us take a look at the mapping:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;CountOfPosts&quot;</span>
	<span style="color: #ff0000">formula</span>=<span style="color: #0000ff">&quot;(select count(*) from Posts where Posts.Id = Id)&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>And selecting an entity will now result in:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3E253195.png"><img height="188" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5D6A6919.png" width="373" border="0" /></a></p>

<p>Note that the formula was slightly preprocessed in order to make it work as a subquery.</p>

<p>6) access determines how we are going to actually set and get the actual value with NHibernate. We aren't limited to a simple public property, in fact, we can use: private variables, private auto property variable, custom implementation, field, and many more. This isn't actually very interesting at the moment to me, so I am just going to mention it and move on.</p>

<p>7) optimistic-lock is pretty complex, I am afraid. Mostly because it is a way to interact with the &lt;version/&gt; option of NHibernate. NHibernate has intrinsic support for optimistic concurrency, but sometimes there are reasons that you <em>don't </em>want to change the value of the version of the entity if a particular value changed. This is the role that optimistic-lock plays. </p>

<p>It will probably be better when we see the code. Let us take the following entity definition:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Blog&quot;</span>
	   <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Blogs&quot;</span><span style="color: #0000ff">&gt;</span>
  
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;identity&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">version</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Version&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Title&quot;</span> <span style="color: #ff0000">update</span>=<span style="color: #0000ff">&quot;false&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Subtitle&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;AllowsComments&quot;</span> <span style="color: #ff0000">insert</span>=<span style="color: #0000ff">&quot;false&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;CreatedAt&quot;</span> <span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;CountOfPosts&quot;</span>
		<span style="color: #ff0000">formula</span>=<span style="color: #0000ff">&quot;(select count(*) from Posts where Posts.Id = Id)&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And now execute the following code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var blog = session.Get&lt;Blog&gt;(1);
	blog.Subtitle = &quot;<span style="color: #8b0000">new value 6</span>&quot;;
	tx.Commit();
}</pre>
</blockquote>

<p>The SQL that is going to be executed is:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_7CAFA09D.png"><img height="138" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0E229227.png" width="431" border="0" /></a> </p>

<p>Note that we increment the value of the version column. But, if we specify optimistic-lock=&quot;false&quot;...</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Subtitle&quot;</span>
	<span style="color: #ff0000">optimistic</span>-<span style="color: #ff0000">lock</span>=<span style="color: #0000ff">&quot;false&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>We will get:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3FB0906D.png"><img height="139" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_77F19836.png" width="405" border="0" /></a> </p>

<p>Note that in this case, we do <em>not</em> increase the value of the version column.</p>

<p>8) generated is an instruction to NHibernate that the value of this property is set by the database, usually using a default value (in which case you'll use &quot;insert&quot;) or a trigger (in which case you'll use &quot;always&quot;).</p>

<p>When we use it like this:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;AllowsComments&quot;</span> <span style="color: #ff0000">generated</span>=<span style="color: #0000ff">&quot;insert&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>And execute the following code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	session.Save(<span style="color: #0000ff">new</span> Blog
	{
		CreatedAt = DateTime.Now,
		Title = &quot;<span style="color: #8b0000">hello</span>&quot;,
		Subtitle = &quot;<span style="color: #8b0000">world</span>&quot;,
	});
	tx.Commit();
}</pre>
</blockquote>

<p>We will get an insert followed immediately by a select:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_055A3BEE.png"><img height="39" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_74E1CAF2.png" width="317" border="0" /></a> \</p>

<p>And the select is:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_723B9FF2.png"><img height="79" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0F444EBB.png" width="308" border="0" /></a> </p>

<p>So we have to get it back from the database before we can actually make any sort of use of it.</p>

<p>And that was my in depth tour into &lt;property/&gt;, more will probably follow...</p>
