---
layout: post
title: "NHibernate 5.0 Released"
date: 2017-10-10T22:00:00+13:00
author: hazzik
gravatar: 849b5057cdc84934daae1942749f0270
tags:
  - Release Notes
---
NHibernate 5.0.0 is now released with 141 issues resolved.

For a list of resolved issues, see the release notes:
https://github.com/nhibernate/nhibernate-core/blob/5.0.0/releasenotes.txt

Binaries are available on NuGet and SourceForge:

- https://sourceforge.net/projects/nhibernate/files/NHibernate/5.0.0/
- https://www.nuget.org/packages/NHibernate/5.0.0

##### Highlights #####
* IO bound methods have gained an async counterpart. Not intended for parallelism, make sure to await each call before further interacting with a session and its queries.
* Strongly typed DML operation (insert/update/delete) are now available as Linq extensions on queryables.
* Entities collections can be queried with .AsQueryable() Linq extension without being fully loaded.
* Reference documentation has been curated and completed, notably with a Linq section.
    http://nhibernate.info/doc/nhibernate-reference/index.html

##### Known BREAKING CHANGES from NH4.1.1.GA to 5.0.0 #####

NHibernate now targets .Net 4.6.1.

Remotion.Linq and Antlr3 libraries are no more merged in the NHibernate library, and must be deployed along NHibernate library. (NuGet will reference them.)

Classes and members which were flagged as obsolete in the NHibernate 4.x series have been dropped.
Prior to upgrading, fix any obsolete warning according to its message. See NH-4075 and NH-3684 for a list.

##### Possible Breaking Changes #####

* All members exposing some System.Data types have been changed for the corresponding System.Data.Common types. (IDbCommand => DbCommand, ...)
* The Date NHibernate type will no more replace by null values below its base value (which was year 1753).
    Its base value is now DateTime.MinValue. Its configuration parameter is obsolete.
* NHibernate type DateTimeType, which is the default for a .Net DateTime, does no longer cut fractional seconds. Use DateTimeNoMsType if you wish to have fractional seconds cut. It applies to its Local/Utc counterparts too.
* LocalDateTimeType and UtcDateTimeType do no more accept being set with a value having a non-matching kind, they throw instead.
* DbTimestamp will now round the retrieved value according to Dialect.TimestampResolutionInTicks.
* When an object typed property is mapped to a NHibernate timestamp, setting an invalid object in the property will now throw at flush instead of replacing it with DateTime.Now.
* Decimal type registration now correctly handles maximal precision. For most dialects, it is 28, matching the .Net limit. Values in mappings above maximal precision will be reduced to maximal precision.
* Default cast types do no more resolve string to 255 length and decimal to its default precision/scale for the dialect. They resolve to 4000 length string and (28, 10) precision/scale decimals by default, and are trimmed down according to dialect. Those defaults can be overridden with query.default_cast_length, query.default_cast_precision and query.default_cast_scale settings.
* Transaction scopes handling has undergone a major rework. See NH-4011 for full details.
  * More transaction promotion to distributed may occur if you use the "flush on commit" feature with transaction scopes. Explicitly flush your session instead. Ensure it does not occur by disabling transaction.use_connection_on_system_events setting.
  * After transaction events no more allow using the connection when they are raised from a scope completion.
  * Connection enlistment in an ambient transaction is now enforced by NHibernate by default.
  * The connection releasing is no more directly triggered by a scope completion, but by later interactions with the session.
* AdoNetWithDistributedTransactionFactory has been renamed AdoNetWithSystemTransactionFactory.
* Subcriteria.UniqueResult<T> for value types now return default(T) when result is null, as was already doing CriteriaImpl.UniqueResult<T>.
* AliasToBeanResultTransformer property/field resolution logic has changed for supporting members which names differ only by case. See NH-3693 last comments for details.
* Linq extension methods marked with attribute LinqExtensionMethod will no more be evaluated in-memory prior to query execution when they do not depend on query results, but will always be translated to their corresponding SQL call. This can be changed with a parameter of the attribute.
* Linq Query methods are now native members of ISession and IStatelessSession instead of being extension methods.
* Linq provider now use Remotion.Linq v2, which may break Linq provider extensions, mainly due to names changes. See https://github.com/nhibernate/nhibernate-core/pull/568 changes to test files for examples.
* NHibernate Linq internals have undergone some minor changes which may break custom Linq providers due to method signature changes and additional methods to implement.
* IMapping interface has an additional Dialect member. ISessionFactoryImplementor has lost it, since it gains it back through IMapping.
* IDriver.ExpandQueryParameters and DriverBase.CloneParameter take an additional argument.
* NullableType, its descendent (notably all PrimitiveType) and IUserType value getters and setters now take the session as an argument. This should mainly impact custom types implementors.
* EmitUtil is now internal and has been cleaned of unused members.
* ContraintOrderedTableKeyColumnClosure has been renamed ConstraintOrderedTableKeyColumnClosure.
* enabledFilter parameter has been removed from IProjection.ToSqlString and ICriterion.ToSqlString methods.
* Proxy factory and proxy cache now use TypeInfo instead of System.Type. This should be transparent for most users.
* Exceptions which were based on ApplicationException are now based on Exception: HibernateException, ParserException and AssertionFailure. The logger factory which could throw a bare ApplicationException now throws an InstantiationException instead.
* ThreadSafeDictionary class has been removed. Use System.Collections.Concurrent.ConcurrentDictionary instead.
* Entity mode switching capability, which had never been fully implemented, is dropped.
* BytecodeProviderImpl, intended for .Net Framework 1 and broken, is dropped.
* Sessions concrete classes constructors have been changed. (It is not expected for them to be used directly.)
* Obsolete setting interceptors.beforetransactioncompletion_ignore_exceptions is dropped.
* SQL Server 2008+ dialects now use datetime2 instead of datetime for all date-time types, including timestamp. This can be reverted with sql_types.keep_datetime setting.
* SQL Server 2008+ timestamp resolution is now 100ns in accordance with datetime2 capabilities, down from 10ms previously. This can be reverted with sql_types.keep_datetime setting.
* Oracle 9g+ dialects now use timestamp(7) for all date time types, instead of timestamp(4).
* Oracle 9g+ timestamp resolution is now 100ns in accordance with timestamp(7) capabilities, down from 100µs previously. 
* Oracle: Hbm2dll will no-more choose N- prefixed types for typing Unicode string columns by default.
    This can be changed with oracle.use_n_prefixed_types_for_unicode setting, which will furthermore control DbCommand parameters typing accordingly. See NH-4062.
* SqlServerCe: the id generator "native" will now resolve as table-hilo instead of identity.
* Firebird: timestamp resolution is now 1ms.
* PostgreSQL: if Npgsql v3 or later is used, time DbParameters will be fetched as TimeSpan instead of DateTime.
* DB2 & Oracle lite: decimal type registration was hardcoding precision as 19 and was using length as scale. It now uses precision and scale from mapping when specified, and disregards length.
* Ingres & Sybase ASA: decimal type registration was hardcoding precision as 18 and was using length as scale. It now uses precision and scale from mapping when specified, and disregards length.
* ODBC: String parameter length will no more be specified by the OdbcDriver.

--

Huge thanks to everyone involved in this release, especially to Frédéric Delaporte, Oskar Berggren, Boštjan Markežič (maca88), and Nathan Brown for their invaluable help.

Special thanks to Boštjan for awesome AsyncGenerator without which this release would not be possible.
