---
layout: post
title: "NHibernate Mapping Examples"
date: 2008-08-31 14:56:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
alias: ["/blogs/nhibernate/archive/2008/08/31/nhibernate-mapping-examples.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Note: this post was originally posted on <a href="http://davybrion.com/blog/2007/07/nhibernate-mapping-examples/">July 15, 2007</a>
</p>
<p>When you're starting out with NHibernate, it's sometimes hard to find good examples. Most examples online are too simple, or are incomplete (just the mappings, but no code for instance).  It's always easier if you have some examples that are large enough, but still small enough to be easy to grasp. So i created mappings and classes for the Northwind tables. I figured this could be useful reference material for anyone new to NHibernate so i'm making the whole thing available for everyone. You'll find examples of one-to-many, many-to-one and many-to-many associations in there.  I used a couple of different cascade options for the associations, depending on the constraints on the tables.  I've also included about 60 unit tests to verify the mappings are working correctly. These tests should also give you a good idea about how NHibernate deals with certain mappings and options.
I did modify the Northwind database here and there... the zip file contains all the sql create scripts. This is what my version looks like:
</p>
<p><a href="http://davybrion.com/blog/wp-content/uploads/2007/07/tablediagram.png" title="Northwind Table Diagram"><img src="http://davybrion.com/blog/wp-content/uploads/2007/07/tablediagram.png" alt="Northwind Table Diagram" width="886" height="795" /></a>
</p>
<p>&nbsp;</p>
<p>And the class diagram looks like this:
</p>
<p><a href="http://davybrion.com/blog/wp-content/uploads/2007/07/classdiagram.png" title="Northwind Class Diagram"><img src="http://davybrion.com/blog/wp-content/uploads/2007/07/classdiagram.png" alt="Northwind Class Diagram" width="886" height="797" /></a></p>
<p>
I do want to make it clear that this is just an example. I'm not saying that this how you should map your objects and their associations to tables and their relationships.  I pretty much provided every possible association in this example, whereas on a real project i'd only create the associations that i actaully need to implement the required functionality. But for the purpose of this example, i thought it would be a good idea to provide as much as possible.
You can download it <a href="http://www.ralinx.be/NorthwindNHibernateExample.zip">here</a></p>
