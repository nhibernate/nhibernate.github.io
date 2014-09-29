---
layout: post
title: "Date/Time Support in NHibernate"
date: 2011-01-26 16:00:00 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: ["mapping", "SQL Server 2008", "Date", "DateTimeOffset", "DateTime2"]
alias: ["/blogs/nhibernate/archive/2011/01/26/date-time-support-in-nhibernate.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>[This article was originally published on my personal blog <a href="http://jameskovacs.com/2011/01/26/datetime-support-in-nhibernate/">here</a>. I hereby grant myself permission to re-publish it on NHForge.org.]</p>  <p>[Code for this article is available on GitHub <a href="https://github.com/JamesKovacs/NH3Features/tree/02-DateTimeSupport">here</a>.]</p>  <p>In this post, we’ll examine the ways that NHibernate supports the DateTime-related data types, including some new features introduced in NHibernate 2 and 3. Here is a quick summary for the impatient.</p>  <table border="1" cellspacing="0" cellpadding="2"><tbody>     <tr>       <td><strong>DbType</strong></td>        <td><strong>.NET</strong></td>        <td><strong>SQL Type</strong></td>     </tr>      <tr>       <td>DateTime</td>        <td>System.DateTime</td>        <td>datetime</td>     </tr>      <tr>       <td>LocalDateTime</td>        <td>System.DateTime</td>        <td>datetime</td>     </tr>      <tr>       <td>UtcDateTime</td>        <td>System.DateTime</td>        <td>datetime</td>     </tr>      <tr>       <td>DateTimeOffset</td>        <td>System.DateTimeOffset</td>        <td>datetimeoffset</td>     </tr>      <tr>       <td>DateTime2</td>        <td>System.DateTime</td>        <td>datetime2</td>     </tr>      <tr>       <td>Date</td>        <td>System.DateTime</td>        <td>date</td>     </tr>      <tr>       <td>Time</td>        <td>System.DateTime</td>        <td>time</td>     </tr>      <tr>       <td>TimeAsTimeSpan</td>        <td>System.TimeSpan</td>        <td>time</td>     </tr>      <tr>       <td>TimeSpan</td>        <td>System.TimeSpan</td>        <td>bigint (int64)</td>     </tr>   </tbody></table>  <h3>Local/UTC</h3>  <p>Let’s take a look at a few DateTime-related problems that developers have run into in the past…</p>  <pre class="brush: csharp;">public class DateTimeEntity {
    public DateTimeEntity() {
        CreationTime = DateTime.Now;
    }

    public virtual Guid Id { get; private set; }
    public virtual DateTime CreationTime { get; set; }
}</pre>

<p>Note that CreationTime is initialized using DateTime.Now. The corresponding mapping file would be:</p>

<pre class="brush: xml;"><p>&lt;hibernate-mapping xmlns=&quot;urn:nhibernate-mapping-2.2&quot;</p><p>                   namespace=&quot;Nh3Hacking&quot;</p><p>                   assembly=&quot;Nh3Hacking&quot;&gt;
  &lt;class name=&quot;DateTimeEntity&quot;&gt;
    &lt;id name=&quot;Id&quot;&gt;
      &lt;generator class=&quot;guid.comb&quot; /&gt;
    &lt;/id&gt;
    &lt;property name=&quot;CreationTime&quot;/&gt;
  &lt;/class&gt;
&lt;/hibernate-mapping&gt;</p></pre>

<p>If we create an instance of our DateTimeEntity and reload it, we get:</p>

<pre>Original entity:
Id: 09bead07-5a05-4459-a108-9e7501204918
        CreationTime: 2011-01-24 5:29:36 PM (Local)
Reloaded entity:
Id: 09bead07-5a05-4459-a108-9e7501204918
        CreationTime: 2011-01-24 5:29:36 PM (Unspecified)</pre>

