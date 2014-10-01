---
layout: post
title: "Dynamic LINQ to NHibernate"
date: 2011-11-17 13:18:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["linq"]
redirect_from: ["/blogs/nhibernate/archive/2011/11/17/dynamic-linq-to-nhibernate.aspx/"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p align="justify">Even if Linq To NHibernate provider allow us to write query in a strongly type manner, it is sometimes needed to works with property names literally. For example in a RIA application a service can receive a column as a string containing the name of the property to order by. Since Linq to <a href="http://nhforge.org" target="_blank">NHibernate</a> is a standard Linq provider, we can leverage a standard dynamic linq parser. This is achieved by using an old code by MS, known as <a href="http://weblogs.asp.net/scottgu/archive/2008/01/07/dynamic-linq-part-1-using-the-linq-dynamic-query-library.aspx">System.Linq.Dynamic</a>. By following the link you will find a <a href="http://msdn.microsoft.com/en-us/vstudio/bb894665.aspx">download location</a> that point to an almost just a sample project that eventually contains the file <a href="https://raw.github.com/gist/1372806/f22488235a328af162f94de83b34bfe68f5975ce/Dynamic.cs">Dynamic.cs</a> that contains some extension method allowing to merge literal parts in a type safe linq query.</p>
<p align="justify">Let&rsquo;see an example:</p>
<pre class="code"><span style="color: blue">var </span>elist = session.Query&lt;<span style="color: #2b91af">MyEntity</span>&gt;()
              <b>.OrderBy(&ldquo;Name descending&rdquo;)</b>
              .Skip(first)
              .Take(count)
              .ToList();</pre>
<p align="justify">I supposed we have a property called Name on the class MyEntity. The OrderBy taking a string as a parameter is an extension method provided by <a href="https://raw.github.com/gist/1372806/f22488235a328af162f94de83b34bfe68f5975ce/Dynamic.cs">Dynamic.cs</a>, and in order to have it working you just need to merge the file <b>dynamic.cs</b> in your project and import <b>System.Linq.Dynamic</b>. Of course you will have extension for Where and for other linq operators too.</p>
<p>( <a href="http://www.felicepollano.com/">cross post from my blog</a> )</p>
