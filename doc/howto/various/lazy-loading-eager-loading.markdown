---
layout: default
title: Lazy loading - eager loading
---
In this article I want to discuss the [lazy loading](http://martinfowler.com/eaaCatalog/lazyLoad.html) mechanism provided by NHibernate. It is recommended for maximum flexibility to define all relations in your domain as lazy loadable. This is the default behavior of NHibernate since version 1.2\. But this can lead to some undesired effects if querying your data. Let's discuss these effects and how to avoid them.

In my previous posts I showed [how to prepare your system for NHibernate](http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/03/31/prepare-your-system-for-nhibernate.aspx) and [how to implement a first NHibernate base application](/doc/tutorials/first-nh-app/your-first-nhibernate-based-application.html). This post is based on those two articles.

## The Domain

Let's first define a simple domain. It shows part of an order entry system. I keep this model as simple as possible (a real domain model would be more complex) but it contains all aspects we want to discuss in this post. Below is the class diagram of our model

![](LazyLoadingEagerLoadingDomain.png)

We have an order entity which can be placed by a customer entity. Each order can have many order line entities. Each of the three entity types is uniquely identified by a property Id (surrogate key).

## The Mapping Files

We have to write one mapping file per entity. It is recommended that you always have one mapping per file. Don't forget to set the **Build Action** of each mapping file to **Embedded Resource**. People often tend to forget it and the subsequent errors raised by NHibernate are not always obvious. Also do not forget to give the mapping files the correct name, that is *.**hbm**.xml where * denotes the placeholder for the entity name.

The mapping for the **Order** entity might be implemented as follows

<pre style="width:100%;">

<div>
<span style="color:#0000FF;"><?</span><span style="color:#FF00FF;">xml version="1.0" encoding="utf-8"</span> <span style="color:#0000FF;">?></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">hibernate-mapping</span> <span style="color:#FF0000;">xmlns</span><span style="color:#0000FF;">="urn:nhibernate-mapping-2.2"</span> <span style="color:#FF0000;">assembly</span><span style="color:#0000FF;">="LazyLoadEagerLoad"</span> <span style="color:#FF0000;">namespace</span><span style="color:#0000FF;">="LazyLoadEagerLoad.Domain"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">class</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Order"</span> <span style="color:#FF0000;">table</span><span style="color:#0000FF;">="Orders"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">id</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Id"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">generator</span> <span style="color:#FF0000;">class</span><span style="color:#0000FF;">="guid"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">id</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">property</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="OrderNumber"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">property</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="OrderDate"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">many-to-one</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Customer"</span> <span style="color:#FF0000;"></span> <span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">set</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="OrderLines"</span> <span style="color:#FF0000;">cascade</span><span style="color:#0000FF;">="all-delete-orphan"</span> <span style="color:#FF0000;"></span> <span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">key</span> <span style="color:#FF0000;">column</span><span style="color:#0000FF;">="OrderId"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">one-to-many</span> <span style="color:#FF0000;">class</span><span style="color:#0000FF;">="OrderLine"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">set</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">class</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">hibernate-mapping</span><span style="color:#0000FF;">></span>
</div>

</pre>

Analogous you can implement the mappings for the **Customer** entity

<div class="wlWriterEditableSmartContent" id="scid:F2210F5F-69EB-4d4c-AFF7-B8A050E9CC72:3acfe276-b736-4c58-88ae-7c262976b50f" style="padding-right:0px;display:inline;padding-left:0px;float:none;padding-bottom:0px;margin:0px;padding-top:0px;">

<pre style="width:100%;">

<div>
<span style="color:#0000FF;"><?</span><span style="color:#FF00FF;">xml version="1.0" encoding="utf-8"</span> <span style="color:#0000FF;">?></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">hibernate-mapping</span> <span style="color:#FF0000;">xmlns</span><span style="color:#0000FF;">="urn:nhibernate-mapping-2.2"</span> <span style="color:#FF0000;">assembly</span><span style="color:#0000FF;">="LazyLoadEagerLoad"</span> <span style="color:#FF0000;">namespace</span><span style="color:#0000FF;">="LazyLoadEagerLoad.Domain"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">class</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Customer"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">id</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Id"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">generator</span> <span style="color:#FF0000;">class</span><span style="color:#0000FF;">="guid"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">id</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">property</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="CompanyName"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">class</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">hibernate-mapping</span><span style="color:#0000FF;">></span>
</div>

</pre>

</div>

and finally the mapping for the **OrderLine** entity.

<div class="wlWriterEditableSmartContent" id="scid:F2210F5F-69EB-4d4c-AFF7-B8A050E9CC72:23053d0d-5f88-44d1-8099-ff8406d62f4e" style="padding-right:0px;display:inline;padding-left:0px;float:none;padding-bottom:0px;margin:0px;padding-top:0px;">

<pre style="width:100%;">

<div>
<span style="color:#0000FF;"><?</span><span style="color:#FF00FF;">xml version="1.0" encoding="utf-8"</span> <span style="color:#0000FF;">?></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">hibernate-mapping</span> <span style="color:#FF0000;">xmlns</span><span style="color:#0000FF;">="urn:nhibernate-mapping-2.2"</span> <span style="color:#FF0000;">assembly</span><span style="color:#0000FF;">="LazyLoadEagerLoad"</span> <span style="color:#FF0000;">namespace</span><span style="color:#0000FF;">="LazyLoadEagerLoad.Domain"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">class</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="OrderLine"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">id</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Id"</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">generator</span> <span style="color:#FF0000;">class</span><span style="color:#0000FF;">="guid"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">id</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">property</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="Amount"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"><</span><span style="color:#800000;">property</span> <span style="color:#FF0000;">name</span><span style="color:#0000FF;">="ProductName"</span><span style="color:#0000FF;">/></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">class</span><span style="color:#0000FF;">></span> <span style="color:#000000;"></span> <span style="color:#0000FF;"></</span><span style="color:#800000;">hibernate-mapping</span><span style="color:#0000FF;">></span>
</div>

</pre>

</div>

## Testing the Mapping

To test the mapping we use the following test method

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;max-height:370px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<div style="line-height:12pt;background-color:#f4f4f4;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> LazyLoadEagerLoad.Domain;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate.Cfg;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate.Tool.hbm2ddl;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NUnit.Framework;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">namespace</span> LazyLoadEagerLoad.Tests</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">{</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    [TestFixture]</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">class</span> GenerateSchema_Fixture</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        [Test]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Can_generate_schema()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            var cfg = <span style="color:#0000ff;">new</span> Configuration();</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            cfg.Configure();</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            cfg.AddAssembly(<span style="color:#0000ff;">typeof</span>(Order).Assembly);</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            <span style="color:#0000ff;">new</span> SchemaExport(cfg).Execute(<span style="color:#0000ff;">false</span>, <span style="color:#0000ff;">true</span>, <span style="color:#0000ff;">false</span>, <span style="color:#0000ff;">false</span>);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">}</pre>

</div>

</div>

First we create a new instance of the NHibernate Configuration class and tell it to configure itself. Since we don't provide any explicit configuration here in the code NHibernate looks out for an adequate configuration file. I have included such a file (called hibernate.cfg.xml) in my project. Please consult [this](http://blogs.hibernatingrhinos.com/nhibernate/archive/2008/04/01/your-first-nhibernate-based-application.aspx) previous post for further details about the configuration file.

## Testing the Loading Behavior of NHibernate

### Defining a base class for our tests

To avoid repetitive task ([DRY](http://en.wikipedia.org/wiki/Don't_repeat_yourself) principle) we implement the following base class.

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:866px;max-height:866px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<div style="line-height:12pt;background-color:#f4f4f4;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> LazyLoadEagerLoad.Domain;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate.Cfg;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate.Tool.hbm2ddl;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NUnit.Framework;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">namespace</span> LazyLoadEagerLoad.Tests</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">{</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">class</span> TestFixtureBase</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">private</span> Configuration _configuration;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">private</span> ISessionFactory _sessionFactory;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">protected</span> ISessionFactory SessionFactory</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            get { <span style="color:#0000ff;">return</span> _sessionFactory; }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        [TestFixtureSetUp]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> TestFixtureSetUp()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _configuration = <span style="color:#0000ff;">new</span> Configuration();</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _configuration.Configure();</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _configuration.AddAssembly(<span style="color:#0000ff;">typeof</span>(Customer).Assembly);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _sessionFactory = _configuration.BuildSessionFactory();</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        [TestFixtureTearDown]</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> TestFixtureTearDown()</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _sessionFactory.Close();</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        [SetUp]</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> SetupContext()</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            <span style="color:#0000ff;">new</span> SchemaExport(_configuration).Execute(<span style="color:#0000ff;">false</span>, <span style="color:#0000ff;">true</span>, <span style="color:#0000ff;">false</span>, <span style="color:#0000ff;">false</span>);</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            Before_each_test();</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        [TearDown]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> TearDownContext()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            After_each_test();</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">protected</span> <span style="color:#0000ff;">virtual</span> <span style="color:#0000ff;">void</span> Before_each_test()</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        { }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">protected</span> <span style="color:#0000ff;">virtual</span> <span style="color:#0000ff;">void</span> After_each_test()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        { }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">}</pre>

</div>

</div>

When the test fixture is started, the base class configures NHibernate and creates a session factory (**TestFixtureSetUp**). When the whole test fixture is ended the session factory is closed (**TestFixtureTearDown**).

Before each test in the fixture is run the database schema is (re-) created and the virtual **Before_each_test** method is called. After each test in the fixture is finished the virtual **After_each_test** method is called. The two virtual methods can (but must not necessarily) be overridden in a child class.

All our test fixtures we implement will derive from this base class.

### Filling the database with test data

To be able to test the loading behavior of NHibernate we need some test data in our database. We create this test data every time a test is run (just after the database schema is re-created). We add a new class **Order_Fixture** to our test project and inherit from the **TestFixtureBase** base class. Then we override the Before_each_test method and call a helper method which creates our initial data. We create just the absolute minimum of data we need (again -->DRY). That is: one customer placing one order with two order lines.

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:Consolas,'Courier New',Courier,Monospace;max-height:749px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<div style="line-height:12pt;background-color:#f4f4f4;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> System;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> LazyLoadEagerLoad.Domain;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate.Criterion;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NHibernate.SqlCommand;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> NUnit.Framework;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">using</span> Order=LazyLoadEagerLoad.Domain.Order;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">namespace</span> LazyLoadEagerLoad.Tests</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">{</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    [TestFixture]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    <span style="color:#0000ff;">public</span> <span style="color:#0000ff;">class</span> Order_Fixture : TestFixtureBase</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">private</span> Order _order;</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">protected</span> <span style="color:#0000ff;">override</span> <span style="color:#0000ff;">void</span> Before_each_test()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            <span style="color:#0000ff;">base</span>.Before_each_test();</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            CreateInitialData();</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">private</span> <span style="color:#0000ff;">void</span> CreateInitialData()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            <span style="color:#008000;">// create a single customer and an order with two order lines for this customer</span></pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            var customer = <span style="color:#0000ff;">new</span> Customer {CompanyName = <span style="color:#006080;">"IBM"</span>};</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            var line1 = <span style="color:#0000ff;">new</span> OrderLine {Amount = 5, ProductName = <span style="color:#006080;">"Laptop XYZ"</span>};</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            var line2 = <span style="color:#0000ff;">new</span> OrderLine {Amount = 2, ProductName = <span style="color:#006080;">"Desktop PC A100"</span>};</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _order = <span style="color:#0000ff;">new</span> Order</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                        {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                            OrderNumber = <span style="color:#006080;">"o-100-001"</span>,</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                            OrderDate = DateTime.Today,</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                            Customer = customer</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                        };</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _order.OrderLines.Add(line1);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            _order.OrderLines.Add(line2);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">            <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                <span style="color:#0000ff;">using</span> (ITransaction transaction = session.BeginTransaction())</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                {</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                    session.Save(customer);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                    session.Save(_order);</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                    transaction.Commit();</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    }</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:Consolas,'Courier New',Courier,Monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">}</pre>

</div>

</div>

The **CreateInitialData** method is run before each test. With this we guarantee that each test is side effects free.

### Verifying the default behavior - Lazy Loading

When loading an order entity from database the default behavior of NHibernate is to lazy load all associated objects of the order entity. Let's write a test to verify this. For the verification we use a utility class provided by NHibernate (NHibernateUtil) which can test whether an associated object or object collection is initialized (i.e. loaded) or not. The class can also force the initialization of an un-initialized relation.

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:170px;max-height:200px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">[Test]
<span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Customer_and_OrderLines_are_not_loaded_when_loading_Order()
{
    Order fromDb;
    <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())
        fromDb = session.Get<Order>(_order.Id);

    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.Customer));
    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.OrderLines));
}</pre>

