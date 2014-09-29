---
layout: post
title: "NHibernate Futures"
date: 2009-04-27 05:33:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["Future"]
alias: ["/blogs/nhibernate/archive/2009/04/27/nhibernate-futures.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>One of the nicest new features in NHibernate 2.1 is the Future&lt;T&gt;() and FutureValue&lt;T&gt;() functions. They essentially function as a way to defer query execution to a later date, at which point NHibernate will have more information about what the application is supposed to do, and optimize for it accordingly. This build on an existing feature of NHibernate, Multi Queries, but does so in a way that is easy to use and almost seamless.</p>  <p>Let us take a look at the following piece of code:</p>  <blockquote>   <pre><span style="color: #0000ff">using</span> (var s = sf.OpenSession())
<span style="color: #0000ff">using</span> (var tx = s.BeginTransaction())
{
	var blogs = s.CreateCriteria&lt;Blog&gt;()
		.SetMaxResults(30)
		.List&lt;Blog&gt;();
	var countOfBlogs = s.CreateCriteria&lt;Blog&gt;()
		.SetProjection(Projections.Count(Projections.Id()))
		.UniqueResult&lt;<span style="color: #0000ff">int</span>&gt;();

	Console.WriteLine(&quot;<span style="color: #8b0000">Number of blogs: {0}</span>&quot;, countOfBlogs);
	<span style="color: #0000ff">foreach</span> (var blog <span style="color: #0000ff">in</span> blogs)
	{
		Console.WriteLine(blog.Title);
	}

	tx.Commit();
}</pre>
</blockquote>

<p>This code would generate two queries to the database:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_404AC599.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="99" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_4E41B6E9.png" width="798" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_12187BF2.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="132" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_7193CCF0.png" width="415" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_70BDF7B7.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="77" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_49863F33.png" width="292" border="0" /></a> </p>

<p>Two queries to the database is a expensive, we can see that it took us 114ms to get the data from the database. We can do better than that, let us tell NHibernate that it is free to do the optimization in any way that it likes, I have marked the changes in red:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var s = sf.OpenSession())
<span style="color: #0000ff">using</span> (var tx = s.BeginTransaction())
{
	var blogs = s.CreateCriteria&lt;Blog&gt;()
		.SetMaxResults(30)
		<strong><font color="#ff0000">.Future&lt;Blog&gt;();</font></strong>
	var countOfBlogs = s.CreateCriteria&lt;Blog&gt;()
		.SetProjection(Projections.Count(Projections.Id()))
		<strong><font color="#ff0000">.FutureValue&lt;<span style="color: #0000ff">int</span>&gt;();</font></strong>

	Console.WriteLine(&quot;<span style="color: #8b0000">Number of blogs: {0}</span>&quot;, countOfBlogs<strong><font color="#ff0000">.Value</font></strong>);
	<span style="color: #0000ff">foreach</span> (var blog <span style="color: #0000ff">in</span> blogs)
	{
		Console.WriteLine(blog.Title);
	}

	tx.Commit();
}</pre>
</blockquote>

<p>Now, we seem a different result:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_38A19B43.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="96" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5E99DC4A.png" width="795" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_453469C1.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="163" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_445E9488.png" width="394" border="0" /></a> </p>

<p>Instead of going to the database twice, we only go <em>once</em>, with both queries at once. The speed difference is quite dramatic, 80 ms instead of 114 ms, so we saved about 30% of the total data access time and a total of 34 ms.</p>

<p>To make things even more interesting, it gets better the more queries that you use. Let us take the following scenario. We want to show the front page of a blogging site, which should have:</p>

<ul>
  <li>A grid that allow us to page through the blogs.</li>

  <li>Most recent posts.</li>

  <li>All categories</li>

  <li>All tags</li>

  <li>Total number of comments</li>

  <li>Total number of posts</li>
</ul>

<p>For right now, we will ignore caching, and just look at the queries that we need to handle. I think that you can agree that this is not an unreasonable amount of data items to want to show on the main page. For that matter, just look at <em>this</em> page, and you can probably see as much data items or more.</p>

