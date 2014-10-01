---
layout: post
title: "How-To: Using the N* Stack, part 4"
date: 2009-08-16 23:44:22 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/08/16/how-to-using-the-n-stack-part-4.aspx/"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>This is part 4 of my series on <a href="http://www.asp.net/mvc/" target="_blank">ASP.NET MVC</a> and NHibernate. If you’re not up to date, you can go check out:</p>  <ul>   <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">Part 1</a> – Setting up the Visual Studio solution </li>    <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">Part 2</a> – Building the model </li>    <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-3/" target="_blank">Part 3</a> – Mapping the model to the database </li> </ul>  <p>As promised, today, we’re going to test our mappings and get a little familiar with using <a href="http://nhforge.org" target="_blank">NHibernate</a>.</p>  <p>We’ll be using NUnit 2.5.2, but any recent version should work.</p>  <p><strong>Disclaimer</strong>: I’m still learning some of this myself, so use at your own risk. This may not be considered best practice. Also, there’s almost certainly better ways to write these tests using one of the dozens of popular testing frameworks out there, but we’re using plain vanilla NUnit.</p>  <p>Let’s create a new Class Library project for our tests. We’ll call it NStackExample.Data.Tests. Now, in the data test project, add references to your core project, data project, NHibernate.dll, FluentNHibernate.dll, and NUnit.Framework.dll. If you’ve installed NUnit, NUnit.Framework.dll will be on the .NET tab. If you have multiple versions of NUnit installed, be sure to pick the right version.</p>  <h3>SQL: Now in a convenient travel size</h3>  <p>If you haven’t heard of SQLite before, you’re going to love this. It’s a tiny, self-contained, open-source SQL database engine in a DLL. Even better, it can run entirely in-memory and it’s blazing fast. Here’s how you get set up to use it:</p>  <ol>   <li>Download the SQLite ADO.NET Provider from here. Get the full version – the one named something like SQLLit-1.0.65.0-setup.exe. Install it, then grab a copy of System.Data.Sqlite.dll and put it in your Solution Items folder with all the other 3rd party libraries. If you’re running on a 64-bit operating system, grab the one from the bin\x64 directory. If not, use the one in bin. </li>    <li>Download the SQLite library itself. Scroll down to Precompiled Binaries for Windows. It should be named something like sqlitedll-3_6_17.zip. Extract the SQLite3.dll to your Solution Items folder. </li>    <li>In your data test project, add a reference to System.Data.SQLite.dll. </li>    <li>Because SQLite3.dll was written in C and is completely unmanaged, we can’t add a direct reference to it. To ensure it gets put in the right place, we’re going to set it up as a content file. Right click on your data test project, choose Add Existing Item, then browse for SQLite3.dll. Add it. In Solution Explorer, it’ll be mixed in with the code for your project. Right click on it and choose properties. Set it to Copy Always. This will copy it to the bin\Debug or bin\Release folder every time your project is built, so it never gets forgotten. </li>    <li>If you haven’t already, grab the code for the SQLiteDatabaseScope class from <a href="http://jasondentler.com/blog/2009/08/nhibernate-unit-testing-with-sqlite-in-memory-db/" target="_blank">my previous post</a>. Add it to your data test project. </li> </ol>  <h3>A simple mapping test</h3>  <pre class="brush:vbnet">Imports NUnit.Framework

