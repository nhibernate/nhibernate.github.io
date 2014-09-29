---
layout: post
title: "New Kid on the Block.  And some info on Linq to NHibernate"
date: 2009-05-07 18:52:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["linq"]
alias: ["/blogs/nhibernate/archive/2009/05/07/new-kid-on-the-block-and-some-info-on-linq-to-nhibernate.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>This is my first post on this site as an NH committer, and I'm very pleased to be part of the team helping move NH forward for the benefit of everyone. &nbsp;Specifically, I've spent the last few months working semi-full time on helping to build a full Linq-to-NHibernate implementation. &nbsp;The bulk of the effort so far has been porting over the Hibernate ANTLR-based HQL parser - see <a href="http://blogs.imeta.co.uk/sstrong/archive/2009/02/22/617.aspx">here</a> for a fairly detailed description of the work that I've been doing. &nbsp;Progress updates so far can be found <a href="http://blogs.imeta.co.uk/sstrong/archive/2009/03/09/628.aspx">here</a>, <a href="http://blogs.imeta.co.uk/sstrong/archive/2009/04/16/680.aspx">here</a> and <a href="http://blogs.imeta.co.uk/sstrong/archive/2009/04/27/688.aspx">here</a>.</p>
<p>For those that don't want to follow all those links, the summary is that the AST parser is largely done (and already being used to great advantage on <a href="/blogs/nhibernate/archive/2009/05/05/nh2-1-executable-hql.aspx">non-Linq related work by Fabio</a>). &nbsp;I'm currently working through building a basic Linq provider. &nbsp;Based on extensive blogs from <a href="http://blogs.msdn.com/mattwar/">Matt Warren</a> &amp; <a href="http://weblogs.asp.net/FBouma/">Frans Bouma</a>, I'm fully expecting to hit a couple of fairly big walls whilst doing this, and the chaps at <a href="http://www.rubicon.eu/de/Home/Default.aspx">Rubicon</a> have a product called <a href="http://www.re-motion.org/">re-linq</a> which may assist with effort. &nbsp;Once I see exactly where the pain points lie, I'll be in a good position to evaluate how to move forward.</p>
<p>Everyone is bound to want to know when this is going to be ready for use - that's a real hard thing to answer right now. &nbsp;It's difficult to foresee exactly how many dragons lie in between me and the goal, plus knowing exactly how much time I can spend on the project is hard. &nbsp;Personally, I'd like to have something looking respectable by June, but don't bet your house on it :)</p>
<p>Anyhow, it's great to be a part of this fantastic product, and I hope the my contribution helps at least some of you out there.</p>
<p>Cheers,</p>
<p>Steve</p>
<p>BTW, as well as this blog, you can also find me at <a href="http://blogs.imeta.co.uk/sstrong">http://blogs.imeta.co.uk/sstrong</a> or on <a href="http://twitter.com/srstrong">http://twitter.com/srstrong</a></p>
