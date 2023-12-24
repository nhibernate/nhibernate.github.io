---
layout: post
title: "NHibernate 5.4 Released"
date: 2022-11-20T17:20:00Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Release Notes
---
NHibernate 5.4.0 is now released.

For a list of resolved issues & pull requests, see the [milestone](https://github.com/nhibernate/nhibernate-core/milestone/36?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.4.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:
- https://sourceforge.net/projects/nhibernate/files/NHibernate/5.4.0/
- https://www.nuget.org/packages/NHibernate/5.4.0

##### Highlights #####
* NHibernate has gained three new target frameworks: .Net 6, .Net Framework 4.8 and .Net Standard 2.1. NHibernate NuGet package provides them, along with the older targets, .Net Core 2.0, .Net Framework 4.6.1 and .Net Standard 2.0. These new targets allow some NHibernate optimizations for applications using them. The same limitations apply for .Net 6 and .Net Standard 2.1 as for .Net Core 2.0 and .Net Standard 2.0, see NHibernate 5.1.0 release notes.
* A new batching strategy is available, minimizing the batching memory footprint. See [#2959](https://github.com/nhibernate/nhibernate-core/pull/2959). Using it may increase CPU usage.
* 201 issues were resolved in this release.

##### Possible Breaking Changes #####
* Linq and criteria queries on unmapped entities will throw instead of returning an empty result list. See [#1106](https://github.com/nhibernate/nhibernate-core/pull/1106), [#1095](https://github.com/nhibernate/nhibernate-core/pull/1095).
* The second level cache UpdateTimestampsCache does not use locks anymore. This may slightly increase the number of cases where stale data is returned by the query cache. See [#2742](https://github.com/nhibernate/nhibernate-core/pull/2742).
* Equality and hashcode access on uninitialized persistent collections will no more trigger their loading. See [#2461](https://github.com/nhibernate/nhibernate-core/pull/2461).
* DB2CoreDriver now uses named parameters instead of positional ones. See [#2546](https://github.com/nhibernate/nhibernate-core/pull/2546).

--

Huge thanks to everyone involved in this release.