&lt;TestFixture()&gt; _
Public Class CourseMappingTests

    &lt;Test()&gt; _
    Public Sub CanLoadAndSaveCourse()
        Using Scope As New SQLiteDatabaseScope(Of CourseMapping)
            Using Session = Scope.OpenSession
                Dim ID As Guid
                Dim Course As Course

                Using Tran = Session.BeginTransaction
                    ID = Session.Save(New Course With { _
                        .Subject = &quot;SUBJ&quot;, _
                        .CourseNumber = &quot;1234&quot;, _
                        .Title = &quot;Title&quot;, _
                        .Description = &quot;Description&quot;, _
                        .Hours = 3})
                    Tran.Commit()
                End Using
                Session.Clear()

                Using Tran = Session.BeginTransaction
                    Course = Session.Get(Of Course)(ID)

                    Assert.AreEqual(&quot;SUBJ&quot;, Course.Subject)
                    Assert.AreEqual(&quot;1234&quot;, Course.CourseNumber)
                    Assert.AreEqual(&quot;Title&quot;, Course.Title)
                    Assert.AreEqual(&quot;Description&quot;, Course.Description)
                    Assert.AreEqual(3, Course.Hours)

                    Tran.Commit()

                End Using

            End Using
        End Using
    End Sub

End Class</pre>

<pre class="brush:csharp">using System;
using NUnit.Framework;
using NHibernate;

namespace NStackExample.Data.Tests
{
    [TestFixture]
    public class CourseMappingTests
    {

        [Test]
        public void CanSaveAndLoadCourse()
        {
            using (SQLiteDatabaseScope&lt;CourseMapping&gt; Scope = new SQLiteDatabaseScope&lt;CourseMapping&gt;())
            {
                using (ISession Session = Scope.OpenSession())
                {
                    Guid ID;
                    Course Course;

                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        ID = (Guid)Session.Save(new Course
                        {
                            Subject = &quot;SUBJ&quot;,
                            CourseNumber = &quot;1234&quot;,
                            Title = &quot;Title&quot;,
                            Description = &quot;Description&quot;,
                            Hours = 3
                        });
                        Tran.Commit();
                    }
                    Session.Clear();

                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        Course = Session.Get&lt;Course&gt;(ID);

                        Assert.AreEqual(&quot;SUBJ&quot;, Course.Subject);
                        Assert.AreEqual(&quot;1234&quot;, Course.CourseNumber);
                        Assert.AreEqual(&quot;Title&quot;, Course.Title);
                        Assert.AreEqual(&quot;Description&quot;, Course.Description);
                        Assert.AreEqual(3, Course.Hours);

                        Tran.Commit();
                    }
                }
            }
        }
    }
}</pre>

<p>Here’s how it works:</p>

<ul>
  <li>First, we get a fresh in-memory SQLite database with our schema built. </li>

  <li>Put a new course in the database </li>

  <li>Clear the session </li>

  <li>Get the course back out of the database </li>

  <li>Check to make sure each of our properties survived the trip. If they didn’t, fail the test. </li>
</ul>

<p>There’s a few things that may be new to you.</p>

<ul>
  <li>Our class has the TestFixture attribute. This tells NUnit that this class contains tests. </li>

  <li>Each subroutine has the Test attribute. This tells NUnit that this method is a test. </li>

  <li>The SQLiteDatabaseScope is almost certainly new, considering I wrote it Friday. You can read my previous post for more information. </li>
</ul>

<h3>Use of implicit transaction is discouraged</h3>

<p>You’re probably wondering why I would wrap such simple one-statement database logic in a transaction, especially a Session.Get, which is essentially a single select statement. Prior to writing this series, I wouldn’t have done it that way. Rookie mistake.</p>

<p>While doing research for this entry, I ran across <a href="http://ayende.com/Blog/archive/2009/04/28/nhibernate-unit-testing.aspx" target="_blank">an example test</a> from Ayende. He was using transactions on everything,&#160; even his calls to Session.Get. I asked him why and he sent me a link to this <a href="http://nhprof.com/Learn/Alert?name=DoNotUseImplicitTransactionsHibernate" target="_blank">NHProfiler Alert</a>. It’s important and not obvious – at least not to me - so with permission, I’ve quoted the entire page.</p>

