---
layout: post
title: "Part 10: Testing and Refactoring"
date: 2009-09-20 19:07:41 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/09/20/part-10-testing-and-refactoring.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p><strike>Today’s post will be short</strike>. I’m going to cover the basics of testing with Rhino Mocks and do some refactoring in the DAOs. </p>  <p>I’m not an expert. This is just how I do things. If you have a better way, do it your way. Better yet, tell me about it so I can improve the way I work as well.</p>  <h3>Testing Terminology</h3>  <p>In recent years, testing vocabulary has exploded. There are mocks and stubs and fakes and unit tests and integration tests and acceptance tests and all sorts of jargon. You may be thinking “who cares?” This jargon is only important when code needs to communicate its intent to humans, right?. The compiler doesn’t care what terminology we use. Well, sorry. Code is written for humans, not compilers, so programming jargon is a prerequisite.</p>  <h4>Test Doubles</h4>  <p>So, let’s go over some common terms. I’m going to lift these definitions straight from Marton Fowler’s <a href="http://martinfowler.com/articles/mocksArentStubs.html#TheDifferenceBetweenMocksAndStubs" target="_blank">Mocks Aren’t Stubs</a>. Test Double is a “generic term for any kind of pretend object used in place of a real object for testing purposes.” That’s pretty straight forward. Test doubles come in four types:</p>  <blockquote>   <ul>     <li><b>Dummy</b> objects are passed around but never actually used. Usually they are just used to fill parameter lists. </li>      <li><b>Fake</b> objects actually have working implementations, but usually take some shortcut which makes them not suitable for production (an <a href="http://www.martinfowler.com/bliki/InMemoryTestDatabase.html">in memory database</a> is a good example). </li>      <li><b>Stubs</b> provide canned answers to calls made during the test, usually not responding at all to anything outside what's programmed in for the test. Stubs may also record information about calls, such as an email gateway stub that remembers the messages it 'sent', or maybe only how many messages it 'sent'. </li>      <li><b>Mocks</b> are what we are talking about here: objects pre-programmed with expectations which form a specification of the calls they are expected to receive. </li>   </ul> </blockquote>  <p>Hi. Still with me? Good. </p>  <p>Mocks are significant. They are part of the “proof” of the test. The other three amount to plumbing. Now, you may be asking your self why we even need test doubles. Why can’t we just run our production code and inspect the output? <a href="http://martinfowler.com/articles/mocksArentStubs.html#ClassicalAndMockistTesting" target="_blank">Fowler’s article has several sections</a> about the differences and pros and cons of classical testing (using objects from the real code) vs. mockist testing (creating doubles for everything except what you’re testing).</p>  <p>Even in classical testing, you sometimes have to swap in a test double for objects that lead to permanent side effects or operate too slowly. In mockist testing, you swap in test doubles for everything that you’re not explicitly testing. Either way, you need to know how to create and use test doubles.</p>  <p><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" border="0" src="http://ayende.com/Blog/images/ayende_com/Blog/WindowsLiveWriter/NewRhinoMocksLogo_ECFE/rhinomocks-120x90.png" /></p>  <p>We’re going to use <a href="http://ayende.com/projects/rhino-mocks.aspx" target="_blank">Rhino Mocks</a>, a fluent framework for creating stubs and mocks. I don’t know if it’s the best, but if Ayende wrote it, you can bet it’s pretty darn awesome. Plus, the fluent syntax works OK in VB.NET, which is rare. </p>  <h3>Writing the Test</h3>  <p>Suppose we had a standard GetByID function on our DAO (because we do) containing some code like this (because it does). How would we test that the function actually did what it claimed? </p>  <pre class="brush:vbnet">        If m_Session.Transaction Is Nothing OrElse Not m_Session.Transaction.IsActive Then
            Dim RetVal As TEntity
            Using Tran = m_Session.BeginTransaction
                RetVal = m_Session.Get(Of TEntity)(ID)
                Tran.Commit()
                Return RetVal
            End Using
        Else
            Return m_Session.Get(Of TEntity)(ID)
        End If</pre>

<pre class="brush:csharp">            if (null == m_Session.Transaction || !m_Session.Transaction.IsActive)
            {
                TEntity retval;
                using (var Tran = m_Session.BeginTransaction())
                {
                    retval = m_Session.Get&lt;TEntity&gt;(ID);
                    Tran.Commit();
                    return retval;
                }
            }
            else
            {
                return m_Session.Get&lt;TEntity&gt;(ID);
            }</pre>

