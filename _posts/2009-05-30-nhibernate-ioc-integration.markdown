---
layout: post
title: "NHibernate IoC integration"
date: 2009-05-30 13:20:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "NH2.1", "Inversion of Control", "IoC"]
alias: ["/blogs/nhibernate/archive/2009/05/30/nhibernate-ioc-integration.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>[<a target="_blank" href="http://fabiomaulo.blogspot.com/">my Blog</a>]</p>
<p>Do you remember <a target="_blank" href="http://fabiomaulo.blogspot.com/2008/11/entities-behavior-injection.html">this</a> post ?</p>
<p>As you can see you can use Dependency Injection even for entities, but what about all others classes needed by NHibernate ?</p>
<p>Can you inject something in a custom Dialect or in a custom UserType or UserCollectionType or Listener and all others extensions points ?</p>
<p>Sure you can ;)</p>
<p>NHibernate 2.1.0Alpha3, the fresh released today, has <span style="color: #2b91af">IObjectsFactory</span>. As the <em>ProxyFactoryFactory</em>, the <em>ReflectionOptimizer</em> even the <em>ObjectsFactory</em> is a responsibility of the <em>ByteCodeProvider</em>.</p>
<p>To be short&hellip; an implementation of a <span style="color: #2b91af">IUserType</span> now can look like this:</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">InjectableStringUserType </span>: <span style="color: #2b91af">IUserType<br /></span>{<br /><span style="color: blue">private readonly </span><span style="color: #2b91af">IDelimiter </span>delimiter;<br /><br /><span style="color: blue">public </span>InjectableStringUserType(<span style="color: #2b91af">IDelimiter </span>delimiter)<br />{<br />    <span style="color: blue">this</span>.delimiter = delimiter;<br />}</pre>
<p>The implementation of <span style="color: #2b91af">IPostInsertEventListener</span> now can look like this:</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">YourPostInsertListener </span>: <span style="color: #2b91af">IPostInsertEventListener<br /></span>{<br /><span style="color: blue">private readonly </span><span style="color: #2b91af">IPersistentAuditor </span>auditor;<br /><br /><span style="color: blue">public </span>YourPostInsertListener(<span style="color: #2b91af">IPersistentAuditor </span>auditor)<br />{<br />    <span style="color: blue">this</span>.auditor = auditor;<br />}<br /><br /><span style="color: blue">public void </span>OnPostInsert(<span style="color: #2b91af">PostInsertEvent </span>@event)</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>If you want use Dependency-Injection for both entities and all others NH stuff, in <a target="_blank" href="http://code.google.com/p/unhaddins/">uNhAddIns</a> you can find two full implementation for <a target="_blank" href="http://code.google.com/p/unhaddins/source/browse/#svn/trunk/uNhAddIns/uNhAddIns.CastleAdapters/EnhancedBytecodeProvider">Castle</a> and <a target="_blank" href="http://code.google.com/p/unhaddins/source/browse/#svn/trunk/uNhAddIns/uNhAddIns.SpringAdapters/EnhancedBytecodeProvider">Spring</a>.</p>
<p>Enjoy NHibernate injectability.</p>
<p><span style="webkit-border-horizontal-spacing: 2px; webkit-border-vertical-spacing: 2px"><span style="font-family: 'trebuchet ms'">P.S. Part of it (tests), was a live implementation before start the Alt.NET VAN today.</span></span></p>
