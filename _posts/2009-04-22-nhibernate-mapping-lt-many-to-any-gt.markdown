---
layout: post
title: "NHibernate Mapping - &lt;many-to-any/&gt;"
date: 2009-04-22 03:52:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2009/04/22/nhibernate-mapping-lt-many-to-any-gt.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>&lt;many-to-any/&gt; is the logical extension of the &lt;any/&gt; feature that NHibernate has. At the time of this writing, if you do a Google search on &lt;many-to-any/&gt;, the first result is <a href="http://ayende.com/Blog/archive/2005/10/07/ObscureNHibernateFeature.aspx">this post</a>. It was written by me, in 2005, and contains absolutely <em>zero</em> useful information. Time to fix that.</p>  <p>Following up on the <a href="http://ayende.com/Blog/archive/2009/04/21/nhibernate-mapping-ltanygt.aspx">&lt;any/&gt;</a> post, let us say that we need to map not a single heterogeneous association, but a multiple heterogeneous one, such as this:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0B0F7595.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="289" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_02448EAB.png" width="403" border="0" /></a> </p>  <p>In the database, it would appear as:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_15F408F0.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="318" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_750326F9.png" width="674" border="0" /></a> </p>  <p>How can we map such a thing?</p>  <p>Well, that turn out to be pretty easy to do:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">set</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Payments&quot;</span> <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;OrderPayments&quot;</span> <span style="color: #ff0000">cascade</span>=<span style="color: #0000ff">&quot;all&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">key</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;OrderId&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">many</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">any</span> <span style="color: #ff0000">id</span>-<span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;System.Int64&quot;</span>
			<span style="color: #ff0000">meta</span>-<span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;System.String&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">meta</span>-<span style="color: #ff0000">value</span> <span style="color: #ff0000">value</span>=<span style="color: #0000ff">&quot;CreditCard&quot;</span>
			<span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;CreditCardPayment&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">meta</span>-<span style="color: #ff0000">value</span> <span style="color: #ff0000">value</span>=<span style="color: #0000ff">&quot;Wire&quot;</span>
			<span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;WirePayment&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">column</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PaymentType&quot;</span> 
			<span style="color: #ff0000">not</span>-<span style="color: #ff0000">null</span>=<span style="color: #0000ff">&quot;true&quot;</span><span style="color: #0000ff">/&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">column</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PaymentId&quot;</span>
			<span style="color: #ff0000">not</span>-<span style="color: #ff0000">null</span>=<span style="color: #0000ff">&quot;true&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">many</span>-to-any<span style="color: #0000ff">&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">set</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>Now, let us look at how we use this when we insert values:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var order = <span style="color: #0000ff">new</span> Order
	{
		Payments = <span style="color: #0000ff">new</span> HashSet&lt;IPayment&gt;
        {
        	<span style="color: #0000ff">new</span> CreditCardPayment
        	{
        		Amount = 6,
                CardNumber = &quot;<span style="color: #8b0000">35434</span>&quot;,
                IsSuccessful = <span style="color: #0000ff">true</span>
        	},
            <span style="color: #0000ff">new</span> WirePayment
            {
            	Amount = 3,
                BankAccountNumber = &quot;<span style="color: #8b0000">25325</span>&quot;,
                IsSuccessful = <span style="color: #0000ff">false</span>
            }
        }
	};
	session.Save(order);
	tx.Commit();
}</pre>
</blockquote>

<p>This will produce some very interesting SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_5007F731.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="106" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_73C3AF7C.png" width="326" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_5E688AC5.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="119" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_1DC8CF07.png" width="400" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6AFB5943.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="121" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_156A1B12.png" width="398" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_30A504C4.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="109" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5B13C692.png" width="436" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_21271457.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="112" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_6E599E93.png" width="411" border="0" /></a> </p>

<p>I think that the SQL make it pretty clear what is going on here, so let us move to a more fascinating topic, what does NHibernate do when we <em>read</em> them?</p>

<p>Here is the code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var order = session.Get&lt;Order&gt;(1L);
	<span style="color: #0000ff">foreach</span> (var payment <span style="color: #0000ff">in</span> order.Payments)
	{
		Console.WriteLine(payment.Amount);
	}
	tx.Commit();
}</pre>
</blockquote>

<p>And the SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_18C86062.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="103" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_712474E8.png" width="355" border="0" /></a> </p>

<p></p>

<p></p>

<p></p>

<p></p>

<p></p>

<p></p>

<p></p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_45763B9D.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="107" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_41F7AAB3.png" width="332" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_5D329465.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="118" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_476B3CB9.png" width="386" border="0" /></a> </p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_4DB4A3F8.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="119" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_3B023AF2.png" width="429" border="0" /></a> </p>

<p>As you can see, this is about as efficient as you can get. We load the order, we check what tables we need to check, and the we select from each of the tables that we found to get the actual values in the association.</p>

<p>True heterogeneous association, not used very often, but when you need it, you really <em>love</em> it when you do.</p>