<p>Because I’m not an expert, I won’t try to explain the computer science of testing. I can tell you that if we ignore possible branches inside NHibernate objects, there are two possible paths through our function (the first if we don’t have an existing explicit transaction, and the second if we do), giving us a <a href="http://en.wikipedia.org/wiki/Cyclomatic_complexity" target="_blank">cyclomatic complexity</a> of 2. This means that we need two unit tests to achieve 100% code coverage. 100% code coverage doesn’t mean perfect code, but it helps.</p>

<p>I prefer the Record / Playback style of testing. In this style, you start by setting up your expectations within a record section – which mock methods will be called, how many times they’ll be called, in what order they’ll be called, and what their return values should be. Then, in the playback section, you perform the actual action. In this case, we’ll create an instance of our DAO and call its GetByID method. Finally, you verify that the expectations of your mock were met, as well as any other assertions you may need to prove.</p>

<p>Edit: The alternative to Record / Playback is Arrange / Act / Assert. If you don’t know the difference, <a href="http://rasmuskl.dk/post/Why-AAA-style-mocking-is-better-than-Record-Playback.aspx" target="_blank">here’s a good article</a> Jose sent me. Rhino Mocks supports both styles. I still prefer Record / Playback, probably just because I’m used to it.</p>

<p>Here’s what a test of GetByID with a pre-existing transaction would look like:</p>

<pre class="brush:vbnet">    &lt;Test()&gt; _
    Public Sub GetByIDTest()
        Dim mocks As New MockRepository()
        Dim session As NHibernate.ISession = mocks.StrictMock(Of NHibernate.ISession)()
        Dim transaction As NHibernate.ITransaction = mocks.Stub(Of NHibernate.ITransaction)()
        Dim expected As Student = mocks.Stub(Of Student)()
        Dim actual As Student
        Using mocks.Record()
            Rhino.Mocks.Expect.Call(session.Transaction).Return(transaction).Repeat.Any()
            Rhino.Mocks.Expect.Call(transaction.IsActive).Return(True)
            Rhino.Mocks.Expect.Call(session.Get(Of Student)(Guid.Empty)).Return(expected)
        End Using

        Using mocks.Playback()
            Dim StudentDao As IReadStudent = New StudentDaoImpl(session)
            actual = StudentDao.GetByID(Guid.Empty)
        End Using
        mocks.VerifyAll()
        Assert.IsNotNull(actual, &quot;null entity returned&quot;)
        Assert.AreSame(expected, actual, &quot;wrong entity returned&quot;)
    End Sub</pre>

<pre class="brush:csharp">        [Test]
        public void GetByIDTest()
        {
            MockRepository mocks = new MockRepository();
            NHibernate.ISession session = mocks.StrictMock&lt;NHibernate.ISession&gt;();
            NHibernate.ITransaction transaction = mocks.Stub&lt;NHibernate.ITransaction&gt;();
            Student expected = new Student();
            Student actual;
            using (mocks.Record())
            {
                Rhino.Mocks.Expect.Call(session.Transaction)
                    .Return(transaction)
                    .Repeat.Any();
                Rhino.Mocks.Expect.Call(transaction.IsActive)
                    .Return(true);
                Rhino.Mocks.Expect.Call(session.Get&lt;Student&gt;(Guid.Empty))
                    .Return(expected);
            }
            using (mocks.Playback())
            {
                IReadStudent StudentDao = new StudentDAOImpl(session);
                actual = StudentDao.GetById(Guid.Empty);
            }
            mocks.VerifyAll();
            Assert.IsNotNull(actual);
            Assert.AreSame(expected,actual);
        }</pre>

<p>We start by creating a MockRepository. This is the factory for all of our mocks and stubs, controls our record and playback blocks, and verifies that all the mock expectations have been met.</p>

<p>Next, we create a mock of the <a href="http://nhforge.org" target="_blank">NHIbernate</a> session and a stub of an NHibernate transaction. We create a mock because we want to make sure our DAO calls m_Session.Get&lt;&gt;. We also create a double for our return value called expected. We’ll compare it to the actual return value. </p>

<p>Now that we have our doubles, we set up our expectations. We are testing the path of the pre-existing transaction. Session.transaction will return our transaction stub. Since this is a mock, not a stub, the default is to assert that it is called exactly once. Since we’re not interested in this part, we specify that it can be called <strong>any</strong> number of times. We also specify that a call to transaction.IsActive should return true. Finally, we specify that our DAO will call session.Get&lt;&gt; exactly once, and that our mock session should return our expected student.</p>

<p>Next, we start our playback block and perform the action. We create an instance of our DAO, passing in the mock session we wired up in our record block, and we call GetByID. </p>

<p>Finally, we verify that our DAO interacted with the stub as expected. We also assert that the actual instance returned during our test is the same as our expected instance.</p>

