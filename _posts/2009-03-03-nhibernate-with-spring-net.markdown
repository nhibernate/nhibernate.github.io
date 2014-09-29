---
layout: post
title: "NHibernate with Spring.NET"
date: 2009-03-03 21:00:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["proxy", "ProxyGenerators", "NHibernate", "AOP", "IoC"]
alias: ["/blogs/nhibernate/archive/2009/03/03/nhibernate-with-spring-net.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>A new Dynamic-Proxy provider is available in NHibernate trunk (<a href="/blogs/nhibernate/archive/2008/11/09/nh2-1-0-bytecode-providers.aspx">here</a> the others two)</p>
<p><a href="http://eeichinger.blogspot.com/">Erich Eichinger</a> (Spring.NET team member) sent us the implementation of <strong>NHibernate.ByteCode.Spring</strong>.</p>
<p>The property to configure is</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">proxyfactory.factory_class</span>"<span style="color: blue">&gt;</span></pre>
<pre class="code"><span style="color: blue"></span>NHibernate.ByteCode.Spring.ProxyFactoryFactory, NHibernate.ByteCode.Spring</pre>
<pre class="code"><span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;
</span></pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>The advantage to use the same engine of your preferred IoC/DI/AOP framework is pretty clear: everything is fully integrated (you can configure some aspect and you have it working when the proxy is generated trough NHibernate).</p>
<p>Now you have three options for dynamic proxy generation:</p>
<p><a href="http://www.castleproject.org/">Castle</a>, <a href="http://code.google.com/p/linfu/">LinFu</a> and <a href="http://www.springframework.net/">Spring</a>.</p>
<p>What next ? Probably <a href="http://www.codeplex.com/unity">Unity</a>.</p>
