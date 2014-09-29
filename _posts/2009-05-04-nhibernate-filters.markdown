---
layout: post
title: "NHibernate Filters"
date: 2009-05-04 08:33:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["query", "mapping", "HowTo", "querying"]
alias: ["/blogs/nhibernate/archive/2009/05/04/nhibernate-filters.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>One of the more interesting ability of NHibernate is to selectively filter records based on some global filters. This allow us to very easily create global where clauses that we can flip on and off at the touch of a switch. </p>
<p>Let us take a look at see what I mean.</p>
<p>We define the filter effectiveDate:</p>
<blockquote>
<pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">filter</span>-<span style="color: #ff0000">def</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"effectiveDate"</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">filter</span>-<span style="color: #ff0000">param</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"asOfDate"</span> <span style="color: #ff0000">type</span>=<span style="color: #0000ff">"System.DateTime"</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">filter</span>-def<span style="color: #0000ff">&gt;</span></pre>
</blockquote>
<p>A filter definition is most commonly just a set of parameters that we can define, which will later be applied to in the appropriate places. An example of an appropriate place would be Post.PostedAt, we don&rsquo;t want to show any post that was posted at a later time than the effective date. We can define this decision in the mapping, like this:</p>
<blockquote>
<pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"Post"</span>
		   <span style="color: #ff0000">table</span>=<span style="color: #0000ff">"Posts"</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"Id"</span><span style="color: #0000ff">&gt;</span>
			<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">"identity"</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
		
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"Title"</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"Text"</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"PostedAt"</span><span style="color: #0000ff">/&gt;</span>
		
		
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">filter</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"effectiveDate"</span>
						<span style="color: #ff0000">condition</span>=<span style="color: #0000ff">":asOfDate &gt;= PostedAt"</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>
<p>And now we can start play:</p>
<blockquote>
<pre>s.CreateCriteria&lt;Post&gt;()
	.SetMaxResults(5)
	.List();

s.EnableFilter("<span style="color: #8b0000">effectiveDate</span>")
	.SetParameter("<span style="color: #8b0000">asOfDate</span>", DateTime.Now);

s.CreateCriteria&lt;Post&gt;()
	.SetMaxResults(5)
	.List();</pre>
</blockquote>
<p>Who do you think this will generate?</p>
<p>Well, the first query is pretty easy to understand:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_52EF04CB.png"><img border="0" width="373" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_58CEC9C6.png" alt="image" height="136" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" title="image" /></a> </p>
<p>But the second one is much more interesting:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_23589852.png"><img border="0" width="447" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_10A62F4C.png" alt="image" height="152" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" title="image" /></a> </p>
<p>We have selectively applied the filter so only posted posted after the 16th can be seen.</p>
<p>This is a very powerful capability to have, since we can use this globally, to define additional condition. For that matter, we can apply it in multiple places, so comments would also be so limited, etc.</p>
<p>For that matter, we can also put filters on associations as well:</p>
<blockquote>
<pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"Comments"</span>
	 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">"Comments"</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">"PostId"</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">many</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">"Comment"</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">filter</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">"effectiveDate"</span>
					<span style="color: #ff0000">condition</span>=<span style="color: #0000ff">":asOfDate &gt;= PostedAt"</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>
<p>And trying to access the Comments collection on a Post would generate the following SQL when the filter is active:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0FD05A13.png"><img border="0" width="509" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_6349BADD.png" alt="image" height="204" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" title="image" /></a> </p>
<p>Nice, isn&rsquo;t it?</p>