<blockquote>
  <p>A common mistake when using a database is to use transactions only when orchestrating several write statements. In reality, every operation that the database is doing is done inside a transaction, including queries and writes (update, insert, delete).</p>

  <p>When we don't define our own transactions, it falls back into implicit transaction mode, where every statement to the database runs in its own transaction, resulting in a large performance cost (database time to build and tear down transactions), and reduced consistency.</p>

  <p>Even if we are only reading data, we should use a transaction, because using transactions ensures that we get consistent results from the database. Hibernate assumes that all access to the database is done under a transaction, and strongly discourages any use of the session without a transaction.</p>

  <pre class="brush:csharp">Session session = sessionFactory.openSession();
try {
  Transaction tx = session.beginTransaction();
  try {
    //execute code that uses the session
  } finally {
    tx.commit();
  }
} finally {
  session.close();
}</pre>

  <p>Leaving aside the safety issue of working with transactions, the assumption that transactions are costly and that we need to optimize them is false. As previously mentioned, databases are always running in a transaction. Also, they have been heavily optimized to work with transactions.</p>

  <p>The real question here is: Is the transaction per-statement or per-batch? There is a non-trivial amount of work that needs to be done to create and dispose of a transaction; having to do it per-statement is more costly than doing it per-batch.</p>

  <p>It is possible to control the number and type of locks that a transaction takes by changing the transaction isolation level (and, indeed, a common optimization is to reduce the isolation level).</p>

  <p>Hibernate treats the call to commit() as the time to flush all changed items from the unit of work to the database, and without an explicit call to Commit(), it has no way of knowing when it should do that. A call to Flush() is possible, but it is frowned upon because this is usually a sign of improper transaction usage.</p>

  <p>I strongly suggest that you use code similar to that shown above (or use another approach to transactions, such as TransactionScope, or Castle's Automatic Transaction Management) in order to handle transactions correctly.</p>

  <h5>Transaction and the second level cache</h5>

  <p>Another implication of not using explicit transactions with Hibernate is related to the use of the second level cache.</p>

  <p>Hibernate goes to great length in order to ensure that the 2nd level cache maintains a consistent view of the database. This is accomplished by deferring all 2nd level cache updates to the transaction commit. In this way, we can assert that the data in the 2nd level cache is the one committed to the database.</p>

  <p>Forgoing the use of explicit transactions has the effect of nulling the 2nd level cache. Here is an example that would make this clear:</p>

  <pre class="brush:csharp">try {
  Post post = session.get(Post.class, 1);
  // do something with post
} finally {
  session.close();
}</pre>

  <p>Even if the 2nd level cache is enabled for Post, it is still not going to be cached in the 2nd level cache. The reason is that until we commit a transaction, Hibernate will not update the cache with the values for the loaded entities.</p>

  <p>This code, however, does make use of the 2nd level cache:</p>

  <pre class="brush:csharp">Session session = sessionFactory.openSession();
try {
  Transaction tx = sessionFactory.beginTransaction();
  try {
    Post post = session.get(Post.class, 1);
    // do something with post
  } finally {
    tx.commit();
  }
} finally {
  session.close();
}</pre>
</blockquote>

<p>&#160;</p>

<h3>A slightly more complicated mapping test</h3>

<p>When an entity has a required parent, as in the case of our section, you must create and insert the parent before actually testing the child. We’re not testing the cascade here. That’s a separate test. In this case, section has two required parents: a course, and a term. Here’s the test:</p>

<pre class="brush:vbnet">    &lt;Test()&gt; _
    Public Sub CanLoadAndSaveCourse()
        Using Scope As New SQLiteDatabaseScope(Of CourseMapping)
            Using Session = Scope.OpenSession

                Dim ID As Guid
                Dim Section As Section
                Dim Course As New Course With { _
                        .Subject = &quot;SUBJ&quot;, _
                        .CourseNumber = &quot;1234&quot;, _
                        .Title = &quot;Title&quot;, _
                        .Description = &quot;Description&quot;, _
                        .Hours = 3}

                Dim Term As New Term With { _
                        .Name = &quot;Fall 2009&quot;, _
                        .StartDate = New Date(2009, 9, 1), _
                        .EndDate = New Date(2009, 12, 1)}

                'We're not testing the cascade, so save the parents first...
                Using Tran = Session.BeginTransaction
                    Session.Save(Course)
                    Session.Save(Term)
                    Tran.Commit()
                End Using
                Session.Clear()

                Using Tran = Session.BeginTransaction
                    ID = Session.Save(New Section With { _
                                      .Course = Course, _
                                      .FacultyName = &quot;FacultyName&quot;, _
                                      .RoomNumber = &quot;R1&quot;, _
                                      .SectionNumber = &quot;1W&quot;, _
                                      .Term = Term})
                    Tran.Commit()
                End Using

                Session.Clear()

                Using Tran = Session.BeginTransaction
                    Section = Session.Get(Of Section)(ID)

                    Assert.AreEqual(Course, Section.Course)
                    Assert.AreEqual(&quot;FacultyName&quot;, Section.FacultyName)
                    Assert.AreEqual(&quot;R1&quot;, Section.RoomNumber)
                    Assert.AreEqual(&quot;1W&quot;, Section.SectionNumber)
                    Assert.AreEqual(Term, Section.Term)

                    Tran.Commit()

                End Using

            End Using
        End Using
    End Sub</pre>

<pre class="brush:csharp">        [Test]
        public void CanSaveAndLoadSection()
        {
            using (SQLiteDatabaseScope&lt;CourseMapping&gt; Scope = new SQLiteDatabaseScope&lt;CourseMapping&gt;) {
                using (ISession Session = Scope.OpenSession()) {

                    Guid ID;
                    Section Section;
                    Course Course = new Course { 
                        Subject = &quot;SUBJ&quot;, 
                        CourseNumber = &quot;1234&quot;, 
                        Title = &quot;Title&quot;, 
                        Description = &quot;Description&quot;, 
                        Hours = 3};
                    Term Term = new Term {
                        Name = &quot;Fall 2009&quot;,
                        StartDate = new DateTime(2009,8,1),
                        EndDate = new DateTime(2009,12,1)};
                    
                    // We're not testing the cascade here, so explicitly save these parent objects.
                    using (ITransaction Tran = Session.BeginTransaction()) {
                        Session.Save(Course);
                        Session.Save(Term);
                        Tran.Commit();
                    }

                    Session.Clear();

                    using (ITransaction Tran = Session.BeginTransaction()) {
                        ID = (Guid) Session.Save(new Section {
                                 Course = Course,
                                 FacultyName = &quot;FacultyName&quot;, 
                                 RoomNumber = &quot;R1&quot;, 
                                 SectionNumber = &quot;W1&quot;,
                                 Term = Term});
                        Tran.Commit();
                    }

                    Session.Clear();

                    using (ITransaction Tran = Session.BeginTransaction()) {
                        Section = Session.Get&lt;Section&gt;(ID);

                        Assert.AreEqual(Course, Section.Course);
                        Assert.AreEqual(&quot;FacultyName&quot;, Section.FacultyName);
                        Assert.AreEqual(&quot;R1&quot;,Section.RoomNumber);
                        Assert.AreEqual(&quot;W1&quot;, Section.SectionNumber);
                        Assert.AreEqual(Term, Section.Term);

                        Tran.Commit();
                    }

                }
            }

        }</pre>

<h3>Testing the cascade</h3>

<p>“Cascade what? “</p>

<p>In your application, when you’ve just registered a student for a whole bunch of classes, usually with several changes along the way, you don’t want to have to remember what entities were added, removed or changed. That’s just crazy. Thanks to the Cascade functionality in NHibernate, you don’t have to do that. Just save the student entity. If your mappings are correct, it just works™.</p>

<p>For some people, especially me, that’s a big if. That’s why we test our mappings.</p>

<pre class="brush:vbnet">    &lt;Test()&gt; _
    Public Sub CanCascadeSaveFromCourseToSections()
        Using Scope As New SQLiteDatabaseScope(Of CourseMapping)
            Using Session = Scope.OpenSession
                Dim ID As Guid

                Dim Term As New Term With { _
                        .Name = &quot;Fall 2009&quot;, _
                        .StartDate = New Date(2009, 9, 1), _
                        .EndDate = New Date(2009, 12, 1)}

                'We're not testing the cascade of section -&gt; term here
                Using Tran = Session.BeginTransaction
                    Session.Save(Term)
                    Tran.Commit()
                End Using
                Session.Clear()

                Dim Course As New Course With { _
                        .Subject = &quot;SUBJ&quot;, _
                        .CourseNumber = &quot;1234&quot;, _
                        .Title = &quot;Title&quot;, _
                        .Description = &quot;Description&quot;, _
                        .Hours = 3}

                Dim Section1 As New Section With { _
                        .FacultyName = &quot;FacultyName&quot;, _
                        .RoomNumber = &quot;R1&quot;, _
                        .SectionNumber = &quot;1&quot;, _
                        .Term = Term}

                Dim Section2 As New Section With { _
                        .FacultyName = &quot;FacultyName&quot;, _
                        .RoomNumber = &quot;R1&quot;, _
                        .SectionNumber = &quot;2&quot;, _
                        .Term = Term}

                Course.AddSection(Section1)
                Course.AddSection(Section2)

                'Test saving
                Using Tran = Session.BeginTransaction
                    ID = Session.Save(Course)
                    Tran.Commit()
                End Using
                Session.Clear()

                'Check the results
                Using Tran = Session.BeginTransaction
                    Course = Session.Get(Of Course)(ID)

                    Assert.AreEqual(2, Course.Sections.Count)
                    Assert.AreEqual(1, Course.Sections _
                                    .Where(Function(S As Section) _
                                               S.Equals(Section1)) _
                                    .Count(), &quot;Course.Sections does not contain section 1.&quot;)

                    Assert.AreEqual(1, Course.Sections _
                                    .Where(Function(S As Section) _
                                               S.Equals(Section2)) _
                                    .Count(), &quot;Course.Sections does not contain section 2.&quot;)


                    Tran.Commit()
                End Using
            End Using
        End Using
    End Sub</pre>

<pre class="brush:csharp">        [Test()]
        public void CanCascadeSaveFromCourseToSections()
        {
            using (SQLiteDatabaseScope<coursemapping> Scope = new SQLiteDatabaseScope<coursemapping>())
            {
                using (ISession Session = Scope.OpenSession())
                {
                    Guid ID;

                    Term Term = new Term { 
                                Name = &quot;Fall 2009&quot;, 
                                StartDate = new System.DateTime(2009, 9, 1), 
                                EndDate = new System.DateTime(2009, 12, 1) };

                    //We're not testing the cascade of section -&gt; term here
                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        Session.Save(Term);
                        Tran.Commit();
                    }
                    Session.Clear();

                    Course Course = new Course { 
                        Subject = &quot;SUBJ&quot;, 
                        CourseNumber = &quot;1234&quot;, 
                        Title = &quot;Title&quot;, 
                        Description = &quot;Description&quot;, 
                        Hours = 3 };

                    Section Section1 = new Section { 
                        FacultyName = &quot;FacultyName&quot;, 
                        RoomNumber = &quot;R1&quot;, 
                        SectionNumber = &quot;1&quot;, 
                        Term = Term };

                    Section Section2 = new Section { 
                        FacultyName = &quot;FacultyName&quot;, 
                        RoomNumber = &quot;R1&quot;, 
                        SectionNumber = &quot;2&quot;, 
                        Term = Term };

                    Course.AddSection(Section1);
                    Course.AddSection(Section2);

                    //Test saving
                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        ID = (Guid) Session.Save(Course);
                        Tran.Commit();
                    }
                    Session.Clear();

                    //Check the results
                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        Course = Session.Get<course>(ID);

                        Assert.AreEqual(2, Course.Sections.Count);
                        Assert.AreEqual(1, Course.Sections
                                .Where(S =&gt; S.Equals(Section1)).Count(), 
                                &quot;Course.Sections does not contain section 1.&quot;);

                        Assert.AreEqual(1, Course.Sections
                                .Where(S =&gt; S.Equals(Section2)).Count(), 
                                &quot;Course.Sections does not contain section 2.&quot;);


                        Tran.Commit();
                    }
                }
            }
        }</pre>

