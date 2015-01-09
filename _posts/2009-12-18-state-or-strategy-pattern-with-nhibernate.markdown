---
layout: post
title: "State (or Strategy) Pattern with NHibernate"
date: 2009-12-18 15:08:00 +1300
comments: true
published: false
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/12/18/state-or-strategy-pattern-with-nhibernate.aspx/", "/blogs/nhibernate/archive/2009/12/18/state-or-strategy-pattern-with-nhibernate.html"]
author: diegose
gravatar: f00318698e65fce00b7cbd612a466571
---
{% include imported_disclaimer.html %}
<p>The State/Strategy patterns are among the simplest design patterns, yet they can help a lot when designing maintainable applications.</p>
<p>If you've never read about them, it's a good time to do so: <a href="http://en.wikipedia.org/wiki/State_pattern">State Pattern 1</a>, <a href="http://www.dofactory.com/patterns/PatternState.aspx">State Pattern 2</a>, <a href="http://en.wikipedia.org/wiki/Strategy_pattern">Strategy Pattern 1</a>, <a href="http://www.dofactory.com/patterns/PatternStrategy.aspx">Strategy Pattern 2</a>.</p>
<p>Both patterns are pretty much the same, with the small difference of the State usually knowing its context and being able to swap itself with a different state.</p>
<p>Now, how can we take advantage of this with NHibernate?</p>
