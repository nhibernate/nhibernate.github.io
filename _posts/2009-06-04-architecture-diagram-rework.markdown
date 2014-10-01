---
layout: post
title: "Architecture Diagram Rework"
date: 2009-06-04 13:34:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate Documentation"]
redirect_from: ["/blogs/nhibernate/archive/2009/06/04/architecture-diagram-rework.aspx"]
author: ssteinegger
gravatar: 5d9c48ac94a9376f1b7bccdd13c4d987
---
{% include imported_disclaimer.html %}
<p>While working on the <a title="NHibernate Documentation Structure Proposal" href="/wikis/reference2-0en/nhibernate-documentation-structure-proposal.aspx">NHibernate Documentation</a>, I&rsquo;m drawing some pretty pictures. I actually never liked the architecture diagrams much, because I never knew what exactly they are trying to show.</p>
<p>The original architecture diagram looks like this:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_0CABFF94.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" alt="image" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_45593A52.png" border="0" width="482" height="394" /></a> </p>
<p>I never found this diagram very helpful. (When I started learning NH, Transient Objects and Persistent Objects were very confusing to me. Are this different classes?)</p>
<p>So I decided to rework it. I ended up with something that is not very different from the existing diagrams so:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_7E067510.png"><img title="image" style="display: inline; border-width: 0px; border: 0;" alt="New Architecture Diagram" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_719AE298.png" border="0" width="591" height="465" /></a> </p>
<p>I shouldn&rsquo;t cover all the little details of the NHibernate&rsquo;s internal design, just the concepts that are visible to the user.</p>
<p>What do you think: is this kind of useful?</p>
