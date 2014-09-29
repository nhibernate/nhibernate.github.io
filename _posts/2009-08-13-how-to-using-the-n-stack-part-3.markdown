---
layout: post
title: "How-To: Using the N* Stack, part 3"
date: 2009-08-13 23:50:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/08/13/how-to-using-the-n-stack-part-3.aspx"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>This is the third installment in my series. In <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">part 1</a>, we downloaded our libraries and set up our solution. In <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">part 2</a>, we built our model. In this part, we&rsquo;ll configure <a href="http://sourceforge.net/projects/nhibernate/" target="_blank">NHibernate</a> and set up our database mappings. We&rsquo;ll also set up our database schema.</p>
<h3>Java &ndash; A language of XML files loosely coupled by code.</h3>
<p>Before we can talk about Fluent NHibernate, you need to know a little bit about setting up mappings in plain old NHibernate. In a typical NHibernate setup, you&rsquo;ll have a bunch of mapping files like this:</p>
<pre class="brush:xml">&lt;?xml version="1.0" encoding="utf-8" ?&gt;
&lt;hibernate-mapping xmlns="urn:nhibernate-mapping-2.2"&gt;
    &lt;class name="NStackExample.Address, NStackExample.Core" table="Address"&gt;
        &lt;composite-id&gt;
            &lt;key-many-to-one name="Person" class="NStackExample.Person, NStackExample.Core" column="ID" /&gt;
            &lt;key-property name="Type" type="Int32" /&gt;
        &lt;/composite-id&gt;
        &lt;property name="City" type="String" length="255" /&gt;
        &lt;property name="Lines" type="String" length="255" /&gt;
        &lt;property name="State" type="String" length="2" /&gt;
        &lt;property name="Zip" type="String" length="10" /&gt;
    &lt;/class&gt;
&lt;/hibernate-mapping&gt;</pre>
<p>You&rsquo;ll have one of those for each of your entities. It&rsquo;s left over from Java&rsquo;s Hibernate project, and in my opinion, It&rsquo;s a royal pain, complete with ruby scepter. Lucky for you, there&rsquo;s a better way&trade;.</p>
<h3>A Better Way&trade;: Fluent Mappings</h3>
<p>With Fluent NHibernate, the mapping file above can be expressed using this class instead:</p>
<pre class="brush:vbnet">Imports FluentNHibernate.Mapping

Public Class AddressMapping
    Inherits ClassMap(Of Address)

    Public Sub New()
        UseCompositeId _
            .WithKeyReference(Function(x As Address) x.Person) _
            .WithKeyProperty(Function(x As Address) x.Type)
        Map(Function(x As Address) x.Lines).WithLengthOf(255)
        Map(Function(x As Address) x.City).WithLengthOf(255)
        Map(Function(x As Address) x.State).WithLengthOf(2)
        Map(Function(x As Address) x.Zip).WithLengthOf(5)

    End Sub

End Class</pre>
<p>&nbsp;</p>
<pre class="brush:csharp">using FluentNHibernate.Mapping;

namespace NStackExample.Data
{

    public class AddressMapping : ClassMap&lt;Address&gt;
    {

        public AddressMapping()
        {
            UseCompositeId()
                .WithKeyReference(x =&gt; x.Person)
                .WithKeyProperty(x =&gt; x.Type);
            Map(x =&gt; x.Lines).WithLengthOf(255);
            Map(x =&gt; x.City).WithLengthOf(255);
            Map(x =&gt; x.State).WithLengthOf(2);
            Map(x =&gt; x.Zip).WithLengthOf(5);
        }

    }
}</pre>
<p>It may look even more complicated than the XML mapping, but with Intellisense, it&rsquo;s a breeze. Plus, there are no magic strings to worry about. When you change a property name using a refactor tool, your mapping won&rsquo;t be left out of sync.</p>
<p>Now that you have the basic idea, let&rsquo;s get back on track.</p>
<h3>Where?</h3>
<p>Since the database connection, NHibernate configuration, entity mappings, and DAO implementations are really just implementation details of our chosen ORM, they should go in a separate assembly.</p>
<ol>
<li>Make a new Class Library project called NStackExample.Data </li>
<li>In the new Data project, add references to your core project, NHibernate.dll and FluentNHibernate.dll </li>
<li>Add a reference to System.Configuration.dll so we can easily retrieve some application settings later. </li>
<li>Also, the web project needs a reference to the data project. </li>
</ol>
<p>Now, let&rsquo;s make our mappings.</p>
<pre class="brush:vbnet">Imports FluentNHibernate.Mapping

