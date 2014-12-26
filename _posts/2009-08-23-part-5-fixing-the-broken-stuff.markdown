---
layout: post
title: "Part 5: Fixing the Broken Stuff"
date: 2009-08-23 22:20:04 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/08/23/part-5-fixing-the-broken-stuff.aspx/"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>This is part 5 of my series on <a href="http://www.asp.net/mvc/" target="_blank">ASP.NET MVC</a> with <a href="http://nhforge.org" target="_blank">NHibernate</a>. So far, we concentrated on NHibernate and persistence concerns. In this part, we’re going to correct our model and mappings to pass our tests. This will be the last full-time NHibernate post for a while. The next part will be focused on integrating <a href="http://ninject.org/" target="_blank">Ninject</a>, our inversion of control / dependency injection framework, with ASP.NET MVC.</p>  <p>If you’re just joining us, you can still catch up.</p>  <ul>   <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">Part 1</a> – Solution setup </li>    <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">Part 2</a> – Model design </li>    <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-3/" target="_blank">Part 3</a> – Persistence mapping </li>    <li><a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-4/" target="_blank">Part 4</a> – Persistence tests <a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/LogoNH_5F00_3F6D6799.gif"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" title="LogoNH" border="0" alt="LogoNH" align="right" src="/images/posts/2009/08/23/LogoNH_5F00_thumb_5F00_0511F1B8.gif" width="43" height="40" /></a> </li> </ul>  <p>First, some trivia. According to Fabio Maulo, the NHibernate logo is probably a sleeping <a href="http://en.wikipedia.org/wiki/Marmot" target="_blank">marmot</a>.&#160;&#160;&#160; </p>  <h3>Know what you’re fixing</h3>  <p>When correcting bugs, you should correct only bugs. This seems obvious. Yes, we write tests so we can find out what’s broken. The less obvious purpose is to know what’s not broken.</p>  <p><strong>Confession</strong>: Sometimes I code first, then test. Sometimes I put on my pants, then my shirt. As long as you leave the house fully dressed, the order isn’t all that important. As long as you write your code and tests every day, the order isn’t all that important.</p>  <p>Now, when you’re on a team working on a project, I assume things *should* work a little different. I wouldn’t know. My project team is just me, and I’ve picked up a lot of bad habits from my team over the years.</p>  <p>Here are the results of the NUnit tests from part 4: 2 passed, 3 failed, 5 threw exceptions. 2 out of 10 is actually pretty good for me. Let’s work through these 8 problems one at a time.</p>  <p>&#160;</p>  <h3>Bare-minimum NHibernate debugging</h3>  <p>NHibernate makes extensive use of the log4net log framework. It’s quick and painless to expose this log to NUni or most other test runners.</p>  <ol>   <li>In your data test project, add a reference to log4net.dll </li>    <li>Add an app.config </li>    <li>Add a new class called BaseFixture </li>    <li>Set all of your test fixtures to inherit from the base fixture. </li> </ol>  <p>Here’s what your app.config should look like with the log4net configuration:</p>  <pre class="brush:xml">&lt;?xml version=&quot;1.0&quot; encoding=&quot;utf-8&quot; ?&gt;
&lt;configuration&gt;
  &lt;configSections&gt;
    &lt;section name=&quot;log4net&quot; type=&quot;log4net.Config.Log4NetConfigurationSectionHandler,log4net&quot;/&gt;
  &lt;/configSections&gt;
  &lt;log4net&gt;
    &lt;appender name=&quot;Debugger&quot; type=&quot;log4net.Appender.ConsoleAppender&quot;&gt;
      &lt;layout type=&quot;log4net.Layout.PatternLayout&quot;&gt;
        &lt;conversionPattern value=&quot;%date [%thread] %-5level %logger - %message%newline&quot;/&gt;
      &lt;/layout&gt;
    &lt;/appender&gt;
    &lt;logger name=&quot;NHibernate.SQL&quot;&gt;
      &lt;level value=&quot;ALL&quot;/&gt;
      &lt;appender-ref ref=&quot;Debugger&quot;/&gt;
    &lt;/logger&gt;
  &lt;/log4net&gt;
