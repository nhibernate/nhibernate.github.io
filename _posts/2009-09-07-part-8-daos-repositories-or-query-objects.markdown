---
layout: post
title: "Part 8: DAOs, Repositories, or Query Objects"
date: 2009-09-07 20:17:50 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/09/07/part-8-daos-repositories-or-query-objects.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Part 8 is about abstracting <a href="http://nhforge.org" target="_blank">NHibernate</a>. Catch up by reading <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">Part 1</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">Part 2</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-3/" target="_blank">Part 3</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-4/" target="_blank">Part 4</a>, <a href="http://jasondentler.com/blog/2009/08/part-5-fixing-the-broken-stuff/" target="_blank">Part 5</a>, <a href="http://jasondentler.com/blog/2009/08/part-6-ninject-and-mvc-or-how-to-be-a-web-ninja/" target="_blank">Part 6</a>, and <a href="http://jasondentler.com/blog/2009/08/part-7-nhibernate-and-ninject-for-asp-net-mvc/" target="_blank">Part 7</a>. </p>  <div><em><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" border="0" align="left" src="http://commons.wikimedia.org/w/thumb.php?f=Nuvola%20apps%20important%20yellow.svg&amp;width=200px" width="100" height="84" />Warning: This post will contain an extraordinary number of links. They will lead you to the opinions of very smart people™. Click them. Read them. Learn something new.</em></div>  <div>There is no one best practice. I know. I googled for it. It seems there are just as many patterns as there are anti-patterns. In fact, these days we’re not even clear <a href="http://msdn.microsoft.com/en-us/library/aa973811.aspx" target="_blank">which</a> is <a href="http://ayende.com/Blog/archive/2009/04/17/repository-is-the-new-singleton.aspx" target="_blank">which</a>. There are <a href="http://codebetter.com/blogs/gregyoung/archive/2009/04/23/repository-is-dead-long-live-repository.aspx" target="_blank">differing opinions</a> all <a href="http://www.udidahan.com/2007/03/28/query-objects-vs-methods-on-a-repository/" target="_blank">over</a> the <a href="http://geekswithblogs.net/Billy/archive/2006/02/15/69607.aspx" target="_blank">place</a>.</div>  <h3>What are my options?</h3>  <p><a href="http://martinfowler.com/eaaCatalog/repository.html" target="_blank">Repositories</a></p>  <ul>   <li><a href="http://twitter.com/sbohlen" target="_blank">Steve Bohlen</a> uses the repository pattern. </li>    <li><a href="http://twitter.com/jfroma" target="_blank">José Romaniello</a> <a href="http://jfromaniello.blogspot.com/2009/08/chinook-media-manager-core.html" target="_blank">uses repositories</a> in his Chinook Media Manager sample on NHForge.org </li>    <li><a href="http://twitter.com/ayende" target="_blank">Ayende</a> <a href="http://msdn.microsoft.com/en-us/library/aa973811.aspx" target="_blank">loved repositories in 2006</a>, but not anymore. </li> </ul>  <p><a href="http://java.sun.com/blueprints/corej2eepatterns/Patterns/DataAccessObject.html" target="_blank">Data Access Objects</a>:</p>  <ul>   <li><a href="http://fabiomaulo.blogspot.com/" target="_blank">Fabio Maulo</a> <a href="http://ayende.com/Blog/archive/2009/04/17/repository-is-the-new-singleton.aspx#30272" target="_blank">uses DAOs</a> with query objects. </li>    <li><a href="http://twitter.com/tehlike" target="_blank">Tuna Toksoz</a> uses DAOs with FindBy methods </li> </ul>  <p><a href="http://martinfowler.com/eaaCatalog/queryObject.html" target="_blank">Query objects</a>:</p>  <li>In early 2009, Ayende posted that he <a href="http://ayende.com/Blog/archive/2009/04/17/repository-is-the-new-singleton.aspx" target="_blank">no longer likes repositories,</a> and has switched to query objects which expose raw NHibernate&#160; ICriteria. </li>  <li><a href="http://twitter.com/udidahan" target="_blank">Udi Dahan</a> also prefers <a href="http://www.udidahan.com/2007/03/28/query-objects-vs-methods-on-a-repository/" target="_blank">query objects</a>     <p>One note about all of this: Repositories and DAOs can both be used with query objects or simple FindBy methods. Query objects can also be used on their own.</p>    <h3>What’s the score? </h3>    <p>The experts don’t agree, so use whatever you think will work best for your application and your team. By the way, if you’re not following all of these people on twitter, go follow them now.</p>    <p>If you’re looking for a good NHibernate repository sample, check out <a href="http://nhforge.org/wikis/howtonh/your-first-nhibernate-based-application.aspx" target="_blank">Your First NHibernate based application</a> by Gabriel Schenker on the NHForge wiki, or José’s Chinook WPF app. </p>    <p>In this sample application, we’re going to use Data Access Objects. The pattern is simple and well known. This application is small and we won’t have many queries, so we’ll use DAOs with FindBy methods. In a large project, such as an ERP, I would use query objects. </p>    <h3>Splitting the CRUD</h3>    <p>CRUD stands for create, read/retrieve, update, and delete/destroy. which correspond to SQL INSERT, SELECT, UPDATE, and DELETE respectively. </p>    <p>Suppose we’re tracking down an issue in our system where the customer’s middle name was being erased from the database. You start with the most likely locations such as the round trip through the customer update view. No luck. You’ll have to dig in deeper.</p>    <p>We’re using constructor dependency injection throughout our application. Our DAO is defined by the interface IDAO&lt;T&gt;. If you saw some object with a dependency of IDAO&lt;Customer&gt;, you would assume that it performs some database action on customer, so it would be a candidate for deeper investigation. Of course, without diving in to the code, you wouldn’t know what it actually does to customer. </p>    <p>As it turns out 95% of the uses of IDAO&lt;Customer&gt; only display customer data. They don’t actually change anything. You just wasted a LOT of time digging through code that couldn’t possibly cause your bug.</p>    <p>Now suppose you had split your IDAO interface to allow more fine-grained dependencies. Instead of IDAO&lt;T&gt;, you now have ICreate&lt;T&gt;, IRead&lt;T&gt;, IUpdate&lt;T&gt;, and IDelete&lt;T&gt;. When searching for a bug like the one I described, you only need to search through classes with dependencies on IUpdate&lt;Customer&gt; and possibly ICreate&lt;Customer&gt;. </p>    <p>We’re tracking which entity instances are transient (new, not saved) and which ones are already persisted (saved to the database) by the ID property. If the ID is equal to Guid.Empty, the instance is transient. If the ID has any other value, it’s persistent. Since we know that handy bit of information, we don’t really need separate interfaces for create and update operations. We can combine them in to one called ISave&lt;T&gt;. We now have IRead&lt;T&gt;, ISave&lt;T&gt;, and IDelete&lt;T&gt;. </p>    <p>Even though we’ve split our interface up by operation, we’re still only going to have one DAO implementation. In the <a href="http://ninject.org/" target="_blank">Ninject</a> module, we’ll bind each of our three interfaces to the DAO implementation.</p>    <p>Every entity has the same basic CUD, but what about entity-specific queries? In these cases, we’ll create entity-specific interfaces such as IReadCustomer. This means you could have up to four IoC bindings for each entity. </p>    <p>Splitting the CRUD operations in to separate interfaces has one added benefit. In our case, we don’t want to allow certain (most) entities to be deleted. In these cases, your entity-specific DAO shouldn’t implement IDelete. For this reason, we won’t implement deletes in our generic base DAO.</p>    <h3>Show me some code already!</h3>    <p>We put our interfaces in the data namespace of the core project and our implementations in the data project.</p>    <pre class="brush:vbnet">Namespace Data

    Public Interface IRead(Of TEntity As Entity)

        Function GetByID(ByVal ID As Guid) As TEntity

    End Interface

