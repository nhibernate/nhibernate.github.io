---
layout: post
title: "Bulk Data Operations With NHibernate's Stateless Sessions"
date: 2008-10-30 20:28:00 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: ["bulk", "Stateless", "Session"]
alias: ["/blogs/nhibernate/archive/2008/10/30/bulk-data-operations-with-nhibernate-s-stateless-sessions.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Note: this was originally posted on my <a target="_blank" href="http://davybrion.com/blog/2008/10/bulk-data-operations-with-nhibernates-stateless-sessions/">own blog</a></p>
<p>In my previous <a href="http://davybrion.com/blog/2008/10/batching-nhibernates-dm-statements/">post</a>, i showed how you can configure NHibernate to batch create/update/delete statements and what kind of performance benefits you can get from it.  In this post, we're going to take this a bit further so we can actually use NHibernate in bulk data operations, an area where ORM's traditionally perform pretty badly.
</p>
<p>
First of all, let's get back to our test code from the last post:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> testObjects = CreateTestObjects(500000);</p>
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
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> time = stopwatch.Elapsed;</p>
</div>
<p>

The only thing that changed since the previous post is the amount of objects that are created. In the previous post we only created 10000 objects, whereas now we'll be creating 500000 objects.
The batch size is configured like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">property</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">adonet.batch_size</span>"<span style="color: blue;">&gt;</span>100<span style="color: blue;">&lt;/</span><span style="color: #a31515;">property</span><span style="color: blue;">&gt;</span></p>
</div>
<p>

This means that NHibernate will send its DML statements in batches of 100 statements instead of sending all of them one by one.  The above code runs in 2 minutes and 24 seconds with a batch size of 100.  
However, if we use NHibernate's IStatelessionSession instead of a regular ISession, we can get some nice improvements. </p>
<p>First of all, here's the code to use the IStatelessSession:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> testObjects = CreateTestObjects(500000);</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> stopwatch = <span style="color: blue;">new</span> <span style="color: #2b91af;">Stopwatch</span>();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; stopwatch.Start();</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">using</span> (<span style="color: #2b91af;">IStatelessSession</span> statelessSession = sessionFactory.OpenStatelessSession())</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">using</span> (<span style="color: #2b91af;">ITransaction</span> transaction = statelessSession.BeginTransaction())</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> testObject <span style="color: blue;">in</span> testObjects)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; statelessSession.Insert(testObject);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; transaction.Commit();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; stopwatch.Stop();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> time = stopwatch.Elapsed;</p>
</div>
<p>

As you can see, apart from the usage of the IStatelessSession instead of the regular ISession, this is pretty much the same code.
With a batch-size of 100, this code creates and inserts the 500000 records in 1 minute and 26 seconds.  While not a spectacular improvement, it's definitely a nice improvement in duration.
The biggest difference however is in memory usage while the code is running. A regular NHibernate ISession keeps a lot of data in its first-level cache (this enables a lot of the NHibernate magical goodies).  The IStatelessSession however, does no such thing.  It does no caching whatsoever and it also doesn't fire all of the events that you could usually plug into.  This is strictly meant to be used for bulk data operations.
</p>
<p>
To give you an idea on the difference in memory usage, here are the memory statistics (captured by Process Explorer) after running the original code (with the ISession instance):
</p>
<p><a href="http://davybrion.com/blog/wp-content/uploads/2008/10/isession.png"><img src="http://davybrion.com/blog/wp-content/uploads/2008/10/isession.png" title="isession" class="alignnone size-full wp-image-551" height="385" width="398" /></a></p>
<p>
And here are the memory statistics after running the modified code (with the IStatelessSession instance):</p>
<p>
<a href="http://davybrion.com/blog/wp-content/uploads/2008/10/istatelesssession.png"><img src="http://davybrion.com/blog/wp-content/uploads/2008/10/istatelesssession.png" title="istatelesssession" class="alignnone size-full wp-image-552" height="386" width="400" /></a></p>
<p>Quite a difference for what is essentially the same operation.  We could even improve on this because the code in its current form keeps all of the object instances in its own collection, preventing them from being garbage collected after they have been inserted in the database.  But i think this already demonstrates the value in using the IStatelessSession if you need to perform bulk operations.
Obviously, this will never perform as well as a bulk data operation that directly uses low-level ADO.NET code.  But if you already have the NHibernate mappings and infrastructure set up, implementing those bulk operations could be cheaper while still being 'fast enough' for most situations.</p>
