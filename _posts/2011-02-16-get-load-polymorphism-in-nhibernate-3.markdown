---
layout: post
title: "Get/Load Polymorphism in NHibernate 3"
date: 2011-02-16 22:46:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["querying"]
alias: ["/blogs/nhibernate/archive/2011/02/16/get-load-polymorphism-in-nhibernate-3.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>[This article was originally published on my personal blog <a href="http://jameskovacs.com/2011/02/16/getload-polymorphism-in-nhibernate-3/">here</a>. I hereby grant myself permission to re-publish it on NHForge.org.]</p>  <p>[Code for this article is available on GitHub <a href="https://github.com/JamesKovacs/NH3Features/tree/03-GetLoadPolymorphism-Updated">here</a>.]</p>  <p>Nothing gets an OO zealot hot under the collar the way the term polymorphism does. You probably have three questions right now… What does polymorphism have to do with object-relational mapping? How does it relate to NHibernate? And why should I care?</p>  <p>An ORM that supports polymorphic loading allows us to request one type of object, but potentially get an object of a derived type back. As an example, let's say we have the following simple inheritance hierarchy in our application:</p>  <p><img style="border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" title="Animal Inheritance Hierarchy" border="0" alt="Animal Inheritance Hierarchy" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/_5F00_ClassDiagram_5F00_35C5B6A3.png" width="383" height="233" /></p>  <p>We can query for an Animal, but receive back an instance of Dog or Cat instead.</p>  <pre class="brush: csharp;">var dog = session.Get&lt;Animal&gt;(dogId);</pre>

<p>NHibernate has supported this type of polymorphic loading behaviour for awhile, but the base class (or interface) had to be mapped. If it wasn’t, polymorphic loading would only work when querying with Criteria or LINQ. The following works for both NH 2.1.2 and NH3 regardless of whether the Animal base class is mapped or not.</p>

<pre class="brush: csharp;">var animal = session.CreateCriteria&lt;Animal&gt;()
                    .Add(Restrictions.IdEq(dogId))
                    .UniqueResult&lt;Animal&gt;();

// N.B. Use session.Linq&lt;Animal&gt;() in NH2.1.2
var query = from a in session.Query&lt;Animal&gt;()
            where a.Id == dogId
            select a;
var animal = query.Single();</pre>

<p>In NHibernate 2.1.2 and earlier, ISession.Get&lt;T&gt;(id) or ISession.Load&lt;T&gt;(id) would fail if T was an unmapped base class or interface. With NHibernate 3, these methods now work regardless of whether T is mapped or not.*</p>

<pre class="brush: csharp;">// Works in NH3; works in NH2.1.2 only if Animal is mapped
// In the sample code, works in NH3 for both Animal and UnmappedAnimal base classes
// In NH2.1.2 and before, works for Animal (mapped), but not UnmappedAnimal
var dog = session.Get&lt;Animal&gt;(dogId);
var cat = session.Load&lt;Animal&gt;(catId);</pre>

<p>ASIDE: ISession.Get(id) returns null when the entity doesn’t exist in the database, whereas ISession.Load(id) throws an exception. Generally ISession.Load(id) is preferred if you know the entity should exist as NHibernate can return a proxy object that delays hitting the database until the last possible moment. ISession.Get(id) requires querying the database immediately because there is no way to return an object (e.g. a proxy), but later change it to null when accessed.</p>

<p>In NHibernate 3, polymorphic loading works for Criteria, LINQ, and Get/Load. <strike>It has not been implemented for HQL. (If you want/need this feature, the NHibernate team is always willing to accept a feature request with patch.)</strike> HQL in NH3 supports polymorphic loading if the queried class is imported via &lt;import class=”UnmappedClass”/&gt; in a hbm.xml file.</p>

<pre class="brush: csharp;">// Criteria works in NH2.1.2 and NH3
var animal = session.CreateCriteria&lt;UnmappedAnimal&gt;()
                    .Add(Restrictions.IdEq(dogId))
                    .UniqueResult&lt;UnmappedAnimal&gt;());

// LINQ works in NH2.1.2 and NH3 (NH2.1.2 uses session.Linq&lt;T&gt;())
var query = from a in session.Query&lt;UnmappedAnimal&gt;()
            where a.Id == dogId
            select a;
var animal = query.Single();

// Get/Load works in NH3, but fails in NH2.1.2 and earlier
var animal = session.Get&lt;UnmappedAnimal&gt;(dogId);

// HQL works for NH3 if UnmappedAnimal is imported, but fails for NH2.1.2
var animal = session.CreateQuery(&quot;from a in AbstractAnimal where a.id = :id&quot;)
                    .SetParameter(&quot;id&quot;, dogId)
                    .UniqueResult&lt;UnmappedAnimal&gt;());</pre>

<p>* I should note one restriction on the generic parameter T when calling ISession.Get&lt;T&gt;(id) and ISession.Load&lt;T&gt;(). Polymorphic loading only works if there is a unique persister for T. Otherwise NHibernate throws a HibernateException, “Ambiguous persister for [T] implemented by more than one hierarchy”. What does this mean? Let’s say you have an unmapped abstract base class, such as Entity. (Entity is a class defined in our application, which includes properties common across all persistent entities, such as primary key, audit fields, and similar. It is not required by NHibernate, but often useful for extracting common domain code.) Consider the following contrived example:</p>

<p><img style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" title="Contrived Inheritance Hierarchy" border="0" alt="Contrived Inheritance Hierarchy" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/_5F00_ClassDiagram_5F00_215FF118.png" width="599" height="497" /></p>

<p>Note that the Animal inheritance hierarchy is mapped and so is Customer. If we try to execute the following code:</p>

<pre class="brush: csharp;">var id = 42;
var entity = session.Get&lt;Entity&gt;(id);</pre>

<p>We will get a HibernateException as mentioned above. We are asking NHibernate to load an Entity with an id of 42. But primary keys are only unique within a mapped inheritance hierarchy. So there could be a Cat (or Dog) with id of 42 <b>and</b> a Customer with id of 42! So NHibernate fails with a HibernateException since it has no way of returning a list of objects from Get/Load. If you really want to query across inheritance hierarchies, you can do so with Critera or LINQ where you return a list of objects. The following code will work:</p>

<pre class="brush: csharp;">var id = 42;
var entities = session.CreateCriteria&lt;Entity&gt;()
                      .Add(Restrictions.IdEq(id))
                      .List&lt;Entity&gt;();</pre>

<p>Here’s a NHibernate trick that makes for a good demo, but isn’t terribly practical in real applications… Retrieve a list of all entities in the database:</p>

<pre class="brush: csharp;">var allEntities = session.CreateCriteria&lt;object&gt;()
                         .List&lt;object&gt;();</pre>

<p>Happy coding!</p>

<p><strong>UPDATE</strong>: Fabio Maulo, NH project lead, pointed out to me that HQL in NHibernate 3 can load unmapped classes so long as you make NHibernate aware of the classes via an &lt;import class=”UnmappedAnimal”/&gt; directive in a hbm.xml file. Thanks, Fabio.</p>
