---
layout: post
title: "NHibernate HQL AST Parser"
date: 2009-02-22 20:12:58 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["query", "querying", "linq"]
alias: ["/blogs/nhibernate/archive/2009/02/22/nhibernate_2D00_hql_2D00_ast_2D00_parser.aspx", "/blogs/nhibernate/archive/2009/02/22/nhibernate_2d00_hql_2d00_ast_2d00_parser.aspx"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p><a href="http://blogs.imeta.co.uk/sstrong/Default.aspx">Steve</a> from <a href="http://imeta.co.uk/">iMeta</a> has been doing a <em>lot</em> of work on the HQL AST Parser. For a long time, that has been a really troublesome pain point for us, since this is a prerequisite for a lot of other features. It is also one of two parts of NHibernate that <em>really </em>need significant refactoring because the way they are built right now make it hard to do stuff (the second being the semantic model for the mapping, which the Fluent NHibernate guys are working on).</p>  <p>Just to give you two features that should make you drool which depends on this work:</p>  <ul>   <li>Full Linq implementation </li>    <li>Set based DML operations on top of the domain model </li> </ul>  <p>In true Open Source manner, you can view the work being done right now: <a href="http://unhaddins.googlecode.com/svn/trunk">http://unhaddins.googlecode.com/svn/trunk</a>, Checkout the ANTRL-HQL project.</p>  <p>This is something that several members of the NHibernate project has tried doing in the past, but the scope of the work is very big, and require full time work for an extended period of time. <a href="http://imeta.co.uk">iMeta</a> has been sponsoring Steve’s work on NHibernate, which make this possible. </p>  <p>I have been going through the code, and I am literally jumping up and down in excitement. It is still <em>very</em> early, but it is already clear that Steve has taken us much farther than before, and it is possible to see the end. The most significant milestone has been reached, and we are currently able to execute ( a very simple ) query and get the results back:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_2050794E.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="112" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_245D57D1.png" width="485" border="0" /></a> </p>  <p>Yes, it also integrates with NH Prof :-)</p>
