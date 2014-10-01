---
layout: post
title: "NHibernate – The difference between Get, Load and querying by id"
date: 2009-04-30 06:55:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["querying"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/30/nhibernate-the-difference-between-get-load-and-querying-by-id.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>One of the more common mistakes that I see people doing with NHibernate is related to how they are loading entities by the primary key. This is because there are important differences between the three options.</p>  <p>The most common mistake that I see is using a query to load by id. in particular when using Linq for NHibernate.</p>  <blockquote>   <pre>var customer = (
	select customer from s.Linq&lt;Customer&gt;()
	where customer.Id = customerId
	select customer
	).FirstOrDefault();</pre>
</blockquote>

<p>Every time that I see something like that, I wince a little inside. The reason for that is quite simple. This is doing a query by primary key. The key word here is a query.</p>

<p>This means that we have to hit the database in order to get a result for this query. Unless you are using the query cache (which by default you won’t), this force a query on the database, bypassing both the first level identity map and the second level cache.</p>

<p>Get&#160; and Load are here for a reason, they provide a way to get an entity by primary key. That is important for several aspects, most importantly, it means that NHibernate can apply quite a few optimizations for this process.</p>

<p>But there is another side to that, there is a significant (and subtle) difference between Get and Load.</p>

<p>Load will <em>never</em> return null. It will always return an entity or throw an exception. Because that is the contract that we have we it, it is permissible for Load to <em>not</em> hit the database when you call it, it is free to return a proxy instead.</p>

<p>Why is this useful? Well, if you <em>know</em> that the value exist in the database, and you don’t want to pay the extra select to have that, but you want to get that value so we can add that reference to an object, you can use Load to do so:</p>

<blockquote>
  <pre>s.Save(
	<span style="color: #0000ff">new</span> Order
	{
		Amount = amount,
		customer = s.Load&lt;Customer&gt;(1)
	}
);</pre>
</blockquote>

<p>The code above will <em>not</em> result in a select to the database, but when we commit the transaction, we will set the CustomerID column to 1. This is how NHibernate maintain the OO facade when giving you the same optimization benefits of working directly with the low level API.</p>

<p>Get, however, is different. Get will return null if the object does not exist. Since this is its contract, it <em>must </em>return either the entity or null, so it cannot give you a proxy if the entity is not known to exist. Get will usually result in a select against the database, but it will check the session cache and the 2nd level cache first to get the values first.</p>

<p>So, next time that you need to get some entity by its primary key, just remember the differences…</p>
