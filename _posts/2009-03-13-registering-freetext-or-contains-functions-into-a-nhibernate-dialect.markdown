---
layout: post
title: "Registering FREETEXT or CONTAINS functions into a NHibernate dialect"
date: 2009-03-13 13:04:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["SQL Server", "NH2.1", "Dialect", "Function"]
redirect_from: ["/blogs/nhibernate/archive/2009/03/13/registering-freetext-or-contains-functions-into-a-nhibernate-dialect.aspx/"]
author: darioquintana
gravatar: f436801727b13a5c4c4a38380fc17290
---
{% include imported_disclaimer.html %}
<p>Ms Sql Server FREETEXT and CONTAINS functions are used into FullText search capabilities to querying. These functions are of course natives to this particular RDBMS and even comes a with particular structure: they don&rsquo;t return a value. So far, till NH 2.0, you couldn&rsquo;t do it because a little parser issue, but from <b>NHibernate 2.1</b> in forward you&rsquo;re enable register them.</p>
<p>First of all, we define the new dialect with the new functions in order that when we run a query, NHibernate can recognize those functions and can transform to native-sql, in this case, Transact-SQL.</p>
<!-- code formatted by http://manoli.net/csharpformat/ -->
<pre class="csharpcode"><span class="kwrd">using</span> NHibernate.Dialect;
<span class="kwrd">using</span> NHibernate.Dialect.Function;

<span class="kwrd">namespace</span> MyCompany.Data
{
    <span class="kwrd">public</span> <span class="kwrd">class</span> MyDialect : MsSql2008Dialect
    {
        <span class="kwrd">public</span> MyDialect()
        {
            RegisterFunction(<span class="str">"freetext"</span>, <span class="kwrd">new</span> StandardSQLFunction(<span class="str">"freetext"</span>, <span class="kwrd">null</span>));
            RegisterFunction(<span class="str">"contains"</span>, <span class="kwrd">new</span> StandardSQLFunction(<span class="str">"contains"</span>, <span class="kwrd">null</span>));
        }
    }
}</pre>
<p>Note that we are using <b>StandardSQLFunction</b>, we can also use <b>SQLFunctionTemplate</b> or implement our <b>ISQLFunction</b> class with all the constraints (ie: parameter number accepted) we need.</p>
<p>Once our new dialect is ready let&rsquo;s call it from our <i>hibernate.cfg.xml</i> file, then NHibernate can know that this dialect will be inject. Suppose <b>MyDialect</b> is placed into the assembly <b>MyCompany.Data</b>, so the configuration file should look like this:</p>
<!-- code formatted by http://manoli.net/csharpformat/ -->
<pre class="csharpcode"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">="1.0"</span> <span class="attr">encoding</span><span class="kwrd">="utf-8"</span> ?<span class="kwrd">&gt;</span>
<span class="kwrd">&lt;</span><span class="html">hibernate-configuration</span>  <span class="attr">xmlns</span><span class="kwrd">="urn:nhibernate-configuration-2.2"</span> <span class="kwrd">&gt;</span>
    <span class="kwrd">&lt;</span><span class="html">session-factory</span> <span class="attr">name</span><span class="kwrd">="NH"</span><span class="kwrd">&gt;</span>        
        <b><span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="dialect"</span><span class="kwrd">&gt;</span>MyCompany.Data.MyDialect, MyCompany.Data<span class="kwrd">&lt;/</span><span class="html">property</span><span class="kwrd">&gt;</span></b>
        <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="connection.connection_string"</span><span class="kwrd">&gt;</span>
            Data Source=(local)\sqlexpress;Initial Catalog=test;Integrated Security = true
        <span class="kwrd">&lt;/</span><span class="html">property</span><span class="kwrd">&gt;</span>
        <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="proxyfactory.factory_class"</span><span class="kwrd">&gt;</span>NHibernate.ByteCode.LinFu.ProxyFactoryFactory, NHibernate.ByteCode.LinFu<span class="kwrd">&lt;/</span><span class="html">property</span><span class="kwrd">&gt;</span>
    <span class="kwrd">&lt;/</span><span class="html">session-factory</span><span class="kwrd">&gt;</span>
<span class="kwrd">&lt;/</span><span class="html">hibernate-configuration</span><span class="kwrd">&gt;</span></pre>
<p>Everything is ready, you just have to do this 2 steps and the functions are ready to use it, then we can query using them.</p>
<!-- code formatted by http://manoli.net/csharpformat/ -->
<pre class="csharpcode">session.CreateQuery(<span class="str">"from Documento where freetext(Texto,:keywords)"</span>)
    .SetString(<span class="str">"keywords"</span>,<span class="str">"hey apple car"</span>)
    .List();</pre>
<pre class="csharpcode">Note the above query is HQL, so NHibernate knows about <b>freetext</b> and can operate with it.</pre>
