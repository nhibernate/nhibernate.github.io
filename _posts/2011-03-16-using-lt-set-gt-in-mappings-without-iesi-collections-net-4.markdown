---
layout: post
title: "Using &lt;set /&gt; in mappings without Iesi.Collections (.Net 4)"
date: 2011-03-16 01:26:06 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["collections"]
alias: ["/blogs/nhibernate/archive/2011/03/15/using-lt-set-gt-in-mappings-without-iesi-collections-net-4.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>I’ve created a new nuget package; “NHibernate.SetForNet4”. </p>  <p>The package is only one file that will be inserted in your project. This class contains the implementation for the Set&lt;T&gt; and SortedSet&lt;T&gt;.</p>  <p>After you install NHibernate.SetForNet4; the only thing you have to do is to add the collection factory to your configuration as follows:</p>  <pre class="csharpcode">configuration.Properties[Environment.CollectionTypeFactoryClass] 
        = <span class="kwrd">typeof</span>(Net4CollectionTypeFactory).AssemblyQualifiedName; </pre>
<style type="text/css">




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
.csharpcode .lnum { color: #606060; }</style>

<br />this is a sample mapping: 

<pre class="csharpcode"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">=&quot;1.0&quot;</span> <span class="attr">encoding</span><span class="kwrd">=&quot;utf-8&quot;</span> ?<span class="kwrd">&gt;</span>
<span class="kwrd">&lt;</span><span class="html">hibernate-mapping</span> <span class="attr">xmlns</span><span class="kwrd">=&quot;urn:nhibernate-mapping-2.2&quot;</span>
        <span class="attr">assembly</span><span class="kwrd">=&quot;NHibernateSetForNet4&quot;</span>
        <span class="attr">namespace</span><span class="kwrd">=&quot;NHibernateSetForNet4&quot;</span><span class="kwrd">&gt;</span>
  <span class="kwrd">&lt;</span><span class="html">class</span> <span class="attr">name</span><span class="kwrd">=&quot;Person&quot;</span><span class="kwrd">&gt;</span>
    <span class="kwrd">&lt;</span><span class="html">id</span> <span class="attr">name</span><span class="kwrd">=&quot;Id&quot;</span><span class="kwrd">&gt;</span>
      <span class="kwrd">&lt;</span><span class="html">generator</span> <span class="attr">class</span><span class="kwrd">=&quot;hilo&quot;</span><span class="kwrd">/&gt;</span>
    <span class="kwrd">&lt;/</span><span class="html">id</span><span class="kwrd">&gt;</span>
    
    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">=&quot;Name&quot;</span> <span class="kwrd">/&gt;</span>
    
    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">=&quot;Age&quot;</span> <span class="kwrd">/&gt;</span>

    <span class="kwrd">&lt;</span><span class="html">set</span> <span class="attr">name</span><span class="kwrd">=&quot;Tags&quot;</span> <span class="attr">access</span><span class="kwrd">=&quot;field.camelcase&quot;</span><span class="kwrd">&gt;</span>
      <span class="kwrd">&lt;</span><span class="html">key</span> <span class="attr">column</span><span class="kwrd">=&quot;PersonId&quot;</span> <span class="kwrd">/&gt;</span>
      <span class="kwrd">&lt;</span><span class="html">element</span> <span class="attr">column</span><span class="kwrd">=&quot;Tag&quot;</span> <span class="kwrd">/&gt;</span>
    <span class="kwrd">&lt;/</span><span class="html">set</span><span class="kwrd">&gt;</span>

    <span class="kwrd">&lt;</span><span class="html">set</span> <span class="attr">name</span><span class="kwrd">=&quot;Childs&quot;</span> 
        <span class="attr">access</span><span class="kwrd">=&quot;field.camelcase&quot;</span> 
        <span class="attr">cascade</span><span class="kwrd">=&quot;persist&quot;</span> 
        <span class="attr">sort</span><span class="kwrd">=&quot;PersonByAgeComparator&quot;</span><span class="kwrd">&gt;</span>
      <span class="kwrd">&lt;</span><span class="html">key</span> <span class="attr">column</span><span class="kwrd">=&quot;ParentId&quot;</span> <span class="kwrd">/&gt;</span>
      <span class="kwrd">&lt;</span><span class="html">one-to-many</span> <span class="attr">class</span><span class="kwrd">=&quot;Person&quot;</span> <span class="kwrd">/&gt;</span>
    <span class="kwrd">&lt;/</span><span class="html">set</span><span class="kwrd">&gt;</span>

  <span class="kwrd">&lt;/</span><span class="html">class</span><span class="kwrd">&gt;</span>
<span class="kwrd">&lt;/</span><span class="html">hibernate-mapping</span><span class="kwrd">&gt;</span></pre>

<p>this is the class:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">class</span> Person
{
    <span class="kwrd">private</span> <span class="kwrd">readonly</span> ISet&lt;<span class="kwrd">string</span>&gt; tags 
        = <span class="kwrd">new</span> HashSet&lt;<span class="kwrd">string</span>&gt;();
    <span class="kwrd">private</span> <span class="kwrd">readonly</span> ISet&lt;Person&gt; childs 
        = <span class="kwrd">new</span> SortedSet&lt;Person&gt;(<span class="kwrd">new</span> PersonByAgeComparator());

    <span class="kwrd">public</span> <span class="kwrd">virtual</span> <span class="kwrd">int</span> Id { get; set; }

    <span class="kwrd">public</span> <span class="kwrd">virtual</span> <span class="kwrd">string</span> Name { get; set; }

    <span class="kwrd">public</span> <span class="kwrd">virtual</span> <span class="kwrd">int</span> Age { get; set; }

    <span class="kwrd">public</span> <span class="kwrd">virtual</span> ISet&lt;<span class="kwrd">string</span>&gt; Tags
    {
        get { <span class="kwrd">return</span> tags; }
    }

    <span class="kwrd">public</span> <span class="kwrd">virtual</span> ISet&lt;Person&gt; Childs
    {
        get
        {
            <span class="kwrd">return</span> childs;
        }
    }
}</pre>

<p><style type="text/css">



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
.csharpcode .lnum { color: #606060; }</style></p>

<p>ISet&lt;T&gt;, HashSet&lt;T&gt; and SortedSet&lt;T&gt; are from System.Collections.Generics (.Net 4).</p>

<p>All these tests are green:</p>

<pre class="csharpcode">[TestFixture]
<span class="kwrd">public</span> <span class="kwrd">class</span> Fixture
{
    <span class="kwrd">private</span> ISessionFactory sessionFactory;
    <span class="kwrd">private</span> <span class="kwrd">int</span> personId;

    [TestFixtureSetUp]
    <span class="kwrd">public</span> <span class="kwrd">void</span> SetUp()
    {
        var configuration = <span class="kwrd">new</span> Configuration();
        configuration.Properties[Environment.CollectionTypeFactoryClass]
                = <span class="kwrd">typeof</span>(Net4CollectionTypeFactory).AssemblyQualifiedName;
        configuration.Configure();
        

        var schemaExport = <span class="kwrd">new</span> SchemaExport(configuration);
        schemaExport.Execute(<span class="kwrd">true</span>, <span class="kwrd">true</span>, <span class="kwrd">false</span>);
        sessionFactory = configuration.BuildSessionFactory();
        InitializeData();
    }

    <span class="kwrd">private</span> <span class="kwrd">void</span> InitializeData()
    {
        <span class="kwrd">using</span> (var s = sessionFactory.OpenSession())
        <span class="kwrd">using</span> (var tx = s.BeginTransaction())
        {
            var person = <span class="kwrd">new</span> Person
            {
                Name = <span class="str">&quot;Pipo&quot;</span>
            };
            person.Childs.Add(<span class="kwrd">new</span> Person { Name = <span class="str">&quot;Jose&quot;</span>, Age = 1 });
            person.Childs.Add(<span class="kwrd">new</span> Person { Name = <span class="str">&quot;Juan&quot;</span>, Age = 5 });
            person.Childs.Add(<span class="kwrd">new</span> Person { Name = <span class="str">&quot;Francisco&quot;</span>, Age = 10 });

            person.Tags.Add(<span class="str">&quot;one&quot;</span>);
            person.Tags.Add(<span class="str">&quot;two&quot;</span>);
            person.Tags.Add(<span class="str">&quot;three&quot;</span>);

            s.Persist(person);
            personId = person.Id;
            tx.Commit();
        }
    }

    [Test]
    <span class="kwrd">public</span> <span class="kwrd">void</span> CanGetAPersonWithTags()
    {
        <span class="kwrd">using</span>(var s = sessionFactory.OpenSession())
        <span class="kwrd">using</span> (s.BeginTransaction())
        {
            var person = s.Get&lt;Person&gt;(personId);
            person.Tags.Should().Have.SameValuesAs(<span class="str">&quot;one&quot;</span>, <span class="str">&quot;two&quot;</span>, <span class="str">&quot;three&quot;</span>);
        }
    }
    
    [Test]
    <span class="kwrd">public</span> <span class="kwrd">void</span> SortedSetShouldWork()
    {
        <span class="kwrd">using</span> (var s = sessionFactory.OpenSession())
        <span class="kwrd">using</span> (s.BeginTransaction())
        {
            var person = s.Get&lt;Person&gt;(personId);
            person.Childs
                .Select(p =&gt; p.Age).ToArray()
                .Should().Have.SameSequenceAs(10, 5, 1);
        }
    }


    [Test]
    <span class="kwrd">public</span> <span class="kwrd">void</span> LazyLoadShouldWork()
    {
        <span class="kwrd">using</span> (var s = sessionFactory.OpenSession())
        <span class="kwrd">using</span> (s.BeginTransaction())
        {
            var person = s.Get&lt;Person&gt;(personId);
            s.Statistics.EntityCount.Should().Be.EqualTo(1);
            person.Childs.ToArray();
            s.Statistics.EntityCount.Should().Be.EqualTo(4);

        }
    }
}</pre>

<p>The implementation of the proxy collections is a copy from the Iesi version. Let me know if you find some bug. The raw code is <a href="https://bitbucket.org/jfromaniello/nhibernate.setfornet4">here</a>.</p>

<p>Note: you still need Iesi.Collections.dll somewhere because nhibernate internals are tied to these collections, but you don’t longer need to reference it in your domain.</p>
