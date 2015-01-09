---
layout: post
title: "Customizing Schema Export with schema-action"
date: 2008-12-16 00:50:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["views", "export", "schema action"]
redirect_from: ["/blogs/nhibernate/archive/2008/12/15/customizing-schema-export-with-schema-action.aspx/", "/blogs/nhibernate/archive/2008/12/15/customizing-schema-export-with-schema-action.html"]
author: Woil
gravatar: 7be987ee1e38d64e17712ba97a4c525c
---
{% include imported_disclaimer.html %}
<p>Mapping views with NHibernate just got a whole lot easier. Previous to revisions committed to the trunk today (Dec 15, 2008) there was no good way to exclude certain files from being exported with a schema export. </p>
<p>Now a new attribute has been added to the &lt;class&gt; schema. </p>
<p>&lt;class name="Cat" schema-action="none|drop|export|update|validate|all"&gt; ...</p>
<p>Using this to map a view is easy:</p>
<p>&lt;class name="CustomersView" table="CustomsReportView" schema-action="none" mutable="false"&gt; ...</p>
<p>This will automatically exclude this class from all schema actions such as updates, drops, and exports. You can mix and match with schema-action="update,drop" etc.</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
