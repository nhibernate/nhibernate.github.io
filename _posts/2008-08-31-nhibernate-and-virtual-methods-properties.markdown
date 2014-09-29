---
layout: post
title: "NHibernate and virtual methods/properties"
date: 2008-08-31 15:02:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["postsharp", "virtual", "validation", "proxy"]
alias: ["/blogs/nhibernate/archive/2008/08/31/nhibernate-and-virtual-methods-properties.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>NOTE: This post was originally published on <a href="http://davybrion.com/blog/2008/05/nhibernate-and-virtual-methodsproperties/">July 4, 2008</a>
</p>
<p>
I love NHibernate but one of the things that bothers the hell out of me is that i keep forgetting to add the virtual keyword to each method or property in my entities.  And since NHibernate needs your classes' properties and methods to be virtual, this causes run-time errors when i run my tests. Since i'm already using <a href="http://davybrion.com/blog/2008/05/creating-sanity-checks/">custom compile time checks</a>, i figured i might as well add another one... from now on, i want my compilation to fail if any of my NHibernate entities have public methods/properties that aren't marked virtual.
Once again, it's PostSharp to the rescue:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">using</span> System;</p>
<p style="margin: 0px;"><span style="color: blue;">using</span> System.Reflection;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;"><span style="color: blue;">using</span> PostSharp.Extensibility;</p>
<p style="margin: 0px;"><span style="color: blue;">using</span> PostSharp.Laos;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;"><span style="color: blue;">namespace</span> Northwind.Aspects</p>
<p style="margin: 0px;">{</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">Serializable</span>]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">AttributeUsage</span>(<span style="color: #2b91af;">AttributeTargets</span>.Assembly | <span style="color: #2b91af;">AttributeTargets</span>.Method | <span style="color: #2b91af;">AttributeTargets</span>.Property)]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; [<span style="color: #2b91af;">MulticastAttributeUsage</span>(<span style="color: #2b91af;">MulticastTargets</span>.Method, TargetMemberAttributes = <span style="color: #2b91af;">MulticastAttributes</span>.Managed | </p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">MulticastAttributes</span>.NonAbstract | <span style="color: #2b91af;">MulticastAttributes</span>.Instance | </p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">MulticastAttributes</span>.Protected | <span style="color: #2b91af;">MulticastAttributes</span>.Public)]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: #2b91af;">RequireVirtualMethodsAndProperties</span> : <span style="color: #2b91af;">OnMethodBoundaryAspect</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">override</span> <span style="color: blue;">bool</span> CompileTimeValidate(<span style="color: #2b91af;">MethodBase</span> method)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (!method.IsVirtual)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">string</span> methodName = method.DeclaringType.FullName + <span style="color: #a31515;">"."</span> + method.Name;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> message = <span style="color: blue;">new</span> <span style="color: #2b91af;">Message</span>(<span style="color: #2b91af;">SeverityType</span>.Fatal, <span style="color: #a31515;">"MustBeVirtual"</span>,</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">string</span>.Format(<span style="color: #a31515;">"{0} must be virtual"</span>, methodName), GetType().Name);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">MessageSource</span>.MessageSink.Write(message);</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> <span style="color: blue;">false</span>;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> <span style="color: blue;">true</span>;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">}</p>
</div>
<p>

And then we make sure this check is applied to my NHibernate entities:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">#if</span> DEBUG</p>
<p style="margin: 0px;">[<span style="color: blue;">assembly</span>: <span style="color: #2b91af;">RequireVirtualMethodsAndProperties</span>(AttributeTargetTypes = <span style="color: #a31515;">"Northwind.Domain.Entities.*"</span>)]</p>
<p style="margin: 0px;"><span style="color: blue;">#endif</span></p>
</div>
<p>

Now, whenever i forget to mark my properties/methods as virtual, i get this:
<code>
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.RemoveTerritory must be virtual
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.AddTerritory must be virtual
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.get_Territories must be virtual
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.set_Description must be virtual
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.get_Description must be virtual
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.set_Id must be virtual
</code></p>
<p><code>EXEC : error MustBeVirtual: Northwind.Domain.Entities.Region.get_Id must be virtual
</code></p>
<p>&nbsp;</p>
<p><code>...
Done building project "Northwind.csproj" -- FAILED.
</code></p>
<p>&nbsp;</p>
<p>
And there we go :)</p>
