---
layout: page
title: Update From NH 1.2.1GA to NH 2.0.0
---
### Infrastructure

* .NET 1.1 is no longer supported
* Nullables.NHibernate is no longer supported (use nullable types of .NET 2.0)
* Contrib projects moved to http://sourceforge.net/projects/nhcontrib

### Compile time

* NHibernate.Expression namespace was renamed to NHibernate.Criterion

* IInterceptor have additional methods. (IsUnsaved was renamed IsTransient)

* INamingStrategy

* IType

* IEntityPersister

* IVersionType

* IBatcher

* IUserCollectionType

* IEnhancedUserType

* IPropertyAccessor

* ValueTypeType renamed to PrimitiveType 

### Possible Breaking Changes for external frameworks

* Various classes were moved between namespaces

* Various classes have been renamed (to match Hibernate 3.2 names)

* ISession interface have additional methods

* ICacheProvider

* ICriterion

* CriteriaQueryTranslator

### Initialization time

* `<nhibernate>` section, in App.config, is no longer supported and will be ignored. Configuration schema for configuration file and App.config is now identical, and the App.config section name is: <hibernate-configuration>

* `<hibernate-configuration>` have a different schema and all properties names are cheked

* configuration properties are no longer prefixed by "hibernate.", if before you would specify "hibernate.dialect", now you specify just "dialect"

* All named queries will be validated at initialization time, an exception will be thrown if any is not valid (can be disabled if needed)

* Stricter checks for proxying classes (all public methods must be virtual)

### Run time

* SaveOrUpdateCopy() returns a new instance of the entity without changing the original

* AutoFlush will not occur outside a transaction - Database transactions are never optional, all communication with the database must occur inside a transaction, whatever you read or write data.

* NHibernate will return long for count(*) queries on SQL Server

* `<formula>` must contain parenthesis when needed

* The HQL functions names may cause conflic in your HQL (reserved names are: substring, locate, trim, length, bit_length, coalesce, nullif, abs, mod, sqrt, upper, lower, cast, extract, concat, current_timestamp, sysdate, second, minute, hour, day, month, year, str)

* `<any>` when meta-type="class" the persistent type is a string containing the Class.FullName (In order to set a parameter in a query you must use SetParameter("paraName", typeof(YourClass).FullName, NHibernateUtil.ClassMetaType) )
 
### Mapping

* `<any>` : default meta-type is "string" (was "class") 
