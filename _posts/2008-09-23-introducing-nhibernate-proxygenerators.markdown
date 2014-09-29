---
layout: post
title: "Introducing NHibernate ProxyGenerators"
date: 2008-09-23 04:28:22 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: ["proxy", "lazy loading", "ProxyGenerators"]
alias: ["/blogs/nhibernate/archive/2008/09/22/introducing-nhibernate-proxygenerators.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>I am pleased to announce the first release of <a href="http://sourceforge.net/project/showfiles.php?group_id=216446&amp;package_id=292389&amp;release_id=628137" target="_blank">NHibernate ProxyGenerators</a>, the latest addition to the <a href="http://sourceforge.net/projects/nhcontrib/" target="_blank">NHibernate Contrib</a> project.&#160; NHibernate ProxyGenerators (NHPG)&#160; is a simple utility that you can use to pre-generate lazy loading proxies for use with NHibernate.&#160; Why would you want to pre-generate lazy loading proxies you ask?&#160; The prime example is to make use of lazy loading functionality in a Medium Trust environment, like a shared hosting ASP.Net environment.&#160; NHibernate will function in a <a href="http://www.nhforge.org/wikis/howtonh/run-in-medium-trust.aspx" target="_blank">Medium Trust</a> environment but you were previously required to disable lazy loading for all of your entities.&#160; The default behavior of NHibernate is to generate these proxies at runtime during your application’s startup, an operation that requires elevated permissions not present under Medium Trust.&#160; NHPG now allows you to generate these proxies in your development or build environment (which should have the required permissions) and deploy them along with the rest of your application’s assemblies.</p>  <p>Please visit <a href="http://nhforge.org/" target="_blank">NHForge.org</a> for complete reference information and <a href="http://www.nhforge.org/wikis/howtonh/pre-generate-lazy-loading-proxies.aspx" target="_blank">tutorials</a>.&#160; Any feedback or issues can be sent to the <a href="http://groups.google.com/group/nhusers" target="_blank">NHibernate Users</a> group and is greatly anticipated.</p>
