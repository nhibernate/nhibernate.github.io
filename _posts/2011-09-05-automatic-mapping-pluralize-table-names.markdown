---
layout: post
title: "Automatic Mapping: Pluralize table names"
date: 2011-09-05 07:28:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "mapping by code"]
redirect_from: ["/blogs/nhibernate/archive/2011/09/05/automatic-mapping-pluralize-table-names.aspx/", "/blogs/nhibernate/archive/2011/09/05/automatic-mapping-pluralize-table-names.html"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p>Note: this is a cross post <a href="http://www.felicepollano.com/2011/09/02/AutomaticMappingPluralizeTableNames.aspx" target="_blank">from my own blog</a>.</p>
<p>In <a href="http://www.felicepollano.com/2011/09/01/UsingNH32MappingByCodeForAutomaticMapping.aspx" target="_blank">this post</a> we done some effort in automatically generate the mapping based on convention, but we miss a very common one: table names is usually the pluralized entity name. This is usually done by using an inflector. Thanks to <a href="http://www.stackoverflow.com" target="_blank">Stack Overflow</a>, <a href="http://stackoverflow.com/questions/2552816/alternatives-to-inflector-net" target="_blank">I found this question about it</a>, and choose <a href="http://cid-net.googlecode.com/svn/trunk/src/Cid.Mvc/Inflector.cs" target="_blank">that one</a>, that is a single easily embeddable file. So we modify a little our AutoMapper class as below:</p>
<blockquote>
<pre class="code"><span style="color: blue">void </span>AutoMapper_BeforeMapClass(<span style="color: #2b91af">IModelInspector </span>modelInspector, <span style="color: #2b91af">Type </span>type, <span style="color: #2b91af">IClassAttributesMapper </span>classCustomizer)
       {
           <span style="color: green">//
           // Create the column name as "c"+EntityName+"Id"
           //
           </span>classCustomizer.Id(k =&gt; 
                               { 
                                   k.Generator(<span style="color: #2b91af">Generators</span>.Native); k.Column(<span style="color: #a31515">"c" </span>+ type.Name + <span style="color: #a31515">"Id"</span>); 
                               }
                               );
           classCustomizer.Table(<span style="color: #2b91af">Inflector</span>.Pluralize(type.Name));
        }</pre>
</blockquote>
<p><a href="http://11011.net/software/vspaste"></a>&nbsp;</p>
<p>And this is all, the generated mapping will change as:</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">hibernate-mapping </span><span style="color: red">xmlns:xsi</span><span style="color: blue">=</span>"<span style="color: blue">http://www.w3.org/2001/XMLSchema-instance</span>" <span style="color: red">xmlns:x</span><span style="color: blue">=</span>""
<span style="color: red">sd</span><span style="color: blue">=</span>"<span style="color: blue">http://www.w3.org/2001/XMLSchema</span>" <span style="color: red">namespace</span><span style="color: blue">=</span>"<span style="color: blue">MappingByCode</span>" <span style="color: red">assembly</span><span style="color: blue">=</span>"<span style="color: blue">Mappin
gByCode</span>" <span style="color: red">xmlns</span><span style="color: blue">=</span>"<span style="color: blue">urn:nhibernate-mapping-2.2</span>"<span style="color: blue">&gt;
  &lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">SimpleEntity</span>" <span style="color: #00ff00;"><b><span style="font-size: medium;"><span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">SimpleEntities</span>"</span></b></span><span style="color: blue"><span style="color: #00ff00; font-size: medium;"><b>&gt;</b></span>
    &lt;</span><span style="color: #a31515">id </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Id</span>" <span style="color: red">column</span><span style="color: blue">=</span>"<span style="color: blue">cSimpleEntityId</span>" <span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">Int32</span>"<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">native</span>" <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Description</span>"<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">column </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">txtSimpleEntityDescr</span>" <span style="color: red">sql-type</span><span style="color: blue">=</span>"<span style="color: blue">AnsiString</span>" <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">many-to-one </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Referred</span>" <span style="color: red">column</span><span style="color: blue">=</span>"<span style="color: blue">cReferredId</span>" <span style="color: blue">/&gt;
  &lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;
</span></pre>
<p>
<a href="http://11011.net/software/vspaste"></a>&hellip; 
</p>
<p>Just for better sharing, <a href="https://bitbucket.org/Felice_Pollano/mappingbycode" target="_blank">I published this &ldquo;laboratory&rdquo; project here</a>.</p>