</div>

The test succeeds and NHibernate generates SQL similar to this one

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:109px;max-height:200px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">SELECT</span>    order0_.Id <span style="color:#0000ff;">as</span> Id0_0_, 
    order0_.OrderNumber <span style="color:#0000ff;">as</span> OrderNum2_0_0_, 
    order0_.OrderDate <span style="color:#0000ff;">as</span> OrderDate0_0_, 
    order0_.CustomerId <span style="color:#0000ff;">as</span> CustomerId0_0_ 
<span style="color:#0000ff;">FROM</span>    Orders order0_ 
<span style="color:#0000ff;">WHERE</span>    order0_.Id=<span style="color:#006080;">'15bca5b3-2771-4bee-9923-85bda66318d8'</span></pre>

</div>

Now we have a problem: If we want to access the order line items (after the session has been closed) we get an exception. Since the session is closed NHibernate cannot lazily load the order line items for us. We can show this behavior with the following test method

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:202px;max-height:200px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">[Test]
[ExpectedException(<span style="color:#0000ff;">typeof</span>(LazyInitializationException))]
<span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Accessing_customer_of_order_after_session_is_closed_throws()
{
    Order fromDb;
    <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())
        fromDb = session.Get<Order>(_order.Id);

    <span style="color:#008000;">// trying to access the Customer of the order, will throw exception</span>
    <span style="color:#008000;">// Note: at this point the session is already closed</span>
    <span style="color:#0000ff;">string</span> name = fromDb.Customer.CompanyName;
}</pre>

