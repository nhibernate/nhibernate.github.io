---
layout: post
title: "NHibernate 4.0.2 Released"
date: 2014-11-15T20:49:00+13:00
author: hazzik
gravatar: 849b5057cdc84934daae1942749f0270
tags:
  - Release Notes
---
NHibernate 4.0.2 General Availability is now available for download from [Sourceforge](https://sourceforge.net/projects/nhibernate/files/NHibernate/4.0.2.GA/) and [Nuget](https://www.nuget.org/packages/NHibernate/4.0.2.4000).

This includes fixes for regressions in NH 4.0.1, and some fixes for mapping-by-code and Firebird issues.
Please see the full release notes for more information:
[releasenotes.txt](https://github.com/nhibernate/nhibernate-core/blob/4.0.2.GA/releasenotes.txt)

Full list of changes:

## Bug
* [NH-2779] - Session.Get() can throw InvalidCastException when log-level is set to DEBUG
* [NH-2782] - Linq: selecting into a new array doesn't work
* [NH-2831] - NH cannot load mapping assembly from GAC 
* [NH-3049] - Mapping by code to Field not working
* [NH-3222] - NHibernate Futures passes empty tuples to ResultSetTransformer
* [NH-3650] - ComponentAsId<T> used more than once, cache first mapping and produces  subsequently a sql select wrong
* [NH-3709] - Fix Reference to One Shot Delete and Inverse Collections
* [NH-3710] - Use of SetLockMode with DetachedCriteria causes null reference exception

## Task
* [NH-3697] - Ignore Firebird in NHSpecificTest.NH1981
* [NH-3698] - NHSpecificTest.NH1989 fails for some drivers