Public Class CourseMapping
    Inherits ClassMap(Of Course)

    Public Sub New()
        Id(Function(x As Course) x.ID).GeneratedBy.GuidComb()
        Map(Function(x As Course) x.Subject).Not.Nullable.WithLengthOf(4).UniqueKey("CourseNaturalKey")
        Map(Function(x As Course) x.CourseNumber).Not.Nullable.WithLengthOf(4).UniqueKey("CourseNaturalKey")
        Map(Function(x As Course) x.Title).Not.Nullable.WithLengthOf(255)
        Map(Function(x As Course) x.Description).Not.Nullable.WithLengthOf(1024)
        Map(Function(x As Course) x.Hours).Not.Nullable()

        HasMany(Function(x As Course) x.Sections) _
            .AsSet() _
            .WithForeignKeyConstraintName("CourseSections")

    End Sub

End Class</pre>
<p>&nbsp;</p>
<pre class="brush:csharp">using NStackExample;
using FluentNHibernate.Mapping;

namespace NStackExample.Data
{
    public class CourseMapping : ClassMap&lt;Course&gt;
    {
        public CourseMapping()
        {
            Id(x =&gt; x.ID).GeneratedBy.GuidComb();
            Map(x =&gt; x.CourseNumber)
                .Not.Nullable()
                .WithLengthOf(4)
                .UniqueKey("CourseNaturalKey");

            Map(x =&gt; x.Subject)
                .Not.Nullable()
                .WithLengthOf(4)
                .UniqueKey("CourseNaturalKey");

            Map(x =&gt; x.Title)
                .Not.Nullable()
                .WithLengthOf(255);

            Map(x =&gt; x.Description)
                .Not.Nullable()
                .WithLengthOf(1024);

            Map(x =&gt; x.Hours)
                .Not.Nullable();

            HasMany(x =&gt; x.Sections)
                .AsSet()
                .WithForeignKeyConstraintName("CourseSections");

        }

    }
}</pre>
<p>Most of this is self-explanatory and works exactly like you would expect.</p>
<p>Our mapping class inherits from ClassMap(Of Course). ClassMap is the specific type that Fluent NHibernate searches for when looking for mappings. In this case, it signifies that this class provides the mapping for our Course entity. In the constructor, we define our specific mapping for each property.</p>
<ul>
<li>Id sets up the persistent object identifier (POID). This is basically the primary key for the table. If you have more than one property in the primary key, as in the case of natural keys, go with UseCompositeId like in the address example above. Using multi-part keys isn&rsquo;t really suggested and to my knowledge, isn&rsquo;t fully supported by Fluent NHibernate. </li>
<li>GeneratedBy specifies the POID generator. How will you assign your keys? In my case, I use GuidComb. I get all of the benefits of guid identifiers, but I don&rsquo;t fragment my database index nearly as much. You can read up on it more in <a href="/blogs/nhibernate/archive/2009/05/21/using-the-guid-comb-identifier-strategy.aspx" target="_blank">Davy Brion&lsquo;s post on the NHForge blog</a>. </li>
<li>Map simply maps a property to a database column. You can specify Not.Nullable and WithLengthOf as necessary. </li>
<li>UniqueKey specifies a unique index on the column. If you specify the same name on several columns, all of those columns will be part of the same unique index. In this example, we are forcing our natural key to be unique. Each combination of subject and course number must be unique. There can only be one ENGL 1301 course. Thank goodness. </li>
<li>HasMany defines a one-to-many relationship. You can specify the exact behavior of the collection. You have several options here, but the two types I use almost exclusively are Set and Bag. 
    