</div>

Note: the above test **only** succeeds if the method throws the expected exception of type **LazyInitializationException**. And this is just what we want to show!

Another problem is the **n+1 select statements problem**. If we access the order line items after loading the order we generate a select statement for each line item we access. Thus if we have n line items and want to access them all we generate one select statement for the order itself and n select statements for all line items (result: n+1 select statements). This can make our data fetching rather slow and put a (unnecessary) burden onto our database.

We can simulate this behavior with this test method

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:233px;max-height:200px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">[Test]
<span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Show_n_plus_1_select_behavior()
{
    <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())
    {
        var fromDb = session.Get<Order>(_order.Id);
        <span style="color:#0000ff;">int</span> sum = 0;
        <span style="color:#0000ff;">foreach</span> (var line <span style="color:#0000ff;">in</span> fromDb.OrderLines)
        {
            <span style="color:#008000;">// just some dummy code to force loading of order line</span>
            sum += line.Amount;
        } 
    }
}</pre>

</div>

NHibernate will generate SQL similar to the following

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:235px;max-height:200px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">SELECT</span> order0_.Id <span style="color:#0000ff;">as</span> Id3_0_, 
       order0_.OrderNumber <span style="color:#0000ff;">as</span> OrderNum2_3_0_, 
       order0_.OrderDate <span style="color:#0000ff;">as</span> OrderDate3_0_, 
       order0_.Customer <span style="color:#0000ff;">as</span> Customer3_0_ 
