---
layout: post
title: "NHibernate Pitfalls: The SaveOrUpdate Event"
date: 2015-01-09T12:52:03+03:00
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
author: "Ricardo Peres"
---
<p>You may be familiar with the NHibernate <strong>SaveOrUpdate</strong> event. In fact, you may have already attempted to use it in order to “audit stamping” your entities, by setting properties like <strong>CreatedBy</strong>, <strong>CreatedAt</strong>, <strong>UpdatedBy</strong>, <strong>UpdatedAt</strong>, etc.</p>  <p>It happens that you shouldn’t do it, mostly because <strong>SaveOrUpdate</strong> may be raised even when the session is not dirty and, consequently, there are no dirty entities. It happens on some circumstances as part of the NHibernate session’s dirty check procedure.</p>  <p>Instead, you should be using <strong>FlushEntity</strong> event, <strong>but</strong> you must also be sure that the entity that is passed to the event handler is not changed, before, well, changing it with the aforementioned “audit” properties. You should do the check using the event properties<strong> FlushEntityEvent.Status </strong>and <strong>FlushEntityEvent.HasDirtyCollection</strong>.</p>  <p><a href="http://fabiomaulo.blogspot.com" target="_blank">Fabio Maulo</a>, the NHibernate team leader, has a post on it on his blog: <a href="http://fabiomaulo.blogspot.com/2011/05/nhibernate-bizarre-audit.html" target="_blank">http://fabiomaulo.blogspot.com/2011/05/nhibernate-bizarre-audit.html</a>.</p>
