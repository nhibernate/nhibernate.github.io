---
layout: post
title: "NHibernate MyGet feed available"
date: 2020-05-11T13:02:00Z
author: fredericDelaporte
gravatar: 5eaae4002cdfc206faf907aaf38d8a09
tags:
  - Development
---
NHibernate has now a [MyGet feed](https://www.myget.org/gallery/nhibernate) for latest master builds.

For a list of resolved issues & pull requests in latest build, see the corresponding milestone in [milestones](https://github.com/nhibernate/nhibernate-core/milestones).

To be able to install NHibernate development builds you need to add additional package source in NuGet options in you IDE:
https://www.myget.org/F/nhibernate/api/v3/index.json

Or alternatively you can add/update `nuget.config` file in top folder of your project with the following content:
```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
	<packageSources>
		<add key="NHibernateDevBuilds" value="https://www.myget.org/F/nhibernate/api/v3/index.json" />
	</packageSources>
</configuration>
```

--

Thanks to bahusoid for having done most of the work, and thanks to the other people having helped getting it done.