<span style="color:#0000ff;">FROM</span>   Orders order0_ 
<span style="color:#0000ff;">WHERE</span>  order0_.Id=<span style="color:#006080;">'5b2dbcb7-d0bf-4c53-86aa-8cd40cb5061a'</span>

<span style="color:#0000ff;">SELECT</span> orderlines0_.OrderId <span style="color:#0000ff;">as</span> OrderId1_, 
       orderlines0_.Id <span style="color:#0000ff;">as</span> Id1_, 
       orderlines0_.Id <span style="color:#0000ff;">as</span> Id4_0_, 
       orderlines0_.Amount <span style="color:#0000ff;">as</span> Amount4_0_, 
       orderlines0_.ProductName <span style="color:#0000ff;">as</span> ProductN3_4_0_ 
<span style="color:#0000ff;">FROM</span>   OrderLine orderlines0_ 
<span style="color:#0000ff;">WHERE</span>  orderlines0_.OrderId=<span style="color:#006080;">'5b2dbcb7-d0bf-4c53-86aa-8cd40cb5061a'</span></pre>

</div>

This time we have been lucky! NHibernate has automatically generated an optimized query for us and has loaded the 2 order line items in one go. But this is not always the case! Imagine having a collection with several 100 items and you only need to access one or two of them. It would be a waste of resources to always load all items.

