---
layout: post
title: "Simple CQRS + NHibernate event store"
date: 2010-10-10 22:10:00 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2010/10/10/simple-cqrs-nhibernate-event-store.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>(From my personal blog @ <a href="http://jasondentler.com">http://jasondentler.com</a>)</p>
<p>I had hoped to include a CQRS-related recipe in the <a target="_blank" href="https://www.packtpub.com/nhibernate-3-0-cookbook/book">Data Access Layer chapter of my book</a>. Of course, not having any real world CQRS experience myself, I couldn't offer any authoritative guidance. Now that I have some free time, I'm determined to remedy that situation. </p>
<p>I won't go in to the specifics of CQRS or even event sourcing. The internet already has plenty of people explaining it better than I ever could. If you're like me, you need code to learn. You need to hack away at something for a few days before you really get it. </p>
<p>In the spirit of "learning in the open," I'm sharing this weekend's effort to fix up <a target="_blank" href="http://github.com/gregoryyoung/m-r">Greg Young's Simple CQRS example</a>. His solution is called "SimplestPossibleThing.sln" which describes it perfectly. It's a great learning tool, but it's all built on top of in-memory collections, not persistent storage. </p>
<p>In this post, I'm going to make his event store persistent. With some luck, I'll move on to the read model and bring it full circle in a later post. </p>
<p> Before we dive in, take a look at <a target="_blank" href="http://github.com/gregoryyoung/m-r/blob/master/SimpleCQRS/EventStore.cs">Greg's in-memory implementation</a>. There's a few things to note:   </p>
<ol>
<li>Rather than persisting the actual events, he&rsquo;s &ldquo;persisting&rdquo; EventDescriptor structs with references to the Events. I&rsquo;m going to steal this idea to make our NHibernate code easier. </li>
<li>The expectedVersion parameter should match the version of the most recent event. When it doesn&rsquo;t, we know we have a concurrency violation. </li>
</ol>
<h4>A persistent event store</h4>
<p>First, let's do a little refactoring of the EventStore implementation:</p>
<pre class="brush:csharp">public abstract class BaseEventStore : IEventStore
{
  private readonly IEventPublisher _publisher;

  protected BaseEventStore(IEventPublisher publisher)
  {
    _publisher = publisher;
  }

  public void SaveEvents(Guid aggregateId, 
    IEnumerable&lt;Event&gt; events, 
    int expectedVersion)
  {
    var eventDescriptors = new List&lt;EventDescriptor&gt;();
    var i = expectedVersion;
    foreach (var @event in events)
    {
      i++;
      @event.Version = i;
      eventDescriptors.Add(new EventDescriptor(aggregateId, @event, i));
    }

    AddEvents(eventDescriptors, aggregateId, expectedVersion);

    foreach (var @event in events)
    {
      _publisher.Publish(@event);
    }
  }

  public List&lt;Event&gt; GetEventsForAggregate(Guid aggregateId)
  {
    var eventDescriptors = GetEventDescriptorsForAggregate(aggregateId);
    if (null == eventDescriptors || !eventDescriptors.Any())
    {
      throw new AggregateNotFoundException();
    }
    return eventDescriptors.Select(desc =&gt; desc.EventData).ToList();
  }

  protected abstract IEnumerable&lt;EventDescriptor&gt;
    LoadEventDescriptorsForAggregate(Guid aggregateId);

  protected abstract void PersistEventDescriptors(
    IEnumerable&lt;EventDescriptor&gt; newEventDescriptors,
    Guid aggregateId,
    int expectedVersion);

}</pre>
<h4>Concurrency violation checking</h4>
<p>Greg's implementation explicitly checked for concurrency violations before persisting. Since he's working in memory, it's a simple check and a cheap operation. With a database, it gets more complicated. We could lock and query for the max version, but that's extreme and unnecessary. </p>
<p>We assume that the expectedVersion value is not greater than the actual current version. Since we're not deleting events from the event stream, I think this is a safe assumption. Essentially, while there's a small chance someone may have done something to our aggregate, they'll never undo something from our aggregate. </p>
<p>We can rely on our database for the check. If we insert an event with version 2 after events 0, 1, 2, and 3 are written, we'll get a primary key constraint violation. Since this is the only PK in our database, we know exactly why this happened. We'll convert this to a ConcurrencyException.</p>
<h4>Persistence implementation</h4>
<p>Now we have a base class that handles the transformation and event publishing and lets us implement our own persistence. </p>
<pre class="brush:csharp">public class NHibernateEventStore : BaseEventStore
{
  private readonly IStatelessSession _session;

  public NHibernateEventStore(
    IEventPublisher publisher,
    IStatelessSession session)
    : base(publisher)
  {
    _session = session;
  }

  protected override IEnumerable&lt;EventDescriptor&gt; 
    LoadEventDescriptorsForAggregate(Guid aggregateId)
  {
    var query = _session.GetNamedQuery("LoadEventDescriptors")
      .SetGuid("aggregateId", aggregateId);
    return Transact(() =&gt; query.List&lt;EventDescriptor&gt;());
  }

  protected override void PersistEventDescriptors(
    IEnumerable&lt;EventDescriptor&gt; newEventDescriptors, 
    Guid aggregateId, int expectedVersion)
  {
    // Don't bother to check expectedVersion. Since we can't delete 
    // events, we won't skip a version. If we do have a true concurrency 
    // violation, we'll get a PK violation exception. 
    // SqlExceptionConverter will change it to a ConcurrencyViolation.
    Transact(() =&gt;
                {
                  foreach (var ed in newEventDescriptors)
                    _session.Insert(ed);
                });
  }

  protected virtual TResult Transact&lt;TResult&gt;(Func&lt;TResult&gt; func)
  {
    if (!_session.Transaction.IsActive)
    {
      // Wrap in transaction
      TResult result;
      using (var tx = _session.BeginTransaction())
      {
        result = func.Invoke();
        tx.Commit();
      }
      return result;
    }

    // Don't wrap;
    return func.Invoke();
  }

  protected virtual void Transact(Action action)
  {
    Transact&lt;bool&gt;(() =&gt;
    {
      action.Invoke();
      return false;
    });
  }

}</pre>
<p>We&rsquo;re using stateless sessions because it&rsquo;s easy. We don&rsquo;t need a big unit of work implementation, automatic dirty checking, lazy loading, or any of that other stuff we rely on for traditional applications. We&rsquo;re just stuffing rows in to a table. </p>
<p>For those of you who&rsquo;ve read <a target="_blank" href="https://www.packtpub.com/nhibernate-3-0-cookbook/book">my book</a>, the Transact methods are taken right from the first section of my Data Access Layer chapter. They let us manage the <a target="_blank" href="http://nhforge.org">NHibernate</a> transaction when we need to, and handle it for us when we don&rsquo;t. </p>
<h4>Query and Model</h4>
<p>The LoadEventDescriptors query is dead simple:</p>
<pre class="brush:xml">&lt;?xml version="1.0" encoding="utf-8" ?&gt;
&lt;hibernate-mapping xmlns="urn:nhibernate-mapping-2.2"&gt;
  &lt;query name="LoadEventDescriptors"&gt;
    &lt;![CDATA[
    from EventDescriptor ed
    where ed.Id = :aggregateId
    order by ed.Version
    ]]&gt;
  &lt;/query&gt;
&lt;/hibernate-mapping&gt;</pre>
<p>Next, we redesign the EventDescriptor for use with NHibernate.</p>
<pre class="brush:csharp">public class EventDescriptor
{

  public Event EventData { get; private set; }
  public Guid Id { get; private set; }
  public int Version { get; private set; }

  public EventDescriptor(Guid id, Event eventData, int version)
  {
    EventData = eventData;
    Version = version;
    Id = id;
  }

  private EventDescriptor()
  {
  }

  public override bool Equals(object obj)
  {
    return Equals(obj as EventDescriptor);
  }

  public bool Equals(EventDescriptor other)
  {
    return null == other
              ? false
              : other.Id == Id &amp;&amp; other.Version == Version;
  }

  public override int GetHashCode()
  {
    return Id.GetHashCode() ^ Version.GetHashCode();
  }

}</pre>
<p>We've switched from a struct to a class, converted the readonly fields to properties with private setters, added a private constructor, and implemented Equals and GetHashCode. We did all of this to make NHibernate happy. We won't be doing any lazy loading, so we don't need to make our properties virtual. Because we'll use a composite key (Id and Version), we need to override Equals and GetHashCode. </p>
<p>Here&rsquo;s our mapping for EventDescriptor:</p>
<pre class="brush:xml">&lt;?xml version="1.0" encoding="utf-8" ?&gt;
&lt;hibernate-mapping xmlns="urn:nhibernate-mapping-2.2"
                   assembly="SimpleCQRS"
                   namespace="SimpleCQRS.EventStore"&gt;
  &lt;typedef class="SimpleCQRS.EventStore.NHibernate.JsonType, SimpleCQRS.EventStore.NHibernate"
           name="json" /&gt;
  &lt;class name="EventDescriptor" table="Events"
         mutable="false" lazy="false"&gt;
    &lt;composite-id&gt;
      &lt;key-property name="Id" /&gt;
      &lt;key-property name="Version" /&gt;
    &lt;/composite-id&gt;
    &lt;property name="EventData" type="json" &gt;
      &lt;column name="Type"/&gt;
      &lt;column name="Data"/&gt;
    &lt;/property&gt;
  &lt;/class&gt;
&lt;/hibernate-mapping&gt;</pre>
<p>EventDescriptor is immutable. We&rsquo;ve disabled lazy loading. Our primary key is a composite of the Id and Version. Our EventData is stored in two columns. The first stored the assembly qualified name of the .NET type. The second column stores the event as json serialized data. We use the JsonType IUserType to handle the serialization and deserialization transparently. Newtonsoft json.Net does all of the heavy lifting.</p>
<pre class="brush:csharp">[Serializable]
public class JsonType : IUserType
{

  private static object Deserialize(string data, string type)
  {
    return Deserialize(data, TypeNameHelper.GetType(type));
  }

  private static object Deserialize(string data, Type type)
  {
    return JsonConvert.DeserializeObject(data, type);
  }

  private static string Serialize(object value)
  {
    return null == value
              ? null
              : JsonConvert.SerializeObject(value);
  }

  private static string GetType(object value)
  {
    return null == value
              ? null
              : TypeNameHelper.GetSimpleTypeName(value);
  }

  public object NullSafeGet(IDataReader rs, string[] names, object owner)
  {
    int typeIndex = rs.GetOrdinal(names[0]);
    int dataIndex = rs.GetOrdinal(names[1]);
    if (rs.IsDBNull(typeIndex) || rs.IsDBNull(dataIndex))
    {
      return null;
    }

    var type = (string) rs.GetValue(typeIndex);
    var data = (string) rs.GetValue(dataIndex);
    return Deserialize(data, type);
  }

  public void NullSafeSet(IDbCommand cmd, object value, int index)
  {
    if (value == null)
    {
      NHibernateUtil.String.NullSafeSet(cmd, null, index);
      NHibernateUtil.String.NullSafeSet(cmd, null, index + 1);
      return;
    }

    var type = GetType(value);
    var data = Serialize(value);
    NHibernateUtil.String.NullSafeSet(cmd, type, index);
    NHibernateUtil.String.NullSafeSet(cmd, data, index + 1);
  }

  public object DeepCopy(object value)
  {
    return value == null
              ? null
              : Deserialize(Serialize(value), GetType(value));
  }

  public object Replace(object original, object target, object owner)
  {
    return original;
  }

  public object Assemble(object cached, object owner)
  {
    var parts = cached as string[];
    return parts == null
              ? null
              : Deserialize(parts[1], parts[0]);
  }

  public object Disassemble(object value)
  {
    return (value == null)
              ? null
              : new string[]
                  {
                    GetType(value),
                    Serialize(value)
                  };
  }

  public SqlType[] SqlTypes
  {
    get
    {
      return new[]
                {
                  SqlTypeFactory.GetString(10000), // Type
                  SqlTypeFactory.GetStringClob(10000) // Data
                };
    }
  }

  public Type ReturnedType
  {
    get { return typeof(Event); }
  }

  public bool IsMutable
  {
    get { return false; }
  }

  public new bool Equals(object x, object y)
  {
    if (ReferenceEquals(x, y))
    {
      return true;
    }
    if (ReferenceEquals(null, x) || ReferenceEquals(null, y))
    {
      return false;
    }

    return x.Equals(y);
  }

  public int GetHashCode(object x)
  {
    return (x == null) ? 0 : x.GetHashCode();
  }
}</pre>
<p>
TypeNameHelper still needs some work. GetSimpleTypeName should strip out the version, public key, processor architecture, and all that goo from the assembly qualified name. 
</p>
<pre class="brush:csharp">public static class TypeNameHelper
{
    
  public static string GetSimpleTypeName(object obj)
  {
    return null == obj
              ? null
              : obj.GetType().AssemblyQualifiedName;
  }

  public static Type GetType(string simpleTypeName)
  {
    return Type.GetType(simpleTypeName);
  }

}</pre>
<p>Finally, we need a bit of NHibernate magic to convert to primary key constraint violations in to ConcurrencyExceptions. I probably could have made this simpler, but it works.</p>
<pre class="brush:csharp">public class SqlExceptionConverter : ISQLExceptionConverter 
{

  public Exception Convert(AdoExceptionContextInfo exInfo)
  {
    var dbException = ADOExceptionHelper.ExtractDbException(exInfo.SqlException);

    var ns = dbException.GetType().Namespace ?? string.Empty;
    if (ns.ToLowerInvariant().StartsWith("system.data.sqlite"))
    {
      // SQLite exception
      switch (dbException.ErrorCode)
      {
        case -2147467259: // Abort due to constraint violation
          throw new ConcurrencyException();
      }
    }

    if (ns.ToLowerInvariant().StartsWith("system.data.sqlclient"))
    {
      // MS SQL Server
      switch (dbException.ErrorCode)
      {
        case -2146232060:
          throw new ConcurrencyException();
      }
    }

    return SQLStateConverter.HandledNonSpecificException(exInfo.SqlException,
        exInfo.Message, exInfo.Sql);
  }

}</pre>
<p>Fabio has a <a target="_blank" href="http://fabiomaulo.blogspot.com/2009/06/improving-ado-exception-management-in.html">blog post</a> all about NHibernate&rsquo;s SQLExceptionConverter. To turn this on, just set the sql_exception_converter property in your NHibernate configuration. </p>
<p>While I was working on this, I ran in to NH-2020, despite being resolved. Basically, batching and the SQL exception converter don&rsquo;t mix, so turn off batching. I told <a target="_blank" href="http://fabiomaulo.blogspot.com/">Fabio</a> about it. I&rsquo;ll do what I can to get it fixed for good in NH 3 GA. </p>
<p>Thanks to Greg Young for all his efforts to teach the world CQRS through <a target="_blank" href="http://cqrsinfo.com">CQRSInfo.com</a>, including his 6 1/2 hour screen cast. Also, thank you Fabio for sharing your json user type with me and answering my questions. </p>