<ul>
<li>AsSet doesn&rsquo;t allow duplicate items. </li>
<li>With AsBag, duplicates are allowed. </li>
</ul>
</li>
</ul>
<p>By default, all relationships are lazy-loaded. This means that when you fetch a course from the database, the associated sections aren&rsquo;t fetched right away. It works just like you would expect: They aren&rsquo;t fetched until you access the Sections property. If you never access the Sections property, those sections are never fetched from the database, which can greatly improve performance. This is all made possible with proxies, but that&rsquo;s another series of posts.</p>
<p>Now let&rsquo;s map the sections:</p>
<pre class="brush:vbnet">Imports FluentNHibernate.Mapping

Public Class SectionMapping
    Inherits ClassMap(Of Section)

    Public Sub New()
        Id(Function(x As Section) x.ID).GeneratedBy.GuidComb()

        Map(Function(x As Section) x.FacultyName).WithLengthOf(255)
        Map(Function(x As Section) x.RoomNumber).WithLengthOf(10)
        Map(Function(x As Section) x.SectionNumber) _
            .WithLengthOf(4) _
            .Not.Nullable() _
            .UniqueKey("SectionNaturalKey")

        References(Function(x As Section) x.Course) _
            .Not.Nullable() _
            .UniqueKey("SectionNaturalKey")

        References(Function(x As Section) x.Term) _
            .Not.Nullable() _
            .UniqueKey("SectionNaturalKey")

        HasMany(Function(x As Section) x.StudentSections) _
            .AsSet() _
            .WithForeignKeyConstraintName("SectionStudentSections")

    End Sub
End Class</pre>
<p>The References function maps the Many-to-one relationship. Think of it as the other side of our one-to-many relationship. It is the reference from the child &ndash; section - back to it&rsquo;s parent - course.</p>
<p>For homework, finish mapping all of the entities.</p>
<p>I bet you&rsquo;re thinking this post is getting long considering we haven&rsquo;t even started building the database. Well don&rsquo;t worry. NHibernate will do that for us.</p>
<h3>8 hours or 8 minutes?</h3>
<p>Before I discovered NHibernate, I would spend at least a day setting up my database. It was insane. It drove me insane. I bet it drives you insane. It ends today.</p>
<p><strong>Disclaimer</strong>: If you are trying to use an existing shared legacy database, the chances of your existing DB schema working without some tweaking are slim. <a href="/blogs/nhibernate/archive/2009/06/26/database-the-eliot-ness-of-it.aspx" target="_blank">This post by Fabio Maulo</a> explains your options.</p>
<p>First, let&rsquo;s configure NHibernate. The Fluent NHibernate Wiki has <a href="http://wiki.fluentnhibernate.org/show/DatabaseConfiguration" target="_blank">a great page</a> explaining the fluent configuration of NHibernate.</p>
<pre class="brush:vbnet">Imports NHibernate
Imports NHibernate.Tool.hbm2ddl
Imports FluentNHibernate.Cfg
Imports System.Configuration
Imports System.IO

Public Class Configuration

    Private m_SchemaPath As String
    Private m_Factory As ISessionFactory

    Public Function Configure() As Configuration
        m_SchemaPath = ConfigurationManager.AppSettings("NStackExample.Data.Configuration.SchemaPath")
        m_Factory = Fluently.Configure _
            .Database(Db.MsSqlConfiguration.MsSql2005 _
                      .ConnectionString(Function(x As Db.MsSqlConnectionStringBuilder) _
                                            x.FromConnectionStringWithKey("NStackExample.Data.Configuration.DB"))) _
            .Mappings(Function(x As MappingConfiguration) _
                          x.FluentMappings.AddFromAssemblyOf(Of CourseMapping)() _
                          .ExportTo(m_SchemaPath)) _
            .ExposeConfiguration(AddressOf BuildSchema) _
            .BuildSessionFactory()
        Return Me
    End Function

    Private Sub BuildSchema(ByVal Cfg As NHibernate.Cfg.Configuration)
        Dim SchemaExporter As New NHibernate.Tool.hbm2ddl.SchemaExport(Cfg)
        SchemaExporter.SetOutputFile(Path.Combine(m_SchemaPath, "schema.sql"))
        SchemaExporter.Create(False, True)
    End Sub

    Public Function OpenSession() As ISession
        If m_Factory Is Nothing Then Configure()
        Return m_Factory.OpenSession
    End Function

