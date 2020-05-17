---
layout: post
title: "NHibernate 5.2 Released"
date: 2018-12-03T22:00:00Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Release Notes
---
NHibernate 5.2.0 is now released.

For a list of resolved issues & pull requests, see the [milestone](https://github.com/nhibernate/nhibernate-core/milestone/14?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.2.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:

- https://sourceforge.net/projects/nhibernate/files/NHibernate/5.2.0/
- https://www.nuget.org/packages/NHibernate/5.2.0

157 issues were resolved in this release.

##### Possible Breaking Changes #####
* Entities having many non-readonly properties (including many-to-one) mapped to the same column will no more silently ignore the trouble till an insert or update is attempted. They will now cause the session factory built to fail. When mapping many properties to the same column, all of them excepted at most one should be mapped with `insert="false" update="false"`.
* Mappings mixing column elements and formula elements were taking into account only the formula elements. They will now take into account all elements.
* Mappings mixing column elements and/or formula elements with a column attribute or a formula attribute were silently ignoring the attribute. They will now throw.
* Mappings mixing a column attribute and a formula attribute were silently doing some best effort logic, either considering this as a two columns mapping, the second one being the formula (most cases), or only taking into account the formula (case of the `<element>` mapping). They will now throw.
* NHibernate `StringType` has gained case-sensitivity and culture parameters. Previously it was ignoring parameters. This type may change its behavior for any mapping having defined parameters for this type. See #1833.
* Mapping a dynamic component with a `Hashtable` property instead of an `IDictionary` is no more supported.
* Querying a dynamic entity as a `Hashtable` instead of an `IDictionary` is no more supported.
* With PostgreSQL, a HQL query using the bitwise xor operator `^` or `bxor` was exponentiating the arguments instead. It will now correctly apply the xor operator. (`#` operator in PostgreSQL SQL.)
* Auto-generated constraint names will not be the same than the ones generated with previous NHibernate versions under .Net Framework. (Under .Net Core those names were anyway changing at each run.) The new ones will be the same whatever the runtime used for generating them.
* Some generated PK names may change, if a table name has a quoting symbol at precise 13th character.
* The `WcfOperationSessionContext` has been removed from .Net Core and .Net Standard builds. See #1842.
* Some classes, which were not serializing the session factory, do now serialize it. In case of cross-process serialization/deserialization, these session factories will need to be properly named, by setting the `session_factory_name` setting in the configuration used to build them. This may mainly affect users of a distributed second level cache, if their cache implementation uses binary serialization. Affected classes are: `CacheKey`, `CollectionKey`, `EntityKey` and `EntityUniqueKey`.
* Some types cache representations have changed. Out-of-process second level caches should be cleared after upgrading NHibernate, if some of those types were cached. The concerned types are: `CultureInfoType`, `TypeType`, `UriType`, `XDocType`, `XmlDocType`.
* `Dialect.GetIdentitySelectString` was called by the entity persisters with inverted parameter values: the table name in the column parameter, and the column name in the table parameter. No built-in dialects were using the parameter values. External dialects which were using it inverted (causing issues to collection persisters, which have always supplied them correctly) needs to be accordingly adjusted.
* Users providing through an `IObjectFactory` some custom logic for instantiating value types will now need to supply their own result transformer if they were using `AliasToBeanResultTransformer` with value types, or their own entity tuplizer if they were using value types as entities.
* Users providing through an `IObjectFactory` some custom logic for instantiating their custom session contexts will have to implement `ICurrentSessionContextWithFactory` and add a parameterless public constructor to their custom context, and move their custom instantiation logic from `IObjectsFactory.CreateInstance(Type, object[])` to `IObjectsFactory.CreateInstance(Type)`.
* Various *Binding classes of NHibernate will now always have their protected dialect field null. (These classes are not expected to be derived by users, as there is no way to use custom descendants with NHibernate.)
* `AbstractPersistentCollection.AfterInitialize` does no more perform queued operations. Queued operations are now run by a later call to a new method, `ApplyPendingOperations`. Concrete custom implementations relying on the queued operations to be done by their base `AfterInitialize` will need to be changed accordingly.

--

Huge thanks to everyone involved in this release.