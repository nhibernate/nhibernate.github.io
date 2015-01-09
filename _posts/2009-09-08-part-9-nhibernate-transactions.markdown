---
layout: post
title: "Part 9: NHibernate transactions"
date: 2009-09-08 13:26:05 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2009/09/08/part-9-nhibernate-transactions.aspx/", "/blogs/nhibernate/archive/2009/09/08/part-9-nhibernate-transactions.html"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>In this part, we’re going to wrap our <a href="http://nhforge.org" target="_blank">NHibernate</a> transactions and create a factory for them so we can use them in higher layers without referencing NHibernate all the way up.</p>  <p>If you’re new to the series, you can read <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">Part 1</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">Part 2</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-3/" target="_blank">Part 3</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-4/" target="_blank">Part 4</a>, <a href="http://jasondentler.com/blog/2009/08/part-5-fixing-the-broken-stuff/" target="_blank">Part 5</a>, <a href="http://jasondentler.com/blog/2009/08/part-6-ninject-and-mvc-or-how-to-be-a-web-ninja/" target="_blank">Part 6</a>, <a href="http://jasondentler.com/blog/2009/08/part-7-nhibernate-and-ninject-for-asp-net-mvc/" target="_blank">Part 7</a>, and <a href="http://jasondentler.com/blog/2009/09/part-8-daos-repositories-or-query-objects" target="_blank">Part 8</a> to catch up.</p>  <p>You may have noticed in part 8 that in each DAO method, if we didn’t already have an explicit transaction, I created one around each database interaction. My reason for this is explained in Ayende’s NHibernate Profiler alert “<a href="http://nhprof.com/Learn/Alert?name=DoNotUseImplicitTransactions" target="_blank">Use of implicit transactions is discouraged</a>.” This works great for simple DB interaction, but what about the more complex scenarios? </p>  <p>This is where we get to talk about this great thing called a business transaction. So once again, I’m going to parade out my experts. Actually, this time it’s only Udi Dahan. There are two key points he’s written about on his blog. </p>  <ol>   <li><a href="http://www.udidahan.com/2009/01/24/ddd-many-to-many-object-relational-mapping/" target="_blank">Partial failures can be good</a>. The programmer in all of us sees that and screams <a href="http://en.wikipedia.org/wiki/ACID" target="_blank">atomicity</a>. Transactions&#160; should be all-or-nothing. Anything less is just wrong. Right? In real life, there are instances where we allow, and even prefer partial failures of business transactions. Udi gives us a great example. Would you leave the grocery store empty handed simply because they were out of one item on your list? Probably not. When you’re gathering requirements, be sure to ask questions about the proper way to fail. “Roll it all back” isn’t the only option. </li>    <li><a href="http://www.udidahan.com/2007/01/22/realistic-concurrency/" target="_blank">Realistic Concurrency</a> – The entire post is worth reading, but Udi makes one point I want to touch on specifically. When performing an operation for the user, you should get the current state, validate, and then perform the task all within the business transaction. </li> </ol>  <p>Let’s use our college application as an example. We have a user story / use case / requirement / story card / whatever to allow students to register for classes, provided those classes aren’t full. If you’ve ever worked at or attended a college or university where certain classes always have more demand than available seats, you are no doubt aware of how quickly those classes will fill up. In fact, the best sections (best professors and best times) can fill up just minutes after registration is opened. It’s very possible that dozens of potential students could access the section when there is only a few seats left. Since the enrollment in a particular section (the current state) changes so rapidly, you must obtain a lock, refresh your enrollment numbers and make sure there is room (revalidate) before actually enrolling that student. If more than one registration request is received, they should be performed serially. </p>  <p>The process is:</p>  <ol>   <li>Open a transaction at the proper <a href="http://en.wikipedia.org/wiki/Isolation_(database_systems)" target="_blank">isolation level</a>. Consult your nearest DBA, as isolation levels are outside the scope of this series. </li>    <li>Refresh – Get the current state of the entity </li>    <li>(Re)Validate – Be sure the business transaction is still valid for the current state </li>    <li>Execute – Perform the insert / update / delete </li>    <li>Commit the transaction </li> </ol>  <p>Now that we’ve covered business transactions, let’s get set up to use them in our business logic. We shouldn’t have NHibernate types floating around at that level, so we’ll wrap them. Once again, the interfaces go in the Data namespace of the core project and the implementations go in the Data project.</p>  <pre class="brush:vbnet">Imports System.Data

Namespace Data

    Public Interface ITransactionFactory

        Function BeginTransaction() As ITransaction
        Function BeginTransaction(ByVal IsolationLevel As IsolationLevel) As ITransaction

    End Interface