<p>This covers the first test. What about the second one? Well, the test would be identical except for your expectations. We would setup our transaction stub so that transaction.IsActive returned false. We would also expect our DAO to call session.BeginTransaction(). </p>

<p>Now, I’m lazy and we’ve already done things backwards by writing our code before our tests, so let’s continue being lazy. I don’t want to write two tests for each DAO method just because of some transaction handling code, which by the way, is repeated all over the place. Not good. Let’s refactor things a bit.</p>

<h3>Refactored Transaction Handling</h3>

<p>In all of the DAO methods, I’ve made the choice to ensure we have an explicit transaction before interacting with the database. In previous versions, each method is nearly identical to the code we tested above above.</p>

<p>In all of this, the only unique code is the call to m_Session.Get(). The rest of the code is just uninteresting transaction handling, and this uninteresting plumbing code is repeated in every method of our DAO. Let’s pull it out in to its own function.</p>

<pre class="brush:vbnet">    Protected Function WrapInTransaction(ByVal F As Func(Of TEntity)) As TEntity
        Return WrapInTransaction(Of TEntity)(F)
    End Function

    Protected Function WrapInTransaction(Of TResult)(ByVal F As Func(Of TResult)) As TResult
        If m_Session.Transaction Is Nothing OrElse _
            m_Session.Transaction.IsActive = False Then
            Using Tran = m_Session.BeginTransaction
                Dim RetVal As TResult = F.Invoke()
                Tran.Commit()
                Return RetVal
            End Using
        Else
            Return F.Invoke()
        End If
    End Function</pre>

<pre class="brush:csharp">        protected TEntity WrapInTransaction(System.Func&lt;TEntity&gt; F)
        {
            return WrapInTransaction&lt;TEntity&gt;(F);
        }

        protected TResult WrapInTransaction&lt;TResult&gt;(System.Func&lt;TResult&gt; F)
        {
            if (null == m_Session.Transaction || !m_Session.Transaction.IsActive)
            {
                using (NHibernate.ITransaction Tran = m_Session.BeginTransaction())
                {
                    TResult RetVal = F.Invoke();
                    Tran.Commit();
                    return RetVal;
                }
            }
            else
            {
                return F.Invoke();
            }
        }</pre>
Now we can pass in the small-but-interesting bit of code as a parameter to the WrapInTransaction method. This lets us simplify our methods down to this: 

<pre class="brush:vbnet">    Public Function GetByID(ByVal ID As System.Guid) As TEntity Implements IRead(Of TEntity).GetByID
        Return WrapInTransaction(Function() m_Session.Get(Of TEntity)(ID))
    End Function</pre>

<pre class="brush:csharp">        public TEntity GetById(System.Guid ID)
        {
            return WrapInTransaction(() =&gt; m_Session.Get&lt;TEntity&gt;(ID));
        }</pre>

<p>It’s shorter. Some might argue that it’s not as readable since it uses lambda syntax. In this case, I think DRY (don’t repeat yourself) is more important. To be honest, I’m not sure if this cuts the cyclomatic complexity of our methods in half, but It certainly lets us write about 1/2 as many tests and still have 100% coverage. We just need to write our already-have-a-transaction and wrap-in-transaction tests once period, instead of once per method.</p>

<p>If you’re working in C#, you can create another overload that accepts a System.Action (System.Func but returning void). In Visual Basic.NET, this would be a Sub, but unfortunately, there’s no lambda syntax for calling a Sub in VB.NET. To get around this, I’ve updated our Save method to this:</p>

<pre class="brush:vbnet">    Public Function Save(ByVal Entity As TEntity) As TEntity Implements ISave(Of TEntity).Save
        Return WrapInTransaction(Function() SaveOrUpdate(Entity))
    End Function

    Private Function SaveOrUpdate(ByVal Entity As TEntity) As TEntity
        m_Session.SaveOrUpdate(Entity)
        Return Entity
    End Function</pre>
Since we're returning a value, we can use our existing WrapInTransaction(Func&lt;&gt;) method. The download includes tests for all of our DAO methods, including WrapInTransaction. 

<p>That’s it for part 10. For homework, write the tests for our StudentDaoImpl class. Hints: Use a fake, verify that it returns what it should, and verify that it doesn’t return what it shouldn’t.</p>

<p>I’ve changed the SQLiteDatabaseScope to match my previous post, and pulled it in to its own project. </p>

<p>Download the entire solution in <a href="http://jasondentler.com/downloads/NStackExample.Part10.VBNET.zip" target="_blank">VB.NET</a> or <a href="http://jasondentler.com/downloads/NStackExample.Part10.CSharp.zip" target="_blank">C#</a>.</p>

<p>In part 11, we’ll dive in to validation.</p>

<p>Jason</p>
