---
layout: post
title: "NHibernate Auditing v3 – Poor Man’s Envers"
date: 2010-07-06 05:25:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "NHibernate", "schema action", "uNHAddins"]
redirect_from: ["/blogs/nhibernate/archive/2010/07/05/nhibernate-auditing-v3-poor-man-s-envers.aspx/"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>First, let me explain the title of this post. The Hibernate folks &ndash; you know, that <a target="_blank" href="http://nhforge.org">NHibernate</a> knock off written in the Java (pronounced &ldquo;ex em el&rdquo;) programming language &ndash; have a project called Envers. Among other things, It audits changes to entities, then allows you to easily retrieve the entity as it was at any previous point in time. </p>
<p>Well, Simon Duduica is porting this over to .NET and NHibernate, and he&rsquo;s making some AMAZING progress. On June 28th, he shared this news with us on the NH Contrib development group:</p>
<blockquote>
<p>Hi everybody,</p>
<p>I have news regarding Envers.NET. I've commited a version that works in basic tests for CUD operations, with entities that have relationships between them, also with entities that are not audited. To make things work I had to make two small modifications of NHibernate, both modifications were tested running all NHibernate unit tests and they all passed. I already sent the first modification to Fabio and the second I will send this evening. I would like to thank Tuna for helping me out with good advices when I was stuck :)</p>
</blockquote>
<p>&nbsp;</p>
<p>So, on to the topic of this post. For <span style="text-decoration: underline;">NHibernate 3.0 Cookbook</span>, I&rsquo;ve included a section that explains how to use NHibernate to generate audit triggers. Originally, I had planned to use the code from <a target="_blank" href="http://jasondentler.com/blog/2009/12/generate-audit-triggers-from-nhibernate-v2/">my previous blog post on the topic</a>, but I didn&rsquo;t like its structure. I also didn&rsquo;t want to include all that plumbing code in the printed book. Instead, I&rsquo;ve rewritten and contributed the &ldquo;framework&rdquo; code to <a target="_blank" href="http://code.google.com/p/unhaddins/">uNHAddIns</a>. The &ldquo;how-to use it&rdquo; is explained in the book, so I won&rsquo;t explain it here.</p>
<p>Today, I was writing an integration test for this contribution, and thought the idea was worth sharing. I have a simple Cat class:</p>
<p><img height="143" width="163" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/ClassDiagram1_5F00_1E6B8C88.png" alt="ClassDiagram1" border="0" title="ClassDiagram1" style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /> </p>
<p>When I do anything to this cat, in addition to the normal INSERT, UPDATE, or DELETE, a database trigger records that action in a table called CatAudit:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6ECD6DFB.png"><img height="159" width="206" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_5B400E5A.png" alt="image" border="0" title="image" style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> </p>
<p>I wanted an easy way to investigate the contents of this table to prove that my audit triggers worked. Here&rsquo;s what I came up with, along with help from Jose Romaniello (@jfroma). First, I created a class to match this table:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/ClassDiagram1_5F00_60AE7EFE.png"><img height="240" width="150" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/ClassDiagram1_5F00_thumb_5F00_65B0BCAD.png" alt="ClassDiagram1" border="0" title="ClassDiagram1" style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> </p>
<p>Next, I mapped it, made it readonly and excluded it from hbm2ddl with this mapping:</p>
<pre class="brush:xml">&lt;?xml version="1.0" encoding="utf-8" ?&gt;
&lt;hibernate-mapping xmlns="urn:nhibernate-mapping-2.2"
				   assembly="uNhAddIns.Test"
				   namespace="uNhAddIns.Test.Audit.TriggerGenerator"&gt;
  &lt;typedef class="NHibernate.Type.EnumStringType`1[[uNhAddIns.Audit.TriggerGenerator.TriggerActions, uNhAddIns]], NHibernate"
           name="triggerActions" /&gt;
  &lt;class name="CatAudit" 
         mutable="false"
         schema-action="none"&gt;
    &lt;composite-id&gt;
      &lt;key-property name="Id" /&gt;
      &lt;key-property name="AuditUser" /&gt;
      &lt;key-property name="AuditTimestamp" /&gt;
    &lt;/composite-id&gt;
    &lt;property name="Color"/&gt;
    &lt;property name="AuditOperation" type="triggerActions" /&gt;
  &lt;/class&gt;
	
&lt;/hibernate-mapping&gt;</pre>
<p>I made it readonly by setting mutable="false" and excluded it from hbm2ddl with schema-action="none". That&rsquo;s it!</p>
<p>By the way, the &lt;typedef&gt; along with type="triggerActions" just tells NHibernate I've stored my TriggerActions enum values as strings, not numbers.</p>
