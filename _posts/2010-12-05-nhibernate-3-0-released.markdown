---
layout: post
title: "NHibernate 3.0 released"
date: 2010-12-05 13:51:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2010/12/05/nhibernate-3-0-released.aspx"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>First, <a href="http://www.packtpub.com/nhibernate-3-0-cookbook/book?utm_source=jasondentler.com&amp;utm_medium=blog&amp;utm_content=authorsite&amp;utm_campaign=mdb_004974">NHibernate 3.0 Cookbook</a> is now a Packt Publishing best seller. Thank you everyone who bought a copy. The NHibernate project gets a portion of each and every sale.</p>
<p>Yesterday, <a href="http://fabiomaulo.blogspot.com/">Fabio</a> announced the release of <a href="/">NHibernate</a> 3.0 General Availability. Go get it! </p>
<p>The previous official release of NHibernate was version 2.1.2, just over 1 year ago. Since then, the team has made a ton of improvements and bug fixes.</p>
<p>Most importantly, NHibernate now targets .NET 3.5, allowing us to use lambda expressions and LINQ. This has led to an explosion of new ways to configure and query. </p>
<p>There are a few very minor breaking changes mentioned in the release notes:</p>
<ul>
<li><a target="_blank" href="http://216.121.112.228/browse/NH-2392">[NH-2392]</a> ICompositeUserType.NullSafeSet method signature has changed </li>
<li><a target="_blank" href="http://216.121.112.228/browse/NH-2199">[NH-2199]</a> null values in maps/dictionaries are no longer silently ignored/deleted </li>
<li><a target="_blank" href="http://216.121.112.228/browse/NH-1894">[NH-1894]</a> SybaseAnywhereDialect has been removed, and replaced with SybaseASA9Dialect. Sybase Adaptive Server Enterprise (ASE) dialects removed. </li>
<li><a target="_blank" href="http://216.121.112.228/browse/NH-2251">[NH-2251]</a> Signature change for GetLimitString in Dialect </li>
<li><a target="_blank" href="http://216.121.112.228/browse/NH-2284">[NH-2284]</a> Obsolete members removed </li>
<li><a target="_blank" href="http://216.121.112.228/browse/NH-2358">[NH-2358]</a> DateTimeOffset type now works as a DateTimeOffset instead a "surrogate" of DateTime </li>
</ul>
<p>Plans for version 3.1 include additional bug fixes and patches, as well as enhancements for the new LINQ provider.</p>
<p>As Fabio says, Happy Persisting!</p>
