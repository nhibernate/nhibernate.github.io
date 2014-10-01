---
layout: post
title: "Batching NHibernate’s DML Statements"
date: 2008-10-27 15:23:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["batch", "DML"]
redirect_from: ["/blogs/nhibernate/archive/2008/10/27/batching-nhibernate-s-dml-statements.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>Note: this was originally posted on <a target="_blank" href="http://davybrion.com/blog/2008/10/batching-nhibernates-dm-statements/">my own blog</a></p>
<p>&nbsp;</p>
<p>
An oft-forgotten feature of NHibernate is that of batching DML statements.  If you need to create, update or delete a bunch of objects you can get NHibernate to send those statements in batches instead of one by one.  Let's give this a closer look.
</p>
<p>
I have an 'entity' with the following mapping:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;</span><span style="color: #a31515;">class</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">CrudTest</span>"<span style="color: blue;"> </span><span style="color: red;">table</span><span style="color: blue;">=</span>"<span style="color: blue;">CrudTest</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">id</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Id</span>"<span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Id</span>"<span style="color: blue;"> </span><span style="color: red;">type</span><span style="color: blue;">=</span>"<span style="color: blue;">guid</span>"<span style="color: blue;"> &gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">generator</span><span style="color: blue;"> </span><span style="color: red;">class</span><span style="color: blue;">=</span>"<span style="color: blue;">assigned</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;/</span><span style="color: #a31515;">id</span><span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">property</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Description</span>"<span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Description</span>"<span style="color: blue;"> </span><span style="color: red;">type</span><span style="color: blue;">=</span>"<span style="color: blue;">string</span>"<span style="color: blue;"> </span><span style="color: red;">length</span><span style="color: blue;">=</span>"<span style="color: blue;">200</span>"<span style="color: blue;"> </span><span style="color: red;">not-null</span><span style="color: blue;">=</span>"<span style="color: blue;">true</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;/</span><span style="color: #a31515;">class</span><span style="color: blue;">&gt;</span></p>
</div>
<p>
Nothing special here, just a Guid Id field and a string Description field. 
First, let's see how much time it takes to create 10000 records of this without using the batching feature. </p>
<p> I use the following method to create a bunch of dummy objects:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: #2b91af;">IEnumerable</span>&lt;<span style="color: #2b91af;">CrudTest</span>&gt; CreateTestObjects(<span style="color: blue;">int</span> count)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">List</span>&lt;<span style="color: #2b91af;">CrudTest</span>&gt; objects = <span style="color: blue;">new</span> <span style="color: #2b91af;">List</span>&lt;<span style="color: #2b91af;">CrudTest</span>&gt;(count);</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">for</span> (<span style="color: blue;">int</span> i = 0; i &lt; count; i++)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; objects.Add(<span style="color: blue;">new</span> <span style="color: #2b91af;">CrudTest</span> { Id = <span style="color: #2b91af;">Guid</span>.NewGuid(), Description = <span style="color: #2b91af;">Guid</span>.NewGuid().ToString() });</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> objects;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>
Then, the code to persist these objects:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> testObjects = CreateTestObjects(10000);</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> stopwatch = <span style="color: blue;">new</span> <span style="color: #2b91af;">Stopwatch</span>();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; stopwatch.Start();</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">using</span> (<span style="color: #2b91af;">ITransaction</span> transaction = Session.BeginTransaction())</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> testObject <span style="color: blue;">in</span> testObjects)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Session.Save(testObject);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; transaction.Commit();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; stopwatch.Stop();</p>
</div>
<p>
Without enabling the batching, this code took 23 seconds to run on my cheap MacBook.  Now let's enable the batching in the hibernate.cfg.xml file:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">property</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">adonet.batch_size</span>"<span style="color: blue;">&gt;</span>5<span style="color: blue;">&lt;/</span><span style="color: #a31515;">property</span><span style="color: blue;">&gt;</span></p>
</div>
<p>
A batch size of 5 is still very small, but for this test it means that it only has to do 2000 trips to the database instead of the original 10000.  The code above now runs in 5.5 seconds.  Setting the batch size to 100 made it run in 1.8 seconds.  Going from 23 to 1.8 seconds with a small configuration change is a pretty nice improvement with very little effort.  Obviously, these aren't real benchmarks so your results may vary but i think it does show that you can easily get some performance benefits from it.
</p>
<p>You can get performance benefits like this whenever you need to create/update/delete a bunch of records simply by enabling this setting.  Keep in mind that this batching of statements doesn't apply to select queries... for that you need to use NHibernate's MultiCriteria or MultiQuery features :)
</p>
<p>Another thing to keep in mind is that for this test i used the 'assigned' Id generator... which means that the developer is responsible for providing the Id value for new objects.  One of the consequences of this is that NHibernate does not have to go to the database to retrieve the Id values like it would have to do if you were using (for instance) Identity Id values.  If you were using the Identity Id generator, this configuration setting would have no effect whatsoever for inserts, although the benefits would still apply to update and delete statements.
</p>
<p>Note that this approach is good for regular applications, but it's still not good enough if you need to process very large data sets (like import processes and things of that nature). Obviously, an ORM isn't well suited for those purposes, but we will examine another NHibernate feature in a future post which makes it possible to use NHibernate in such bulk operations with a pretty low performance overhead.</p>
