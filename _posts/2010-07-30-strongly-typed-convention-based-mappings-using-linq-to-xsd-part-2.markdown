---
layout: post
title: "Strongly typed convention based mappings using Linq to Xsd - Part 2"
date: 2010-07-30 14:08:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "linqtoxsdmappings"]
redirect_from: ["/blogs/nhibernate/archive/2010/07/30/strongly-typed-convention-based-mappings-using-linq-to-xsd-part-2.aspx/", "/blogs/nhibernate/archive/2010/07/30/strongly-typed-convention-based-mappings-using-linq-to-xsd-part-2.html"]
author: mcintyre321
gravatar: 4908618aea7c32eb0f94d398b57fa28d
---
{% include imported_disclaimer.html %}
<p>In <a target="_blank" href="http://www.adverseconditionals.com/2010/07/fluent-xml-free-convention-based.html">part 1</a> we found out how to generate a mapping file using c# and Linq To XSD. In this post we will extend that to show the use of conventions.</p>
<p>The first thing we need an automapping framework to do is to create a class element in our xml mapping file for each of the entity types in our project. We will need a list of the entities in our project:</p>
<div id="codeSnippetWrapper" style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; width: 97.5%; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; cursor: text; border: silver 1px solid; padding: 4px;">
<div id="codeSnippet" style="text-align: left; line-height: 12pt; background-color: #f4f4f4; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">var types = <span style="color: #0000ff">typeof</span>(User).Assembly.GetTypesSafe().Where(t.Namespace.StartsWith(<span style="color: #006080">"Servit.Domain.Entities"</span>)).ToList();</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">var mappingXDoc = <span style="color: #0000ff">new</span> hibernatemapping();</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;"><span style="color: #0000ff">foreach</span> (var type <span style="color: #0000ff">in</span> types)</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">{</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    var @<span style="color: #0000ff">class</span> = <span style="color: #0000ff">new</span> @<span style="color: #0000ff">class</span>()</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    {</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">        name = type.AssemblyQualifiedName,</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">        table = type.Name + <span style="color: #006080">"s"</span>, <span style="color: #008000">//feel free to use a more advanced pluralization method (<a href="http://bit.ly/b98JK6" title="http://bit.ly/b98JK6">http://bit.ly/b98JK6</a>) &ndash; adding an s works for me! </span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    };</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    mappingXDoc.@<span style="color: #0000ff">class</span>.Add(@<span style="color: #0000ff">class</span>); <span style="color: #008000">//LINQ to XSD didn't pluralize the @class collection, </span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    <span style="color: #008000">//it might have been better if it generated mappingXDoc.classes instead of mappingXDoc.@class...</span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">}</pre>
<!--CRLF--></div>
</div>
<p>A pretty simple convention, but it will do for now. So far we have a mapping document with all our classes, but they are all empty &ndash; no properties! We need some conventions. The idea is that these conventions should be easy peasy to write so that you don&rsquo;t need a big framework like FNH to get your mapping written.</p>
<p>Imagine we want to add conventions to do the following:</p>
<ol>
<li>add an Id element for each class with an Id property, mapped to a entity.Name + "Id" column in the db </li>
<li>add property elements for each int, string, bool etc. etc. except the id property </li>
<li>Add many-to-one properties automatically </li>
</ol>
<p>Lets suppose we have an interface IClassConvention. We&rsquo;re going to get hold of the conventions and apply them to the mappingXDoc variable we defined in the bootstrap code from <a target="_blank" href="http://www.adverseconditionals.com/2010/07/fluent-xml-free-convention-based.html">part 1</a>. Note the use of the <a target="_blank" href="http://www.adverseconditionals.com/2010/07/using-topological-sort-to-order-rules.html">TopologicalSort method</a> from another of my posts, called via an extension method, because we want the conventions to execute in a certain order.</p>
<div id="codeSnippetWrapper">
<div id="codeSnippet" style="text-align: left; line-height: 12pt; background-color: #f4f4f4; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;"><span style="color: #008000">//get all the convention types in our assembly</span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">var conventions = <span style="color: #0000ff">typeof</span>(IClassConvention).Assembly.GetTypesSafe()</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    .Where(t =&gt; <span style="color: #0000ff">typeof</span> (IClassConvention).IsAssignableFrom(t))</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    .Where(t =&gt; t.CanBeInstantiated()) <span style="color: #008000">//check they aren't abstract or have open generic types</span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    .TopoSort((t, potentialTypes) =&gt; potentialTypes.Where(pt =&gt; <span style="color: #0000ff">typeof</span> (IRunAfter&lt;&gt;).MakeGenericType(t).IsAssignableFrom(pt)))</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    .Select(t =&gt; (IClassConvention)Activator.CreateInstance(t)).ToList(); <span style="color: #008000">//and instantiate them</span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">&nbsp;</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;"><span style="color: #0000ff">foreach</span> (var convention <span style="color: #0000ff">in</span> conventions)</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">{</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    <span style="color: #0000ff">foreach</span> (var type <span style="color: #0000ff">in</span> types)</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    {</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">        var @<span style="color: #0000ff">class</span> = mappingXDoc.@<span style="color: #0000ff">class</span>.Single(c =&gt; c.name == type.AssemblyQualifiedName);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">        convention.Apply(type, @<span style="color: #0000ff">class</span>, types, mappingXDoc);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    }</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">}</pre>
<!--CRLF--></div>
</div>
<p>OK, so we haven&rsquo;t got any conventions yet, but you can see how we call them and apply them. This is pretty much the whole &ldquo;framework&rdquo; right there. As you can see, there isn&rsquo;t much to it. With this little code, you should be able to start writing your own convention framework, tailored specifically to your classes and database schema.&nbsp;</p>
<p>In the next post, we&rsquo;ll implement a convention or two, and link to a sample project.</p>
