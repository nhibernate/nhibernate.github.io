---
layout: post
title: "Identity: The never ending story"
date: 2008-12-21 12:38:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["identity", "NHibernate", "Session", "Unit of Work"]
alias: ["/blogs/nhibernate/archive/2008/12/21/identity-the-never-ending-story.aspx"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>How many times you heard us saying &ldquo;don&rsquo;t use identity POID generator!&rdquo; ?</p>
<p>To understand it better you must move your mind to an application, or a <a href="http://en.wikipedia.org/wiki/Use_case">use-case</a>, where the pattern <a href="http://www.hibernate.org/43.html">open-session-in-view</a> (aka session-per-request) is not applicable.</p>
<h4>The Unit of Work</h4>
<p>The Unit of Work (UoW) is a <a href="http://martinfowler.com/eaaCatalog/unitOfWork.html">pattern described by Martin Fowler</a>. When you work with NHibernate the real implementation of the pattern is the NH-Session (more exactly in PersistentContext inside de session). The <em>commit </em>and <em>rollback</em>, described in the pattern, are respectively the session.Flush() and the session.Close() (the close mean when close the session without Flush it). As usual the pattern described by Fowler is short and very clear so an explication is unneeded; here I want put more emphasis in two phrases:</p>
<p>&ldquo;You can change the database with each change to your object model, but this can lead to lots of very small database calls, which ends up being very slow.&rdquo; </p>
<p>&ldquo;A Unit of Work keeps track of everything you do during a business transaction that can affect the database. When you're done, it figures out everything that needs to be done to alter the database as a result of your work.&rdquo;</p>
<p>In addition note, that Fowler, are talking about <strong>business transaction</strong> (repeat business-transaction).</p>
<p>In NHibernate, setting the <span style="color: #2b91af">FlushMode</span> to <span style="color: #2b91af">FlushMode</span>.Never (MANUAL in Hibernate), if you begin a NH-Transaction and commit it, but without a session.Flush, nothing happen in DB.</p>
<h4>Analyze Session-per-conversation</h4>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/SessionPerConversation_5F00_587705A2.png"><img title="SessionPerConversation" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="458" alt="SessionPerConversation" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/SessionPerConversation_5F00_thumb_5F00_7345BC5F.png" width="640" border="0" /></a> </p>
<p>The session-per-conversation pattern is an example of a business transaction that spans multiple requests. As described by Fowler the nh-session (the real UoW) spans the whole business-transaction and <strong>in each request we are begin-commit a NH-Transaction</strong>. At the end of the conversation, inside a NH-Transaction, we will chose to Flush or Close the NH-session (mean commit or rollback the UoW).</p>
<p>In session-per-conversation we don&rsquo;t want have a NH-Transaction (that, in this moment, mean a ADO.NET transaction) open for the whole conversation because not only is &ldquo;impractical&rdquo;, as said Fowler, but, in my opinion, it break the concept of <a href="http://en.wikipedia.org/wiki/ACID">ACID</a>.</p>
<h4>How to break all ?</h4>
<p>If you want break the UoW pattern, and session-per-conversation pattern, you have a very easy way:<strong>use <span style="color: #ff0000">identity</span> as your POID strategy</strong>.</p>
<p>The <span style="color: #ff0000">identity</span> strategy mean :</p>
<ul>
<li>change the database with each change to your object model (see the phrase above) </li>
<li>if you run a session.Save in the first request you will have a new record in the DB, and you can&rsquo;t rollback this change without run an explicit Delete. </li>
</ul>
<p>In addition I want say that using <strong><span style="color: #ff0000">identity</span></strong> you are &ldquo;disabling&rdquo; the ADO-batcher NH&rsquo;s feature for inserts.</p>
<p>You can continue using <span style="color: #ff0000">identity</span> but you must know what you are loosing, and only you know what you are winning (I don&rsquo;t know what you are winning using <span style="color: #ff0000">identity</span> when you are working with a spectacular persistence layer as NHibernate is). </p>