But fortunately we have a solution for these kind of problems with NHibernate. It's called eagerly loading.

### Eagerly loading with the NHibernateUtil class

If you know you need have access to related objects of the order entity you can use the **NHibernateUtil** class to initialize the related objects (that is: to fetch them from the database). Have a look at this test methods

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:444px;max-height:444px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<div style="line-height:12pt;background-color:#f4f4f4;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">[Test]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Can_initialize_customer_of_order_with_nhibernate_util()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">{</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Order fromDb;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        fromDb = session.Get<Order>(_order.Id);</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        NHibernateUtil.Initialize(fromDb.Customer);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">}</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">[Test]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Can_initialize_order_lines_of_order_with_nhibernate_util()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">{</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Order fromDb;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        fromDb = session.Get<Order>(_order.Id);</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        NHibernateUtil.Initialize(fromDb.OrderLines);</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Assert.IsFalse(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">}</pre>

</div>

</div>

With this utility class you can initialize single objects as well as collection of objects. In each case NHibernate will send 2 select statements to the database. One to select the order and one to initialize the related object(s).

### Eagerly loading with HQL

If you know that you want to load all order items of a given order then you can tell NHibernate to do so and eagerly load all order lines together with the order in one go. The following test method shows how you can formulate a HQL query which not only loads the order but also the associated customer and order lines.

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:286px;max-height:286px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<div style="line-height:12pt;background-color:#f4f4f4;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">[Test]</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">public</span> <span style="color:#0000ff;">void</span> Can_eagerly_load_order_aggregate_with_hql_query()</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">{</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Order fromDb;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    <span style="color:#0000ff;">using</span> (ISession session = SessionFactory.OpenSession())</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    {</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        <span style="color:#0000ff;">string</span> sql = <span style="color:#006080;">"from Order o"</span> +</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                     <span style="color:#006080;">" inner join fetch o.OrderLines"</span> +</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                     <span style="color:#006080;">" inner join fetch o.Customer"</span> +</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                     <span style="color:#006080;">" where o.Id=:id"</span>;</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">        fromDb = session.CreateQuery(sql)</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                        .SetGuid(<span style="color:#006080;">"id"</span>, _order.Id)</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">                        .UniqueResult<Order>();</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    }</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.Customer));</pre>

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">    Assert.IsTrue(NHibernateUtil.IsInitialized(fromDb.OrderLines));</pre>

<pre style="line-height:12pt;background-color:white;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;">}</pre>

</div>

</div>

The resulting sql generated by NHibernate is then similar to this one

<div style="line-height:12pt;background-color:#f4f4f4;margin:20px 0px 10px;width:97.5%;font-family:consolas,'Courier New',courier,monospace;height:261px;max-height:260px;font-size:8pt;overflow:auto;cursor:text;border:gray 1px solid;padding:4px;">

<pre style="line-height:12pt;background-color:#f4f4f4;margin:0em;width:100%;font-family:consolas,'Courier New',courier,monospace;color:black;font-size:8pt;overflow:visible;border-style:none;padding:0px;"><span style="color:#0000ff;">select</span>      order0_.Id <span style="color:#0000ff;">as</span> Id0_0_, 
            orderlines1_.Id <span style="color:#0000ff;">as</span> Id1_1_, 
            customer2_.Id <span style="color:#0000ff;">as</span> Id2_2_, 
            order0_.OrderNumber <span style="color:#0000ff;">as</span> OrderNum2_0_0_, 
            order0_.OrderDate <span style="color:#0000ff;">as</span> OrderDate0_0_, 
            order0_.CustomerId <span style="color:#0000ff;">as</span> CustomerId0_0_, 
            orderlines1_.Amount <span style="color:#0000ff;">as</span> Amount1_1_, 
            orderlines1_.ProductName <span style="color:#0000ff;">as</span> ProductN3_1_1_, 
            customer2_.CompanyName <span style="color:#0000ff;">as</span> CompanyN2_2_2_, 
            orderlines1_.OrderId <span style="color:#0000ff;">as</span> OrderId0__, 
            orderlines1_.Id <span style="color:#0000ff;">as</span> Id0__ 
<span style="color:#0000ff;">from</span>        Orders order0_ 
<span style="color:#0000ff;">inner</span> <span style="color:#0000ff;">join</span>  OrderLine orderlines1_ <span style="color:#0000ff;">on</span> order0_.Id=orderlines1_.OrderId 
<span style="color:#0000ff;">inner</span> <span style="color:#0000ff;">join</span>  Customer customer2_ <span style="color:#0000ff;">on</span> order0_.CustomerId=customer2_.Id 
<span style="color:#0000ff;">where</span>       order0_.Id=<span style="color:#006080;">'409ebd99-3206-459b-bfed-6df989284da9'</span></pre>

</div>

NHibernate has created an SQL select statement which joins the 3 tables involved, namely **Orders**, **Customer** and**OrderLine**. The returned (flat) set of records is then used by NHibernate to build up the object tree with the order entity as a root.

## Aggregates in the Domain

DDD defines the concept of [aggregates](http://domaindrivendesign.org/discussion/messageboardarchive/Aggregates.html). A short definition of an aggregate is "_A cluster of associated objects that are treated as a unit for the purpose of data changes.". _An aggregate always has a _root_.In this context we can define the following aggregate in our domain

![](LazyLoadingEagerLoadingAggDomain.png)

The order entity is the _root_ and the order lines belong to the aggregate (can be regarded as children of the _root_). When creating a new order or changing an existing one we only want to modify either the order itself or its order lines. We certainly do not want to change the customer entity because this would be a completely different use case and does not belong to the _order management_ use case.

So, when dealing with aggregates we often want to load the complete aggregate in one go! This is the perfect example for using **eager loading** techniques.

## Summary

I have introduced the concept of lazy loading as provided by NHibernate. I have discussed the consequences and shown how to avoid negative side effects by using different techniques of so called eager loading.
