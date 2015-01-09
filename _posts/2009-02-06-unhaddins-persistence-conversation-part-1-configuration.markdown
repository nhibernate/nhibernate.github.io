---
layout: post
title: "uNHaddins Persistence Conversation – Part 1: Configuration"
date: 2009-02-06 16:33:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "Session"]
redirect_from: ["/blogs/nhibernate/archive/2009/02/06/unhaddins-persistence-conversation-part-1-configuration.aspx/", "/blogs/nhibernate/archive/2009/02/06/unhaddins-persistence-conversation-part-1-configuration.html"]
author: Gustavo
gravatar: 934c5a2299da30163f720bcd2ee826f4
---
{% include imported_disclaimer.html %}
<p><i>This post was previously published in my blog <a target="_blank" title="uNHaddins Persistence Conversation &ndash; Part 1: Configuration" href="http://gustavoringel.blogspot.com/">here </a></i></p>
<p>uNHAddins Conversation and motivations where widely presented on Fabio&rsquo;s blog <a href="http://fabiomaulo.blogspot.com/2009/01/aspect-conversation-per.html" target="_blank">here</a>.</p>
<p>The focus of this series of posts is configuring the Persistence Conversation aspect using uNHAddins and CastleAdapter targeting a Windows Forms Application (some of the concepts are easily movable to a Web application, but there are much more frameworks and examples matching this)</p>
<p>A working example can be found in the examples folder of <a href="http://groups.google.com/group/unhaddins" target="_blank">uNHAddins</a> trunk, <a href="http://unhaddins.googlecode.com/svn/trunk/Examples/uNHAddins.Examples.SessionManagement/" target="_blank">here</a>.</p>
<p>The following assumptions are made about your repositories/Dao&rsquo;s for this to work. </p>
<p>1) You are injecting the ISessionFactory in the repositories and not an ISession. </p>
<p>2) You are using GetCurrentSession() instead of OpenSession() to get the active session inside the repositories / dao&rsquo;s.</p>
<p>3) You are able to use Castle for Dependency Injection, I hope more adapters will come in the future, but this is one that it is implemented and it is enough popular.</p>
<p>First thing we should do is to decide the conversation context strategy and set it in the hibernate cfg. For this example it is:</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property</span> <span style="color: #ff0000;">name</span>=<span style="color: #0000ff;">"current_session_context_class"</span><span style="color: #0000ff;">&gt;</span> </pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">uNhAddIns.SessionEasier.Conversations.ThreadLocalConversationalSessionContext, uNhAddIns </pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">property</span><span style="color: #0000ff;">&gt;</span></pre>
</pre>
<p>Next thing is configuring castle to accept the PersistenceConversationalFacility, which will bring AOP in a similar manner to the TransactionalFacility from castle, and all the factories and services that compose a conversation.</p>
<p>The configuration for the facilities and default uNHAddins components for Castle can be found <a href="http://unhaddins.googlecode.com/svn/trunk/Examples/uNHAddins.Examples.SessionManagement/SessionManagement.Infrastructure/uNhAddIns-PersistenceConversation-nh-default.config" target="_blank">here</a> . There are some cases when you will want to play with the factories, this will be the reason for another post.</p>
<p>
Finally you set the way you are going to create sessions in your application (sessionFactory provider is the id to an implementation of ISessionFactoryProvider)</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">component</span> <span style="color: #ff0000;">id</span>=<span style="color: #0000ff;">"uNhAddIns.sessionFactory"</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">      <span style="color: #ff0000;">type</span>=<span style="color: #0000ff;">"NHibernate.ISessionFactory, NHibernate"</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">      <span style="color: #ff0000;">factoryId</span>=<span style="color: #0000ff;">"sessionFactoryProvider"</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">      <span style="color: #ff0000;">factoryCreate</span>=<span style="color: #0000ff;">"GetFactory"</span><span style="color: #0000ff;">&gt;</span><br /></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">      <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">parameters</span><span style="color: #0000ff;">&gt;</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">        <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">factoryId</span><span style="color: #0000ff;">&gt;</span>uNhAddIns<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">factoryId</span><span style="color: #0000ff;">&gt;</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">      <span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">parameters</span><span style="color: #0000ff;">&gt;</span></pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace"><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">component</span><span style="color: #0000ff;">&gt;</span></pre>
</pre>
<p>
This is all the magic we need to set it up all. The following post will be about using it in our application. 
<br />
<br />If you want to see it working follow the link to the source at the beginning of the post.</p>
