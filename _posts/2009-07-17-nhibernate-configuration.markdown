---
layout: post
title: "NHibernate Configuration"
date: 2009-07-17 21:30:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["caches", "configuration", "NHibernate", "fluent configuration"]
redirect_from: ["/blogs/nhibernate/archive/2009/07/17/nhibernate-configuration.aspx"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>[<a target="_blank" href="http://fabiomaulo.blogspot.com/">My blog</a>]</p>
<p>Perhaps not so many people know in how many ways NH can be configured since NH2.0.0. In this post I&rsquo;ll try to summarize some one before implement <em><a target="_blank" href="http://fabiomaulo.blogspot.com/2009/02/nhvloquacious-fluent-configuration-for.html">Loquacious configuration</a></em> in NH3.0.0.</p>
<h4>Xml (default)</h4>
<p>The xml way is the most common used so only some little notes are needed here.</p>
<p>Inside the root node, <span style="color: #800000">hibernate-configuration</span>, you can configure 3 &ldquo;things&rdquo;: the bytecode provider, the reflection optimizer usage and the session-factory.</p>
<p>The bytecode provider and the reflection optimizer can be configured only and exclusively inside the application config (app.config or web.config); outside application config the two configuration are ignored. If you need to configure the bytecode provider or the reflection optimizer the minimal configuration required, inside app.config is, for example:</p>
<pre class="code">    <span style="color: blue">&lt;</span><span style="color: #a31515">hibernate-configuration </span><span style="color: red">xmlns</span><span style="color: blue">=</span>"<span style="color: blue">urn:nhibernate-configuration-2.2</span>"<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">bytecode-provider </span><span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">null</span>"<span style="color: blue">/&gt;<br />   &lt;</span><span style="color: #a31515">reflection-optimizer </span><span style="color: red">use</span><span style="color: blue">=</span>"<span style="color: blue">false</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">hibernate-configuration</span><span style="color: blue">&gt;</span></pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>As you can see the <span style="color: #800000">session-factory</span> section is not present (for this reason I wrote &ldquo;<em>minimal</em>&rdquo;).</p>
<p>The session-factory configuration can be wrote inside or outside the app.config or even in both (inside <strong><span style="text-decoration: underline;">and</span></strong> outside). The minimal configuration required is:</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">hibernate-configuration </span><span style="color: red">xmlns</span><span style="color: blue">=</span>"<span style="color: blue">urn:nhibernate-configuration-2.2</span>"<span style="color: blue">&gt;<br />&lt;</span><span style="color: #a31515">session-factory </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">NHibernate.Test</span>"<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">dialect</span>"<span style="color: blue">&gt;</span>NHibernate.Dialect.MsSql2005Dialect<span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">proxyfactory.factory_class</span>"<span style="color: blue">&gt;<br />       </span>NHibernate.ByteCode.LinFu.ProxyFactoryFactory, NHibernate.ByteCode.LinFu<br />   <span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;<br />&lt;/</span><span style="color: #a31515">session-factory</span><span style="color: blue">&gt;<br />&lt;/</span><span style="color: #a31515">hibernate-configuration</span><span style="color: blue">&gt;</span></pre>
<p>As you can see there are only two properties and, as is, you can&rsquo;t use this configuration because there isn&rsquo;t the connection string.</p>
<p>If you want you can write the minimal configuration inside your application config and merge/override it with the configuration wrote in an external file. I&rsquo;m using this technique everywhere for tests purpose because test suite and production has some common configuration and some other different configuration (for example the <span style="color: #0000ff">current_session_context_class</span>). The code to merge/override the configuration inside app.config with the configuration outside the app.config is:</p>
<pre class="code"><span style="color: blue">var </span>configuration = <span style="color: blue">new </span><span style="color: #2b91af">Configuration</span>()<br />.Configure()<br />.Configure(yourNhConfPath);</pre>
<p>After this two lines you can continue configuring NHibernate by code (even using the method chaining).</p>
<h4>Xml (custom configSections)</h4>
<p>As usual in NHibernate, you can have a custom <strong><em>Schema</em></strong> for the <span style="color: #800000">hibernate-configuration</span> section. The way is simple:</p>
<pre class="code">    <span style="color: blue">&lt;</span><span style="color: #a31515">configSections</span><span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">section </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">hibernate-configuration</span>"<br />            <span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">YourCompany.YourProduct.YourConfigurationSectionHandler, YourAssembly</span>" <span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">configSections</span><span style="color: blue">&gt;<br /></span></pre>
<p>The restriction is :</p>
<ol>
<li>The section name must be &ldquo;hibernate-configuration&rdquo;. </li>
<li>Your ConfigurationSectionHandler must implements <span style="color: #2b91af">IHibernateConfiguration</span>. </li>
</ol>
<p>The reason to write a custom ConfigurationSectionHandler, more than implement something related to <em>Enterprise Library-Configuration Application Block</em>, can be related with the need of some framework (your imagination may work here).</p>
<h4>Xml : <em>The mystery</em></h4>
<p>In these year I saw :</p>
<ul>
<li>everybody using <span style="color: #a31515">property</span> </li>
<li>somebody using the <span style="color: #a31515">mapping</span> section </li>
<li>few people using the <span style="color: #a31515">event</span> and/or the <span style="color: #a31515">listener</span> sections </li>
<li><strong>absolutely nobody using the <span style="color: #a31515">class-cache</span> nor <span style="color: #a31515">collection-cache</span> sections</strong> </li>
</ul>
<p>The two sections related with the second-level-cache configuration are very useful. In general the configuration of the cache is something happening after wrote all mappings; you may have a tests suite that must work without cache and another test suite to check the behavior using second-level-cache. Even if I have changed NH2.1.0 to ignore the cache configuration, inside a class-mapping, when the <span style="color: #0000ff">cache.use_second_level_cache</span> is set to <span style="color: #0000ff">false</span>, the right place to configure the cache, of each class/collection, is inside the session-factory-configuration and not inside the class-mapping itself; you don&rsquo;t need to modify a tested mapping only because cache and you don&rsquo;t need to re-deploy class-mappings only because you need to modify/add the cache configuration of a class/collection.</p>
<h4>Configuration by code</h4>
<p>The whole configuration via XML can be done by pure .NET code.</p>
<p>The bytecode provider can be set before create an instance of the <span style="color: #2b91af">Configuration</span> class:</p>
<pre class="code"><span style="color: #2b91af">Environment</span>.BytecodeProvider = <span style="color: blue">new </span><span style="color: #2b91af">EnhancedBytecode</span>(container);<br /><span style="color: blue">var </span>cfg = <span style="color: blue">new </span><span style="color: #2b91af">Configuration</span>();</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>To set properties in a no strongly typed way (mean by strings) :</p>
<pre class="code">configuration.SetProperty(<span style="color: #2b91af">Environment</span>.GenerateStatistics, <span style="color: #a31515">"true"</span>);<br />configuration.SetProperty(<span style="color: #2b91af">Environment</span>.BatchSize, <span style="color: #a31515">"10"</span>);</pre>
<p>To set listeners in a no strongly typed way (mean by strings) :</p>
<pre class="code">configuration.SetListeners(<span style="color: #2b91af">ListenerType</span>.PreInsert,<br /><span style="color: blue">new</span>[] { <span style="color: #a31515">"YourCompany.YourProduct.YourListener, YourAssembly" </span>});</pre>
<p>To set listeners in strongly typed way :</p>
<pre class="code">configuration.EventListeners.DeleteEventListeners =<br /><span style="color: blue">new</span>[] {<span style="color: blue">new </span><span style="color: #2b91af">ResetReadOnlyEntityDeleteListener</span>()}<br />.Concat(listeners.DeleteEventListeners).ToArray();</pre>
<p>To add class-mappings the <span style="color: #2b91af">Configuration</span> class has various <em>Add*</em> methods :</p>
<p>AddAssembly(<span style="color: #2b91af">Assembly</span> assembly) 
  <br />AddAssembly(<span style="color: #0000ff">string</span> assemblyName) 
  <br />AddClass(System.<span style="color: #2b91af">Type</span> persistentClass) 
  <br />AddDirectory(<span style="color: #2b91af">DirectoryInfo</span> dir) 
  <br />AddFile(<span style="color: #0000ff">string</span> xmlFile) 
  <br />AddFile(<span style="color: #2b91af">FileInfo</span> xmlFile) 
  <br />AddXmlReader(<span style="color: #2b91af">XmlReader</span> hbmReader) 
  <br />AddXml(<span style="color: #0000ff">string</span> xml) 
  <br />AddResource(<span style="color: #0000ff">string</span> path, <span style="color: #2b91af">Assembly</span> assembly) 
  <br />... 
  <br />...</p>
<p><strong>Note</strong> AddXml(<span style="color: #0000ff">string</span> xml) or AddXmlString(<span style="color: #0000ff">string</span> xml) mean that you can add a mapping created at run-time:</p>
<pre class="code"><span style="color: blue">string </span>hbm =<br /><span style="color: #a31515">@"&lt;?xml version='1.0' encoding='utf-8' ?&gt;<br />           &lt;hibernate-mapping xmlns='urn:nhibernate-mapping-2.2'<br />               namespace='NHibernate.DomainModel'<br />               assembly='NHibernate.DomainModel'&gt;<br />               &lt;class name='A' persister='A'&gt;<br />                   &lt;id name='Id'&gt;<br />                       &lt;generator class='native' /&gt;<br />                   &lt;/id&gt;<br />               &lt;/class&gt;<br />           &lt;/hibernate-mapping&gt;"</span>;<br /><br /><span style="color: #2b91af">Configuration </span>cfg = <span style="color: blue">new </span><span style="color: #2b91af">Configuration</span>();<br />cfg.AddXmlString(hbm);</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>To set second-level-cache configuration for classes and collections:</p>
<p>SetCacheConcurrencyStrategy(<span style="color: #0000ff">string</span> clazz, <span style="color: #0000ff">string</span> concurrencyStrategy) 
  <br />SetCacheConcurrencyStrategy(<span style="color: #0000ff">string</span> clazz, <span style="color: #0000ff">string</span> concurrencyStrategy, <span style="color: #0000ff">string</span> region) 
  <br />SetCollectionCacheConcurrencyStrategy(<span style="color: #0000ff">string</span> collectionRole, <span style="color: #0000ff">string</span> concurrencyStrategy)</p>
<h4>The trick of custom Dialect</h4>
<p>Few people know this trick (perhaps only the one I&rsquo;m seeing everyday in the mirror).</p>
<p>Each Dialect has the ability to define its own <em>DefaultProperties</em>. Inside the core, so far, we are using the <em>DefaultProperties</em> property only for few purpose (for example to define the default driver):</p>
<pre class="code">DefaultProperties[<span style="color: #2b91af">Environment</span>.ConnectionDriver] =<br /><span style="color: #a31515">"NHibernate.Driver.SqlClientDriver"</span>;</pre>
<p>If you are not so scared by inherit from a dialect implemented in the core and extends it to register some functions or to change some behavior, you can use it even to define default properties:</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">YourCustomDialect </span>: <span style="color: #2b91af">MsSql2005Dialect<br /></span>{<br /><span style="color: blue">public </span>YourCustomDialect()<br />{<br />   DefaultProperties[<span style="color: #2b91af">Environment</span>.QuerySubstitutions] =<br />       <span style="color: #a31515">"wahr 1, falsch 0, ja 'J', nein 'N'"</span>;<br />   DefaultProperties[<span style="color: #2b91af">Environment</span>.ConnectionString] =<br />       <span style="color: #a31515">"your connection string"</span>;<br />   DefaultProperties[<span style="color: #2b91af">Environment</span>.BatchSize] = <span style="color: #a31515">"50"</span>;<br />}<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<h4>What we saw</h4>
<p>Since NH2.0.0GA, you have three or four ways to configure NHibernate with merge/override from different sources.</p>
