---
layout: post
title: "NHibernate Mapping - &lt;dynamic-component/&gt;"
date: 2009-04-11 05:23:00 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/04/11/nhibernate-mapping-lt-dynamic-component-gt.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Like the &lt;component/&gt; mapping, &lt;dynamic-component/&gt; allows us to treat parts of the entity table in a special way. In this case, it allow us to push properties from the mapping into a dictionary, instead of having to have the entity have properties for it. </p>  <p>This is very useful when we need to build dynamically extended entities, where the client can add columns on the fly. </p>  <p>Let us take this entity as an example:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0A4B790D.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="162" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_3BDC0804.png" width="163" border="0" /></a> </p>  <p>And this table:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3FE8E687.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="114" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_1A7EF319.png" width="202" border="0" /></a></p>  <p>Where we want to have the SSN accessible from our entity, but without modifying its structure. We can do this using &lt;dynamic-component/&gt;:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Person&quot;</span>
		<span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;People&quot;</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;identity&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Name&quot;</span> <span style="color: #0000ff">/&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">dynamic</span>-<span style="color: #ff0000">component</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Attributes&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;SSN&quot;</span>
			<span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;System.String&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">dynamic</span>-component<span style="color: #0000ff">&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>And the query just treat this as yet another column in the table:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0A06821E.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="94" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_57A53F4F.png" width="230" border="0" /></a></p>