<p>Note that I am outputting both CreationTime.ToString() and CreationTime.Kind. DateTime.Kind returns a DateTimeKind (surprising, huh?), which indicates whether this DateTime represents Local time or UTC time. We initialized the value with DateTime.Now, which is the local time. (If we wanted UTC time, we would use DateTime.UtcNow.) When the object is reloaded, the DateTimeKind is Unspecified. This is because the database does not store whether the DateTime value is Local or UTC. NHibernate has no way of knowing which one it is, hence Unspecified.</p>

<p>NHibernate 3 includes two new DbTypes that allow us to resolve this ambiguity. In our mapping file, we can write:</p>

<pre class="brush: xml;">&lt;property name=&quot;CreationTimeAsLocalDateTime&quot; type=&quot;LocalDateTime&quot;/&gt;
&lt;property name=&quot;CreationTimeAsUtcDateTime&quot; type=&quot;UtcDateTime&quot;/&gt;</pre>

<p>We are explicitly telling NHibernate whether the database stores Local or UTC times.</p>

<pre>Original entity:
Id: 09bead07-5a05-4459-a108-9e7501204918
        CreationTimeAsDateTime: 2011-01-24 5:29:36 PM (Local)
        CreationTimeAsLocalDateTime: 2011-01-24 5:29:36 PM (Local)
        CreationTimeAsUtcDateTime: 2011-01-25 12:29:36 AM (Utc)
Reloaded entity:
Id: 09bead07-5a05-4459-a108-9e7501204918
        CreationTimeAsDateTime: 2011-01-24 5:29:36 PM (Unspecified)
        CreationTimeAsLocalDateTime: 2011-01-24 5:29:36 PM (Local)
        CreationTimeAsUtcDateTime: 2011-01-25 12:29:36 AM (Utc)</pre>

<p>This is strictly metadata and it is up to the developer to ensure that the proper DateTime is present in the property/field. For instance, if I initialize the entity as follows:</p>

<pre class="brush: csharp;">public DateTimeEntity() {
    CreationTimeAsDateTime = DateTime.Now;
    CreationTimeAsLocalDateTime = DateTime.UtcNow;
    CreationTimeAsUtcDateTime = DateTime.Now;
}</pre>

<p>Note that the LocalDateTime property contains a UTC DateTime and the UTC property contains a Local DateTime. The results are:</p>

<pre>Original entity:
Id: 4579d245-46f3-4c3f-893b-9e750124a90b
        CreationTimeAsDateTime: 2011-01-24 5:45:32 PM (Local)
        CreationTimeAsLocalDateTime: 2011-01-25 12:45:32 AM (Utc)
        CreationTimeAsUtcDateTime: 2011-01-24 5:45:32 PM (Local)
Reloaded entity:
Id: 4579d245-46f3-4c3f-893b-9e750124a90b
        CreationTimeAsDateTime: 2011-01-24 5:45:32 PM (Unspecified)
        CreationTimeAsLocalDateTime: 2011-01-25 12:45:32 AM (Local)
        CreationTimeAsUtcDateTime: 2011-01-24 5:45:32 PM (Utc)</pre>

<p>Notice that NHibernate did not perform any conversions or throw an exception when saving/loading a DateTime value with the wrong DateTimeKind. (It could be argued that NHibernate should throw an exception when asked to save a Local DateTime and the property is mapped as a UtcDateTime.) It is up to the developer to ensure that the proper kind of DateTime is in the appropriate field/property.</p>

<h3>System.DateTimeOffset</h3>

<p>One problem that LocalDateTime and UtcDateTime does not solve is the offset problem. If you have a DateTime and its Kind is Local, all you know is that it is a Local DateTime. You do not know if that Local DateTime is Mountain (MST), Eastern (EST), Pacific (PST), etc. You do not know whether it has been corrected for daylight savings time. All you know is that it is a Local DateTime. You have to assume that the local time is based on the time zone of the current computer. Although this is often a reasonable assumption, it’s not always. (Consider for example that you’re collecting log files from a distributed system and servers reside in multiple time zones.) The problem is that System.DateTime class does not contain a place to record the timezone offset. Microsoft solved this problem starting in .NET 3.5 by introducing the System.DateTimeOffset class. It looks a lot like System.DateTime, but does include the timezone offset rather than the DateTimeKind. So we can just use System.DateTimeOffset in our applications rather than System.DateTime.</p>

