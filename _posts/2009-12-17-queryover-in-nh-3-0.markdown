---
layout: post
title: "QueryOver in NH 3.0"
date: 2009-12-17 23:22:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/12/17/queryover-in-nh-3-0.aspx"]
author: FlukeFan
gravatar: 2075ce3339bd0f16c52adac5b8e4b7b1
---
{% include imported_disclaimer.html %}
<h4><a name="Introduction"></a>Introduction</h4>
<p>
    The ICriteria API
    is NHibernate's implementation of <a target="_blank" href="http://martinfowler.com/eaaCatalog/queryObject.html">Query Object</a>.
    NHibernate 3.0 introduces the QueryOver api, which combines the use of
    <a target="_blank" href="http://weblogs.asp.net/scottgu/archive/2007/03/13/new-orcas-language-feature-extension-methods.aspx">Extension Methods</a>
    and
    <a target="_blank" href="http://weblogs.asp.net/scottgu/archive/2007/04/08/new-orcas-language-feature-lambda-expressions.aspx">Lambda Expressions</a>
    (both new in .Net 3.5) to provide a statically typesafe wrapper round the ICriteria API.
</p>
<p>
    QueryOver uses Lambda Expressions to provide some extra
    syntax to remove the 'magic strings' from your ICriteria queries.
</p>
<p>
    So, for example:</p>
<pre><code>.Add(Expression.Eq("Name", "Smith"))
</code></pre>
<p>becomes:</p>
<pre><code>.Where&lt;Person&gt;(p =&gt; p.Name == "Smith")
</code></pre>
<p>
    With this kind of syntax there are no 'magic strings', and refactoring tools like
    'Find All References', and 'Refactor-&gt;Rename' work perfectly.
</p>
<p>
    Note: QueryOver is intended to remove the references to 'magic strings'
    from the ICriteria API while maintaining it's opaqueness.  It is <span style="text-decoration: underline;"><strong>not</strong></span> a LINQ provider;
    NHibernate 3.0 has a built-in Linq provider for this.
</p>
<p>&nbsp;</p>
<h4><a name="StructureOfAQuery"></a>Structure of a Query</h4>
<p>
    Queries are created from an ISession using the syntax:
</p>
<pre><code>IList&lt;Cat&gt; cats =
    session.QueryOver&lt;Cat&gt;()
        .Where(c =&gt; c.Name == "Max")
        .List();
</code></pre>
<p>&nbsp;</p>
<p>
    Detached QueryOver (analagous to DetachedCriteria) can be created, and then used with an ISession using:
</p>
<pre><code>QueryOver&lt;Cat&gt; query =
    QueryOver.Of&lt;Cat&gt;()
        .Where(c =&gt; c.Name == "Paddy");
        
IList&lt;Cat&gt; cats =
    query.GetExecutableQueryOver(session)
        .List();
</code></pre>
<p>&nbsp;</p>
<p>
    Queries can be built up to use restrictions, projections, and ordering using
    a fluent inline syntax:    
</p>
<pre><code>var catNames =
    session.QueryOver&lt;Cat&gt;()
        .WhereRestrictionOn(c =&gt; c.Age).IsBetween(2).And(8)
        .Select(c =&gt; c.Name)
        .OrderBy(c =&gt; c.Name).Asc
        .List&lt;string&gt;();
</code></pre>
<p>&nbsp;</p>
<h4><a name="SimpleExpressions"></a>Simple Expressions</h4>
<p>
    The Restrictions class (used by ICriteria) has been extended to include overloads
    that allow Lambda Expression syntax.  The Where() method works for simple expressions (&lt;, &lt;=, ==, !=, &gt;, &gt;=)
    so instead of:
</p>
<pre><code>ICriterion equalCriterion = Restrictions.Eq("Name", "Max")
</code></pre>
<p>
    You can write:
</p>
<pre><code>ICriterion equalCriterion = Restrictions.Where&lt;Cat&gt;(c =&gt; c.Name == "Max")
</code></pre>
<p>&nbsp;</p>
<p>
    Since the QueryOver class (and IQueryOver interface) is generic and knows the type of the query,
    there is an inline syntax for restrictions that does not require the additional qualification
    of class name.  So you can also write:
</p>
<pre><code>var cats =
    session.QueryOver&lt;Cat&gt;()
        .Where(c =&gt; c.Name == "Max")
        .And(c =&gt; c.Age &gt; 4)
        .List();
</code></pre>
<p>
    Note, the methods Where() and And() are semantically identical; the And() method is purely to allow
    QueryOver to look similar to HQL/SQL.
</p>
<p>&nbsp;</p>
<p>
    Boolean comparisons can be made directly instead of comparing to true/false:
</p>
<pre><code>        .Where(p =&gt; p.IsParent)
        .And(p =&gt; !p.IsRetired)
</code></pre>
<p>&nbsp;</p>
<p>
    Simple expressions can also be combined using the || and &amp;&amp; operators.  So ICriteria like:
</p>
<pre><code>        .Add(Restrictions.And(
            Restrictions.Eq("Name", "test name"),
            Restrictions.Or(
                Restrictions.Gt("Age", 21),
                Restrictions.Eq("HasCar", true))))
</code></pre>
<p>
    Can be written in QueryOver as:
</p>
<pre><code>        .Where(p =&gt; p.Name == "test name" &amp;&amp; (p.Age &gt; 21 || p.HasCar))
</code></pre>
<p>&nbsp;</p>
<p>
    Each of the corresponding overloads in the QueryOver API allows the use of regular ICriterion
    to allow access to private properties.
</p>
<pre><code>        .Where(Restrictions.Eq("Name", "Max"))
</code></pre>
<p>&nbsp;</p>
<p>
    It is worth noting that the QueryOver API is built on top of the ICriteria API.  Internally the structures are the same, so at runtime
    the statement below, and the statement above, are stored as exactly the same ICriterion.  The actual Lambda Expression is not stored
    in the query.
</p>
<pre><code>        .Where(c =&gt; c.Name == "Max")
</code></pre>
<p>&nbsp;</p>
<h4><a name="AdditionalRestrictions"></a>Additional Restrictions</h4>
<p>
    Some SQL operators/functions do not have a direct equivalent in C#.
    (e.g., the SQL <code>where name like '%anna%'</code>).
    These operators have overloads for QueryOver in the Restrictions class, so you can write:
</p>
<pre><code>        .Where(Restrictions.On&lt;Cat&gt;(c =&gt; c.Name).IsLike("%anna%"))
</code></pre>
<p>
    There is also an inline syntax to avoid the qualification of the type:
</p>
<pre><code>        .WhereRestrictionOn(c =&gt; c.Name).IsLike("%anna%")
</code></pre>
<p>&nbsp;</p>
<p>
    While simple expressions (see above) can be combined using the || and &amp;&amp; operators, this is not possible with the other
    restrictions.  So this ICriteria:
</p>
<pre><code>        .Add(Restrictions.Or(
            Restrictions.Gt("Age", 5)
            Restrictions.In("Name", new string[] { "Max", "Paddy" })))
</code></pre>
<p>
    Would have to be written as:
</p>
<pre><code>        .Add(Restrictions.Or(
            Restrictions.Where&lt;Cat&gt;(c =&gt; c.Age &gt; 5)
            Restrictions.On&lt;Cat&gt;(c =&gt; c.Name).IsIn(new string[] { "Max", "Paddy" })))
</code></pre>
<p>&nbsp;</p>
<h4><a name="Associations"></a>Associations</h4>
<p>
    QueryOver can navigate association paths using JoinQueryOver() (analagous to ICriteria.CreateCriteria() to create sub-criteria).
</p>
<p>
    The factory method QuerOver&lt;T&gt;() on ISession returns an IQueryOver&lt;T&gt;.
    More accurately, it returns an IQueryOver&lt;T,T&gt; (which inherits from IQueryOver&lt;T&gt;).
</p>
<p>
    An IQueryOver has two types of interest; the root type (the type of entity that the query returns),
    and the type of the 'current' entity being queried.  For example, the following query uses
    a join to create a sub-QueryOver (analagous to creating sub-criteria in the ICriteria API):