&lt;/configuration&gt;</pre>

<p>Here’s the code for BaseFixture.</p>

<pre class="brush:vbnet">Public MustInherit Class BaseFixture

    Protected Shared ReadOnly Log As log4net.ILog = GetLogger()

    Private Shared Function GetLogger() As log4net.ILog
        log4net.Config.XmlConfigurator.Configure()
        Return log4net.LogManager.GetLogger(GetType(BaseFixture))
    End Function

End Class</pre>

<p>We’re calling log4net.Config,XmlConfiguration.Configure() just once. This loads the logging configuration from the app.config, which wires up log4net with Console.Out through the ConsoleAppender. With the example configuration, we'll get to see the SQL NHibernate is executing.</p>

<p>If you want something a lot more powerful, check out Ayende’s <a href="http://nhprof.com/" target="_blank">NHProf</a>.</p>

<h3>Problem #1</h3>

<pre>NStackExample.Data.Tests.CourseMappingTests.CanCascadeOrphanDeleteFromCourseToSections:
NHibernate.TransientObjectException : object references an unsaved transient instance - save the transient instance before flushing. Type: NStackExample.Section, Entity: NStackExample.Section</pre>

<pre class="brush:vbnet">                Dim Course As New Course() With { _
                        .Subject = &quot;SUBJ&quot;, _
                        .CourseNumber = &quot;1234&quot;, _
                        .Title = &quot;Title&quot;, _
                        .Description = &quot;Description&quot;, _
                        .Hours = 3}

                Dim Section As New Section() With { _
                        .FacultyName = &quot;FacultyName&quot;, _
                        .RoomNumber = &quot;R1&quot;, _
                        .SectionNumber = &quot;1&quot;}

                Term.AddSection(Section)
                Course.AddSection(Section)

                Using Tran = Session.BeginTransaction()
                    ID = Session.Save(Course)
                    Session.Save(Section)
                    Tran.Commit() ' &lt;==== Exception here
                End Using
                Session.Clear()</pre>

<p>When a transaction is committed, the session is flushed to the database. That just means data changes are written to the database. This exception is telling us we’re trying to save an object, but it references another object that isn’t saved. We can infer that this means cascading is turned off for this relationship. When we go to this particular line in the code, we see that this transaction is committing a save (INSERT) of a new course, and that this course references a new section. If this were a TestCascadeSaveFromParentToChild test, we would adjust our mapping. In this case, we’re testing the delete-orphan functionality, not the cascade of inserts and updates. We’ll explicitly save the section in this transaction as well.</p>

<p>After making the change and re-running our tests, we see that the same test is still failing, although it got further.</p>

<pre class="brush:vbnet">                'Test removing
                Course.RemoveSection(Section)
                Using Tran = Session.BeginTransaction()
                    Session.Save(Course)
                    Tran.Commit() ' &lt;==== Exception here
                End Using
                Session.Clear()</pre>

<p>Now we're violating a unique constraint. This is because we've called Session.Save(Course) twice. Session.Save is for saving new objects only. Session.SaveOrUpdate or simply Session.Update should be used to save the course. Since neither of those return the identifier, we'll need to get that from our initial Save. We make those change, recompile, and test.</p>

<p>Next, we get this:</p>