<p>Here is the code using the Future options:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var s = sf.OpenSession())
<span style="color: #0000ff">using</span> (var tx = s.BeginTransaction())
{
	var blogs = s.CreateCriteria&lt;Blog&gt;()
		.SetMaxResults(30)
		.Future&lt;Blog&gt;();

	var posts = s.CreateCriteria&lt;Post&gt;()
		.AddOrder(Order.Desc(&quot;<span style="color: #8b0000">PostedAt</span>&quot;))
		.SetMaxResults(10)
		.Future&lt;Post&gt;();

	var tags = s.CreateCriteria&lt;Tag&gt;()
		.AddOrder(Order.Asc(&quot;<span style="color: #8b0000">Name</span>&quot;))
		.Future&lt;Tag&gt;();

	var countOfPosts = s.CreateCriteria&lt;Post&gt;()
		.SetProjection(Projections.Count(Projections.Id()))
		.FutureValue&lt;<span style="color: #0000ff">int</span>&gt;();

	var countOfBlogs = s.CreateCriteria&lt;Blog&gt;()
		.SetProjection(Projections.Count(Projections.Id()))
		.FutureValue&lt;<span style="color: #0000ff">int</span>&gt;();

	var countOfComments = s.CreateCriteria&lt;Comment&gt;()
		.SetProjection(Projections.Count(Projections.Id()))
		.FutureValue&lt;<span style="color: #0000ff">int</span>&gt;();

	Console.WriteLine(&quot;<span style="color: #8b0000">Number of blogs: {0}</span>&quot;, countOfBlogs.Value);

	Console.WriteLine(&quot;<span style="color: #8b0000">Listing of blogs</span>&quot;);
	<span style="color: #0000ff">foreach</span> (var blog <span style="color: #0000ff">in</span> blogs)
	{
		Console.WriteLine(blog.Title);
	}

	Console.WriteLine(&quot;<span style="color: #8b0000">Number of posts: {0}</span>&quot;, countOfPosts.Value);
	Console.WriteLine(&quot;<span style="color: #8b0000">Number of comments: {0}</span>&quot;, countOfComments.Value);
	Console.WriteLine(&quot;<span style="color: #8b0000">Recent posts</span>&quot;);
	<span style="color: #0000ff">foreach</span> (var post <span style="color: #0000ff">in</span> posts)
	{
		Console.WriteLine(post.Title);
	}

	Console.WriteLine(&quot;<span style="color: #8b0000">All tags</span>&quot;);
	<span style="color: #0000ff">foreach</span> (var tag <span style="color: #0000ff">in</span> tags)
	{
		Console.WriteLine(tag.Name);
	}

	tx.Commit();
}</pre>
</blockquote>

<p>This generates the following:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_03BED8CA.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="132" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_05258C4D.png" width="789" border="0" /></a> </p>

<p>And the actual SQL that is sent to the database is:</p>

<blockquote>
  <pre><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=SELECT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">SELECT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=top&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">top</a> 30 this_.Id             <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Id5_0_,
              this_.Title          <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Title5_0_,
              this_.Subtitle       <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Subtitle5_0_,
              this_.AllowsComments <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> AllowsCo4_5_0_,
              this_.CreatedAt      <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> CreatedAt5_0_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=FROM&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">FROM</a>   Blogs this_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=SELECT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">SELECT</a>   <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=top&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">top</a> 10 this_.Id       <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Id7_0_,
                this_.Title    <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Title7_0_,
                this_.<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=Text&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">Text</a>     <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=Text&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">Text</a>7_0_,
                this_.PostedAt <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> PostedAt7_0_,
                this_.BlogId   <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> BlogId7_0_,
                this_.UserId   <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> UserId7_0_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=FROM&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">FROM</a>     Posts this_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=ORDER&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">ORDER</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=BY&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">BY</a> this_.PostedAt <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=desc&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">desc</a>
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=SELECT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">SELECT</a>   this_.Id       <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Id4_0_,
         this_.Name     <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> Name4_0_,
         this_.ItemId   <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> ItemId4_0_,
         this_.ItemType <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> ItemType4_0_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=FROM&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">FROM</a>     Tags this_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=ORDER&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">ORDER</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=BY&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">BY</a> this_.Name <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=asc&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">asc</a>
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=SELECT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">SELECT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=count&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">count</a>(this_.Id) <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> y0_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=FROM&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">FROM</a>   Posts this_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=SELECT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">SELECT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=count&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">count</a>(this_.Id) <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> y0_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=FROM&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">FROM</a>   Blogs this_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=SELECT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">SELECT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=count&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">count</a>(this_.Id) <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=as&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">as</a> y0_
<a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=FROM&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">FROM</a>   Comments this_</pre>
</blockquote>

<p>That is great, but what would happen if we would use List and UniqueResult instead of Future and FutureValue?</p>

<p>I’ll not show the code, since I think it is pretty obvious how it will look like, but this is the result:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_61F8219A.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="180" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_70C4E823.png" width="795" border="0" /></a> </p>

<p>Now it takes 348ms to execute vs. 259ms using the Future pattern.</p>

<p></p>

<p></p>

<p>It is still in the 25% – 30% speed increase, but take note about the difference in <em>time</em>. Before, we saved 34 ms. Now, we saved 89 ms. </p>

<p>Those are pretty significant numbers, and those are against a very small database that I am running locally, against a database that is on another machine, the results would have been even more dramatic.</p>
