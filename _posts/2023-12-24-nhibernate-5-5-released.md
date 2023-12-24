---
layout: post
title: "NHibernate 5.5 Released"
date: 2023-12-24T17:30:00Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Release Notes
---
NHibernate 5.5.0 is now released.

For a list of resolved issues & pull requests, see the [milestone](https://github.com/nhibernate/nhibernate-core/milestone/52?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.5.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:
https://sourceforge.net/projects/nhibernate/files/NHibernate/5.5.0/
https://www.nuget.org/packages/NHibernate/5.5.0

##### Possible Breaking Changes #####
* `Object.Finalize` is no more proxified when the entity base class has a destructor. See #3205.
* Default not-found behavior now works correctly on many-to-many Criteria fetch. It now throws ObjectNotFoundException exception for not found records. See #2687.

62 issues were resolved in this release.

--

Huge thanks to everyone involved in this release.