End Namespace

Namespace Data

    Public Interface ISave(Of TEntity As Entity)

        Function Save(ByVal Entity As TEntity) As TEntity

    End Interface

End Namespace

Namespace Data

    Public Interface IDelete(Of TEntity As Entity)

        Sub Delete(ByVal Entity As TEntity)

    End Interface

End Namespace

Namespace Data

    Public Interface IReadStudent
        Inherits IRead(Of Student)

        Function FindByStudentID(ByVal StudentID As String) As Student
        Function FindByName(ByVal LikeFirstName As String, ByVal LikeLastName As String) As IEnumerable(Of Student)

    End Interface

End Namespace

Imports NHibernate

Public Class GenericDAOImpl(Of TEntity As Entity)
    Implements IRead(Of TEntity)
    Implements ISave(Of TEntity)

    Public Sub New(ByVal Session As ISession)
        m_session = Session
    End Sub

    Protected ReadOnly m_Session As ISession

    Public Function GetByID(ByVal ID As System.Guid) As TEntity Implements IRead(Of TEntity).GetByID
        If m_Session.Transaction Is Nothing Then
            Dim RetVal As TEntity
            Using Tran = m_Session.BeginTransaction
                RetVal = m_Session.Get(Of TEntity)(ID)
                Tran.Commit()
                Return RetVal
            End Using
        Else
            Return m_Session.Get(Of TEntity)(ID)
        End If
    End Function

    Public Function Save(ByVal Entity As TEntity) As TEntity Implements ISave(Of TEntity).Save
        If m_Session.Transaction Is Nothing Then
            Using Tran = m_Session.BeginTransaction
                m_Session.SaveOrUpdate(Entity)
                Tran.Commit()
            End Using
        Else
            m_Session.SaveOrUpdate(Entity)
        End If
        Return Entity
    End Function

End Class

Imports NHibernate
Imports NHibernate.Criterion

