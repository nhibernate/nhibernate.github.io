---
layout: post
title: "NH2.1.0: Bytecode providers"
date: 2008-11-09 15:04:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["proxy", "NH2.1"]
redirect_from: ["/blogs/nhibernate/archive/2008/11/09/nh2-1-0-bytecode-providers.aspx/"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>This post is an update of <a href="/blogs/nhibernate/archive/2008/10/11/nh2-1-0-reference-to-castle-removed.aspx">&ldquo;Reference to Castle removed&rdquo;</a>.</p>
<p>In the trunk we had removed all dependency from any kind of &ldquo;Proxy framework&rdquo; trough various implementations of <span style="color: #2b91af">IProxyFactoryFactory</span>.</p>
<p><span style="text-decoration: underline;">There is not a specific default Proxy-framework</span> and now the set of <span style="color: #0000ff"><strong>proxyfactory.factory_class</strong></span> property, of the <span style="color: #800000">session-factory</span> configuration section, is mandatory (as the property <span style="color: #0000ff"><strong>dialect</strong></span>).</p>
<p>So far, two implementations of <span style="color: #2b91af">IProxyFactoryFactory</span> are available :</p>
<ol>
<li>NHibernate.ByteCode.<strong>LinFu</strong>.ProxyFactoryFactory </li>
<li>NHibernate.ByteCode.<strong>Castle</strong>.ProxyFactoryFactory </li>
</ol>
<p>Soon, we hope to have the availability of NHibernate.ByteCode.<strong>Spring</strong>.ProxyFactoryFactory.</p>
<p>For NHibernate testing purpose we are using <strong>LinFu </strong>without a special reason even if I have the impression that LinFu give us a very little performance improvement. For who are using NHibernate without an IoC framework LinFu.DynamicProxy is more than enough.</p>
<p>For who are working with <strong>Castle.ActiveRecord</strong> and/or <strong>Castle.Windsor</strong>, obviously, the best choice is Castle.DynamicProxy2 (mean NHibernate.ByteCode.Castle.ProxyFactoryFactory).</p>
<p>A minimal <span style="color: #800000">session-factory</span> configuration, to work with NH using MsSQL and LinFu, should look like this one:</p>
<div style="font-size: 8pt; margin: 20px 0px 10px; overflow: auto; width: 97.5%; cursor: text; line-height: 12pt; font-family: consolas, 'Courier New', courier, monospace; background-color: #f4f4f4; max-height: 200px; border: gray 1px solid; padding: 4px;">
<pre style="font-size: 8pt; margin: 0em; overflow: visible; width: 100%; color: black; line-height: 12pt; font-family: consolas, 'Courier New', courier, monospace; background-color: #f4f4f4; border-style: none; padding: 0px;"><span style="color: #0000ff">&lt;</span><span style="color: #800000">hibernate-configuration</span>  <span style="color: #ff0000">xmlns</span><span style="color: #0000ff">="urn:nhibernate-configuration-2.2"</span> <span style="color: #0000ff">&gt;</span>
    <span style="color: #0000ff">&lt;</span><span style="color: #800000">session-factory</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="YourAppName"</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="connection.driver_class"</span><span style="color: #0000ff">&gt;</span>NHibernate.Driver.SqlClientDriver<span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="dialect"</span><span style="color: #0000ff">&gt;</span>NHibernate.Dialect.MsSql2005Dialect<span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="connection.connection_string"</span><span style="color: #0000ff">&gt;</span>
            Server=(local);initial catalog=nhibernate;Integrated Security=SSPI
        <span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="proxyfactory.factory_class"</span><span style="color: #0000ff">&gt;</span>NHibernate.ByteCode.LinFu.ProxyFactoryFactory, NHibernate.ByteCode.LinFu<span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
    <span style="color: #0000ff">&lt;/</span><span style="color: #800000">session-factory</span><span style="color: #0000ff">&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">hibernate-configuration</span><span style="color: #0000ff">&gt;</span></pre>
</div>
<p>In this case you must confirm that your deployment folder contains : <strong>NHibernate.ByteCode.LinFu.dll</strong></p>
<p>&nbsp;</p>
<p>The same configuration for who want use Castle should look like this one:</p>
<div style="font-size: 8pt; margin: 20px 0px 10px; overflow: auto; width: 97.5%; cursor: text; line-height: 12pt; font-family: consolas, 'Courier New', courier, monospace; background-color: #f4f4f4; max-height: 200px; border: gray 1px solid; padding: 4px;">
<pre style="font-size: 8pt; margin: 0em; overflow: visible; width: 100%; color: black; line-height: 12pt; font-family: consolas, 'Courier New', courier, monospace; background-color: #f4f4f4; border-style: none; padding: 0px;"><span style="color: #0000ff">&lt;</span><span style="color: #800000">hibernate-configuration</span>  <span style="color: #ff0000">xmlns</span><span style="color: #0000ff">="urn:nhibernate-configuration-2.2"</span> <span style="color: #0000ff">&gt;</span>
    <span style="color: #0000ff">&lt;</span><span style="color: #800000">session-factory</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="YourAppName"</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="connection.driver_class"</span><span style="color: #0000ff">&gt;</span>NHibernate.Driver.SqlClientDriver<span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="dialect"</span><span style="color: #0000ff">&gt;</span>NHibernate.Dialect.MsSql2005Dialect<span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="connection.connection_string"</span><span style="color: #0000ff">&gt;</span>
            Server=(local);initial catalog=nhibernate;Integrated Security=SSPI
        <span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
        <span style="color: #0000ff">&lt;</span><span style="color: #800000">property</span> <span style="color: #ff0000">name</span><span style="color: #0000ff">="proxyfactory.factory_class"</span><span style="color: #0000ff">&gt;</span>NHibernate.ByteCode.Castle.ProxyFactoryFactory, NHibernate.ByteCode.Castle<span style="color: #0000ff">&lt;/</span><span style="color: #800000">property</span><span style="color: #0000ff">&gt;</span>
    <span style="color: #0000ff">&lt;/</span><span style="color: #800000">session-factory</span><span style="color: #0000ff">&gt;</span>
<span style="color: #0000ff">&lt;/</span><span style="color: #800000">hibernate-configuration</span><span style="color: #0000ff">&gt;</span></pre>
</div>
<p>In this case you must confirm that your deployment folder contains : <strong>NHibernate.ByteCode.Castle.dll</strong></p>
<p>&nbsp;</p>
<p><strong>LinFu info</strong> available <a href="http://www.codeproject.com/info/search.aspx?artkw=LinFu&amp;sbo=kw">here</a> and code <a href="http://code.google.com/p/linfu/">here</a>.</p>
<p>&nbsp;</p>
<h3>Enjoy NHibernate injectability.</h3>
<p>P.S. Let me say that something strange happened in my heart when I had remove the last reference to Castle in NH-Core and NH-Tests.</p>