End Class</pre>
<p>&nbsp;</p>
<pre class="brush:csharp">using FluentNHibernate.Cfg;
using FluentNHibernate.Cfg.Db;
using NHibernate;
using NHibernate.Cfg;
using NHibernate.Tool.hbm2ddl;
using System.IO;
using System.Configuration;

namespace NStackExample.Data
{
    public class Configuration
    {

        private ISessionFactory m_Factory;
        private string m_SchemaPath;

        public Configuration Configure()
        {

            m_SchemaPath = ConfigurationManager.AppSettings["NStackExample.Data.Configuration.SchemaPath"];

            m_Factory = Fluently.Configure()
                .Database(MsSqlConfiguration.MsSql2005
                        .ConnectionString(
                         x =&gt; x.FromConnectionStringWithKey("NStackExample.Data.Configuration.Db")))
                .Mappings(x =&gt; x.FluentMappings.AddFromAssemblyOf&lt;CourseMapping&gt;()
                                .ExportTo(m_SchemaPath))
                .ExposeConfiguration(BuildSchema)
                .BuildSessionFactory();

            return this;
        }

        private void BuildSchema(NHibernate.Cfg.Configuration cfg)
        {
            SchemaExport SchemaExporter = new SchemaExport(cfg);
            SchemaExporter.SetOutputFile(Path.Combine(m_SchemaPath, "schema.sql"));
            SchemaExporter.Create(true, false);
        }

        public ISession OpenSession()
        {
            if (m_Factory == null) Configure();
            return m_Factory.OpenSession();
        }

    }
}</pre>
<p>The configuration falls in to two sections: Database and Mappings. In our case, the database is SQL 2005 and the connection string is read from a connection string element in the web.config. All of the mappings are fluent, not auto-mapped. Notice that we are exporting our mappings to a directory specified in the appsettings section of the web.config. This will convert our fluent mappings to individual hbm.xml files. This is great for debugging the mappings, especially when asking for NHibernate help online.</p>
<p>We have one additional item. We&rsquo;re using the ExposeConfiguration method to call our BuildSchema function, passing in our complete NHibernate configuration.</p>
<p>In BuildSchema, we use a great hidden tool in NHibernate: the schema export. This amazing class will build your database for you. The create function takes two boolean parameters. The first specifies if the schema should be written out to a ddl file &ndash; a database script to build all of the tables, keys, indexes, and relationships in your database. The second boolean parameter specifies if the script should be executed against the specified database.</p>
<p>It&rsquo;s that easy.</p>
<p><strong>Two warnings:</strong></p>
<ol>
<li>Executing this script will drop and recreate every table associated with your model. That can be devastating in a production environment. </li>
<li>The script doesn&rsquo;t start with a a &ldquo;use [databasename]&rdquo; statement, so if you&rsquo;re not careful, when you execute it, you&rsquo;ll build everything in the master database. </li>
</ol>
<p>One last note: As with any project, you will have to adapt as you build. These mappings are not exactly what we use in the final build. I can guarantee our model will change significantly. I will take you through those changes as they happen, and explain the reasons behind them.</p>
<p>I&rsquo;ve decided not to post the complete source code at this stage. Instead, I leave the remaining mappings as an exercise for you, the reader. They will be included in the next source release. </p>
<p>In the next post, I&rsquo;ll show you how to test your mappings &ndash; including querying, reading from and writing to the database.</p>
<p>Jason</p>
<p>- Mapped out. Good night.</p>
<p>&nbsp;</p>
<p>P.S. &ndash; Special thanks to Tuna, Fabio, and Oren for the feedback, answers to stupid questions, and great advice!</p>
<p>For the NHForge readers, I apologize for the lack of code formatting. Now that I know the software, it should improve starting in the next post.</p>
