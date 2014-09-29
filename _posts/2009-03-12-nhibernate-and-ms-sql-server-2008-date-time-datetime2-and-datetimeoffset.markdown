---
layout: post
title: "NHibernate and Ms Sql Server 2008: Date, Time, DateTime2 and DateTimeOffset"
date: 2009-03-12 00:44:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["SQL Server 2008", "NH2.1", "Date", "DateTimeOffset", "DateTime2", "Time"]
alias: ["/blogs/nhibernate/archive/2009/03/11/nhibernate-and-ms-sql-server-2008-date-time-datetime2-and-datetimeoffset.aspx"]
author: darioquintana
gravatar: f436801727b13a5c4c4a38380fc17290
---
{% include imported_disclaimer.html %}
<p>Ms Sql Server 2008 come with a lot of features talking about Date/Time. Besides the already known DbType.DateTime, now we have new types:</p>
<ul>
<li><i><b>Date </b></i></li>
<li><i><b>Time </b></i></li>
<li><i><b>DateTime2 </b></i></li>
<li><i><b>DateTimeOffset</b></i> </li>
</ul>
<p>NHibernate 2.1 introduce changes to support this types out-of-the-box. This table show all the details about how to configurate your system: classes, mappings:</p>
<table border="1" cellpadding="2" cellspacing="0" width="614">
<tbody>
<tr>
<td valign="top" width="155">
<p align="center"><b>CLR Type </b></p>
</td>
<td valign="top" width="111">
<p align="center"><b>DbType </b></p>
</td>
<td valign="top" width="152">
<p align="center"><b>Sql Server Type</b></p>
</td>
<td valign="top" width="194">
<p align="center"><b>NHibernate type</b></p>
</td>
</tr>
<tr>
<td valign="top" width="155">
<p align="center">System.DateTime</p>
</td>
<td valign="top" width="111">
<p align="center">DateTime</p>
</td>
<td valign="top" width="152">
<p align="center">datetime</p>
</td>
<td valign="top" width="194">
<p align="center">datetime</p>
</td>
</tr>
<tr>
<td valign="top" width="155">
<p align="center">System.DateTime</p>
</td>
<td valign="top" width="111">
<p align="center">DateTime2</p>
</td>
<td valign="top" width="152">
<p align="center">datetime2</p>
</td>
<td valign="top" width="194">
<p align="center">datetime2</p>
</td>
</tr>
<tr>
<td valign="top" width="155">
<p align="center">System.DateTime</p>
</td>
<td valign="top" width="111">
<p align="center">Date</p>
</td>
<td valign="top" width="152">
<p align="center">date</p>
</td>
<td valign="top" width="194">
<p align="center">date</p>
</td>
</tr>
<tr>
<td valign="top" width="155">
<p align="center">System.TimeSpan</p>
</td>
<td valign="top" width="111">
<p align="center">Time</p>
</td>
<td valign="top" width="152">
<p align="center">time</p>
</td>
<td valign="top" width="194">
<p align="center">TimeAsTimeSpan</p>
</td>
</tr>
<tr>
<td valign="top" width="155">
<p align="center">System.DateTime</p>
</td>
<td valign="top" width="111">
<p align="center">Time</p>
</td>
<td valign="top" width="152">
<p align="center">time</p>
</td>
<td valign="top" width="194">
<p align="center">time</p>
</td>
</tr>
<tr>
<td valign="top" width="155">
<p align="center">System.DateTimeOffset</p>
</td>
<td valign="top" width="111">
<p align="center">DateTimeOffset</p>
</td>
<td valign="top" width="152">
<p align="center">datetimeoffset</p>
</td>
<td valign="top" width="194">
<p align="center">datetimeoffset</p>
</td>
</tr>
</tbody>
</table>
<p>&nbsp;</p>
<p>When we talk about &ldquo;NHibernate type&rdquo;, we are refering to what you&rsquo;ve to put into your mappings, i.e: <i><b>&lt;property name=&rdquo;OnlineMeeting&rdquo; type=&rdquo;datetimeoffset&rdquo;/&gt;</b> </i>. </p>
<p>To use this features and more you&rsquo;ve to use the dialect <b><i>NHibernate.Dialect.MsSql2008Dialect</i></b>. </p>
<p>The dialect changes include these types and changes to <b>Hql functions</b> that return the current system timestamp.</p>
<ul>
<li><b>current_timestamp</b>: Now returns the current system timestamp as a DateTime2 value. It uses <i>sysdatetime</i> Sql Server function at background.</li>
<li><b>current_timestamp_offset</b>: New function!. Returns the current system timestamp with the offset as a DateTimeOffset value. It uses <i>sysdatetimeoffset</i> Sql Server function at background.</li>
</ul>
<p>The idea of this post isn&rsquo;t to explain every new type and what it can do, otherwise is to show you what have to do in your classes, queries or mappings to configure your date/time types with NHibernate. Besides, to know every detail of these types you can visit this useful <a href="http://msdn.microsoft.com/en-us/library/bb675168.aspx">.NET Framework Developer's Guide</a>.</p>
