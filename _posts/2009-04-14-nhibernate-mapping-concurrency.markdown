---
layout: post
title: "NHibernate Mapping - Concurrency"
date: 2009-04-14 22:40:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2009/04/15/nhibernate-mapping-concurrency.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>NHibernate has several concurrency models that you can use:</p>  <ul>   <li>None </li>    <li>Optimistic      <ul>       <li>Dirty </li>        <li>All </li>     </ul>   </li>    <li>Versioned      <ul>       <li>Numeric </li>        <li>Timestamp </li>        <li>DB timestamp </li>     </ul>   </li>    <li>Pessimistic </li> </ul>  <p>We will explore each of those in turn.</p>  <p>None basically means that we fall back to the transaction semantics that we use in the database. The database may throw us out, but aside from that, we don’t really care much about things.</p>  <p>Optimistic is more interesting. It basically states that if we detect a change in the entity, we cannot update it. Let us see a simple example of using optimistic dirty checking for changed fields only:</p>  <blockquote>   <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">class</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Person&quot;</span>
			 <span style="color: #ff0000">optimistic</span>-<span style="color: #ff0000">lock</span>=<span style="color: #0000ff">&quot;dirty&quot;</span>
			 <span style="color: #ff0000">dynamic</span>-<span style="color: #ff0000">update</span>=<span style="color: #0000ff">&quot;true&quot;</span>
			 <span style="color: #ff0000">table</span>=<span style="color: #0000ff">&quot;People&quot;</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>Using this with this code:</p>

<blockquote>
  <pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var person = session.Get&lt;Person&gt;(1);
	person.Name = &quot;<span style="color: #8b0000">other</span>&quot;;
	tx.Commit();
}</pre>
</blockquote>

<p>Will result in:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_720B8098.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="95" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_2C1F6EDA.png" width="268" border="0" /></a> </p>

<p>Note that we have so specify dynamic-update to true. This is required because doing so will generally cause much greater number of query plan to exist in the database cache.</p>

<p>Setting optimistic-lock to all would result in:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_686D5526.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="178" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_718192BA.png" width="336" border="0" /></a> </p>

<p>If the update fails because the row was updated, we will get a StaleObjectException. Like all exceptions, this will make the session ineligible for use, and you would have to create a new session to handle it.</p>

<p>Usually a better strategy is to use an explicit version column. We can do it by specifying &lt;version/&gt;:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">version</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Version&quot;</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;Version&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>And that would result in:</p>

<p></p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_2A56097F.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="107" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_7570B654.png" width="248" border="0" /></a> </p>

<p>As you can probably guess, if the version doesn’t match, we will get StaleObjectException.</p>

<p>Instead of using numeric values, we can use a timestamp:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">version</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Version&quot;</span> <span style="color: #ff0000">column</span>=<span style="color: #0000ff">&quot;Version&quot;</span> <span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;timestamp&quot;</span><span style="color: #0000ff">/&gt;</span></pre>
</blockquote>

<p>In this case, the property type should be DateTime, and the resulting SQL would be:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_2C08A45D.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="109" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_1501D534.png" width="390" border="0" /></a> </p>

<p>This is, of course, a less safe way of doing things, and I recommend that you would use a numeric value instead.</p>

<p>Another option is to use the database facilities to handle that. in MS SQL Server, this is the TimeStamp column, which is a 8 byte binary that is changed any time that the row is updated.</p>

<p>We do this by changing the type of the Version property to byte array, and changing the mapping to:</p>

<blockquote>
  <pre><span style="color: #0000ff">&lt;</span><span style="color: #800000">version</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Version&quot;</span>
				 <span style="color: #ff0000">generated</span>=<span style="color: #0000ff">&quot;always&quot;</span>
				 <span style="color: #ff0000">unsaved</span>-<span style="color: #ff0000">value</span>=<span style="color: #0000ff">&quot;null&quot;</span>
				 <span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;BinaryBlob&quot;</span><span style="color: #0000ff">&gt;</span>
	<span style="color: #0000ff">&lt;</span><span style="color: #800000">column</span> <span style="color: #ff0000">name</span>=<span style="color: #0000ff">&quot;Version&quot;</span>
					<span style="color: #ff0000">not</span>-<span style="color: #ff0000">null</span>=<span style="color: #0000ff">&quot;false&quot;</span>
					<span style="color: #ff0000">sql</span>-<span style="color: #ff0000">type</span>=<span style="color: #0000ff">&quot;timestamp&quot;</span><span style="color: #0000ff">/&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">version</span><span style="color: #0000ff">&gt;</span></pre>
</blockquote>

<p>Executing the code listed above will result in:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6DEEC804.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="175" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_037128C2.png" width="342" border="0" /></a> </p>

<p>We use the value of the timestamp to ensure that we aren’t overwriting the row data after it was changed. The database will ensure that the row timestamp will change whenever the row itself is updated. This plays well with system where you may need to update the underlying tables outside of NHibernate.</p>

<p>Pessimistic concurrency is also expose with NHibernate, by using the overloads that takes a LockMode. This is done in a database independent way, using each database facilities and syntax.</p>

<p>For example, let us example the following code:</p>

<pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var person = session.Get&lt;Person&gt;(1,LockMode.Upgrade);
	person.Name = &quot;<span style="color: #8b0000">other</span>&quot;;
	tx.Commit();
}</pre>

<p>This will result in the following SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_1B2D818A.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="176" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_772A419E.png" width="352" border="0" /></a> </p>

<p>We can also issue a separate command to the database to obtain a lock on the row representing the entity:</p>

<pre><span style="color: #0000ff">using</span> (var session = sessionFactory.OpenSession())
<span style="color: #0000ff">using</span> (var tx = session.BeginTransaction())
{
	var person = session.Get&lt;Person&gt;(1);
	session.Lock(person, LockMode.Upgrade);
	person.Name = &quot;<span style="color: #8b0000">other</span>&quot;;
	tx.Commit();
}</pre>

<p>The Get() would generate a standard select, without the locks, but the Lock() method would generate the following SQL:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_330E85A7.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="81" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_061E442E.png" width="291" border="0" /></a> </p>

<p>The behavior for conflict in this case is very simple, we wait. If we wait for too long, the timeout will expire and we will get a timeout exception, because we could not obtain the lock.</p>

<p>That is consistent with how we would use pessimistic concurrency elsewhere.</p>