<pre>NStackExample.Data.Tests.CourseMappingTests.CanCascadeOrphanDeleteFromCourseToSections:
NHibernate.Exceptions.GenericADOException : could not delete collection: [NStackExample.Course.Sections#912b489a-4d12-4bc9-9d68-9c6b0147b799][SQL: UPDATE &quot;Section&quot; SET Course_id = null WHERE Course_id = @p0]
  ----&gt; System.Data.SQLite.SQLiteException : Abort due to constraint violation
Section.Course_id may not be NULL</pre>

<p>This message is telling us that when we disassociated the course from the section, NHibernate tried to set the Section's Course_id to NULL. This violated a not-null constraint. More importantly, this violated our business rule. The section was orphaned and should have been deleted. To corrected it, we update our mappings. In our course mapping, we’ll add Cascade.AllDeleteOrphan() to the one-to-many sections relationship.</p>

<pre class="brush:vbnet">        HasMany(Function(x As Course) x.Sections) _
            .AsSet() _
            .WithForeignKeyConstraintName(&quot;CourseSections&quot;) _
            .Cascade.AllDeleteOrphan()</pre>

<p>After a compile and retest, we get this:</p>

<pre>NStackExample.Data.Tests.CourseMappingTests.CanCascadeOrphanDeleteFromCourseToSections:
NHibernate.PropertyValueException : not-null property references a null or transient valueNStackExample.Section.Course</pre>

<p>This error is strange. Basically, even though we’re going to delete the section now that it’s orphaned, NHibernate is complaining that we’ve set Section.Course = null / nothing. For now, simply to appease the marmot god, we’ll remove our not null constraint on Section.Course. If you turn on log4net NHibernate.SQL logging, you’ll see that this operation wouldn’t violate the NOT NULL database constraint. The orphaned row is being deleted. We’re only failing an internal NHibernate property check. I’m hoping for a better explanation from Tuna, one of the NHibernate gurus, who’s been extremely helpful with this series.</p>

<p>The second problem is basically a disconnect between relational database concepts and object relations. All one-to-many database relationships are bidirectional. The many-to-one is implied. In an object graph, we can have a reference from a parent to its children but not reference from the child back to the parent, or vice-versa. Object relationships are unidirectional. Even though it would indicate a bug in most circumstances, we still have to tell NHibernate which of our two unidirectional relationships is the “real” one that we want to persist to the database. The default is to use the one-to-many. This means that the relationship that is saved is based on membership in a course’s sections collection. We would rather have the relationship based on the many-to-one relationship: the Section’s Course property. To do this, we specify Inverse() in our mapping for Course.Sections. This tells NHibernate that the “other side” of the bidirectional relationship is the one we want to persist.</p>

<p>Bug solved. Onward! Wait. Compile it and rerun your tests. You may have unknowingly fixed other problems.</p>

<h3>Problem #2</h3>

<pre>NStackExample.Data.Tests.CourseMappingTests.CanCascadeSaveFromCourseToSections:
  Expected: &lt;nstackexample.section&gt;
  But was:  &lt;nstackexample.section&gt;</pre>

<p>This is another misleading issue. Our test is checking the equality of two sections.</p>

<p>Q: How did we define the equality of a section?</p>

<p>A: We didn’t, so Object.Equals is just looking to see if these two happen to be the same instance. Since one is rehydrated from the database, they aren’t. We’ll have to define our own equality check.</p>

<p>Q: How should we define equality?</p>

<p>A: If two instances represent the same section, they are equal.&#160; Wait. Why are we just talking about sections? Let’s expand that to cover all entities.</p>

<p>Q: Where can we put this rule?</p>

<p>A: We should override Equals In our base Entity class, so all entities can use it.</p>

<p>Q: How do we know if two instances represent the same entity?</p>

<p>A: The ID fields will be equal.</p>

<p>Q: What about when we haven’t persisted the object and don’t have an ID yet?</p>

<p>A: We’ll assume they’re not equal. If a specific class needs something more accurate, it can override Equals again.</p>

<p>Here’s the code:</p>

<pre class="brush:vbnet">    Public Overrides Function Equals(ByVal obj As Object) As Boolean
        Dim other As Entity = TryCast(obj, Entity)
        If other Is Nothing Then Return False
        Return ID.Equals(other.ID) AndAlso Not ID.Equals(Guid.Empty)
    End Function</pre>

<p>Let’s recompile and test again. Look at that! We have 6 out of 10 tests passing now.</p>

<h3>Problem #3</h3>

<pre>NStackExample.Data.Tests.SectionMappingTests.CanCascadeSaveFromSectionToStudentSections:
NHibernate.PropertyValueException : not-null property references a null or transient valueNStackExample.Student.MiddleName</pre>

<p>This particular error can be fixed in two ways. We have defined our Student mapping to not allow null middle names. Our test of the Sections cascade is failing because it doesn’t set a value in middle name. We can either change our test to put something, even an empty string in middle name, or we can change our mapping to allow nulls. I choose option #1. Changing our mapping to allow nulls could lead to NullReferenceExceptions. Let’s set MiddleName = String.Empty around line 83. After a compile and test, we get this error.</p>

<pre>NStackExample.Data.Tests.SectionMappingTests.CanCascadeSaveFromSectionToStudentSections:
NHibernate.TransientObjectException : object references an unsaved transient instance - save the transient instance before flushing. Type: NStackExample.StudentSection, Entity: NStackExample.StudentSection</pre>

<p>This error is saying that our cascade is failing. Why? Because we didn’t actually specify cascade on one of the one-to-many relationships pointing to&#160; StudentSection. Since we know both Sections and Students should cascade to StudentSection, go add Cascade.All to both. Add Inverse() while you’re there.</p>

<p>Compile and retest. Success.</p>

<h3>Problem #4</h3>

<pre>NStackExample.Data.Tests.StudentMappingTests.CanCascadeSaveFromStudentToStudentSection:
NHibernate.TransientObjectException : object references an unsaved transient instance - save the transient instance before flushing. Type: NStackExample.Student, Entity: NStackExample.Student</pre>

<p>This one is a bug in our test. If you look at what we're testing and what we're actually saving, you'll realize that we should be saving Student, not Section. Fix it and try again. Now we have the same MiddleName bug we had in problem #3. Fix it as well. Test again. Now we get a NullReferenceException. Why?</p>

<p>If you look at our test of the Student mapping, you’ll see that we’re not checking the correct results. This was most likely a sloppy cut-and-paste job in the middle of a conference call or some other distracting scenario. Swap in the correct expected results:</p>

<pre class="brush:vbnet">                'Check the results
                Using Tran = Session.BeginTransaction
                    Student = Session.Get(Of Student)(ID)

                    Assert.AreEqual(1, Student.StudentSections.Count)
                    Assert.AreEqual(Student.StudentSections(0), StudentSection)

                    Tran.Commit()
                End Using</pre>

<p>It works!</p>

<h3>Problem #5</h3>

<pre>NStackExample.Data.Tests.TermMappingTests.CanCascadeSaveFromTermToSections:
NHibernate.TransientObjectException : object references an unsaved transient instance - save the transient instance before flushing. Type: NStackExample.Section, Entity: NStackExample.Section</pre>

<p>This is the same as problem #3. Our cascade from term is not cascading the save down to the section. Go add Cascade,All()and Inverse() to Term.Sections.</p>

<h3>Problem #6</h3>

<pre>NStackExample.Data.Tests.TermMappingTests.CanSaveAndLoadTerm:
  Expected: &quot;Fall 2009&quot;
  But was:  null</pre>

<p>In this test, we see that we were expecting a value in the Name property of Term, but we got null / nothing. Whenever you see this, you should first check your mapping. In this case, you'll quickly discover that we didn't map that property. Go map it. Next, you'll discover a bug in our tests. We're comparing the wrong date. EndDate should be compared with December 1st, 2009.</p>

<h3>It works! </h3>

<p>That really wasn’t so terrible. It probably took more effort to read this post than it did to correct those bugs.</p>

<p>Oh yeah, and get some source control.</p>

<p><strike>Before I post the source code, I’ll be updating to Fluent NHibernate v1.0 RC and fixing some of the typos and reference problems you’ve commented about. With any luck, the corrected source code for this part, along with the next part will be out before the weekend is over. </strike></p>

<p>Edit: Download the entire solution in <a href="http://jasondentler.com/downloads/NStackExample.Part5.VBNET.Zip" target="_blank">VB</a> or <a href="http://jasondentler.com/downloads/NStackExample.Part5.CSharp.Zip" target="_blank">C#</a>. I’ve upgraded to Fluent NHibernate v1 RC and updated most of the other assemblies.</p>

<p>Jason 
  <br />- Glad to be moving on to Ninject soon.</p>
