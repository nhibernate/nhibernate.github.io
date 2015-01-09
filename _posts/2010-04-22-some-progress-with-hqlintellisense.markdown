---
layout: post
title: "Some Progress with HqlIntellisense…"
date: 2010-04-22 17:08:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2010/04/22/some-progress-with-hqlintellisense.aspx/", "/blogs/nhibernate/archive/2010/04/22/some-progress-with-hqlintellisense.html"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p>There is some interesting progress with my project <a href="http://sourceforge.net/projects/faticalabshqled/" target="_blank">Fatica.Labs.HqlEditor</a>. I just want to share some screenshot:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s5_5F00_08413719.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s5" alt="s5" src="/images/posts/2010/04/22/s5_5F00_thumb_5F00_65E8DFF8.png" border="0" height="356" width="490" /></a> </p>
<p>Well, it is growing to be a real tool, and in my idea would became a sort of test bed in which the user can add or modify mapping, try the queries, change the config, export a database script, reverse engineering and so on. Actually all the low level tool to achieve that are available.</p>
<p>Ok, let&rsquo;s explain the layout:</p>
<ol>
<li>The document area, here we have mapping/config/hql <b>all</b> with <b>intellisense</b>. In the screenshot the code completion for an Hql is shown. In future maybe I will be able to insert a T4 editor for the hbm2net templates. </li>
<li>The project area: here we have a bounch of file that are representing our testing project: mapping, configurations, assemblies and so on. I have use the MSbuild object as a backend for the project, because in the near future I would like to use it to really build some artifacts using <a href="/media/p/546.aspx" target="_blank">hbm2net</a> and <a href="/media/p/615.aspx" target="_blank">db2hbm</a>. </li>
<li>Here is the SQL preview of the query in editing. Now the view is showing an error because the query is incomplete. </li>
<li>The funny log, a graphical appender for <a href="http://logging.apache.org/log4net/index.html" target="_blank">log4net</a> :-) </li>
</ol>
<p>Some more words about the project itself: the testing environment is hosted in a separate appdomain, this will allow us to:</p>
<ul>
<li>Modify the mapping runtime generating new version of the assembly </li>
<li>Testing production assemblies built with legacy nh versions ( well, not so legacy, starting from 2.xxx ) </li>
</ul>
<p>Let&rsquo;s have another screenshot, showing a real SQL preview:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/s7_5F00_40BB6FBF.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s7" alt="s7" src="/images/posts/2010/04/22/s7_5F00_thumb_5F00_57F64E63.png" border="0" height="322" width="509" /></a> </p>
<p>Next step is to produce the query results in some sort of usable representation ( I need to push the data across two app domain ) so I would probably use some JSON serialization and then display the JSON raw data with some readable formatting.</p>
<p>The project is not yet released, please treat it as a CTP ;) anyway, the svn repository is here:</p>
<p><code><b><a href="https://faticalabshqled.svn.sourceforge.net/svnroot/faticalabshqled">https://faticalabshqled.svn.sourceforge.net/svnroot/faticalabshqled</a></b></code></p>
<p><code><b>Please comments are welcome in the <a href="http://www.felicepollano.com/2010/04/22/SomeProgressWithHqlIntellisense.aspx" target="_blank">original blog post</a>.</b></code></p>
