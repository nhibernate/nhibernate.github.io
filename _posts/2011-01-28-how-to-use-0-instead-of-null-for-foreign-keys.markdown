---
layout: post
title: "How to use 0 instead of null for foreign keys"
date: 2011-01-28 12:46:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["relation", "Tuplizers", "EntityMode"]
redirect_from: ["/blogs/nhibernate/archive/2011/01/28/how-to-use-0-instead-of-null-for-foreign-keys.aspx/", "/blogs/nhibernate/archive/2011/01/28/how-to-use-0-instead-of-null-for-foreign-keys.html"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>My twitter friend <a href="http://twitter.com/#!/hotgazpacho">@hotgazpacho</a> is having a nightmare with a legacy database, which has the following rule:</p>  <blockquote>   <p>“0 represents the absence of an entity without an actual row in the database”</p> </blockquote>  <p>It is pretty interesting how many times I’ve seen this scenario on nhibernate forums. </p>  <p>The first thing people do is to add “not-found=ignore” to every relationship, but not-found ignore is an evil, because NHibernate need to know if the row exist when lazy load. So not-found ignore is like a lazy loading killer. Also, with not-found=ignore doesn’t work when you insert or update, nhibernate will persist a null value instead of 0. </p>  <p>We want to keep and follow the rule until no legacy applications use this database and we can fix the data, maybe never (or like the spanish saying “provisoriamente para siempre”).</p>  <p>NHibernate is bad in many aspects, but the only thing we can’t blame is extensibility. We can tweak NHibernate to work in this scenario and in many more.</p>  <p>First a test:</p>  <pre class="code">[<span style="color: #2b91af">TestFixture</span>]
<span style="color: blue">public class </span><span style="color: #2b91af">Fixture
</span>{
    <span style="color: blue">private </span><span style="color: #2b91af">ISessionFactory </span>sf;
    <span style="color: blue">private </span><span style="color: #2b91af">Configuration </span>configuration;

    [<span style="color: #2b91af">TestFixtureSetUp</span>]
    <span style="color: blue">public void </span>SetUp()
    {
        configuration = <span style="color: blue">new </span><span style="color: #2b91af">Configuration</span>().Configure();

        <span style="color: green">//export the schema
        </span><span style="color: blue">var </span>schemaExport = <span style="color: blue">new </span><span style="color: #2b91af">SchemaExport</span>(configuration);
        schemaExport.Execute(<span style="color: blue">true</span>, <span style="color: blue">true </span>,<span style="color: blue">false</span>);
        sf = configuration.BuildSessionFactory();
    }

    [<span style="color: #2b91af">TestFixtureTearDown</span>]
    <span style="color: blue">public void </span>TearDown()
    {
        <span style="color: blue">var </span>schemaExport = <span style="color: blue">new </span><span style="color: #2b91af">SchemaExport</span>(configuration);
        schemaExport.Execute(<span style="color: blue">true</span>, <span style="color: blue">true</span>, <span style="color: blue">true</span>);
    }


    [<span style="color: #2b91af">Test</span>]
    <span style="color: blue">public void </span>WhenInsertingAPersonWithNullCountryThenInsert0ValueInCountry()
    {
        <span style="color: blue">int </span>personId;
        <span style="color: blue">using</span>(<span style="color: blue">var </span>s = sf.OpenSession())
        <span style="color: blue">using</span>(<span style="color: blue">var </span>tx = s.BeginTransaction())
        {
            <span style="color: blue">var </span>p = <span style="color: blue">new </span><span style="color: #2b91af">Person </span>{Name = <span style="color: #a31515">&quot;tito&quot;</span>};
            s.Save(p);
            tx.Commit();
            personId = p.Id;
        }
        <span style="color: blue">using</span>(<span style="color: blue">var </span>s = sf.OpenSession())
        {
            s.CreateSQLQuery(<span style="color: #a31515">&quot;select CountryId from Person where id = :id&quot;</span>)
                .SetInt32(<span style="color: #a31515">&quot;id&quot;</span>, personId)
                .UniqueResult&lt;<span style="color: blue">int</span>?&gt;()
                .Should().Be.EqualTo(0);
        }

    }

    [<span style="color: #2b91af">Test</span>]
    <span style="color: blue">public void </span>WhenSelectingAPersonWithCountryWithIdEqualsTo0ThenCountryShouldBeNull()
    {
        <span style="color: blue">int </span>personId;
        <span style="color: blue">using </span>(<span style="color: blue">var </span>s = sf.OpenSession())
        <span style="color: blue">using </span>(<span style="color: blue">var </span>tx = s.BeginTransaction())
        {
            <span style="color: blue">var </span>p = <span style="color: blue">new </span><span style="color: #2b91af">Person </span>{ Name = <span style="color: #a31515">&quot;tito&quot; </span>};
            s.Save(p);
            tx.Commit();
            personId = p.Id;
        }

        <span style="color: blue">using </span>(<span style="color: blue">var </span>s = sf.OpenSession())
        <span style="color: blue">using </span>(s.BeginTransaction())
        {
            s.Get&lt;<span style="color: #2b91af">Person</span>&gt;(personId)
                .Country.Should().Be.Null();

        }

    }
}</pre>

<p>The first test persist a Person with null Country, and goes to the database to test if the CountryId is equals to 0.</p>

<p>The second test, persist a Person with null Country, in other session executes Get&lt;Person&gt; and test if the Country is null.</p>

<p>The mapping for person is trivial:</p>

<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">Person</span>&quot;<span style="color: blue">&gt;
&lt;</span><span style="color: #a31515">id </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">Id</span>&quot;<span style="color: blue">&gt;
  &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>&quot;<span style="color: blue">hilo</span>&quot;<span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">param </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">max_lo</span>&quot;<span style="color: blue">&gt;</span>100<span style="color: blue">&lt;/</span><span style="color: #a31515">param</span><span style="color: blue">&gt;
  &lt;/</span><span style="color: #a31515">generator</span><span style="color: blue">&gt;
&lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;    
&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">Name</span>&quot; <span style="color: blue">/&gt;
&lt;</span><span style="color: #a31515">many-to-one </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">Country</span>&quot; 
             <span style="color: red">class</span><span style="color: blue">=</span>&quot;<span style="color: blue">Country</span>&quot; 
             <span style="color: red">column</span><span style="color: blue">=</span>&quot;<span style="color: blue">CountryId</span>&quot; 
             <span style="color: red">foreign-key</span><span style="color: blue">=</span>&quot;<span style="color: blue">none</span>&quot; <span style="color: blue">/&gt;
&lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;</span></pre>

<p>Note: <strike>I am killing the constraint for this test</strike>&#160; foreign-key=”none” tells the schema export to not create a foreign key, that is how the db must be on real life <img style="border-bottom-style: none; border-right-style: none; border-top-style: none; border-left-style: none" class="wlEmoticon wlEmoticon-winkingsmile" alt="Guiño" src="/images/posts/2011/01/28/wlEmoticon_2D00_winkingsmile_5F00_2AC68689.png" />.</p>

<p>The solution is pretty simple:</p>

<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">NullableTuplizer </span>: <span style="color: #2b91af">PocoEntityTuplizer
</span>{
    <span style="color: blue">public </span>NullableTuplizer(<span style="color: #2b91af">EntityMetamodel </span>entityMetamodel, <span style="color: #2b91af">PersistentClass </span>mappedEntity)
        : <span style="color: blue">base</span>(entityMetamodel, mappedEntity)
    {
    }

    <span style="color: blue">public override object</span>[] GetPropertyValuesToInsert(
        <span style="color: blue">object </span>entity, <span style="color: #2b91af">IDictionary </span>mergeMap, <span style="color: #2b91af">ISessionImplementor </span>session)
    {
        <span style="color: blue">object</span>[] values = <span style="color: blue">base</span>.GetPropertyValuesToInsert(entity, mergeMap, session);
        <span style="color: green">//dirty hack 1
        </span><span style="color: blue">for </span>(<span style="color: blue">int </span>i = 0; i &lt; values.Length; i++)
        {
            <span style="color: blue">if </span>(values[i ] == <span style="color: blue">null </span>&amp;&amp; <span style="color: blue">typeof </span>(<span style="color: #2b91af">IEntity</span>).IsAssignableFrom(getters[i ].ReturnType))
            {
                values[i ] = ProxyFactory.GetProxy(0, <span style="color: blue">null</span>);
            }
        }
        <span style="color: blue">return </span>values;
    }

    <span style="color: blue">public override object</span>[] GetPropertyValues(<span style="color: blue">object </span>entity)
    {
        <span style="color: blue">object</span>[] values = <span style="color: blue">base</span>.GetPropertyValues(entity);
        <span style="color: green">//dirty hack 2
        </span><span style="color: blue">for </span>(<span style="color: blue">int </span>i = 0; i &lt; values.Length; i++)
        {
            <span style="color: blue">if </span>(values[i ] == <span style="color: blue">null </span>&amp;&amp; <span style="color: blue">typeof </span>(<span style="color: #2b91af">IEntity</span>).IsAssignableFrom(getters[i ].ReturnType))
            {
                values[i ] = ProxyFactory.GetProxy(0, <span style="color: blue">null</span>);
            }
        }
        <span style="color: blue">return </span>values;
    }


    <span style="color: blue">public override void </span>SetPropertyValues(<span style="color: blue">object </span>entity, <span style="color: blue">object</span>[] values)
    {
        <span style="color: green">//dirty hack 3.
        </span><span style="color: blue">for </span>(<span style="color: blue">int </span>i = 0; i &lt; values.Length; i++)
        {
            <span style="color: blue">if </span>(<span style="color: blue">typeof </span>(<span style="color: #2b91af">IEntity</span>).IsAssignableFrom(getters[i ].ReturnType)
                &amp;&amp; ((<span style="color: #2b91af">IEntity</span>) values[i ]).Id == 0)
            {
                values[i ] = <span style="color: blue">null</span>;
            }
        }
        <span style="color: blue">base</span>.SetPropertyValues(entity, values);
    }
}</pre>

<p>We lie to nhibernate three times:</p>

<ul>
  <li>When getting the values for insert, we change a&#160; “null” in the Country property, for a proxy of country with Id equals to 0. NHibernate assumes that such country exist and executes: </li>

  <li>When getting the values for update , we do the same than for the insert. </li>

  <li>When loading the values in the entity, we will get a nhibernate proxy or entity with Id = 0, we change this value to null. </li>
</ul>

<p>To register the NullableTuplizer for all the mappings:</p>

<pre class="code"><span style="color: blue">foreach </span>(<span style="color: blue">var </span>persistentClass <span style="color: blue">in </span>configuration.ClassMappings)
{
    persistentClass.AddTuplizer(<span style="color: #2b91af">EntityMode</span>.Poco, <span style="color: blue">typeof</span>(<span style="color: #2b91af">NullableTuplizer</span>).AssemblyQualifiedName);
}</pre>
