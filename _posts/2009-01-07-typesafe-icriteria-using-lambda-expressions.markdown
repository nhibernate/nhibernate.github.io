---
layout: post
title: "Typesafe ICriteria using Lambda Expressions"
date: 2009-01-07 10:08:00 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/01/07/typesafe-icriteria-using-lambda-expressions.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p><i>
<p>Originally announced on my own blog here: <a target="_blank" href="http://broloco.blogspot.com/2008/12/using-lambda-expressions-with.html" style="background:#c0ffc0;">Using Lambda Expressions with NHibernate </a></p>
</i></p>
<h4>Introduction</h4>
<p>I love NHibernate, but I've never been a fan of the 'magic strings' used in the ICriteria API. Now we have .Net 3.5, and the ability to have strongly-typed queries built into the language, and a corresponding NH-Contrib project (NHibernate.Linq) to allow us to use LINQ with NHibernate. </p>
<p>However, there are still times when you need to use the ICriteria API (or HQL) to achieve the results you want. </p>
<h4>When ICriteria is more powerful than LINQ</h4>
<p>Consider the following query: </p>
<p><code>&nbsp;&nbsp;&nbsp; session.CreateCriteria(typeof(Person), "personAlias")<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .SetFetchMode("personAlias.PersonDetail", FetchMode.Eager)<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <i>// to prevent select n+1</i><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .SetLockMode("personAlias", LockMode.Upgrade)<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <i>// to read-lock the data until commit</i><br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .Add(Expression.Like("Name", "%anna%"))<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <i>// includes the name 'Polyanna', 'Annabella', ...</i><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ...<br /></code></p>
<p>LINQ provides a high-level abstraction of a query that can potentially be run against any datasource. However, this abstraction comes at a cost (try writing the above query in LINQ). LINQ (out of the box) has no concept of: 
<ul>
<li>Fetch modes (an ORM concept);</li>
<li>Locking (a database/transaction concept);</li>
<li>SQL specific functions (there is not always an equivalent C# function).</li>
</ul>
</p>
<p>So ICriteria and HQL will not be obsolete - they will quite happily live side-by-side with LINQ. </p>
<h4>Typesafe Syntax for ICriteria</h4>
<p>In order to implement LINQ, .Net 3.5 also introduced both <a target="_blank" href="http://weblogs.asp.net/scottgu/archive/2007/03/13/new-orcas-language-feature-extension-methods.aspx">Extension Methods</a> and <a target="_blank" href="http://weblogs.asp.net/scottgu/archive/2007/04/08/new-orcas-language-feature-lambda-expressions.aspx">Lambda Expressions</a> </p>
<p>Extension methods allow us to extend the ICriteria interface with our own methods, while Lambda Expressions allow us to create typesafe expressions that can be examined at runtime. So with some extra syntactic sugar, the above query can be written as: </p>
<p><code>
<divre></divre>&nbsp;&nbsp;&nbsp; Person personAlias = null;<br />&nbsp;&nbsp;&nbsp; session.CreateCriteria(typeof(Person), () =&gt; personAlias)<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .SetFetchMode(() =&gt; personAlias.PersonDetail, FetchMode.Eager)<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .SetLockMode(() =&gt; personAlias, LockMode.Upgrade)<br /><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; .Add(SqlExpression.Like&lt;Person&gt;(p =&gt; p.Name, "%anna%"))<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ...<br /><br /></code></p>
<p>The 'magic strings' are gone! This code uses a combination of Extension Methods and Lambda Expressions to create a typesafe version of the ICriteria. We can now also use our refactoring tools to rename, or find references to properties safe if the knowledge that the IDE will pick them up. </p>
<p>The extensions methods required to do this have been packaged up into a project (link below), making it easy to add this to your own .Net 3.5 NHibernate project. </p>
<p>With the addition of projects like <a target="_blank" href="http://code.google.com/p/fluent-nhibernate/">Fluent NHibernate</a> , perhaps 'magic strings' will finally become a thing of the past. </p>
<h5>Some links:</h5>
<p>
<ul>
<li><a target="_blank" href="http://code.google.com/p/nhlambdaextensions/">Project home</a>;</li>
<li><a target="_blank" href="http://nhlambdaextensions.googlecode.com/files/NhLambdaExtensions.html">Documentation</a>;</li>
<li><a target="_blank" href="http://code.google.com/p/nhlambdaextensions/downloads/list">Download</a>.</li>
</ul>
</p>
<div></div>
<p>
<divre></divre>
<divre></divre></p>
<p>
<divre></divre>
<divre></divre></p>
<p>
<divre></divre></p>
<p>
<divre></divre></p>
<p>
<divre></divre></p>
<p>
<divre></divre>
<divre></divre></p>
<pre></pre>