<p>Except… Date/time types in SQL databases do not have anywhere to store the timezone offset. The notable exception is SQL Server 2008, which introduced the datetimeoffset type. NHibernate 2 introduced support for System.DateTimeOffset, but only for SQL Server 2008 onwards. (If you’re using SQL Server 2005 or earlier or another database server, you’ll have to implement your own IUserType to store System.DateTimeOffset in two separate columns – one for the DateTime and the other for the timezone offset.) The additional code in DateTimeEntity.cs looks like this:</p>

<pre class="brush: csharp;">public virtual DateTimeOffset CreationTimeAsDateTimeOffset { get; set; }</pre>

<p>The mapping file just needs the new property added:</p>

<pre class="brush: xml;">&lt;property name=&quot;CreationTimeAsDateTimeOffset&quot;/&gt;</pre>

<p>Note that I don’t need to specify the type in the mapping as NHibernate can infer it from the property type in DateTimeEntity. The resulting output is:</p>

<pre>Original entity:
Id: 95aa6c15-86f5-4398-aa9e-9e7600ae4580
        CreationTimeAsDateTime: 2011-01-25 10:34:30 AM (Local)
        CreationTimeAsLocalDateTime: 2011-01-25 10:34:30 AM (Local)
        CreationTimeAsUtcDateTime: 2011-01-25 5:34:30 PM (Utc)
        CreationTimeAsDateTimeOffset: 2011-01-25 10:34:30 AM -07:00
Reloaded entity:
Id: 95aa6c15-86f5-4398-aa9e-9e7600ae4580
        CreationTimeAsDateTime: 2011-01-25 10:34:30 AM (Unspecified)
        CreationTimeAsLocalDateTime: 2011-01-25 10:34:30 AM (Local)
        CreationTimeAsUtcDateTime: 2011-01-25 5:34:30 PM (Utc)
        CreationTimeAsDateTimeOffset: 2011-01-25 10:34:30 AM -07:00</pre>

<h3>Support for DateTime2, Date, and Time</h3>

<p>Let’s look at some C# and the corresponding mapping file for these types:</p>

<pre class="brush: csharp;">public virtual DateTime CreationTimeAsDateTime2 { get; set; }
public virtual DateTime CreationTimeAsDate { get; set; }
public virtual DateTime CreationTimeAsTime { get; set; }
public virtual TimeSpan CreationTimeAsTimeAsTimeSpan { get; set; }
public virtual TimeSpan CreationTimeAsTimeSpan { get; set; }</pre>

<p>Modifications to the hbm.xml:</p>

<pre class="brush: xml;">&lt;property name=&quot;CreationTimeAsDateTime2&quot; type=&quot;DateTime2&quot;/&gt;
&lt;property name=&quot;CreationTimeAsDate&quot; type=&quot;Date&quot;/&gt;
&lt;property name=&quot;CreationTimeAsTime&quot; type=&quot;Time&quot;/&gt;
&lt;property name=&quot;CreationTimeAsTimeAsTimeSpan&quot; type=&quot;TimeAsTimeSpan&quot;/&gt;
&lt;property name=&quot;CreationTimeAsTimeSpan&quot;/&gt;</pre>

<p>We’ll examine each of these in turn…</p>

