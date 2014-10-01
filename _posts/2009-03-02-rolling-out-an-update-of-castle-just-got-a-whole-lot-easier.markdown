---
layout: post
title: "Rolling out an update of Castle just got a whole lot easier"
date: 2009-03-02 21:36:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/03/02/rolling-out-an-update-of-castle-just-got-a-whole-lot-easier.aspx"]
author: christianacca
gravatar: bf3c707b9c35add15287382e4ab3a5af
---
{% include imported_disclaimer.html %}
<div><span id="misspell-cursor" class="unmark"></span>I
just released yesterday, that the recent change to NHibernate that removed all dependency from any kind of &ldquo;Proxy framework&rdquo;, has made it a whole lot easier to <span class="mark" id="misspell-1">rollout</span> a fresh build of the Castle trunk to the Enterprise.</div>
<div></div>
<div>(see <a target="_self" href="/blogs/nhibernate/archive/2008/11/09/nh2-1-0-bytecode-providers.aspx">this post</a> that describes the change that I'm talking about)</div>
<div></div>
<div>Prior to this change, <span class="mark" id="misspell-2">NHibernate</span>
had a hard dependency on Castle. The problem however, was that some of
the projects in Castle also has (and still does) have a dependency on <span class="mark" id="misspell-3">NHibernate</span>. This circular dependency lead to the following build cycle:<br /><br />1) Download Castle<br />2) Download NH-source of the release (here you need the sources of NH)<br />3) build Castle.Core + Castle.<span class="mark" id="misspell-4">DynamicProxy</span>2 (because NH2.0.1 has a reference to both)<br />4) copy Castle.Core.dll + Castle.DynamicProxy2.dll to <span class="mark" id="misspell-5">nhibernate</span>\lib\net\2.0 and <span class="mark" id="misspell-6">nhibernate</span>\lib\net\3.5<br />5) build <span class="mark" id="misspell-7">NHibernate</span><br />6) build all other Castle stuff<br /><br />(thanks to Fabio <span class="mark" id="misspell-8">Maulo</span> who described this to me)<br /><br /><span class="mark" id="misspell-9">Ok</span>,
so these build steps can be automated (and I believe Rhino.Tools has
such a script). The real problem however, is that in order to <span class="mark" id="misspell-10">rollout</span> a fresh build of castle you <strong>HAD </strong>to re-build <span class="mark" id="misspell-11">NHibernate</span> (or face having to deploy assembly binding re-directs) if both Castle and <span class="mark" id="misspell-12">NHibernate</span> are used within the same solution.<br /><br />In <span class="mark" id="misspell-13">practice</span> the pain did not stop there. Being forced to rebuild <span class="mark" id="misspell-14">NHibernate</span>, you had to then ensure that these updated <span class="mark" id="misspell-15">NHibernate</span> assemblies were rolled out to all your other projects that required <span class="mark" id="misspell-16">NHibernate</span>. Either that or face having to maintain multiple versions of <span class="mark" id="misspell-17">NHibernate</span> / Castle across multiple source control repositories.<br /><br />All because you wanted to update Castle!<br /><br />This is a thing of the past for NH2.1.0 (or the current version of the NH trunk). Now, to <span class="mark" id="misspell-18">rollout</span> a fresh build of the Castle trunk you do the following:<br /><br />1) Download Castle<br />2) Download NHibernate.ByteCode.Castle (it has 3 classes)<br />3) build whole Castle<br />4) build NHibernate.ByteCode.Castle<br /><br />The key thing to note is that you don't have to rebuild <span class="mark" id="misspell-19">NHibernate</span> - thanks guys!<br /><br />Christian</div>