<p>The test above will make sure new and/or updated sections are saved when you save the course. Here’s how it works:</p>

<ul>
  <li>Get a fresh SQLite DB </li>

  <li>Since we’re not testing terms, but we need one for our sections, build a term and stick it in the database. </li>

  <li>Build a course and two sections. </li>

  <li>Save the course </li>

  <li>Clear the session </li>

  <li>Get the course </li>

  <li>Make sure it has our two sections </li>
</ul>

<p>What should happen when you remove a section from a course? A parent course is required for each section. Remember, we specified not nullable in the mapping. More importantly, an orphaned section isn’t allowed in the real world. So, if a section is orphaned, it should be deleted. We need to write a test for that.</p>

<pre class="brush:vbnet">    &lt;Test()&gt; _
    Public Sub CanCascadeOrphanDeleteFromCourseToSections()
        Using Scope As New SQLiteDatabaseScope(Of CourseMapping)
            Using Session = Scope.OpenSession
                Dim ID As Guid

                Dim Term As New Term With { _
                        .Name = &quot;Fall 2009&quot;, _
                        .StartDate = New Date(2009, 9, 1), _
                        .EndDate = New Date(2009, 12, 1)}

                Using Tran = Session.BeginTransaction
                    'We're not testing the cascade of section -&gt; term here
                    Session.Save(Term)
                    Tran.Commit()
                End Using
                Session.Clear()

                Dim Course As New Course With { _
                        .Subject = &quot;SUBJ&quot;, _
                        .CourseNumber = &quot;1234&quot;, _
                        .Title = &quot;Title&quot;, _
                        .Description = &quot;Description&quot;, _
                        .Hours = 3}

                Dim Section1 As New Section With { _
                        .FacultyName = &quot;FacultyName&quot;, _
                        .RoomNumber = &quot;R1&quot;, _
                        .SectionNumber = &quot;1&quot;, _
                        .Term = Term}

                Dim Section2 As New Section With { _
                        .FacultyName = &quot;FacultyName&quot;, _
                        .RoomNumber = &quot;R1&quot;, _
                        .SectionNumber = &quot;2&quot;, _
                        .Term = Term}

                Course.AddSection(Section1)
                Course.AddSection(Section2)

                Using Tran = Session.BeginTransaction
                    Session.Save(Course)
                    Tran.Commit()
                End Using
                Session.Clear()

                'Test removing
                Course.RemoveSection(Section1)
                Using Tran = Session.BeginTransaction
                    ID = Session.Save(Course)
                    Tran.Commit()
                End Using
                Session.Clear()

                'Check the results
                Using Tran = Session.BeginTransaction
                    Course = Session.Get(Of Course)(ID)

                    Assert.AreEqual(1, Course.Sections.Count())

                    Assert.AreEqual(0, Course.Sections _
                                    .Where(Function(S As Section) _
                                               S.Equals(Section1)) _
                                    .Count(), &quot;Course.Sections still contains section 1&quot;)

                    Tran.Commit()
                End Using

            End Using
        End Using
    End Sub</pre>

