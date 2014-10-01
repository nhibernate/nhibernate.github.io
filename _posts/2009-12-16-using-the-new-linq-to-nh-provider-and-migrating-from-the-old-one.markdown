---
layout: post
title: "Using the new Linq to NH Provider and migrating from the old one"
date: 2009-12-16 23:52:39 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/12/17/using-the-new-linq-to-nh-provider-and-migrating-from-the-old-one.aspx"]
author: srstrong
gravatar: be49dc22186b4215272ffa6a46599424
---
{% include imported_disclaimer.html %}
<p>Using the new Linq provider is pretty simple. It all hangs of a Query() extension method on ISession, so you can do things like the following:</p><code>  from c in session.Query&lt;Customer&gt;() select c</code><br />
<p>In my tests, I've tended to wrap the session.Query() call behind a simple facade, along the lines of:</p><code>  public class Northwind<br />
  {<br />
   private readonly ISession _session;<br />
<br />
   public Northwind(ISession session)<br />
   {<br />
   _session = session;<br />
   }<br />
<br />
   public IQueryable&lt;Customer&gt; Customers   { get { return _session.Query&lt;Customer&gt;(); }<br />
  }<br /></code>
<p>Of course, that's entirely optional, but I find the resulting code easier to read:</p><code>  from c in db.Customers select c</code><br />
<p>Once you know how to hook into the session (which as you can see is pretty simple), the rest is just straightforward Linq code, and entirely up to you! Right now I'm not exposing any extension points, but they'll be coming soon (plus another post to describe how to use them).</p>
<p>The version 1 provider used an ISession extension method call Linq() to provide its hook. I purposefully used a different name, since there's no reason at all why you can't use both providers within the same project or, indeed, within the same session. So that gives a couple of migration options for folk that want to move to the new provider:</p>
<ul>
  <li>Leave all your current queries using .Linq(), and start using .Query() for new ones.</li>

  <li style="list-style: none"><br /></li>

  <li>Start changing existing queries from .Linq() to .Query(), just by changing them or by a simple search &amp; replace. The rest of the expression will (hopefully!) just work.</li>

  <li style="list-style: none"><br /></li>

  <li>Drop your reference to the original Linq provider assembly, and create your own extension method:<br />
  <br />
  <code>  public static IQueryable&lt;T&gt; Linq&lt;T&gt;(this ISession session)<br />
    {<br />
      return session.Query&lt;T&gt;();<br />
    }</code><br />
  <br />
  This lets you switch to the new provider without changing a line of your code - and if you find it all goes to hell, you just re-add the V1 reference and comment out your extension method. Should work like a treat.</li>
</ul>
<p>Other than that, I don't think there's much to tell - usage really should be pretty simple. Oh, one thing that springs to mind - although you can use the V1 provider and the new provider within the same project (or session), don't try to compose queries from them together; that's really going to do weird stuff!</p>
<div class="posttagsblock"><a href="http://technorati.com/tag/Linq" rel="tag">Linq</a>, <a href="http://technorati.com/tag/NHibernate" rel="tag">NHibernate</a></div>
