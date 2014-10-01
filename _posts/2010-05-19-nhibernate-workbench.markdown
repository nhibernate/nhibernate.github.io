---
layout: post
title: "NHibernate Workbench"
date: 2010-05-19 15:29:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["query", "mapping", "querying", "HQL"]
redirect_from: ["/blogs/nhibernate/archive/2010/05/19/nhibernate-workbench.aspx/"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p align="justify">In the spirit of &ldquo;<i>Release early. Release often. And listen to your customers</i>&rdquo; ( cit. ), even if not so early in term of time since the <a href="http://www.felicepollano.com/2010/04/22/SomeProgressWithHqlIntellisense.aspx">preview</a>, I decided to <a href="http://sourceforge.net/projects/faticalabshqled/files/">release a first drop</a> of the &ldquo;HQL Intellisense thing&rdquo; I&rsquo;m working on. The current version is just able to load an existing mapping assembly, a configuration, help us to write an hql query, submit it to NH and see some results. Here an overall screenshot: </p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s1_5F00_6D3E666D.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s1" alt="s1" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s1_5F00_thumb_5F00_55E33C2F.png" border="0" width="580" height="407" /></a></p>
<p align="justify">To use it you need to <a href="http://sourceforge.net/projects/faticalabshqled/files/" target="_blank">download the bits</a>, and then &ldquo;create a project&rdquo; a project is, in the NH Workbench world, a bounch of file representing what we are working on ( and actually is a project in the MSBUILD world. To use the tool now we need at least a working NH configuration file ( your app.config or web config ) and one or more mapping assembly(ies). You add the files to the project by right clicking the project tree:<a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s2_5F00_63199F75.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" title="s2" alt="s2" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s2_5F00_thumb_5F00_0E7DC070.png" align="left" border="0" width="202" height="244" /></a> </p>
<p align="justify">After you added the file you can save the project, so it can be reopened when needed. Please note that the mapping assembly has to be opened from a location containing all the required dependencies ( usually the application folder, or the bin folder ).</p>
<p align="justify">After the project is created, you need to compile it before starting to write the queries:</p>
<p align="justify"><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s3_5F00_0B1C28C8.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" title="s3" alt="s3" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s3_5F00_thumb_5F00_740DA78B.png" align="right" border="0" width="244" height="79" /></a> </p>
<p>You can compile the project by clicking the button on the toolbar as shown in the picture Fig3</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>Compiling the project should produce a report in the log area:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s4_5F00_1F71C886.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s4" alt="s4" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s4_5F00_thumb_5F00_1C7C63D3.png" border="0" width="572" height="142" /></a> </p>
<p>If you find the report too verbose, you can uncheck some of the button in the log toolbar. After a successful compilation, we can open a query (hql) document:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s5_5F00_38C9A5F3.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" title="s5" alt="s5" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s5_5F00_thumb_5F00_15B93483.png" align="left" border="0" width="244" height="256" /></a> </p>
<p>&nbsp;</p>
<p>This will open a pane in the document area in which we can write HQL queries with some intellisense/auto-completion. Plaese note that, for have the entity completion, after the &ldquo;from&rdquo; keyword we need to <b>press ctrl+space</b> to see the completion combo.</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s6_5F00_2B536D20.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" title="s6" alt="s6" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s6_5F00_thumb_5F00_018FF22D.png" align="left" border="0" width="244" height="64" /></a> </p>
<p>Here an example HQL document. After a valid query is done we can submit it to NH and see the result:</p>
<p>&nbsp;</p>
<p>The &ldquo;<b>play</b>&rdquo; button is enabled only if a valid query ( no errors ) is written in the document. The<b> first</b> and <b>coun</b>t places are useful to<b> limit</b> the query results.</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s7_5F00_3E6473FF.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s7" alt="s7" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s7_5F00_thumb_5F00_09E3A1B7.png" border="0" width="213" height="80" /></a> By pressing the play button, you will be able to se the query results ( if any ):</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s8_5F00_59D95035.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s8" alt="s8" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s8_5F00_thumb_5F00_03F8D851.png" border="0" width="482" height="147" /></a> </p>
<p>Next steps:</p>
<ul>
<li>Solve the bugs till now </li>
<li>Add supports for <a href="/media/p/546.aspx" target="_blank">hbm2net</a>, so user can write mapping and immediately see it at works. </li>
</ul>
<p>Enjoy !</p>
