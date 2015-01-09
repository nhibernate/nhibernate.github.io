---
layout: post
title: "NHibernate Mapping - &lt;one-to-one/&gt;"
date: 2009-04-19 01:31:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/19/nhibernate-mapping-lt-one-to-one-gt.aspx/", "/blogs/nhibernate/archive/2009/04/19/nhibernate-mapping-lt-one-to-one-gt.html"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>In the database world, we have three kind of associations: 1:m, m:1, m:n.</p>  <p>However, occasionally we want to have a one to one relationship. We could simulate it easily enough on the database side using two many to one relations, but that would require us to add the association column to both tables, and things gets… tricky when it comes the time to insert or update to the database, because of the cycle that this creates.</p>  <p>NHibernate solves the problem by introducing a one-to-one mapping association, which allow you to define the two relationships based on a single column in the database, which controls the two way association.</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span>
        <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;PropertyName&quot;</span>                                (<span style="color: #ff0000">1</span>)
        <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;ClassName&quot;</span>                                  (<span style="color: #ff0000">2</span>)
        <span style="color: #ff0000">cascade</span>=<span style="color: #0000ff">&quot;all|none|save-update|delete&quot;</span>              (<span style="color: #ff0000">3</span>)
        <span style="color: #ff0000">constrained</span>=<span style="color: #0000ff">&quot;true|false&quot;</span>                           (<span style="color: #ff0000">4</span>)
        <span style="color: #ff0000">fetch</span>=<span style="color: #0000ff">&quot;join|select&quot;</span>                                (<span style="color: #ff0000">5</span>)
        <span style="color: #ff0000">property</span>-<span style="color: #ff0000">ref</span>=<span style="color: #0000ff">&quot;PropertyNameFromAssociatedClass&quot;</span>     (<span style="color: #ff0000">6</span>)
        <span style="color: #ff0000">access</span>=<span style="color: #0000ff">&quot;field|property|nosetter|ClassName&quot;</span>         (<span style="color: #ff0000">7</span>)
<span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>1, 2, 3, 6, 7 were all discussed elsewhere, so I’ll skip them and move directly to showing how this can be used.</p>

<p>We have the follow object model:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6CCFFEAD.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="167" alt="image" src="/images/posts/2009/04/19/image_5F00_thumb_5F00_6F9AD502.png" width="451" border="0" /></a> </p>

<p>And the database model:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_1CB25282.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="114" alt="image" src="/images/posts/2009/04/19/image_5F00_thumb_5F00_5C7EC9B8.png" width="570" border="0" /></a> </p>

<p></p>

<p>Note that while in the object model we have a bidirectional mapping, in the database we have only a single reference on the employees table. In the relational model, all associations are naturally bidirectional, but that is not true on the object model. In order to bridge this inconsistency, we map them as:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Employee&quot;</span>
		<span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;Employees&quot;</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;native&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Role&quot;</span><span style="color: #0000ff">/&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">many</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Person&quot;</span>
		<span style="color: #ff0000">unique</span>=<span style="color: #0000ff">&quot;true&quot;</span>
		<span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;Person&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span>

<span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Person&quot;</span>
		<span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;People&quot;</span><span style="color: #0000ff">&gt;</span>

	<span style="color: #0000ff">&lt;</span><span style="color: #800000">id</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Id&quot;</span><span style="color: #0000ff">&gt;</span>
		<span style="color: #0000ff">&lt;</span><span style="color: #800000">generator</span> <span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;native&quot;</span><span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;/</span><span style="color: #800000">id</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Name&quot;</span> <span style="color: #0000ff">/&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Employee&quot;</span>
			<span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Employee&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">class</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>We have a unique many-to-one association from Employee to Person, but a one to one from Person to Employee. This will reuse the many-to-one association defined in the Employee mapping.</p>

<p>Let see how this works for saving and loading the data:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var person = <span style="color: #0000ff">new</span> Person
	{
		Name = &quot;<span style="color: #8b0000">test</span>&quot;,
	};
	var employee = <span style="color: #0000ff">new</span> Employee
	{
		Person = person,
		Role = &quot;<span style="color: #8b0000">Manager</span>&quot;
	};
	person.Employee = employee;<br />        session.Save(person);<br />        session.Save(employee);
	tx.Commit();
}

<span style="color: #008000">// person to employee</span>
<span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var employee = session.Get&lt;Person&gt;(1).Employee;
	Console.WriteLine(employee.Role);
	tx.Commit();
}

<span style="color: #008000">// employee to person</span>
<span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var person = session.Get&lt;Employee&gt;(1).Person;
	Console.WriteLine(person.Name);
	tx.Commit();
}</pre>
</blockquote>

<p>And the SQL that would be generated would be:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3232228E.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="232" alt="image" src="/images/posts/2009/04/19/image_5F00_thumb_5F00_7F64ACCA.png" width="591" border="0" /></a> </p>

<p>This is quite interesting. We can see that we insert the entities as we expect, but when we pull a person out, we do a join to the employee, to get the one-to-one association. For that matter, even in the second scenario, we do a join to get the associated employee.</p>

<p>The reason that we have to do it is quite interesting as well. NHibernate makes some guarantees about the way the object model and the database model map to one another. And one of those guarantees is that if there is no association in the database, we will get back a null in the object model.</p>

<p>Generally, this works very well, since we can tell whatever an association exists or not using the value in the table (for many-to-one associations). But for one-to-one association, if we want to keep this guarantee, we have to check the associated table to verify if we need to have a null or a proxy there. That is somewhat annoying, but we can get around that by specifying constrained=”true”. This tell NHibernate that in this case, whenever there is a Person, there <em>must</em> also be a matching Employee value. We can specify it like this:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">one</span>-<span style="color: #ff0000">to</span>-<span style="color: #ff0000">one</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Employee&quot;</span> 
	<span style="color: #ff0000">constrained</span>=<span style="color: #0000ff">&quot;true&quot;</span>
	<span style="color: #ff0000">foreign</span>-<span style="color: #ff0000">key</span>=<span style="color: #0000ff">&quot;none&quot;</span>
	<span style="color: #ff0000">class</span>=<span style="color: #0000ff">&quot;Employee&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>Something else to note is that we must specify this with foreign-key=”none”, because otherwise NHibernate’s Schema Export feature would create two foreign keys for us, which would create a circular reference that wouldn’t allow us to insert anything into the database.</p>

<p>When setting this, we can see that there is a dramatic change in NHibernate’s behavior:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_2B3CB2CD.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="253" alt="image" src="/images/posts/2009/04/19/image_5F00_thumb_5F00_637DBA96.png" width="528" border="0" /></a> </p>

<p>Instead of generating joins, NHibernate now uses standard selects to get the data. And we don’t have to pre-populate the information on loading the entity, we can delay that as we usually do with NHibernate.</p>

<p>And the last thing that we will explore for &lt;one-to-one/&gt; is the fetch attribute. It defaults to select, so we have already seen how that works, but when we set fetch=”join”, we get an interesting flashback. Well, almost:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_1BBEC260.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="229" alt="image" src="/images/posts/2009/04/19/image_5F00_thumb_5F00_3B03F9E4.png" width="530" border="0" /></a> </p>

<p>Again, we use a join to get the value upfront, but since we are now using constrained=”true”, we can use an inner join instead of a left outer join, which is more efficient in most cases.</p>