</p>
<pre><code>IQueryOver&lt;Cat,Kitten&gt; catQuery =
    session.QueryOver&lt;Cat&gt;()
        .JoinQueryOver(c =&gt; c.Kittens)
            .Where(k =&gt; k.Name == "Tiddles");
</code></pre>
<p>
    The JoinQueryOver returns a new instance of the IQueryOver than has its root at the Kittens collection.
    The default type for restrictions is now Kitten (restricting on the name 'Tiddles' in the above example),
    while calling .List() will return an IList&lt;Cat&gt;.  The type IQueryOver&lt;Cat,Kitten&gt; inherits from IQueryOver&lt;Cat&gt;.
</p>
<p>
    Note, the overload for JoinQueryOver takes an IEnumerable&lt;T&gt;, and the C# compiler infers the type from that.
    If your collection type is not IEnumerable&lt;T&gt;, then you need to qualify the type of the sub-criteria:
</p>
<pre><code>IQueryOver&lt;Cat,Kitten&gt; catQuery =
    session.QueryOver&lt;Cat&gt;()
        .JoinQueryOver<span style="text-decoration: underline;">&lt;Kitten&gt;</span>(c =&gt; c.Kittens)
            .Where(k =&gt; k.Name == "Tiddles");
</code></pre>
<p>&nbsp;</p>
<p>
    The default join is an inner-join.  Each of the additional join types can be specified using
    the methods <code>.Inner, .Left, .Right,</code> or <code>.Full</code>.
    For example, to left outer-join on Kittens use:
</p>
<pre><code>IQueryOver&lt;Cat,Kitten&gt; catQuery =
    session.QueryOver&lt;Cat&gt;()
        .Left.JoinQueryOver(c =&gt; c.Kittens)
            .Where(k =&gt; k.Name == "Tiddles");
</code></pre>
<p>&nbsp;</p>
<h4><a name="Aliases"></a>Aliases</h4>
<p>
    In the traditional ICriteria interface aliases are assigned using 'magic strings', however their value
    does not correspond to a name in the object domain.  For example, when an alias is assigned using
    <code>.CreateAlias("Kitten", "kittenAlias")</code>, the string "kittenAlias" does not correspond
    to a property or class in the domain.
</p>
<p>
    In QueryOver, aliases are assigned using an empty variable.
    The variable can be declared anywhere (but should
    be empty/default at runtime).  The compiler can then check the syntax against the variable is
    used correctly, but at runtime the variable is not evaluated (it's just used as a placeholder for
    the alias).
</p>
<p>
    Each Lambda Expression function in QueryOver has a corresponding overload to allow use of aliases,
    and a .JoinAlias function to traverse associations using aliases without creating a sub-QueryOver.
</p>
<pre><code>Cat catAlias = null;
Kitten kittenAlias = null;

IQueryOver&lt;Cat,Cat&gt; catQuery =
    session.QueryOver&lt;Cat&gt;(() =&gt; catAlias)
        .JoinAlias(() =&gt; catAlias.Kittens, () =&gt; kittenAlias)
        .Where(() =&gt; catAlias.Age &gt; 5)
        .And(() =&gt; kittenAlias.Name == "Tiddles");
</code></pre>
<p>&nbsp;</p>
<h4><a name="Projections"></a>Projections</h4>
<p>
    Simple projections of the properties of the root type can be added using the <code>.Select</code> method
    which can take multiple Lambda Expression arguments:
</p>
<pre><code>IList selection =
    session.QueryOver&lt;Cat&gt;()
        .Select(
            c =&gt; c.Name,
            c =&gt; c.Age)
        .List&lt;object[]&gt;();
</code></pre>
<p>
    Because this query no longer returns a Cat, the return type must be explicitly specified.
    If a single property is projected, the return type can be specified using:
</p>
<pre><code>IList&lt;int&gt; ages =
    session.QueryOver&lt;Cat&gt;()
        .Select(c =&gt; c.Age)
        .List&lt;int&gt;();
</code></pre>
<p>
    However, if multiple properties are projected, then the returned list will contain
    object arrays, as per a projection
    in ICriteria.  This could be fed into an anonymous type using:
</p>
<pre><code>var catDetails =
    session.QueryOver&lt;Cat&gt;()
        .Select(
            c =&gt; c.Name,
            c =&gt; c.Age)
        .List&lt;object[]&gt;()
        .Select(properties =&gt; new {
            CatName = (string)properties[0],
            CatAge = (int)properties[1],
            });
            
Console.WriteLine(catDetails[0].CatName);
Console.WriteLine(catDetails[0].CatAge);
</code></pre>
<p>
    Note that the second <code>.Select</code> call in this example is an extension method on IEnumerable&lt;T&gt; supplied in System.Linq;
    it is not part of NHibernate.
</p>
<p>&nbsp;</p>
<p>
    QueryOver allows arbitrary IProjection to be added (allowing private properties to be projected).  The Projections factory
    class also has overloads to allow Lambda Expressions to be used:
</p>
<pre><code>IList selection =
    session.QueryOver&lt;Cat&gt;()
        .Select(Projections.ProjectionList()
            .Add(Projections.Property&lt;Cat&gt;(c =&gt; c.Name))
            .Add(Projections.Avg&lt;Cat&gt;(c =&gt; c.Age)))
        .List&lt;object[]&gt;();
</code></pre>
<p>&nbsp;</p>
<p>
    In addition there is an inline syntax for creating projection lists that does not require the explicit class qualification:
</p>
<pre><code>IList selection =
    session.QueryOver&lt;Cat&gt;()
        .SelectList(list =&gt; list
            .Select(c =&gt; c.Name)
            .SelectAvg(c =&gt; c.Age))
        .List&lt;object[]&gt;();
</code></pre>
<p>&nbsp;</p>
<p>
    Projections can also have arbitrary aliases assigned to them to allow result transformation.
    If there is a CatSummary DTO class defined as:
</p>
<pre><code>public class CatSummary
{
    public string Name { get; set; }
    public int AverageAge { get; set; }
}
</code></pre>
<p>
    ... then aliased projections can be used with the AliasToBean&lt;T&gt; transformer:
</p>
<pre><code>CatSummary summaryDto = null;
IList&lt;CatSummary&gt; catReport =
    session.QueryOver&lt;Cat&gt;()
        .SelectList(list =&gt; list
            .SelectGroup(c =&gt; c.Name).WithAlias(() =&gt; summaryDto.Name)
            .SelectAvg(c =&gt; c.Age).WithAlias(() =&gt; summaryDto.AverageAge))
        .TransformUsing(Transformers.AliasToBean&lt;CatSummary&gt;())
        .List&lt;CatSummary&gt;();
</code></pre>
<h4><a name="Subqueries"></a>Subqueries</h4>
<p>
    The Subqueries factory class has overloads to allow Lambda Expressions to express sub-query
    restrictions.  For example:
</p>
<pre><code>QueryOver&lt;Cat&gt; maximumAge =
    QueryOver.Of&lt;Cat&gt;()
        .SelectList(p =&gt; p.SelectMax(c =&gt; c.Age));

IList&lt;Cat&gt; oldestCats =
    session.QueryOver&lt;Cat&gt;()
        .Where(Subqueries.WhereProperty&lt;Cat&gt;(c =&gt; c.Age).Eq(maximumAge))
        .List();
</code></pre>
<p>&nbsp;</p>
<p>
    The inline syntax allows you to use subqueries without requalifying the type:
</p>
<pre><code>IList&lt;Cat&gt; oldestCats =
    session.QueryOver&lt;Cat&gt;()
        .WithSubquery.WhereProperty(c =&gt; c.Age).Eq(maximumAge)
        .List();
</code></pre>
<p>&nbsp;</p>
<p>
    There is an extension method <code>As()</code> on (a detached) QueryOver that allows you to cast it to any type.
    This is used in conjunction with the overloads <code>Where(), WhereAll(),</code> and <code>WhereSome()</code>
    to allow use of the built-in C# operators for comparison, so the above query can be written as:
</p>
<pre><code>IList&lt;Cat&gt; oldestCats =
    session.QueryOver&lt;Cat&gt;()
        .WithSubquery.Where(c =&gt; c.Age == maximumAge.As&lt;int&gt;())
        .List();
</code></pre>
<p>&nbsp;</p>
