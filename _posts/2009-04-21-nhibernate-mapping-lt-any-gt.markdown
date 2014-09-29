---
layout: post
title: "NHibernate Mapping - &lt;any/&gt;"
date: 2009-04-21 03:29:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2009/04/21/nhibernate-mapping-lt-any-gt.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Sometimes, well known associations just don’t cut it. We sometimes need to be able to go not to a single table, but to a collection of table. For example, let us say that an order can be paid using a credit card or a wire transfer. The data about those are stored in different tables, and even in the object model, there is no inheritance association them.</p>  <p>From the database perspective, it looks like this:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_180D51B5.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="134" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_66A68F74.png" width="838" border="0" /></a> </p>  <p>As you can see, based on the payment type, we need to get the data from a different table. That is somewhat of a problem for the standard NHibernate mapping, which is why we have &lt;any/&gt; around.</p>  <p>Just to close the circle before we get down into the mapping, from the object model perspective, it looks like this:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6A473B02.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="289" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_305A88C7.png" width="403" border="0" /></a> </p>  <p>In other words, this is a non polymorphic association, because there is no mapped base class for the association. In fact, we could have used System.Object instead, but even for a sample, I don’t like it.</p>  <p>The mapping that we use are:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Order&quot;</span>
			 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Orders&quot;</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;native&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">any</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Payment&quot;</span> <span style="color: #ff0000">id</span>-<span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;System.Int64&quot;</span> <span style="color: #ff0000">meta</span>-<span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;System.String&quot;</span> <span style="color: #ff0000">cascade</span>=<span style="color: #0000ff">&quot;all&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">meta</span>-<span style="color: #ff0000">value</span> <span style="color: #ff0000">value</span>=<span style="color: #0000ff">&quot;CreditCard&quot;</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;CreditCardPayment&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">meta</span>-<span style="color: #ff0000">value</span> <span style="color: #ff0000">value</span>=<span style="color: #0000ff">&quot;Wire&quot;</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;WirePayment&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">column</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PaymentType&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">column</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PaymentId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">any</span><span style="color: #0000ff">&gt;</span>

<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span>

<span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;CreditCardPayment&quot;</span>
			 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;CreditCardPayments&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;native&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;IsSuccessful&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Amount&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;CardNumber&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span>

<span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;WirePayment&quot;</span>
			 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;WirePayments&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;native&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;IsSuccessful&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Amount&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;BankAccountNumber&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>Pay special attention to the &lt;any/&gt; element. Any &lt;meta-value/&gt; declaration is setting up the association between the type as specified in the PaymentType column and the actual class name that it maps to. The only limitation is that all the mapped class must have the same data type for the primary key column.</p>

<p>Let us look at what this will give us:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var order = <span style="color: #0000ff">new</span> Order
	{
		Payment = <span style="color: #0000ff">new</span> CreditCardPayment
		{
			Amount = 5,
			CardNumber = &quot;<span style="color: #8b0000">1234</span>&quot;,
			IsSuccessful = <span style="color: #0000ff">true</span>
		}
	};
	session.Save(order);
	tx.Commit();
}</pre>
</blockquote>

<p>Which produces:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0B5F58FF.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="123" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_63BB6D85.png" width="378" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_231BB1C7.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="106" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0D545A1B.png" width="348" border="0" /></a> </p>

<p>And for selecting, it works just the way we would expect it to:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var person = session.Get&lt;Order&gt;(1L).Payment;
	Console.WriteLine(person.Amount);
	tx.Commit();
}</pre>
</blockquote>

<p>The generated SQL is:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3A6BD79A.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="104" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_27B96E94.png" width="335" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_19115360.png"><img title="image" style="border-right: 0px; border-top: 0px; display: inline; border-left: 0px; border-bottom: 0px" height="119" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0A69382C.png" width="397" border="0" /></a> </p>

<p>An interesting limitation is that you cannot do an eager load on &lt;any/&gt;, considering the flexibility of the feature, I am most certainly willing to accept that limitation.</p>
