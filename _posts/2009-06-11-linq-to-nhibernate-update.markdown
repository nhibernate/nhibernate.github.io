---
layout: post
title: "LINQ to NHibernate Update"
date: 2009-06-11 13:50:40 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "linq"]
alias: ["/blogs/nhibernate/archive/2009/06/11/linq-to-nhibernate-update.aspx"]
author: srstrong
gravatar: be49dc22186b4215272ffa6a46599424
---
{% include imported_disclaimer.html %}
<p>We're long overdue for another update. Progress as been somewhat slower over the last few weeks, largely due to other commitments and holidays meaning that I've probably only spent a total of around 10 days working on this stuff.</p>
<p>Where we are is that I'm pretty comfortable with what needs to happen, and have a fairly clear route for moving forward from my prototype / exploratory coding phase to something that I can actually release to the wild and let folk start playing with.</p>
<p>There are two options as to how this might happen. The first is by utilizing the concepts within the excellent <a href="http://www.codeplex.com/IQToolkit">IQToolkit</a>, which provides a great sample for anyone who wants to explore how to build a Linq to Sql provider. Alas, the code can't be used as it stands, since it's quite closely tied to building and executing SQL and then processing the resulting data rows, which isn't quite what we're trying to achieve here. However, the fundamental concepts and algorithms for handling some of the Linq complexities are certainly valid, and can be ported across to meet our needs relatively simply.</p>
<p>The second option is by building on top of the promising <a href="http://www.re-motion.org/blogs/team/archive/2009/04/23/introducing-re-linq-a-general-purpose-linq-provider-infrastructure.aspx">re-linq</a> project, which performs a similar task to the first half of the IQ Toolkit, in that it takes a Linq expression tree and turns it into something a little more manageable. re-linq doesn't attempt to handle the execution side, so it precisely avoids some of the stuff that I'd need to rip out of the IQ Toolkit.<br /></p>
<p>re-linq is currently undergoing some final refactoring (some of it driven by the potential to use it within this project,so many thanks to them for keeping us in mind!). This is due to be completed in the next 3 or so weeks; once they are done, a final decision as to the exact approach can be taken and I'd expect pretty fast progress from that point.</p>
<p>Obviously, my original guesstimate of a June date is looking seriously in doubt, but I don't think it'll be too much longer. Hang in there folks, I know it's been a long wait but it'll be worth it!</p>
