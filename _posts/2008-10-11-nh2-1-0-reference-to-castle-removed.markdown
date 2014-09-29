---
layout: post
title: "NH2.1.0: Reference to Castle removed"
date: 2008-10-11 22:58:44 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: ["proxy", "lazy loading", "ProxyGenerators", "NHibernate", "Deploy", "Castle", "NH2.1"]
alias: ["/blogs/nhibernate/archive/2008/10/11/nh2-1-0-reference-to-castle-removed.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p><font size="3">The NH trunk do no longer have dependency from Castle project; Castle.DynamicProxy2 are now only the default option.</font></p>  <p><font size="3">All dependency to Castle was moved to : </font><strong>NHibernate.ProxyGenerators.CastleDynamicProxy</strong></p>  <p><font size="3">To continue working using lazy-loading, exactly as before, now you must deploy the default proxy generator.</font></p>  <p><font size="3">This was the first step to better understand which are the NHibernate intrusions, in your code, and to have some other dynamic-proxy alternative or some other alternative than dynamic-proxy ;)</font></p>  <p><font size="3"></font></p>  <p><font size="3">Less dependency and high-level-injectability is one of the “musts” of NHibernate; <a href="http://www.nhforge.org/wikis/proxygenerators10/introduction.aspx">NHibernate.ProxyGenerators</a> is only one more example.</font></p>
