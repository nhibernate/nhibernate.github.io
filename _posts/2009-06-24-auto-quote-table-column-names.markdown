---
layout: post
title: "Auto Quote Table/Column names"
date: 2009-06-24 03:25:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["configuration", "NHibernate", "NH2.1"]
alias: ["/blogs/nhibernate/archive/2009/06/24/auto-quote-table-column-names.aspx"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>Since long time we have a very interesting request on <a target="_blank" href="http://jira.nhforge.org/">NHibernate JIRA</a> (NH-188).</p>
<p>If you are working in a multi-RDBMS application, you are annoyed, for sure, quoting a table-name or a column-name. As a very good persistent-layer this should be a NHibernate&rsquo;s work.</p>
<p>I&rsquo;m happy to announce that the problem is solved (even if, so far, is not done by default).</p>
<p>If you want that NH take the responsibility of properly quote table-name or column-name only where really needed now you can do it in two ways:</p>
<ol>
<li>Trough configuration </li>
<li>Explicitly by code </li>
</ol>
<h4>Trough configuration</h4>
<p>As you probably know NHibernate&rsquo;s configuration has some property oriented to mapping-to-DLL tasks.</p>
<p>For schema integration you can use</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">hbm2ddl.auto</span>"<span style="color: blue">&gt;</span>create-drop<span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;</span></pre>
<p>Allowed values for hbm2dll are:</p>
<ul>
<li><span style="color: #800000">update</span> : auto execute <span style="color: #2b91af">SchemaUpdate</span> on BuildSessionFactory </li>
<li><span style="color: #800000">create</span> : auto execute <span style="color: #2b91af">SchemaExport</span> on BuildSessionFactory </li>
<li><span style="color: #800000">create-drop</span> : auto execute <span style="color: #2b91af">SchemaExport</span> on BuildSessionFactory recreating the schema </li>
<li><span style="color: #800000">validate</span> : auto execute <span style="color: #2b91af">SchemaValidator</span> on BuildSessionFactory </li>
</ul>
<p>The new property is:</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">hbm2ddl.keywords</span>"<span style="color: blue">&gt;</span>auto-quote<span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;</span></pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>Allowed values are:</p>
<ul>
<li><span style="color: #800000">none</span> : disable any operation regarding RDBMS KeyWords </li>
<li><span style="color: #800000">keywords</span> : (<strong>activated by Default</strong>)imports all RDBMS KeyWords where the NH-Dialect can provide the implementation of <span style="color: #2b91af">IDataBaseSchema</span> (so far available for MsSQL, Oracle, Firebird, MsSqlCe, MySQL, SQLite, SybaseAnywhere) </li>
<li><span style="color: #800000">auto-quote</span> : imports all RDBMS KeyWords and auto-quote all table-names/column-names on BuildSessionFactory </li>
</ul>
<h4>Explicitly by code</h4>
<p>When you have an instance of a configured configuration (just before call BuildSessionFactory) you can execute:</p>
<pre class="code"><span style="color: #2b91af">SchemaMetadataUpdater</span>.QuoteTableAndColumns(configuration);</pre>
<p>That&rsquo;s all.</p>
<h4>The advantage</h4>
<p>Take a look to this mapping:</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Order</span>"<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">id </span><span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">int</span>"<span style="color: blue">&gt;<br />       &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">native</span>"<span style="color: blue">/&gt;<br />   &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Select</span>"<span style="color: blue">/&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">From</span>"<span style="color: blue">/&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">And</span>"<span style="color: blue">/&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Column</span>"<span style="color: blue">/&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Name</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;</span></pre>
<p>Well&hellip; now it is working fine without explicitly quote.</p>
<p>Enjoy NHibernate&rsquo;s multi-RDBMS easy support.</p>