End Namespace

Namespace Data

    Public Interface ITransaction
        Inherits IDisposable

        Sub Commit()
        Sub Rollback()

    End Interface

End Namespace

Imports NHibernate

Public Class TransactionFactoryImpl
    Implements ITransactionFactory

    Public Sub New(ByVal Session As ISession)
        m_Session = Session
    End Sub

    Protected ReadOnly m_Session As ISession

    Public Function BeginTransaction() As ITransaction Implements ITransactionFactory.BeginTransaction
        Return New TransactionWrapper(m_Session.BeginTransaction)
    End Function

    Public Function BeginTransaction(ByVal IsolationLevel As System.Data.IsolationLevel) As ITransaction Implements ITransactionFactory.BeginTransaction
        Return New TransactionWrapper(m_Session.BeginTransaction(IsolationLevel))
    End Function

End Class


Imports NHibernate

Public Class TransactionWrapper
    Implements ITransaction

    Public Sub New(ByVal Transaction As NHibernate.ITransaction)
        m_Transaction = Transaction
    End Sub

    Protected ReadOnly m_Transaction As NHibernate.ITransaction

    Public Sub Commit() Implements ITransaction.Commit
        m_Transaction.Commit()
    End Sub

    Public Sub Rollback() Implements ITransaction.Rollback
        m_Transaction.Rollback()
    End Sub

    Private disposedValue As Boolean = False        ' To detect redundant calls

    ' IDisposable
    Protected Overridable Sub Dispose(ByVal disposing As Boolean)
        If Not Me.disposedValue Then
            If disposing Then
                ' TODO: free other state (managed objects).
                m_Transaction.Dispose()
            End If

            ' TODO: free your own state (unmanaged objects).
            ' TODO: set large fields to null.
        End If
        Me.disposedValue = True
    End Sub

#Region &quot; IDisposable Support &quot;
    ' This code added by Visual Basic to correctly implement the disposable pattern.
    Public Sub Dispose() Implements IDisposable.Dispose
        ' Do not change this code.  Put cleanup code in Dispose(ByVal disposing As Boolean) above.
        Dispose(True)
        GC.SuppressFinalize(Me)
    End Sub
#End Region

End Class</pre>

<pre class="brush:csharp">using System.Data;

namespace NStackExample.Data
{
    public interface ITransactionFactory
    {

        ITransaction BeginTransaction();
        ITransaction BeginTransaction(IsolationLevel isolationLevel);

    }
}

using System;

namespace NStackExample.Data
{
    public interface ITransaction : IDisposable 
    {
        void Commit();
        void Rollback();
    }
}

using System.Data;
using NHibernate;

namespace NStackExample.Data
{
    public class TransactionFactoryImpl : ITransactionFactory 
    {

        public TransactionFactoryImpl(ISession Session)
        {
            m_Session = Session;
        }
        
        protected readonly ISession m_Session;

        #region ITransactionFactory Members

        public ITransaction BeginTransaction()
        {
            return new TransactionWrapper(m_Session.BeginTransaction());
        }

        public ITransaction BeginTransaction(IsolationLevel isolationLevel)
        {
            return new TransactionWrapper(m_Session.BeginTransaction(isolationLevel));
        }

        #endregion
    }
}


using System;
using NHibernate;

namespace NStackExample.Data
{
    public class TransactionWrapper : ITransaction
    {

        public TransactionWrapper(NHibernate.ITransaction Transaction)
        {
            m_Transaction = Transaction;
        }

        protected readonly NHibernate.ITransaction m_Transaction;

        #region ITransaction Members

        void ITransaction.Commit()
        {
            m_Transaction.Commit();
        }

        void ITransaction.Rollback()
        {
            m_Transaction.Rollback();
        }

        private bool disposedValue = false;

        protected override void Dispose(bool Disposing)
        {
            if (!this.disposedValue)
            {
                m_Transaction.Dispose();
            }
            this.disposedValue = true;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        #endregion
    }
}</pre>

<p>You may be interested to know that the NHibernate ITransaction will perform an implicit rollback when it is disposed, unless an explicit call to Commit or Rollback has already occurred. To implement this behavior, we implement IDisposable in our transaction wrapper and chain our wrapper’s Dispose to NHibernate.ITransaction’s Dispose. This implicit rollback can indicate a missing call to Commit, so it <a href="http://nhprof.com/Learn/Alert?name=AvoidImplicitRollback" target="_blank">generates an alert in NHibernate Profiler</a>. If you intend to rollback, do it explicitly. Your code will be easier to understand.</p>

<p>That’s it for part 9.</p>

<p>Jason 
  <br />- Off to mow the lawn.</p>