Public Class StudentDaoImpl
    Inherits GenericDAOImpl(Of Student)
    Implements IReadStudent

    Public Sub New(ByVal Session As ISession)
        MyBase.New(Session)
    End Sub

    Public Function FindByName(ByVal LikeFirstName As String, ByVal LikeLastName As String) As System.Collections.Generic.IEnumerable(Of Student) Implements IReadStudent.FindByName
        Dim crit As ICriteria = m_Session.CreateCriteria(Of Student) _
            .Add(Expression.Like(&quot;FirstName&quot;, LikeFirstName)) _
            .Add(Expression.Like(&quot;LastName&quot;, LikeLastName)) _
            .SetMaxResults(101)
        If m_Session.Transaction Is Nothing Then
            Using Tran = m_Session.BeginTransaction()
                Dim RetVal = crit.List.Cast(Of Student)()
                Tran.Commit()
                Return RetVal
            End Using
        Else
            Return crit.List.Cast(Of Student)()
        End If
    End Function

    Public Function FindByStudentID(ByVal StudentID As String) As Student Implements IReadStudent.FindByStudentID
        Dim Crit = m_Session.CreateCriteria(Of Student) _
            .Add(Expression.Eq(&quot;StudentID&quot;, StudentID))
        If m_Session.Transaction Is Nothing Then
            Using Tran = m_Session.BeginTransaction
                Dim RetVal = Crit.UniqueResult(Of Student)()
                Tran.Commit()
                Return RetVal
            End Using
        Else
            Return Crit.UniqueResult(Of Student)()
        End If
    End Function

End Class</pre>

  <pre class="brush:csharp">using System;

namespace NStackExample.Data
{
    public interface IRead&lt;TEntity&gt; where TEntity : Entity 
    {

        TEntity GetById(Guid ID);

    }
}

namespace NStackExample.Data 
{
    public interface ISave&lt;TEntity&gt; where TEntity : Entity 
    {

        TEntity Save(TEntity entity);

    }
}

namespace NStackExample.Data
{
    public interface IDelete&lt;TEntity&gt; where TEntity:Entity 
    {

        void Delete(TEntity entity);

    }
}

using System.Collections.Generic;

namespace NStackExample.Data
{
    public interface IReadStudent : IRead&lt;Student&gt;
    {

        Student FindByStudentID(string StudentID);
        IEnumerable&lt;Student&gt; FindByName(string LikeFirstName, string LikeLastName);

    }
}

using NHibernate;

namespace NStackExample.Data
{

    public class GenericDAOImpl&lt;TEntity&gt; : IRead&lt;TEntity&gt;, ISave&lt;TEntity&gt; where TEntity : Entity
    {

        public GenericDAOImpl(ISession Session)
        {
            m_Session = Session;
        }

        protected readonly ISession m_Session;

        public TEntity GetByID(System.Guid ID)
        {
            if (m_Session.Transaction == null)
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
            }
        }

        public TEntity Save(TEntity Entity)
        {
            if (m_Session.Transaction == null)
            {
                using (var Tran = m_Session.BeginTransaction())
                {
                    m_Session.SaveOrUpdate(Entity);
                    Tran.Commit();
                }
            }
            else
            {
                m_Session.SaveOrUpdate(Entity);
            }
            return Entity;
        }

    }

}

using NHibernate;
using NHibernate.Criterion;
using System.Collections.Generic;
using System.Linq;

namespace NStackExample.Data
{
    public class StudentDAOImpl : GenericDAOImpl&lt;Student&gt;, IReadStudent
    {

        public StudentDAOImpl(ISession Session) : base(Session) { }

        public System.Collections.Generic.IEnumerable&lt;Student&gt; FindByName(string LikeFirstName, string LikeLastName)
        {
            ICriteria crit = m_Session.CreateCriteria&lt;Student&gt;()
                .Add(Expression.Like(&quot;FirstName&quot;, LikeFirstName))
                .Add(Expression.Like(&quot;LastName&quot;, LikeLastName))
                .SetMaxResults(101);
            if (m_Session.Transaction == null)
            {
                using (var Tran = m_Session.BeginTransaction())
                {
                    var RetVal = crit.List().Cast&lt;Student&gt;();
                    Tran.Commit();
                    return RetVal;
                }
            }
            else
            {
                return crit.List().Cast&lt;Student&gt;();
            }
        }

        public Student FindByStudentID(string StudentID)
        {
            var Crit = m_Session.CreateCriteria&lt;Student&gt;()
                .Add(Expression.Eq(&quot;StudentID&quot;, StudentID));
            if (m_Session.Transaction == null)
            {
                using (var Tran = m_Session.BeginTransaction())
                {
                    var RetVal = Crit.UniqueResult&lt;Student&gt;();
                    Tran.Commit();
                    return RetVal;
                }
            }
            else
            {
                return Crit.UniqueResult&lt;Student&gt;();
            }
        }


    }
}</pre>

  <p></p>

  <h3>Other changes</h3>

  <p>I’ve cleaned out the course and student DAO junk from part 7. These were just used to illustrate session-per-request. </p>

  <p>The fluent mapping classes have been moved in to a mapping folder.</p>

  <p></p>

  <p>That’s it for part 8. Don’t forget to write your tests for the queries. </p>

  <p>Jason 
    <br />- IBlog.Post(Part8) operation completed. Executing IWatchTV.Watch(Timespan.FromHours(1))</p>

  <p></p>

  <p></p>

  <p></p>
</li>
