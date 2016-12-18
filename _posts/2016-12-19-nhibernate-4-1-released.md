---
layout: post
title: "NHibernate 4.1 Released"
date: 2016-12-19T06:35:00+13:00
author: oskarb
gravatar: e4eb2e7b3e607bcf73c97c7df3d07860
tags:
  - Release Notes
---
NHibernate 4.1.0 is now released with 105 issues resolved.

For a list of resolved issues, see the release notes:
https://github.com/nhibernate/nhibernate-core/blob/4.1.0.GA/releasenotes.txt

Binaries are available on NuGet and SourceForge:
- https://sourceforge.net/projects/nhibernate/files/NHibernate/4.1.0.GA/
- https://www.nuget.org/packages/NHibernate/4.1.0.4000

##### Possible Breaking Changes Since 4.0 #####
Proxies for classes that used lazy fields (not collections)
would have any exceptions from the entity wrapped in TargetInvocationException. This
wrapping exception have now been removed. Where relevant, you should instead catch
the original exception type you throw.

For LINQ queries, the startAt parameter and the return value for string.IndexOf() are
now correctly translated from .Net's 0-based indexing to SQL's 1-based indexing. LINQ
queries that are written to expect SQL semantics for IndexOf() will likely need to be
adjusted (NH-3846, NH-3901).
Example: A LINQ query should now use `x=>x.Name.IndexOf("a") == -1` to pick objects where
the name doesn't contain the letter "a".