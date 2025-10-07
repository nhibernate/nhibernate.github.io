---
layout: post
title: "NHibernate 5.6 Released"
date: 2024-10-07T16:47:18Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Release Notes
---
NHibernate 5.6.0 is now released.

For a list of resolved issues & pull requests, see the [milestone](https://github.com/nhibernate/nhibernate-core/milestone/66?closed=1) or [the release notes](https://github.com/nhibernate/nhibernate-core/blob/5.6.0/releasenotes.txt).

Binaries are available on NuGet and SourceForge:
https://sourceforge.net/projects/nhibernate/files/NHibernate/5.6.0/
https://www.nuget.org/packages/NHibernate/5.6.0

##### Possible Breaking Changes #####
* A thread synchronization timeout may now occur in case of transaction scope timeout, throwing an additional exception. The additional throw can be disabled through the new setting `transaction.ignore_session_synchronization_failures`. See #3355.
* The default value of `transaction.system_completion_lock_timeout` has been lowered from 5000 (5 seconds) to 1000 (1 second). See #3355.
* Binary serializations of a session factory or a session from previous versions of NHibernate will not be deserializable with NHibernate 5.6.

76 issues were resolved in this release.

--

Huge thanks to everyone involved in this release.