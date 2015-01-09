---
layout: post
title: "Extending NHibernate's DriverConnectionProvider"
date: 2008-09-18 14:48:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["provider", "connection"]
redirect_from: ["/blogs/nhibernate/archive/2008/09/18/extending-nhibernate-s-driverconnectionprovider.aspx/", "/blogs/nhibernate/archive/2008/09/18/extending-nhibernate-s-driverconnectionprovider.html"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>Note: this was orginally posted on my <a target="_blank" href="http://davybrion.com/blog/2008/09/extending-nhibernates-driverconnectionprovider/">own blog</a>
</p>
<p>Ahh, i'm finally able to use NHibernate again at work, so expect more NHibernate related posts in the future :)
</p>
<p>Today i needed a way to add some functionality when NHibernate opens a database connection, and again when NHibernate closes the connection.  When the connection is opened, i need to setup some context on the connection for auditing purposes and it needs to be cleared again when the connection is closed.  So i started searching on how to plug this into NHibernate.  As usual, this was trivially easy to do.
All you need to do is create a type that implements the IConnectionProvider interface.  In my case, i only needed to add a bit of behavior so i could just derive from NHibernate's standard DriverConnectionProvider class and add the stuff i needed at the right time:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: #2b91af;">AuditingConnectionProvider</span> : NHibernate.Connection.DriverConnectionProvider</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">override</span> <span style="color: #2b91af;">IDbConnection</span> GetConnection()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">IDbConnection</span> connection = <span style="color: blue;">base</span>.GetConnection();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; SetContextInfo(connection);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> connection;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">override</span> <span style="color: blue;">void</span> CloseConnection(<span style="color: #2b91af;">IDbConnection</span> connection)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; ClearContextInfo(connection);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">base</span>.CloseConnection(connection);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">void</span> SetContextInfo(<span style="color: #2b91af;">IDbConnection</span> connection)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// ...</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">void</span> ClearContextInfo(<span style="color: #2b91af;">IDbConnection</span> connection)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// ...</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; }</p>
</div>
<p>
Pretty simple huh? All you have to do now is to configure NHibernate to use this new ConnectionProvider in your hibernate.cfg.xml file:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">property</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">connection.provider</span>"<span style="color: blue;">&gt;</span>My.Assembly.AuditingConnectionProvider, My.Assembly<span style="color: blue;">&lt;/</span><span style="color: #a31515;">property</span><span style="color: blue;">&gt;</span></p>
</div>
<p>
Was that easy or what? If only all frameworks were extensible in such an easy manner ;)</p>
