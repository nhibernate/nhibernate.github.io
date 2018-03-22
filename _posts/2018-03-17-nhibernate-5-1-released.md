---
layout: post
title: "NHibernate 5.1 Released"
date: 2018-03-17T09:07:09Z
author: hazzik
gravatar: 849b5057cdc84934daae1942749f0270
tags:
  - Release Notes
---
NHibernate 5.1.0 is now released.

For a list of resolved issues & pull requests, see the [milestone](https://github.com/nhibernate/nhibernate-core/milestone/9?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.1.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:

- https://sourceforge.net/projects/nhibernate/files/NHibernate/5.1.0/
- https://www.nuget.org/packages/NHibernate/5.1.0

##### Highlights #####
* NHibernate has gained two new target frameworks: .Net Core 2.0 and .Net Standard 2.0. NHibernate NuGet package provides them, along with the .Net framework 4.6.1 build.
   For these new frameworks, some additional specificities or limitations apply:
   * Binary serialization is not supported - the user shall implement [serialization surrogates](https://docs.microsoft.com/en-us/dotnet/api/system.runtime.serialization.iserializationsurrogate) for System.Type, FieldInfo, PropertyInfo, MethodInfo, ConstructorInfo, Delegate, etc.
   * SqlClient, Odbc, Oledb drivers are converted to ReflectionBasedDriver to avoid the extra dependencies.
   * CallSessionContext uses a static AsyncLocal field to mimic the CallContext behavior.
   * System transactions (transaction scopes) are untested, due to the lack of data providers supporting them.
* 114 issues were resolved in this release.

##### Possible Breaking Changes #####
* Since Ingres9Dialect is now supporting sequences, the enhanced-sequence identifier generator will default to using a sequence instead of a table. Revert to previous behavior by using its force_table_use parameter.
* Some overridable methods of the Dialect base class and of MsSql2000Dialect have been obsoleted in favor of new methods. Dialects implementors need to override the replacing methods if they were overriding the obsolete ones, which are:
   * Dialect.GetIfNotExistsCreateConstraint(Table table, string name), replaced by GetIfNotExistsCreateConstraint(string catalog, string schema, string table, string name).
   * Dialect.GetIfNotExistsCreateConstraintEnd(Table table, string name), replaced by GetIfNotExistsCreateConstraintEnd(string catalog, string schema, string table, string name).
   * Dialect.GetIfExistsDropConstraint(Table table, string name), replaced by GetIfExistsDropConstraint(string catalog, string schema, string table, string name).
   * Dialect.GetIfExistsDropConstraintEnd(Table table, string name), replaced by GetIfExistsDropConstraintEnd(string catalog, string schema, string table, string name).
   * MsSql2000Dialect.GetSelectExistingObject(string name, Table table), replaced by GetSelectExistingObject(string catalog, string schema, string table, string name).

--

Huge thanks to everyone involved in this release.