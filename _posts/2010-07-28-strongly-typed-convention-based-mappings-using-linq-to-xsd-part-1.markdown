---
layout: post
title: "Strongly typed convention based mappings using Linq to Xsd - Part 1"
date: 2010-07-28 16:11:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "linqtoxsdmappings"]
alias: ["/blogs/nhibernate/archive/2010/07/28/strongly-typed-convention-based-mappings-using-linq-to-xsd-part-1.aspx"]
author: mcintyre321
gravatar: 4908618aea7c32eb0f94d398b57fa28d
---
{% include imported_disclaimer.html %}
<p>This is part 1 in a blog series about <a href="http://fabiomaulo.blogspot.com/2010/03/nhibernate-mappings-path.html" target="_blank">yet another </a>method for configuring your NHibernate mappings in code and writing conventions. Although there are mature solutions for doing this like <a href="http://fluentnhibernate.org/" target="_blank">Fluent NHibernate</a>, I have found that they have required me to learn a new API and set of conventions, and sometimes the extension points I need haven't yet been implemented. I, like a lot of people, am most familiar with configuring NHibernate using xml files, so having a code based API that is very close in structure to an hbm document means I spend less time learning a new API, and more time getting my mappings written and out of the way. In this series, I will show you this API, and show you how simple it is to write your own custom mapping conventions on top of it.</p>
<p align="left">Given the formula <strong>domain assemblies + automapping framework = nhibernate mapping.xml </strong>it is obvious we will need to somehow manipulate and produce an nhibernate mapping xml file in a structured way, using c# code. The way I do this is to use the <a target="_blank" href="http://linqtoxsd.codeplex.com/">LINQ To Xsd project</a> to generate&nbsp; a statically typed representation of an NHibernate mapping file. Here is a simple mapping file, with the classic xml mapping on the left (thanks <a href="http://www.fincher.org/tips/Languages/NHibernate.shtml">fincher.org</a>), and Linq To Xsd based mapping on the right:</p>
<p><a href="http://dl.dropbox.com/u/2808109/blog/nhmapping/xml%20vs%20linqtoxsd.png"><img src="http://dl.dropbox.com/u/2808109/blog/nhmapping/xml%20vs%20linqtoxsd.png" alt="xml vs linqtoxsd" border="0" title="xml vs linqtoxsd" style="border-right-width: 0px; display: block; float: none; border-top-width: 0px; border-bottom-width: 0px; margin-left: auto; border-left-width: 0px; margin-right: auto" /></a></p>
<p>You can see how similar the xml and the code are. This allows you to use easily migrate from xml mapping to code mappings. We can get rid of magic strings and make the mapping refactor proof very easily, e.g. by replacing "NHibernatePets.Pet, NHibernatePets" with typeof(Pet).AssemblyQualifiedName, and using <a target="_blank" href="http://www.clariusconsulting.net/blogs/kzu/archive/2007/12/30/49063.aspx">static reflection</a> to get the property names.</p>
<p>To try this out, download <a target="_blank" href="http://dl.dropbox.com/u/2808109/blog/nhmapping/nhibernate-configuration.cs">nhibernate-configuration.cs</a> and <a target="_blank" href="http://dl.dropbox.com/u/2808109/blog/nhmapping/nhibernate-mapping.cs">nhibernate-mapping.cs</a> (the LINQ to XSD generated files) and include them in your project (you'll also need the Xml.Schema.Linq.dll from <a href="http://linqtoxsd.codeplex.com/" target="_blank">Linq to XSD</a>), then bootstrap your NHibernate configuration using this snippet:</p>
<div id="codeSnippetWrapper" style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 20px 0px 10px; width: 97.5%; font-family: 'Courier New', courier, monospace; direction: ltr; max-height: 200px; font-size: 8pt; overflow: auto; cursor: text; border: silver 1px solid; padding: 4px;">
<div id="codeSnippet" style="text-align: left; line-height: 12pt; background-color: #f4f4f4; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;"><span style="color: #0000ff">public</span> <span style="color: #0000ff">static</span> Configuration GetConfiguration(<span style="color: #0000ff">string</span> connectionString)</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">{</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    var cfg = <span style="color: #0000ff">new</span> Configuration();</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    var mappingXDoc = <span style="color: #0000ff">new</span> hibernatemapping()</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    {</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">        <span style="color: #008000">//add your mappings here</span></pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    };</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">&nbsp;</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    cfg.SetProperty(NHibernate.Cfg.Environment.Dialect, <span style="color: #006080">"NHibernate.Dialect.MsSql2008Dialect"</span>);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    cfg.SetProperty(NHibernate.Cfg.Environment.ConnectionDriver, <span style="color: #006080">"NHibernate.Driver.SqlClientDriver"</span>);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    cfg.SetProperty(NHibernate.Cfg.Environment.ConnectionString, connectionString);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    cfg.SetProperty(NHibernate.Cfg.Environment.ConnectionProvider, <span style="color: #006080">"NHibernate.Connection.DriverConnectionProvider"</span>);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    cfg.SetProperty(NHibernate.Cfg.Environment.ProxyFactoryFactoryClass, <span style="color: #0000ff">typeof</span>(ProxyFactoryFactory).AssemblyQualifiedName);</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    </pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    cfg.AddXml(mappingXDoc.ToString());</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">&nbsp;</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: white; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">    <span style="color: #0000ff">return</span> cfg;</pre>
<!--CRLF-->
<pre style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;">}</pre>
<!--CRLF--></div>
</div>
<p>Now you should be able to get started with writing typed mappings. Next time we&rsquo;ll get started on conventions.</p>
<p>__________________________________________________________________________________________________________</p>
<p>This article was originally published (more or less) on my blog at <a target="_blank" href="http://www.adverseconditionals.com">www.adverseconditionals.com</a></p>
<p>&nbsp;</p>
