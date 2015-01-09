---
layout: post
title: "From where start to implements IDataBaseSchema"
date: 2009-06-12 17:30:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/06/12/from-where-start-to-implements-idatabaseschema.aspx/", "/blogs/nhibernate/archive/2009/06/12/from-where-start-to-implements-idatabaseschema.html"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>The <a target="_blank" href="http://fabiomaulo.blogspot.com/2009/06/auto-quote-tablecolumn-names.html">auto-quote and auto import KeyWords features</a> are now available in NHibernate but only for those dialects are providing an implementation of <span style="color: #2b91af">IDataBaseSchema</span>.</p>
<p>If the NHibernate&rsquo;s dialect, for your favorite RDBMS, does not provide an implementation of <span style="color: #2b91af">IDataBaseSchema</span>, what can you do ?</p>
<h4>Start point</h4>
<p>First of all you need an easy way to know some &ldquo;internals&rdquo; of your DataProvider/RDBMS. The code to extract all information you are needing to implement a <span style="color: #2b91af">IDataBaseSchema</span> is: </p>
<pre class="code"><span style="color: blue">internal class </span><span style="color: #2b91af">Program<br /></span>{<br /> <span style="color: blue">private static void </span>Main(<span style="color: blue">string</span>[] args)<br /> {<br />  <br />     <span style="color: green">// Extract metadata for Oracle<br />     </span>CreateMetadataXml(<span style="color: #a31515">"System.Data.OracleClient"</span>, <span style="color: #a31515">"User Id=NH; Password=nh"</span>);<br /><br />     <span style="color: green">// Extract metadata for MsSQL<br />     </span>CreateMetadataXml(<span style="color: #a31515">"System.Data.SqlClient"</span>, <span style="color: #a31515">@"Data Source=localhost\SQLEXPRESS;Initial Catalog=NHTEST;Integrated Security=True"</span>);<br />  <br />     <span style="color: #2b91af">Console</span>.WriteLine(<span style="color: #a31515">"Work done!"</span>);<br />     <span style="color: #2b91af">Console</span>.ReadLine();<br /> }<br /><br /> <span style="color: blue">private static void </span>CreateMetadataXml(<span style="color: blue">string </span>providerName, <span style="color: blue">string </span>connectionString)<br /> {<br />     <span style="color: #2b91af">DbProviderFactory </span>factory = <span style="color: #2b91af">DbProviderFactories</span>.GetFactory(providerName);<br /><br />     <span style="color: blue">using </span>(<span style="color: #2b91af">DbConnection </span>conn = factory.CreateConnection())<br />     {<br />         <span style="color: blue">try<br />         </span>{<br />             conn.ConnectionString = connectionString;<br />             conn.Open();<br /><br />             <span style="color: green">//Get MetaDataCollections and write to an XML file.<br />             //This is equivalent to GetSchema()<br />             </span><span style="color: #2b91af">DataTable </span>dtMetadata = conn.GetSchema(<span style="color: #2b91af">DbMetaDataCollectionNames</span>.MetaDataCollections);<br />             dtMetadata.WriteXml(providerName + <span style="color: #a31515">"_MetaDataCollections.xml"</span>);<br /><br />             <span style="color: green">//Get Restrictions and write to an XML file.<br />             </span><span style="color: #2b91af">DataTable </span>dtRestrictions = conn.GetSchema(<span style="color: #2b91af">DbMetaDataCollectionNames</span>.Restrictions);<br />             dtRestrictions.WriteXml(providerName + <span style="color: #a31515">"_Restrictions.xml"</span>);<br /><br />             <span style="color: green">//Get DataSourceInformation and write to an XML file.<br />             </span><span style="color: #2b91af">DataTable </span>dtDataSrcInfo = conn.GetSchema(<span style="color: #2b91af">DbMetaDataCollectionNames</span>.DataSourceInformation);<br />             dtDataSrcInfo.WriteXml(providerName + <span style="color: #a31515">"_DataSourceInformation.xml"</span>);<br /><br />             <span style="color: green">//data types and write to an XML file.<br />             </span><span style="color: #2b91af">DataTable </span>dtDataTypes = conn.GetSchema(<span style="color: #2b91af">DbMetaDataCollectionNames</span>.DataTypes);<br />             dtDataTypes.WriteXml(providerName + <span style="color: #a31515">"_DataTypes.xml"</span>);<br /><br />             <span style="color: green">//Get ReservedWords and write to an XML file.<br />             </span><span style="color: #2b91af">DataTable </span>dtReservedWords = conn.GetSchema(<span style="color: #2b91af">DbMetaDataCollectionNames</span>.ReservedWords);<br />             dtReservedWords.WriteXml(providerName + <span style="color: #a31515">"_ReservedWords.xml"</span>);<br />         }<br />         <span style="color: blue">catch </span>(<span style="color: #2b91af">Exception </span>ex)<br />         {<br />             <span style="color: #2b91af">Console</span>.WriteLine(ex.Message);<br />             <span style="color: #2b91af">Console</span>.WriteLine(ex.StackTrace);<br />         }<br />     }<br /> }<br />}</pre>
<p>The code above will create an XML file for each &ldquo;matter&rdquo; involved with <span style="color: #2b91af">IDataBaseSchema</span> implementation.</p>
<h4>What&rsquo;s next</h4>
<p>I don&rsquo;t want to deep in details because each RDBMS may have different info so the only things I can tell you are:</p>
<ul>
<li>There are some base classes that may work, as is, for your RDBMS : <span style="color: #2b91af">AbstractDataBaseSchema</span>, <span style="color: #2b91af">AbstractTableMetadata</span>, <span style="color: #2b91af">AbstractColumnMetaData</span>, <span style="color: #2b91af">AbstractForeignKeyMetadata</span>, <span style="color: #2b91af">AbstractIndexMetadata</span>. </li>
<li>There are some implementations for various RDBMS where you can see which are the difference and where some information, extracted from the code above, was used : FirebirdMetaData.cs, MsSqlCeMetaData.cs, MsSqlMetaData.cs, MySQLMetaData.cs, OracleMetaData.cs, SQLiteMetaData.cs, SybaseAnywhereMetaData.cs. </li>
<li>Tests to pass are contained in NHibernate.Test.Tools.hbm2ddl namespace. </li>
</ul>
<h4>What you should do after implement IDataBaseSchema</h4>
<p>Create a new <a target="_blank" href="http://jira.nhforge.org/">JIRA ticket</a> as:</p>
<ul>
<li>Project : NHibernate </li>
<li>Issue Type: Improvement </li>
<li>Summary : New DataBase schema provider for <em>&ldquo;your preferred RDBMS&rdquo;</em> </li>
<li>Priority : Minor </li>
<li>Component : DataProviders / Dialects </li>
<li>Affects Version : <em>&ldquo;The last released&rdquo;</em> </li>
<li>Description : <em>&ldquo;Few words&rdquo;</em> </li>
<li>Attachment : this is the most important; <span style="text-decoration: underline;"><strong>send us your implementation</strong></span>!! </li>
</ul>
<p>Thanks.</p>