<pre class="brush:csharp">        [Test()]
        public void CanCascadeOrphanDeleteFromCourseToSections()
        {
            using (SQLiteDatabaseScope&lt;CourseMapping&gt; Scope = new SQLiteDatabaseScope&lt;CourseMapping&gt;())
            {
                using (ISession Session = Scope.OpenSession())
                {
                    Guid ID;

                    Term Term = new Term { 
                        Name = &quot;Fall 2009&quot;, 
                        StartDate = new System.DateTime(2009, 9, 1), 
                        EndDate = new System.DateTime(2009, 12, 1) };

                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        //We're not testing the cascade of section -&gt; term here
                        Session.Save(Term);
                        Tran.Commit();
                    }
                    Session.Clear();


                    Course Course = new Course { 
                        Subject = &quot;SUBJ&quot;, 
                        CourseNumber = &quot;1234&quot;, 
                        Title = &quot;Title&quot;, 
                        Description = &quot;Description&quot;, 
                        Hours = 3 };

                    Section Section1 = new Section { 
                        FacultyName = &quot;FacultyName&quot;, 
                        RoomNumber = &quot;R1&quot;, 
                        SectionNumber = &quot;1&quot;, 
                        Term = Term };

                    Section Section2 = new Section { 
                        FacultyName = &quot;FacultyName&quot;, 
                        RoomNumber = &quot;R1&quot;, 
                        SectionNumber = &quot;2&quot;, 
                        Term = Term };

                    Course.AddSection(Section1);
                    Course.AddSection(Section2);

                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        Session.Save(Course);
                        Tran.Commit();
                    }
                    Session.Clear();

                    //Test removing
                    Course.RemoveSection(Section1);
                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        ID = (Guid) Session.Save(Course);
                        Tran.Commit();
                    }
                    Session.Clear();

                    //Check the results
                    using (ITransaction Tran = Session.BeginTransaction())
                    {
                        Course = Session.Get&lt;Course&gt;(ID);

                        Assert.AreEqual(1, Course.Sections.Count());

                        Assert.AreEqual(0, Course.Sections
                            .Where(S =&gt; S.Equals(Section1)).Count(), 
                            &quot;Course.Sections still contains section 1&quot;);

                        Tran.Commit();

                    }
                }
            }
        }</pre>

