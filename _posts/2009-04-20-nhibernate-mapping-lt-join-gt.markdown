---
layout: post
title: "NHibernate Mapping - &lt;join/&gt;"
date: 2009-04-20 01:56:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2009/04/20/nhibernate-mapping-lt-join-gt.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>We have previously explored the <a href="http://ayende.com/Blog/archive/2009/04/19/nhibernate-mapping-ltone-to-onegt.aspx">one-to-one</a> mapping, which let you create 1:1 association in the database, but there is actually another way to map several tables to an object model. We aren’t constrained by the database model, and we can merge several tables into a single entity. </p>  <p>We do that using the &lt;join/&gt; element:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">join</span>
        <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;tablename&quot;</span>                        (<span style="color: #ff0000">1</span>)
        <span style="color: #ff0000">schema</span>=<span style="color: #0000ff">&quot;owner&quot;</span>                           (<span style="color: #ff0000">2</span>)
        <span style="color: #ff0000">catalog</span>=<span style="color: #0000ff">&quot;catalog&quot;</span>                        (<span style="color: #ff0000">3</span>)
        <span style="color: #ff0000">fetch</span>=<span style="color: #0000ff">&quot;join|select&quot;</span>                      (<span style="color: #ff0000">4</span>)
        <span style="color: #ff0000">inverse</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                     (<span style="color: #ff0000">5</span>)
        <span style="color: #ff0000">optional</span>=<span style="color: #0000ff">&quot;true|false&quot;</span><span style="color: #0000ff">&gt;</span>                   (6)

        <span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> ... <span style="color: #0000ff">/&gt;</span>

        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> ... <span style="color: #0000ff">/&gt;</span>
        ...
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">join</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>Let us explore this a bit, assuming the we have the following database model:&quot;</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_617B3C4E.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="177" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_4BB67553.png" width="543" border="0" /></a> </p>

<p>And what we want is to map this to the following object model:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_1D5F8057.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="235" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_3348F2A7.png" width="163" border="0" /></a> </p>

<p>We can do this will the following mapping:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Person&quot;</span>
	 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;People&quot;</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;identity&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Name&quot;</span> <span style="color: #0000ff">/&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">join</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Addresses&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;PersonId&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Line1&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Line2&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;City&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Country&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;ZipCode&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">join</span><span style="color: #0000ff">&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And getting a Person will now result in the following SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_45281725.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="187" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0011DAA0.png" width="349" border="0" /></a> </p>

<p>NHibernate will now take care of mapping everything to its place, and making sure that everything works just right.</p>

<p>By now you should be able to figure out what fetch means, and inverse should also be familiar. Optional is interesting, what is basically says is that we should always use an outer join to get the values from the Addresses table and if all the mapped properties are null, it wouldn’t create a new row in the Addresses table.</p>

<p>On the face of it, it looks like a nice way to merge tables together, but that isn’t actually the primary reason for this feature. You can use it for that, for sure, but that is mostly useful in legacy databases. In most cases, your object model should be <em>more</em> granular than the database model, not the other way around.</p>

<p>The really interesting part about this feature is that it allows us to mix &amp; match inheritance strategies. It let us create a table per hierarchy that store all the extra fields on another table, for example. That significantly reduce the disadvantage of using a table per hierarchy or table per subclass, since we can tell very easily what is the type of the class that we are using, and act appropriately.</p>