<p>DbType.DateTime2 is a higher precision, wider range version of DbType.DateTime. DbType.DateTime maps to the datetime (or smalldatetime) SQL type, which has a range of 1753-01-01 to 9999-12-31. DbType.DateTime2 maps to the datetime2 SQL type, which has a range of 0001-01-01 to 9999-12-31. (Precision can be as high as 1/10 of a microsecond with a datetime2(7).) One of the niceties of DateTime2 is that an uninitialized DateTime struct (which has a value of 0001-01-01 12:00:00 AM (Unspecified)) does not cause a SqlTypeException with a SqlDateTime underflow.</p>

<p>DbType.Date does just what it advertises. It represents a Date without a Time component. It is stored in the database as only a date. .NET does not have a Date type and NHibernate represents it via a DateTime with the time portion set to 12:00:00 AM. I personally prefer to define my own Date class, which has no time component, and create an IUserType to handle the mapping. My custom Date class can handle the time truncation and provide a more natural programing model for my domain, but that’s a post for another day.</p>

<p>Time-related DbTypes stores just the time, but no date. In .NET, there is no Time class and so NHibernate uses a DateTime with the date component set to 1753-01-01, the minimum value for a SQL datetime or a System.TimeSpan – depending on the DbType that we choose. DbType.Time stores a System.DateTime in a time SQL type. DbType.TimeAsTimeSpan stores a System.TimeSpan as a time SQL type. DbType.TimeSpan stores a Syste.TimeSpan as a 64-bit integer (bigint) SQL type. As I mentioned for DbType.Date, I am more inclined to write my own Time class and custom IUserType to achieve a better programming model than relying on the .NET constructs of System.DateTime and System.TimeSpan. (I typically use System.DateTime or System.TimeSpan as a field in my custom Date or Time class for storing the data, but provide my own API for consistently working with the data.)</p>

<p><strong>WARNING</strong>: Not all databases support all date/time SQL types. So before choosing .NET and SQL types for your entities, make sure that they’re available in all databases that you plan to support.</p>

<p>Now we’ll take a look at these date/time types in action:</p>

<pre>Original entity:
Id: 6b2fb9ff-8036-4c17-b9ef-9e7600bf37e3
        CreationTimeAsDateTime: 2011-01-25 11:36:12 AM (Local)
        CreationTimeAsLocalDateTime: 2011-01-25 11:36:12 AM (Local)
        CreationTimeAsUtcDateTime: 2011-01-25 6:36:12 PM (Utc)
        CreationTimeAsDateTimeOffset: 2011-01-25 11:36:12 AM -07:00
        CreationTimeAsDateTime2: 2011-01-25 11:36:12 AM (Local)
        CreationTimeAsDate: 2011-01-25 11:36:12 AM (Local)
        CreationTimeAsTime: 2011-01-25 11:36:12 AM (Local)
        CreationTimeAsTimeAsTimeSpan: 11:36:12.2688265
        CreationTimeAsTimeSpan: 11:36:12.2688265
Reloaded entity:
Id: 6b2fb9ff-8036-4c17-b9ef-9e7600bf37e3
        CreationTimeAsDateTime: 2011-01-25 11:36:12 AM (Unspecified)
        CreationTimeAsLocalDateTime: 2011-01-25 11:36:12 AM (Local)
        CreationTimeAsUtcDateTime: 2011-01-25 6:36:12 PM (Utc)
        CreationTimeAsDateTimeOffset: 2011-01-25 11:36:12 AM -07:00
        CreationTimeAsDateTime2: 2011-01-25 11:36:12 AM (Unspecified)
        CreationTimeAsDate: 2011-01-25 12:00:00 AM (Unspecified)
        CreationTimeAsTime: 1753-01-01 11:36:12 AM (Unspecified)
        CreationTimeAsTimeAsTimeSpan: 11:36:12.2700000
        CreationTimeAsTimeSpan: 11:36:12.2688265</pre>

<h3>Summary</h3>

<p>As you have seen, NHibernate has a wide variety of options for mapping date/time-related types to and from the database. The right choice is highly dependent on your application and database server. I hope that this post has given you a few more tricks up your sleeve for effectively mapping date/time-related types using NHibernate.</p>
