---
layout: post
title: "uNHAddins Persistence Conversation – Part 2: Configuring the conversation"
date: 2009-02-10 07:17:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["SessionFactory", "NHibernate", "Session", "uNHAddin"]
alias: ["/blogs/nhibernate/archive/2009/02/10/unhaddins-persistence-conversation-part-2-configuring-the-conversation.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>In the <a href="http://gustavoringel.blogspot.com/2009/02/unhaddins-persistence-conversation-part.html" target="_blank">first post</a> I showed how to configure the uNHAddins conversation. Now I will show how to use the PersistenceConversation aspects to manage a uNHAddins conversation.</p>
<p>A class which will rule a conversation should be marked as [PersistenceConversational] every public method that is part of a conversation should be marked as [PersistenceConversation]. </p>
<p>In the example code we have the interface </p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span> IModifyOrderModel</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">{</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  PurchaseOrder FindOrderOrCreateNew(<span style="color: #0000ff;">string</span> number, DateTime dateTime);</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">void</span> Persist(PurchaseOrder order);</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">void</span> AbortConversation();</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">}</pre>
</pre>
<p>
which is implemented by the ModifyOrderModel class:</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">[PersistenceConversational]</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> ModifyOrderModel : IModifyOrderModel</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">{</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p><span style="color: #0000ff;">private</span> <span style="color: #0000ff;">readonly</span> IOrderRepository orderRepository;</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p><span style="color: #0000ff;">public</span> ModifyOrderModel(IOrderRepository orderRepository)</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p>{</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p><span style="color: #0000ff;"><span style="color: #333333;">  </span>this</span>.orderRepository = orderRepository;</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p>}</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p>[PersistenceConversation(ConversationEndMode = EndMode.Abort)]</p></blockquote></pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><blockquote><p><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">void</span> AbortConversation()</p></blockquote></pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><blockquote><p>{<span style="color: #008000;"><span style="color: #333333;">  </span>// Rollback the use case </span>}</p></blockquote></pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><blockquote><p>[PersistenceConversation<span style="color: #0000ff;">]</span></p><p><span style="color: #0000ff;">public</span> PurchaseOrder FindOrderOrCreateNew(<span style="color: #0000ff;">string</span> number, DateTime dateTime)</p><p>{</p><p style="padding-left: 30px;">var order = orderRepository.GetOrderByNumberAndDate(number, dateTime.Date);<span style="color: #0000ff;"><br /></span></p><p style="padding-left: 30px;"><span style="color: #0000ff;">if</span> (order == <span style="color: #0000ff;">null</span>)</p></blockquote></pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><blockquote><p style="padding-left: 30px;">{</p><p style="padding-left: 60px;">order = <span style="color: #0000ff;">new</span> PurchaseOrder { Date = dateTime, Number = number }; </p><p style="padding-left: 30px;">}</p><p><span style="color: #0000ff;">  return</span> order;</p><p>}</p></blockquote></pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace">          [PersistenceConversation(ConversationEndMode = EndMode.End)]</pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><span style="color: #0000ff;"><span style="color: #333333;">          </span>public</span> <span style="color: #0000ff;">void</span> Persist(PurchaseOrder order)</pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace">         {</pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><blockquote><p>orderRepository.MakePersistent(order);</p><p>}</p><p>}</p></blockquote></pre>
</pre>
<p>This class manages the order modification conversation. As you see we don&rsquo;t have references to NHibernate at this point. We do have an IOrderRepository which is going to provide the data we need for the conversation.</p>
<p>The implementation of the repository in the example is very simple, one important thing to notice is that we are injecting an ISessionFactory:</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">class</span> OrderRepository : Repository&lt;PurchaseOrder&gt;, IOrderRepository</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">{</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p><span style="color: #0000ff;">public</span> OrderRepository(ISessionFactory sessionFactory) : <span style="color: #0000ff;">base</span>(sessionFactory) { }</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p><span style="color: #0000ff;">public</span> PurchaseOrder GetOrderByNumberAndDate(<span style="color: #0000ff;">string</span> number, DateTime dateTime)</p></blockquote></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><blockquote><p style="padding-left: 30px;">{ var query = Session.GetNamedQuery("<span style="color: #8b0000;">GetOrderByNumberAndDate</span>").SetParameter("<span style="color: #8b0000;">number</span>", number).SetParameter("<span style="color: #8b0000;">dateTime</span>", dateTime); <span style="color: #0000ff;"><br /></span></p><p style="padding-left: 30px;"><span style="color: #0000ff;">return</span> query.UniqueResult&lt;PurchaseOrder&gt;();</p><p>}</p></blockquote></pre>
</pre>
<p>
The Repository&lt;T&gt; is a very thin class which gives minimum CRUD implementations using NH. The interesting part is how we are getting a session:</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">protected</span> ISession Session</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">{</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">get</span> { <span style="color: #0000ff;">return</span> factory.GetCurrentSession(); }</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">}</pre>
</pre>
<p>From the doc: GetCurrentSession() Obtains the current session. The definition of what exactly "current" means controlled by the <a href="http://www.hibernate.org/hib_docs/v3/api/org/hibernate/context/CurrentSessionContext.html"><code>CurrentSessionContext</code></a> impl configured for use</p>
<p>In our case if you remember from the <a href="http://gustavoringel.blogspot.com/2009/02/unhaddins-persistence-conversation-part.html" target="_blank">first post</a> we are using the uNHAddins <a href="http://www.hibernate.org/hib_docs/v3/api/org/hibernate/context/CurrentSessionContext.html"><code>ThreadLocalConversationalSessionContext</code></a>, which in general is good enough for a Windows Forms Application.</p>
<p>
You may have noticed a property ConversationalEndMode in the PersistenceConversation attribute, for now there are three options:</p>
<p>EndMode.Continue: Can start a conversation and lives it alive.</p>
<p>EndMode.End: Flushes the session and commits current transactions, then it disposes the session</p>
<p>EndMode.Abort: Disposes the session (without accepting the changes)</p>
<p>
Basically this is it. In the <a href="http://unhaddins.googlecode.com/svn/trunk/Examples/uNHAddins.Examples.SessionManagement/" target="_blank">example code</a> you can find an application using MVP with this ideas. Feel free to comment / ask in the <a href="http://groups.google.com/group/unhaddins" target="_blank">uNHAddins forum</a> about it.</p>
