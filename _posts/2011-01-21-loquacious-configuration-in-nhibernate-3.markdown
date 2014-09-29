---
layout: post
title: "Loquacious Configuration in NHibernate 3"
date: 2011-01-21 21:54:07 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "fluent configuration"]
alias: ["/blogs/nhibernate/archive/2011/01/21/loquacious-configuration-in-nhibernate-3.aspx"]
author: James Kovacs
gravatar: 67e778f4df48de5a47de8ee689763eb7
---
{% include imported_disclaimer.html %}
<p>[This article was originally published on my personal blog <a href="http://jameskovacs.com/2011/01/21/loquacious-configuration-in-nhibernate-3/">here</a>. I hereby grant myself permission to re-publish it on NHForge.org.]</p>  <p>[Code for this article is available on GitHub <a href="https://github.com/JamesKovacs/NH3Features/tree/01-Loquacious">here</a>.]</p>  <p>One of the new features in NHibernate 3 is the addition of a fluent API for configuring NHibernate through code. Fluent NHibernate has provided a fluent configuration API for awhile, but now we have an option built into NHibernate itself. (Personally I prefer the new Loquacious API to Fluent NHibernate’s configuration API as I find Loquacious more discoverable. Given that Fluent NHibernate is built on top of NHibernate, you can always use Loquacious with Fluent NHibernate too. N.B. I still really like Fluent NHibernate’s ClassMap&lt;T&gt;, automapping capabilities, and PersistenceSpecification&lt;T&gt;. So don’t take my preference regarding fluent configuration as a denouncement of Fluent NHibernate.)</p>  <p>The fluent configuration API built into NHibernate is called Loquacious configuration and exists as a set of extensions methods on NHibernate.Cfg.Configuration. You can access these extension methods by importing in the NHibernate.Cfg.Loquacious namespace.</p>  <pre class="brush: csharp;">var cfg = new Configuration();
cfg.Proxy(p =&gt; p.ProxyFactoryFactory&lt;ProxyFactoryFactory&gt;())
   .DataBaseIntegration(db =&gt; {
                            db.ConnectionStringName = &quot;scratch&quot;;
                            db.Dialect&lt;MsSql2008Dialect&gt;();
                            db.BatchSize = 500;
                        })
   .AddAssembly(typeof(Blog).Assembly)
   .SessionFactory().GenerateStatistics();</pre>

<p>On the second line, we configure the ProxyFactoryFactory, which is responsible for generating the proxies needed for lazy loading. The ProxyFactoryFactory type parameter (stuff between the &lt;&gt;) is in the NHibernate.ByteCode.Castle namespace. (I have a reference to the NHibernate.ByteCode.Castle assembly too.) So we’re using Castle to generate our proxies. We could also use LinFu or Spring.</p>

<p>Setting db.ConnectionStringName causes NHibernate to read the connection string from the &lt;connectionStrings/&gt; config section of the [App|Web].config. This keeps your connection strings in an easily managed location without being baked into your code. You can perform the same trick in XML-based configuration by using the <em>connection.connection_string_name</em> property instead of the more commonly used <em>connection.connection_string</em>.</p>

<p>Configuring BatchSize turns on update batching in databases, which support it. (Support is limited to SqlClient and OracleDataClient currently and relies on features of these drivers.) Updating batching allows NHibernate to group together multiple, related INSERT, UPDATE, or DELETE statements in a single round-trip to the database. This setting isn’t strictly necessary, but can give you a nice performance boost with DML statements. The value of 500 represents the maximum number of DML statements in one batch. The choice of 500 is arbitrary and should be tuned for your application.</p>

<p>The assembly that we are adding is the one that contains our hbm.xml files as embedded resources. This allows NHibernate to find and parse our mapping metadata. If you have your metadata located in multiple files, you can call cfg.AddAssembly() multiple times.</p>

<p>The last call, cfg.SessionFactory().GenerateStatistics(), causes NHibernate to output additional information about entities, collections, connections, transactions, sessions, second-level cache, and more. Although not required, it does provide additional useful information about NHibernate’s performance.</p>

<p>Notice that there is no need to call <em>cfg.Configure()</em>. cfg.Configure() is used to read in configuration values from [App|Web].config (from the hibernate-configuration config section) or from hibernate.cfg.xml. If we’ve not using XML configuration, cfg.Configure() is not required.</p>

<p>Loquacious and XML-based configuration are not mutually exclusive. We can combine the two techniques to allow overrides or provide default values – it all comes down to the order of the Loquacious configuration code and the call to cfg.Configure().</p>

<pre class="brush: csharp; highlight: [2];">var cfg = new Configuration();
cfg.Configure();
cfg.Proxy(p =&gt; p.ProxyFactoryFactory&lt;ProxyFactoryFactory&gt;())
   .SessionFactory().GenerateStatistics();</pre>

<p>Note the cfg.Configure() on the second line. We read in the standard XML-based configuration and then force the use of a particular ProxyFactoryFactory and generation of statistics via Loquacious configuration.</p>

<p>If instead we make the call to cfg.Configure() after the Loquacious configuration, the Loquacious configuration provides default values, but we can override any and all values using XML-based configuration.</p>

<pre class="brush: csharp; highlight: [10];">var cfg = new Configuration();
cfg.Proxy(p =&gt; p.ProxyFactoryFactory&lt;ProxyFactoryFactory&gt;())
   .DataBaseIntegration(db =&gt; {
                            db.ConnectionStringName = &quot;scratch&quot;;
                            db.Dialect&lt;MsSql2008Dialect&gt;();
                            db.BatchSize = 500;
                        })
   .AddAssembly(typeof(Blog).Assembly)
   .SessionFactory().GenerateStatistics();
cfg.Configure();</pre>

<p>You can always mix and match the techniques by doing some Loquacious configuration before and som after the call to cfg.Configure().</p>

<p><strong>WARNING</strong>: If you call cfg.Configure(), you need to have &lt;hibernate-configuration/&gt; in your [App|Web].config or a hibernate.cfg.xml file. If you don’t, you’ll throw a HibernateConfigException. They can contain an empty root element, but it needs to be there. Another option would be to check whether File.Exists(‘hibernate.cfg.xml’) before calling cfg.Configure().</p>

<p>So there you have it. The new Loquacious configuration API in NHibernate 3. This introduction was not meant as a definitive reference, but as a jumping off point. I would recommend that you explore other extension methods in the NHibernate.Cfg.Loquacious namespace as they provide the means to configure the 2nd-leve cache, current session context, custom LINQ functions, and more. Anything you can do in XML-based configuration can now be accomplished with Loquacious or the existing methods on NHibernate.Cfg.Configuration. So get out there and start coding – XML is now optional…</p>
