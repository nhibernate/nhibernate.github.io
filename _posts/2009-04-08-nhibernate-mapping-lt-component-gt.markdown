---
layout: post
title: "NHibernate Mapping - &lt;component/&gt;"
date: 2009-04-08 14:20:00 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/04/08/nhibernate-mapping-lt-component-gt.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>&lt;component/&gt; is an interesting feature of NHibernate, which map more or less directly into the notion of a Value Type in DDD. This is a way to create an object model with higher granularity than the physical data model.</p>  <p>For example, let us take the following table:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0947AA33.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="197" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5B819380.png" width="202" border="0" /></a> </p>  <p>And this object model:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_28B41DBD.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="198" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_4240CC4C.png" width="451" border="0" /></a> </p>  <p>They are quite different, where the physical data model put all the data in a single table, we want to treat them in our object model as two separate classes. This is where &lt;component/&gt; comes into play:</p>  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Person&quot;</span>
	<span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;People&quot;</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;identity&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Name&quot;</span> <span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">component</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Address&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Line1&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Line2&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;City&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Country&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;ZipCode&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">component</span><span style="color: #0000ff">&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>

<p>This mapping will translate between the physical data model and the object model. And the mapping is complete, so even queries are done in the way you would expect it:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_15508AD3.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="147" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_289662D4.png" width="268" border="0" /></a> </p>

<p>And then we let NHibernate sort it out and give us our pretty object graph.</p>
