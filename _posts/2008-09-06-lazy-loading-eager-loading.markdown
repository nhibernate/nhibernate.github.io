---
layout: post
title: "Lazy Loading - Eager Loading"
date: 2008-09-06 16:59:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["query", "lazy loading"]
alias: ["/blogs/nhibernate/archive/2008/09/06/lazy-loading-eager-loading.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Blog-Signature-Gabriel_5F00_4.png"><img style="border-right: 0px; border-top: 0px; border-left: 0px; border-bottom: 0px" alt="Blog Signature Gabriel" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Blog-Signature-Gabriel_5F00_thumb_5F00_1.png" width="244" border="0" height="21" /></a> </p>
<p>In this article I want to discuss the <a href="http://martinfowler.com/eaaCatalog/lazyLoad.html">lazy loading</a> mechanism provided by NHibernate. It is recommended for maximum flexibility to define all relations in your domain as lazy loadable. This is the default behavior of NHibernate since version 1.2. But this can lead to some undesired effects if querying your data. Let's discuss these effects and how to avoid them.</p>
<p>In my previous posts I showed <a href="http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/03/31/prepare-your-system-for-nhibernate.aspx">how to prepare your system for NHibernate</a> and <a href="/wikis/howtonh/your-first-nhibernate-based-application.aspx">how to implement a first NHibernate base application</a>. This post is based on those two articles.</p>
<h2>The Domain</h2>
<p>Let's first define a simple domain. It shows part of an order entry system. I keep this model as simple as possible (a real domain model would be more complex) but it contains all aspects we want to discuss in this post. Below is the class diagram of our model</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_4.png"><img src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/LazyLoadingEagerLoadingDomain.png" /></a> </p>
<p>We have an order entity which can be placed by a customer entity. Each order can have many order line entities. Each of the three entity types is uniquely identified by a property Id (surrogate key).</p>
<h2>The Mapping Files</h2>
<p>We have to write one mapping file per entity. It is recommended that you always have one mapping per file. Don't forget to set the <b>Build Action</b> of each mapping file to <b>Embedded Resource</b>. People often tend to forget it and the subsequent errors raised by NHibernate are not always obvious. Also do not forget to give the mapping files the correct name, that is *.<b>hbm</b>.xml where * denotes the placeholder for the entity name.</p>
<p>The mapping for the <b>Order</b> entity might be implemented as follows</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">="1.0"</span> <span class="attr">encoding</span><span class="kwrd">="utf-8"</span> ?<span class="kwrd">&gt;</span></pre>
<pre><span class="kwrd">&lt;</span><span class="html">hibernate-mapping</span> <span class="attr">xmlns</span><span class="kwrd">="urn:nhibernate-mapping-2.2"</span></pre>
<pre class="alt">                   <span class="attr">assembly</span><span class="kwrd">="LazyLoadEagerLoad"</span></pre>
<pre>                   <span class="attr">namespace</span><span class="kwrd">="LazyLoadEagerLoad.Domain"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">  </pre>
<pre>  <span class="kwrd">&lt;</span><span class="html">class</span> <span class="attr">name</span><span class="kwrd">="Order"</span> <span class="attr">table</span><span class="kwrd">="Orders"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">id</span> <span class="attr">name</span><span class="kwrd">="Id"</span><span class="kwrd">&gt;</span></pre>
<pre>      <span class="kwrd">&lt;</span><span class="html">generator</span> <span class="attr">class</span><span class="kwrd">="guid"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;/</span><span class="html">id</span><span class="kwrd">&gt;</span></pre>
<pre>    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="OrderNumber"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="OrderDate"</span><span class="kwrd">/&gt;</span></pre>
<pre>    </pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">many-to-one</span> <span class="attr">name</span><span class="kwrd">="Customer"</span> <span class="kwrd">/&gt;</span></pre>
<pre>&nbsp;</pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">set</span> <span class="attr">name</span><span class="kwrd">="OrderLines"</span> <span class="attr">cascade</span><span class="kwrd">="all-delete-orphan"</span> <span class="kwrd">&gt;</span></pre>
<pre>      <span class="kwrd">&lt;</span><span class="html">key</span> <span class="attr">column</span><span class="kwrd">="OrderId"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">      <span class="kwrd">&lt;</span><span class="html">one-to-many</span> <span class="attr">class</span><span class="kwrd">="OrderLine"</span><span class="kwrd">/&gt;</span></pre>
<pre>    <span class="kwrd">&lt;/</span><span class="html">set</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">    </pre>
<pre>  <span class="kwrd">&lt;/</span><span class="html">class</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">  </pre>
<pre><span class="kwrd">&lt;/</span><span class="html">hibernate-mapping</span><span class="kwrd">&gt;</span></pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>Analogous you can implement the mappings for the <b>Customer</b> entity</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">="1.0"</span> <span class="attr">encoding</span><span class="kwrd">="utf-8"</span> ?<span class="kwrd">&gt;</span> </pre>
<pre><span class="kwrd">&lt;</span><span class="html">hibernate-mapping</span> <span class="attr">xmlns</span><span class="kwrd">="urn:nhibernate-mapping-2.2"</span></pre>
<pre class="alt">                   <span class="attr">assembly</span><span class="kwrd">="LazyLoadEagerLoad"</span></pre>
<pre>                   <span class="attr">namespace</span><span class="kwrd">="LazyLoadEagerLoad.Domain"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">  </pre>
<pre>  <span class="kwrd">&lt;</span><span class="html">class</span> <span class="attr">name</span><span class="kwrd">="Customer"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">id</span> <span class="attr">name</span><span class="kwrd">="Id"</span><span class="kwrd">&gt;</span></pre>
<pre>      <span class="kwrd">&lt;</span><span class="html">generator</span> <span class="attr">class</span><span class="kwrd">="guid"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;/</span><span class="html">id</span><span class="kwrd">&gt;</span></pre>
<pre>    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="CompanyName"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">  <span class="kwrd">&lt;/</span><span class="html">class</span><span class="kwrd">&gt;</span></pre>
<pre>&nbsp;</pre>
<pre class="alt"><span class="kwrd">&lt;/</span><span class="html">hibernate-mapping</span><span class="kwrd">&gt;</span></pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>and finally the mapping for the <b>OrderLine</b> entity.</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">="1.0"</span> <span class="attr">encoding</span><span class="kwrd">="utf-8"</span> ?<span class="kwrd">&gt;</span> </pre>
<pre><span class="kwrd">&lt;</span><span class="html">hibernate-mapping</span> <span class="attr">xmlns</span><span class="kwrd">="urn:nhibernate-mapping-2.2"</span></pre>
<pre class="alt">                   <span class="attr">assembly</span><span class="kwrd">="LazyLoadEagerLoad"</span></pre>
<pre>                   <span class="attr">namespace</span><span class="kwrd">="LazyLoadEagerLoad.Domain"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">&nbsp;</pre>
<pre>  <span class="kwrd">&lt;</span><span class="html">class</span> <span class="attr">name</span><span class="kwrd">="OrderLine"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">id</span> <span class="attr">name</span><span class="kwrd">="Id"</span><span class="kwrd">&gt;</span></pre>
<pre>      <span class="kwrd">&lt;</span><span class="html">generator</span> <span class="attr">class</span><span class="kwrd">="guid"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;/</span><span class="html">id</span><span class="kwrd">&gt;</span></pre>
<pre>    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="Amount"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="ProductName"</span><span class="kwrd">/&gt;</span></pre>
<pre>  <span class="kwrd">&lt;/</span><span class="html">class</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">  </pre>
<pre><span class="kwrd">&lt;/</span><span class="html">hibernate-mapping</span><span class="kwrd">&gt;</span></pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>&nbsp;</p>
<h2>Testing the Mapping</h2>
<p>To test the mapping we use the following test method</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">using</span> LazyLoadEagerLoad.Domain;</pre>
<pre><span class="kwrd">using</span> NHibernate.Cfg;</pre>
<pre class="alt"><span class="kwrd">using</span> NHibernate.Tool.hbm2ddl;</pre>
<pre><span class="kwrd">using</span> NUnit.Framework;</pre>
<pre class="alt">&nbsp;</pre>
<pre><span class="kwrd">namespace</span> LazyLoadEagerLoad.Tests</pre>
<pre class="alt">{</pre>
<pre>    [TestFixture]</pre>
<pre class="alt">    <span class="kwrd">public</span> <span class="kwrd">class</span> GenerateSchema_Fixture</pre>
<pre>    {</pre>
<pre class="alt">        [Test]</pre>
<pre>        <span class="kwrd">public</span> <span class="kwrd">void</span> Can_generate_schema()</pre>
<pre class="alt">        {</pre>
<pre>            var cfg = <span class="kwrd">new</span> Configuration();</pre>
<pre class="alt">            cfg.Configure();</pre>
<pre>            cfg.AddAssembly(<span class="kwrd">typeof</span>(Order).Assembly);</pre>
<pre class="alt">&nbsp;</pre>
<pre>            <span class="kwrd">new</span> SchemaExport(cfg).Execute(<span class="kwrd">false</span>, <span class="kwrd">true</span>, <span class="kwrd">false</span>, <span class="kwrd">false</span>);</pre>
<pre class="alt">        }</pre>
<pre>    }</pre>
<pre class="alt">}</pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
First we create a new instance of the NHibernate Configuration class and tell it to configure itself. Since we don't provide any explicit configuration here in the code NHibernate looks out for an adequate configuration file. I have included such a file (called hibernate.cfg.xml) in my project. Please consult <a href="http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/04/01/your-first-nhibernate-based-application.aspx">this</a> previous post for further details about the configuration file. 
</p>
<h2>Testing the Loading Behavior of NHibernate</h2>
<h3>Defining a base class for our tests</h3>
<p>To avoid repetitive task (<a href="http://en.wikipedia.org/wiki/Don't_repeat_yourself">DRY</a> principle) we implement the following base class.</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">using</span> LazyLoadEagerLoad.Domain;</pre>
<pre><span class="kwrd">using</span> NHibernate;</pre>
<pre class="alt"><span class="kwrd">using</span> NHibernate.Cfg;</pre>
<pre><span class="kwrd">using</span> NHibernate.Tool.hbm2ddl;</pre>
<pre class="alt"><span class="kwrd">using</span> NUnit.Framework;</pre>
<pre>&nbsp;</pre>
<pre class="alt"><span class="kwrd">namespace</span> LazyLoadEagerLoad.Tests</pre>
<pre>{</pre>
<pre class="alt">    <span class="kwrd">public</span> <span class="kwrd">class</span> TestFixtureBase</pre>
<pre>    {</pre>
<pre class="alt">        <span class="kwrd">private</span> Configuration _configuration;</pre>
<pre>        <span class="kwrd">private</span> ISessionFactory _sessionFactory;</pre>
<pre class="alt">&nbsp;</pre>
<pre>        <span class="kwrd">protected</span> ISessionFactory SessionFactory</pre>
<pre class="alt">        {</pre>
<pre>            get { <span class="kwrd">return</span> _sessionFactory; }</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        [TestFixtureSetUp]</pre>
<pre>        <span class="kwrd">public</span> <span class="kwrd">void</span> TestFixtureSetUp()</pre>
<pre class="alt">        {</pre>
<pre>            _configuration = <span class="kwrd">new</span> Configuration();</pre>
<pre class="alt">            _configuration.Configure();</pre>
<pre>            _configuration.AddAssembly(<span class="kwrd">typeof</span>(Customer).Assembly);</pre>
<pre class="alt">            _sessionFactory = _configuration.BuildSessionFactory();</pre>
<pre>        }</pre>
<pre class="alt">&nbsp;</pre>
<pre>        [TestFixtureTearDown]</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">void</span> TestFixtureTearDown()</pre>
<pre>        {</pre>
<pre class="alt">            _sessionFactory.Close();</pre>
<pre>        }</pre>
<pre class="alt">&nbsp;</pre>
<pre>        [SetUp]</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">void</span> SetupContext()</pre>
<pre>        {</pre>
<pre class="alt">            <span class="kwrd">new</span> SchemaExport(_configuration).Execute(<span class="kwrd">false</span>, <span class="kwrd">true</span>, <span class="kwrd">false</span>, <span class="kwrd">false</span>);</pre>
<pre>            Before_each_test();</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        [TearDown]</pre>
<pre>        <span class="kwrd">public</span> <span class="kwrd">void</span> TearDownContext()</pre>
<pre class="alt">        {</pre>
<pre>            After_each_test();</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">protected</span> <span class="kwrd">virtual</span> <span class="kwrd">void</span> Before_each_test()</pre>
<pre>        { }</pre>
<pre class="alt">&nbsp;</pre>
<pre>        <span class="kwrd">protected</span> <span class="kwrd">virtual</span> <span class="kwrd">void</span> After_each_test()</pre>
<pre class="alt">        { }</pre>
<pre>    }</pre>
<pre class="alt">}</pre>
</div>
<p>When the test fixture is started, the base class configures NHibernate and creates a session factory (<b>TestFixtureSetUp</b>). When the whole test fixture is ended the session factory is closed (<b>TestFixtureTearDown</b>).</p>
<p>Before each test in the fixture is run the database schema is (re-) created and the virtual <b>Before_each_test</b> method is called. After each test in the fixture is finished the virtual <b>After_each_test</b> method is called. The two virtual methods can (but must not necessarily) be overridden in a child class.
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>All our test fixtures we implement will derive from this base class.</p>
<h3>Filling the database with test data</h3>
<p>To be able to test the loading behavior of NHibernate we need some test data in our database. We create this test data every time a test is run (just after the database schema is re-created). We add a new class <b>Order_Fixture</b> to our test project and inherit from the <b>TestFixtureBase</b> base class. Then we override the Before_each_test method and call a helper method which creates our initial data. We create just the absolute minimum of data we need (again --&gt;DRY). That is: one customer placing one order with two order lines.</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">using</span> System;</pre>
<pre><span class="kwrd">using</span> LazyLoadEagerLoad.Domain;</pre>
<pre class="alt"><span class="kwrd">using</span> NHibernate;</pre>
<pre><span class="kwrd">using</span> NHibernate.Criterion;</pre>
<pre class="alt"><span class="kwrd">using</span> NHibernate.SqlCommand;</pre>
<pre><span class="kwrd">using</span> NUnit.Framework;</pre>
<pre class="alt"><span class="kwrd">using</span> Order=LazyLoadEagerLoad.Domain.Order;</pre>
<pre>&nbsp;</pre>
<pre class="alt"><span class="kwrd">namespace</span> LazyLoadEagerLoad.Tests</pre>
<pre>{</pre>
<pre class="alt">    [TestFixture]</pre>
<pre>    <span class="kwrd">public</span> <span class="kwrd">class</span> Order_Fixture : TestFixtureBase</pre>
<pre class="alt">    {</pre>
<pre>        <span class="kwrd">private</span> Order _order;</pre>
<pre class="alt">&nbsp;</pre>
<pre>        <span class="kwrd">protected</span> <span class="kwrd">override</span> <span class="kwrd">void</span> Before_each_test()</pre>
<pre class="alt">        {</pre>
<pre>            <span class="kwrd">base</span>.Before_each_test();</pre>
<pre class="alt">            CreateInitialData();</pre>
<pre>        }</pre>
<pre class="alt">&nbsp;</pre>
<pre>        <span class="kwrd">private</span> <span class="kwrd">void</span> CreateInitialData()</pre>
<pre class="alt">        {</pre>
<pre>            <span class="rem">// create a single customer and an order with two order lines for this customer</span></pre>
<pre class="alt">            var customer = <span class="kwrd">new</span> Customer {CompanyName = <span class="str">"IBM"</span>};</pre>
<pre>            var line1 = <span class="kwrd">new</span> OrderLine {Amount = 5, ProductName = <span class="str">"Laptop XYZ"</span>};</pre>
<pre class="alt">            var line2 = <span class="kwrd">new</span> OrderLine {Amount = 2, ProductName = <span class="str">"Desktop PC A100"</span>};</pre>
<pre>            _order = <span class="kwrd">new</span> Order</pre>
<pre class="alt">                        {</pre>
<pre>                            OrderNumber = <span class="str">"o-100-001"</span>,</pre>
<pre class="alt">                            OrderDate = DateTime.Today,</pre>
<pre>                            Customer = customer</pre>
<pre class="alt">                        };</pre>
<pre>            _order.OrderLines.Add(line1);</pre>
<pre class="alt">            _order.OrderLines.Add(line2);</pre>
<pre>&nbsp;</pre>
<pre class="alt">            <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre>                <span class="kwrd">using</span> (ITransaction transaction = session.BeginTransaction())</pre>
<pre class="alt">                {</pre>
<pre>                    session.Save(customer);</pre>
<pre class="alt">                    session.Save(_order);</pre>
<pre>                    transaction.Commit();</pre>
<pre class="alt">                }</pre>
<pre>        }</pre>
<pre class="alt">    }</pre>
<pre>}</pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>The <b>CreateInitialData</b> method is run before each test. With this we guarantee that each test is side effects free.</p>
<h3>Verifying the default behavior - Lazy Loading</h3>
<p>When loading an order entity from database the default behavior of NHibernate is to lazy load all associated objects of the order entity. Let's write a test to verify this. For the verification we use a utility class provided by NHibernate (NHibernateUtil) which can test whether an associated object or object collection is initialized (i.e. loaded) or not. The class can also force the initialization of an un-initialized relation.</p>
<div class="csharpcode">
<pre class="alt">[Test]</pre>
<pre><span class="kwrd">public</span> <span class="kwrd">void</span> Customer_and_OrderLines_are_not_loaded_when_loading_Order()</pre>
<pre class="alt">{</pre>
<pre>    Order fromDb;</pre>
<pre class="alt">    <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre>        fromDb = session.Get&lt;Order&gt;(_order.Id);</pre>
<pre class="alt">&nbsp;</pre>
<pre>    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>
<pre class="alt">    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>
<pre>}</pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>The test succeeds and NHibernate generates SQL similar to this one</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">SELECT</span>    order0_.Id <span class="kwrd">as</span> Id0_0_, </pre>
<pre>    order0_.OrderNumber <span class="kwrd">as</span> OrderNum2_0_0_, </pre>
<pre class="alt">    order0_.OrderDate <span class="kwrd">as</span> OrderDate0_0_, </pre>
<pre>    order0_.CustomerId <span class="kwrd">as</span> CustomerId0_0_ </pre>
<pre class="alt"><span class="kwrd">FROM</span>    Orders order0_ </pre>
<pre><span class="kwrd">WHERE</span>    order0_.Id=<span class="str">'15bca5b3-2771-4bee-9923-85bda66318d8'</span></pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>&nbsp;</p>
<p>Now we have a problem: If we want to access the order line items (after the session has been closed) we get an exception. Since the session is closed NHibernate cannot lazily load the order line items for us. We can show this behavior with the following test method</p>
<div class="csharpcode">
<pre class="alt">[Test]</pre>
<pre>[ExpectedException(<span class="kwrd">typeof</span>(LazyInitializationException))]</pre>
<pre class="alt"><span class="kwrd">public</span> <span class="kwrd">void</span> Accessing_customer_of_order_after_session_is_closed_throws()</pre>
<pre>{</pre>
<pre class="alt">    Order fromDb;</pre>
<pre>    <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre class="alt">        fromDb = session.Get&lt;Order&gt;(_order.Id);</pre>
<pre>    </pre>
<pre class="alt">    <span class="rem">// trying to access the Customer of the order, will throw exception</span></pre>
<pre>    <span class="rem">// Note: at this point the session is already closed</span></pre>
<pre class="alt">    <span class="kwrd">string</span> name = fromDb.Customer.CompanyName;</pre>
<pre>}</pre>
</div>
<p>Note: the above test <b>only</b> succeeds if the method throws the expected exception of type <b>LazyInitializationException</b>. And this is just what we want to show!
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>Another problem is the <b>n+1 select statements problem</b>. If we access the order line items after loading the order we generate a select statement for each line item we access. Thus if we have n line items and want to access them all we generate one select statement for the order itself and n select statements for all line items (result: n+1 select statements). This can make our data fetching rather slow and put a (unnecessary) burden onto our database.</p>
<p>We can simulate this behavior with this test method</p>
<div class="csharpcode">
<pre class="alt">[Test]</pre>
<pre><span class="kwrd">public</span> <span class="kwrd">void</span> Show_n_plus_1_select_behavior()</pre>
<pre class="alt">{</pre>
<pre>    <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre class="alt">    {</pre>
<pre>        var fromDb = session.Get&lt;Order&gt;(_order.Id);</pre>
<pre class="alt">        <span class="kwrd">int</span> sum = 0;</pre>
<pre>        <span class="kwrd">foreach</span> (var line <span class="kwrd">in</span> fromDb.OrderLines)</pre>
<pre class="alt">        {</pre>
<pre>            <span class="rem">// just some dummy code to force loading of order line</span></pre>
<pre class="alt">            sum += line.Amount;</pre>
<pre>        } </pre>
<pre class="alt">    }</pre>
<pre>}</pre>
</div>
<p>NHibernate will generate SQL similar to the following
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<div class="csharpcode">
<pre class="alt">SELECT order0_.Id <span class="kwrd">as</span> Id3_0_, </pre>
<pre>       order0_.OrderNumber <span class="kwrd">as</span> OrderNum2_3_0_, </pre>
<pre class="alt">       order0_.OrderDate <span class="kwrd">as</span> OrderDate3_0_, </pre>
<pre>       order0_.Customer <span class="kwrd">as</span> Customer3_0_ </pre>
<pre class="alt">FROM   Orders order0_ </pre>
<pre>WHERE  order0_.Id=<span class="str">'5b2dbcb7-d0bf-4c53-86aa-8cd40cb5061a'</span></pre>
<pre class="alt">&nbsp;</pre>
<pre>SELECT orderlines0_.OrderId <span class="kwrd">as</span> OrderId1_, </pre>
<pre class="alt">       orderlines0_.Id <span class="kwrd">as</span> Id1_, </pre>
<pre>       orderlines0_.Id <span class="kwrd">as</span> Id4_0_, </pre>
<pre class="alt">       orderlines0_.Amount <span class="kwrd">as</span> Amount4_0_, </pre>
<pre>       orderlines0_.ProductName <span class="kwrd">as</span> ProductN3_4_0_ </pre>
<pre class="alt">FROM   OrderLine orderlines0_ </pre>
<pre>WHERE  orderlines0_.OrderId=<span class="str">'5b2dbcb7-d0bf-4c53-86aa-8cd40cb5061a'</span></pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>This time we have been lucky! NHibernate has automatically generated an optimized query for us and has loaded the 2 order line items in one go. But this is not always the case! Imagine having a collection with several 100 items and you only need to access one or two of them. It would be a waste of resources to always load all items.</p>
<p>But fortunately we have a solution for these kind of problems with NHibernate. It's called eagerly loading.</p>
<h3>Eagerly loading with the NHibernateUtil class</h3>
<p>If you know you need have access to related objects of the order entity you can use the <b>NHibernateUtil</b> class to initialize the related objects (that is: to fetch them from the database). Have a look at this test methods</p>
<div class="csharpcode">
<pre class="alt">[Test]</pre>
<pre><span class="kwrd">public</span> <span class="kwrd">void</span> Can_initialize_customer_of_order_with_nhibernate_util()</pre>
<pre class="alt">{</pre>
<pre>    Order fromDb;</pre>
<pre class="alt">    <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre>    {</pre>
<pre class="alt">        fromDb = session.Get&lt;Order&gt;(_order.Id);</pre>
<pre>        NHibernateUtil.Initialize(fromDb.Customer);</pre>
<pre class="alt">    }</pre>
<pre>&nbsp;</pre>
<pre class="alt">    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>
<pre>    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>
<pre class="alt">}</pre>
<pre>&nbsp;</pre>
<pre class="alt">[Test]</pre>
<pre><span class="kwrd">public</span> <span class="kwrd">void</span> Can_initialize_order_lines_of_order_with_nhibernate_util()</pre>
<pre class="alt">{</pre>
<pre>    Order fromDb;</pre>
<pre class="alt">    <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre>    {</pre>
<pre class="alt">        fromDb = session.Get&lt;Order&gt;(_order.Id);</pre>
<pre>        NHibernateUtil.Initialize(fromDb.OrderLines);</pre>
<pre class="alt">    }</pre>
<pre>&nbsp;</pre>
<pre class="alt">    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>
<pre>    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>
<pre class="alt">}</pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>With this utility class you can initialize single objects as well as collection of objects. In each case NHibernate will send 2 select statements to the database. One to select the order and one to initialize the related object(s).</p>
<h3>Eagerly loading with HQL</h3>
<p>If you know that you want to load all order items of a given order then you can tell NHibernate to do so and eagerly load all order lines together with the order in one go. The following test method shows how you can formulate a HQL query which not only loads the order but also the associated customer and order lines.</p>
<div class="csharpcode">
<pre class="alt">[Test]</pre>
<pre><span class="kwrd">public</span> <span class="kwrd">void</span> Can_eagerly_load_order_aggregate_with_hql_query()</pre>
<pre class="alt">{</pre>
<pre>    Order fromDb;</pre>
<pre class="alt">    <span class="kwrd">using</span> (ISession session = SessionFactory.OpenSession())</pre>
<pre>    {</pre>
<pre class="alt">        <span class="kwrd">string</span> sql = <span class="str">"from Order o"</span> +</pre>
<pre>                     <span class="str">" inner join fetch o.OrderLines"</span> +</pre>
<pre class="alt">                     <span class="str">" inner join fetch o.Customer"</span> +</pre>
<pre>                     <span class="str">" where o.Id=:id"</span>;</pre>
<pre class="alt">        fromDb = session.CreateQuery(sql)</pre>
<pre>                        .SetGuid(<span class="str">"id"</span>, _order.Id)</pre>
<pre class="alt">                        .UniqueResult&lt;Order&gt;();</pre>
<pre>    }</pre>
<pre class="alt">    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>
<pre>    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>
<pre class="alt">}</pre>
</div>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>The resulting sql generated by NHibernate is then similar to this one</p>
<pre class="csharpcode"><span class="kwrd">select</span>      order0_.Id <span class="kwrd">as</span> Id0_0_, <br />            orderlines1_.Id <span class="kwrd">as</span> Id1_1_, <br />            customer2_.Id <span class="kwrd">as</span> Id2_2_, <br />            order0_.OrderNumber <span class="kwrd">as</span> OrderNum2_0_0_, <br />            order0_.OrderDate <span class="kwrd">as</span> OrderDate0_0_, <br />            order0_.CustomerId <span class="kwrd">as</span> CustomerId0_0_, <br />            orderlines1_.Amount <span class="kwrd">as</span> Amount1_1_, <br />            orderlines1_.ProductName <span class="kwrd">as</span> ProductN3_1_1_, <br />            customer2_.CompanyName <span class="kwrd">as</span> CompanyN2_2_2_, <br />            orderlines1_.OrderId <span class="kwrd">as</span> OrderId0__, <br />            orderlines1_.Id <span class="kwrd">as</span> Id0__ <br /><span class="kwrd">from</span>        Orders order0_ <br /><span class="kwrd">inner</span> <span class="kwrd">join</span>  OrderLine orderlines1_ <span class="kwrd">on</span> order0_.Id=orderlines1_.OrderId <br /><span class="kwrd">inner</span> <span class="kwrd">join</span>  Customer customer2_ <span class="kwrd">on</span> order0_.CustomerId=customer2_.Id <br /><span class="kwrd">where</span>       order0_.Id=<span class="str">'409ebd99-3206-459b-bfed-6df989284da9'</span></pre>
<p>
<style type="text/css"><!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>NHibernate has created an SQL select statement which joins the 3 tables involved, namely <b>Orders</b>, <b>Customer</b> and <b>OrderLine</b>. The returned (flat) set of records is then used by NHibernate to build up the object tree with the order entity as a root.</p>
<h2>Aggregates in the Domain</h2>
<p>DDD defines the concept of <a href="http://domaindrivendesign.org/discussion/messageboardarchive/Aggregates.html">aggregates</a>. A short definition of an aggregate is "<i>A cluster of associated objects that are treated as a unit for the purpose of data changes.". </i>An aggregate always has a <i>root</i>.<i>&nbsp;</i>In this context we can define the following aggregate in our domain</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_8.png"><img src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/LazyLoadingEagerLoadingAggDomain.png" /></a> </p>
<p>The order entity is the <i>root</i> and the order lines belong to the aggregate (can be regarded as children of the <i>root</i>). When creating a new order or changing an existing one we only want to modify either the order itself or its order lines. We certainly do not want to change the customer entity because this would be a completely different use case and does not belong to the <i>order management</i> use case.</p>
<p>So, when dealing with aggregates we often want to load the complete aggregate in one go! This is the perfect example for using <b>eager loading</b> techniques.</p>
<h2>Summary</h2>
<p>I have introduced the concept of lazy loading as provided by NHibernate. I have discussed the consequences and shown how to avoid negative side effects by using different techniques of so called eager loading.</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Blog-Signature-Gabriel_5F00_2.png"><img style="border-top-width: 0px; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" alt="Blog Signature Gabriel" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Blog-Signature-Gabriel_5F00_thumb.png" width="244" border="0" height="21" /></a></p>
