---
layout: post
title: "NHibernate 4.1.1 Released"
date: 2017-02-02T14:00:00+12:00
author: hazzik
gravatar: 849b5057cdc84934daae1942749f0270
tags:
  - Release Notes
---
NHibernate 4.1.1 is now released. 

For a list of resolved issues, see the release notes:
https://github.com/nhibernate/nhibernate-core/blob/4.1.1.GA/releasenotes.txt

Binaries are available on NuGet and SourceForge:
https://sourceforge.net/projects/nhibernate/files/NHibernate/4.1.1.GA/
https://www.nuget.org/packages/NHibernate/4.1.1.4000

##### Notes #####

The [NH-3904] has been reverted in favor of [NH-2401]: users now required to explicitly specify custom user type via MappedAs method if they want to use IUserType/ICompositeUserType type parameters in Linq queries, or implement generators the way they take the types into account.
