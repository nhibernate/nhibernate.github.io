---
layout: post
title: "NH2.1: Executable HQL"
date: 2009-05-05 13:54:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["query", "News", "NHibernate", "NH2.1", "querying", "HQL"]
alias: ["/blogs/nhibernate/archive/2009/05/05/nh2-1-executable-hql.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>[<a href="http://fabiomaulo.blogspot.com/">from my blog</a>]</p>
<p>Mapping:</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">SimpleClass</span>" <span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">TSIMPLE</span>"<span style="color: blue">&gt;<br />  &lt;</span><span style="color: #a31515">id </span><span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">int</span>"<span style="color: blue">&gt;<br />      &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">native</span>" <span style="color: blue">/&gt;<br />  &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;<br />  &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Description</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;</span></pre>
<p>Class:</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">SimpleClass<br /></span>{<br />  <span style="color: blue">public virtual string </span>Description { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br />}</pre>
<p>DB fill:</p>
<pre class="code"><span style="color: blue">using </span>(<span style="color: blue">var </span>s = OpenSession())<br /><span style="color: blue">using </span>(<span style="color: blue">var </span>tx = s.BeginTransaction())<br />{<br />  s.Save(<span style="color: blue">new </span><span style="color: #2b91af">SimpleClass </span>{Description = <span style="color: #a31515">"simple1"</span>});<br />  s.Save(<span style="color: blue">new </span><span style="color: #2b91af">SimpleClass </span>{Description = <span style="color: #a31515">"simple2"</span>});<br />  tx.Commit();<br />}</pre>
<p>So far doing this:</p>
<pre class="code"><span style="color: blue">using </span>(<span style="color: blue">var </span>s = OpenSession())<br /><span style="color: blue">using </span>(<span style="color: blue">var </span>tx = s.BeginTransaction())<br />{<br />  s.Delete(<span style="color: #a31515">"from SimpleClass"</span>);<br />  tx.Commit();<br />}</pre>
<p>the log is:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/OldDeleteLog_5F00_05C43778.png"><img border="0" width="407" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/OldDeleteLog_5F00_thumb_5F00_2C924DB8.png" alt="OldDeleteLog" height="321" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" title="OldDeleteLog" /></a> <a href="http://11011.net/software/vspaste"></a></p>
<p>But from today (the day of worker), doing this:</p>
<pre class="code"><span style="color: blue">using </span>(<span style="color: blue">var </span>s = OpenSession())<br /><span style="color: blue">using </span>(<span style="color: blue">var </span>tx = s.BeginTransaction())<br />{<br />  s.CreateQuery(<span style="color: #a31515">"delete from SimpleClass"</span>).ExecuteUpdate();<br />  tx.Commit();<br />}</pre>
<p>the log is :<a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/NewDeleteLog_5F00_653CF7C5.png"><img border="0" width="228" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/NewDeleteLog_5F00_thumb_5F00_20FC9079.png" alt="NewDeleteLog" height="64" style="border-top-width: 0px; display: block; border-left-width: 0px; float: none; border-bottom-width: 0px; margin-left: auto; margin-right: auto; border-right-width: 0px" title="NewDeleteLog" /></a> </p>
<p>&nbsp;</p>
<p>what it mean is clear, no ?&nbsp; ;)</p>
<p>Soon some news about bulk insert and update, in HQL.</p>
<p>Now you know <span style="text-decoration: underline;">one of the reasons</span> because NH2.1.0 release, was postponed.</p>
