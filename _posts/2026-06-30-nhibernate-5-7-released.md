---
layout: post
title: "NHibernate 5.7 Released"
date: 2026-06-30T13:09:18Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Release Notes
---
NHibernate 5.7.0 is now released.

For a list of resolved issues & pull requests, see [the milestone](https://github.com/nhibernate/nhibernate-core/milestone/73?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.7.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:
https://sourceforge.net/projects/nhibernate/files/NHibernate/5.7.0/
https://www.nuget.org/packages/NHibernate/5.7.0

##### Highlights #####
* NHibernate targets now directly include .NET 10. This new target comes with changes to adapt to the "first-class span types" C# 14 language feature which was breaking some NHibernate features.
* 14 issues were resolved in this release.

##### Possible Breaking Changes #####
* The NHibernate features using binary serialization will now throw a `SerializationException` for applications targeting .NET 10 or greater. These features can be restored by configuring a serialization strategy with your own custom strategy. (See `Cfg.Environment.SerializationStrategy` or set `NHibernate.Util.SerializationConfiguration.Strategy`.) See [#3745](https://github.com/nhibernate/nhibernate-core/pull/3745).

--

Huge thanks to everyone involved in this release.
