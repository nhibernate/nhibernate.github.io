---
layout: post
title: "NHibernate Unit Testing"
date: 2009-04-28 07:32:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["Tests"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/28/nhibernate-unit-testing.aspx/", "/blogs/nhibernate/archive/2009/04/28/nhibernate-unit-testing.html"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>When using NHibernate we generally want to test only three things, that properties are persisted, that cascade works as expected and that queries return the correct result. In order to do all of those, we generally have to talk to a real database, trying to fake any of those at this level is futile and going to be very complicated.</p>  <p>We can either use a standard RDBMS or use an in memory database such as SQLite in order to get very speedy tests.</p>  <p>I have a pretty big implementation of a base class for unit testing NHibernate in Rhino Commons, but that has so many features that I forget how to use it sometimes. Most of those features, by the way, are now null &amp; void because we have <a href="http://nhprof.com/">NH Prof</a>, and can easily see what is going on without resorting to the SQL Profiler. </p>  <p>At any rate, here is a very simple implementation of that base class, which gives us the ability to execute NHibernate tests in memory.</p>  <blockquote>   <pre><span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> InMemoryDatabaseTest : IDisposable
{
	<span style="color: #0000ff">private</span> <span style="color: #0000ff">static</span> Configuration Configuration;
	<span style="color: #0000ff">private</span> <span style="color: #0000ff">static</span> ISessionFactory SessionFactory;
	<span style="color: #0000ff">protected</span> ISession session;

	<span style="color: #0000ff">public</span> InMemoryDatabaseTest(Assembly assemblyContainingMapping)
	{
		<span style="color: #0000ff">if</span> (Configuration == <span style="color: #0000ff">null</span>)
		{
			Configuration = <span style="color: #0000ff">new</span> Configuration()
				.SetProperty(Environment.ReleaseConnections,&quot;<span style="color: #8b0000">on_close</span>&quot;)
				.SetProperty(Environment.Dialect, <span style="color: #0000ff">typeof</span> (SQLiteDialect).AssemblyQualifiedName)
				.SetProperty(Environment.ConnectionDriver, <span style="color: #0000ff">typeof</span>(SQLite20Driver).AssemblyQualifiedName)
				.SetProperty(Environment.ConnectionString, &quot;<span style="color: #8b0000">data source=:memory:</span>&quot;)
				.SetProperty(Environment.ProxyFactoryFactoryClass, <span style="color: #0000ff">typeof</span> (ProxyFactoryFactory).AssemblyQualifiedName)
				.AddAssembly(assemblyContainingMapping);

			SessionFactory = Configuration.BuildSessionFactory();
		}

		session = SessionFactory.OpenSession();

		<span style="color: #0000ff">new</span> SchemaExport(Configuration).Execute(<span style="color: #0000ff">true</span>, <span style="color: #0000ff">true</span>, <span style="color: #0000ff">false</span>, <span style="color: #0000ff">true</span>, session.Connection, Console.Out);
	}

	<span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> Dispose()
	{
		session.Dispose();
	}
}</pre>
</blockquote>

<p>This just set up the in memory database, the mappings, and create a session which we can now use. Here is how we use this base class:</p>

<blockquote>
  <pre><span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> BlogTestFixture : InMemoryDatabaseTest
{
	<span style="color: #0000ff">public</span> BlogTestFixture() : <span style="color: #0000ff">base</span>(<span style="color: #0000ff">typeof</span>(Blog).Assembly)
	{
	}

	[Fact]
	<span style="color: #0000ff">public</span> <span style="color: #0000ff">void</span> CanSaveAndLoadBlog()
	{
		<span style="color: #0000ff">object</span> id;

		<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
		{
			id = session.Save(<span style="color: #0000ff">new</span> Blog
			{
				AllowsComments = <span style="color: #0000ff">true</span>,
				CreatedAt = <span style="color: #0000ff">new</span> DateTime(2000,1,1),
				Subtitle = &quot;<span style="color: #8b0000">Hello</span>&quot;,
				Title = &quot;<span style="color: #8b0000">World</span>&quot;,
			});

			tx.Commit();
		}

		session.Clear();


		<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
		{
			var blog = session.Get&lt;Blog&gt;(id);

			Assert.Equal(<span style="color: #0000ff">new</span> DateTime(2000, 1, 1), blog.CreatedAt);
			Assert.Equal(&quot;<span style="color: #8b0000">Hello</span>&quot;, blog.Subtitle);
			Assert.Equal(&quot;<span style="color: #8b0000">World</span>&quot;, blog.Title);
			Assert.True(blog.AllowsComments);

			tx.Commit();
		}
	}
}</pre>
</blockquote>

<p>Pretty simple, ah?</p>