<p>I hope you see where I’m going with this one. Except for query tests, which we’ll do when we write our DAOs, that’s it for NHibernate testing. We do the same types of tests for our other entity classes.</p>

<h3>But…</h3>

<p>So, I bet you’re thinking “This mess won’t compile and even if it did, almost all of your tests would fail!” Yep. If the tests always pass, why write them?</p>

<p>Normally, I’d at least declare those missing functions so the solution would compile, but in this case, the discussion of those issues fits better with our next topic: How do we fix the broken stuff?</p>

<p><strike>Download links for the complete solution in both languages are coming soon.</strike></p>

<p>Edit: Download VB.NET <a href="http://jasondentler.com/downloads/NStackExample.Part4.VBNET.zip" target="_blank">here</a> or C# <a href="http://jasondentler.com/downloads/NStackExample.Part4.CSharp.zip" target="_blank">here</a>. To simplify things, I’ve removed the StudentTerm entity from the model.</p>

<p>Jason 
  <br />

  <br />- Testy and in need of sleep.</p>

<p>References: <a href="http://ayende.com/Blog/archive/2009/04/28/nhibernate-unit-testing.aspx" target="_blank">Ayende’s blog post</a>, <a href="http://devlicio.us/blogs/krzysztof_kozmic/archive/2009/08/14/testing-with-nhibernate-and-sqlite.aspx" target="_blank">Krzysztof Kozmic’s recent post on Devlio.us</a>, <a href="http://www.tigraine.at/2009/05/29/fluent-nhibernate-gotchas-when-testing-with-an-in-memory-database/" target="_blank">Daniel Hoebling’s blog post</a>, <a href="http://nhprof.com/Learn/UserGuide" target="_blank">Ayende’s NHProfiler Alerts</a>.</p>
