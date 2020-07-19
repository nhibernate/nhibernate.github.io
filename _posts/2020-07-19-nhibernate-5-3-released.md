---
layout: post
title: "NHibernate 5.3 Released"
date: 2020-07-19T22:00:00Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Release Notes
---
NHibernate 5.3.0 is now released.

For a list of resolved issues & pull requests, see the [milestone](https://github.com/nhibernate/nhibernate-core/milestone/21?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.3.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:

- https://sourceforge.net/projects/nhibernate/files/NHibernate/5.3.0/
- https://www.nuget.org/packages/NHibernate/5.3.0

220 issues were resolved in this release.

##### Possible Breaking Changes #####
* A distributed cache may hold conflicting timestamps after upgrade for as much as twelve hours. Consider flushing a distributed cache after upgrade to avoid any issue. Do not share a distributed cache with applications using an earlier version of NHibernate.
* The counter id generator may generate conflicting ids for as much as twelve hours after upgrade.
* `update` and `delete` statements will now take into account any enabled filter on the entities they update or delete, while previously they were ignoring them. (`insert` statements will also take them into account, but previously they were failing instead of ignoring enabled filters.)
* ISession.Persist will no more trigger immediate generation of identifier.
* Bags will no more be loaded with "null" entities, they will be filtered out.
* Setting the value of an unitialized lazy property will no more trigger loading of all the lazy properties of the entity.
* If an unitialized lazy property has got its value set, without any other subsequent lazy property load on the entity, a dynamic update will occur on flush, even if the entity has dynamic updates disabled. This update will occur even if the set value is identical to the currently persisted property value.
* Assigning an uninitialized proxy to a `no-proxy` property will no more trigger the proxy initialization. Moreover, reading the property afterwards will no more unwrap the assigned proxy, but will yield it.
* A class having an explicitly implemented interface declaring a member with the same name than the class id will have its proxies trigger a lazy load if the interface "id" is accessed.
* SQLite: in order to avoid a floating point division bug losing the fractional part, decimal are now stored as `REAL` instead of `NUMERIC`. Both are binary floating point types, excepted that `NUMERIC` stores integral values as `INTEGER`. This change may cause big integral decimal values to lose more precision in SQLite.
* Custom dialects used for databases that do not support cross join will have to override `SupportsCrossJoin` property and set it to `false`.
* `VisitorParameters.ConstantToParameterMap` may contain the same parameter for multiple constant expressions.
* `ICache` caches yielded by the session factory will be `CacheBase` wrappers around the cache actually provided by the cache provider, if it was not deriving from `CacheBase`.

--

Huge thanks to everyone involved in this release.
