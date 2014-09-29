---
layout: post
title: "Data Access With NHibernate"
date: 2008-08-31 15:07:00 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2008/08/31/data-access-with-nhibernate.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>NOTE: this post was originally published on <a href="http://davybrion.com/blog/2008/06/data-access-with-nhibernate/">June 23rd, 2008</a></p>
<p>&nbsp;</p>
<p>
One thing that keeps amazing me is how many smart developers still feel the urge to write their own data access layer (DAL). They either do it all manually, or they generate parts of it, or they generate the whole thing. Whichever way you go, there are still various alternative paths you can choose from. Some people like to use stored procedures for everything, some people generate sql statements and provide a semi-OO API in front of it, some people still spend time constructing Command objects. I think i've seen most approaches by now, and my personal opinion is that they pretty much all suck.  
</p>
<p>These DAL's usually have at least one big downside to them. Generated DAL's are usually pretty good for productivity but most of the times they don't really offer you that much control over how queries should be executed, whether or not statements should be batched, specify fetching-strategies, etc.  Hand-written DAL's are terrible for productivity but you can fine tune each action to an optimal implementation.  These downsides are pretty big IMHO, and are often underestimated. Sometimes due to semi-religious stances and sometimes it's just due to ignorance.
As you already know, i'm a fan of NHibernate. Well, consider me a fan of decent ORM's in general. NHibernate just happens to be the one i know best and am very happy with. In this post i'd like to take a look at how you can easily offer the most common data access requirements without generating code, while still allowing high developer productivity.  We'll go over the implementation of a generic <a href="http://martinfowler.com/eaaCatalog/repository.html">Repository</a> class, and hopefully you'll see how much NHibernate can improve your way of working.
We're going to look at the implementation piece by piece, so lets just start with the declaration of the class so we can get that out of the way:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">class</span> <span style="color: #2b91af;">Repository</span>&lt;T&gt; : <span style="color: #2b91af;">IRepository</span>&lt;T&gt;</p>
</div>
<p>

As you can see, this is just a generic class that takes a type parameter. The type parameter represents the type of the Entity you want this repository to handle. If you have an Entity base class or interface, you probably want to restrict the type of T to inherit from Entity or implement IEntity or whatever. 
This class needs to be able to access the current NHibernate session, which i <a href="http://davybrion.com/blog/2008/06/managing-your-nhibernate-sessions/">discussed</a> yesterday:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">private</span> <span style="color: blue;">readonly</span> <span style="color: #2b91af;">IActiveSessionManager</span> activeSessionManager;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> Repository(<span style="color: #2b91af;">IActiveSessionManager</span> activeSessionManager)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">this</span>.activeSessionManager = activeSessionManager;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">protected</span> <span style="color: #2b91af;">ISession</span> Session</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">get</span> { <span style="color: blue;">return</span> activeSessionManager.GetActiveSession(); }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Right, now we can actually get to the interesting Data Access parts.  Obviously, each DAL needs a way to retrieve a specific entity based on its Primary Key value:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Retrieves the entity with the given id</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="id"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;</span><span style="color: green;">the entity or null if it doesn't exist</span><span style="color: gray;">&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> T Get(<span style="color: blue;">object</span> id)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> Session.Get&lt;T&gt;(id);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Very straightforward stuff... this simply uses the current NHibernate session to retrieve an entity of the requested type, with the given primary key value.
Another thing we need is a way to create or update entity instances:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Saves or updates the given entity</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="entity"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> SaveOrUpdate(T entity)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Session.SaveOrUpdate(entity);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

This method simply uses the session's SaveOrUpdate method, which will either perform an Insert (in case of a new entity) or an Update (in case of an existing entity).  NHibernate will perform a check for a new instance depending on how you've configured this in your mapping files.
So far this has been really straightforward, so it's time to get to a more interesting part.  Retrieving entities based on criteria (basically a query):
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns each entity that matches the given criteria</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: #2b91af;">IEnumerable</span>&lt;T&gt; FindAll(<span style="color: #2b91af;">DetachedCriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> criteria.GetExecutableCriteria(Session).List&lt;T&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

This probably needs a bit of explaining. The parameter is an instance of the DetachedCriteria type. A DetachedCriteria is just like a <a href="http://www.hibernate.org/hib_docs/nhibernate/1.2/reference/en/html_single/#querycriteria">Criteria</a> instance, except that it hasn't been associated with a session yet. So you can create the DetachedCriteria without being connected to a session.  This basically represents a query.  I'll show a concrete example of this later on.  The thing to remember is that this is the only code you really need to perform any query you want. You just have to write the query using the Criteria API. This does have a bit of a learning curve, but most people pick it up pretty fast.
You usually also want a way to determine the ordering of the result of the query:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns each entity that maches the given criteria, and orders the results </span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> according to the given Orders</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="orders"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: #2b91af;">IEnumerable</span>&lt;T&gt; FindAll(<span style="color: #2b91af;">DetachedCriteria</span> criteria, <span style="color: blue;">params</span> <span style="color: #2b91af;">Order</span>[] orders)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (orders != <span style="color: blue;">null</span>)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (<span style="color: blue;">var</span> order <span style="color: blue;">in</span> orders)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteria.AddOrder(order);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> FindAll(criteria);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Each order you provide is applied to the query and then the query is executed. Again, pretty simple stuff right? 
You want to know how you can get paging working? Here it is:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns each entity that matches the given criteria, with support for paging, </span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> and orders the results according to the given Orders</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="firstResult"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="numberOfResults"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="orders"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: #2b91af;">IEnumerable</span>&lt;T&gt; FindAll(<span style="color: #2b91af;">DetachedCriteria</span> criteria, <span style="color: blue;">int</span> firstResult, <span style="color: blue;">int</span> numberOfResults, <span style="color: blue;">params</span> <span style="color: #2b91af;">Order</span>[] orders)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; criteria.SetFirstResult(firstResult).SetMaxResults(numberOfResults);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> FindAll(criteria, orders);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Keep in mind that the executed query only retrieves the results within the paging range. It does not retrieve everything to perform the paging client-side, this happens in the db where it's supposed to happen.
What if you have a query that should only return one instance? That's easy to do as well:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns the one entity that matches the given criteria. Throws an exception if </span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> more than one entity matches the criteria</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> T FindOne(<span style="color: #2b91af;">DetachedCriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> criteria.GetExecutableCriteria(Session).UniqueResult&lt;T&gt;();</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

What if you have a query and you just want the very first result instead of the entire resultset? Again, pretty easy to do:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns the first entity to match the given criteria</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> T FindFirst(<span style="color: #2b91af;">DetachedCriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> results = criteria.SetFirstResult(0).SetMaxResults(1)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .GetExecutableCriteria(Session).List&lt;T&gt;();</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">if</span> (results.Count &gt; 0)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> results[0];</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> <span style="color: blue;">default</span>(T);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

Again, NHibernate will issue a smart sql statement... that is, it only retrieves the first result instead of the entire resultset.
Obviously, this is also useful if you can define the order of the results to pick the first result:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns the first entity to match the given criteria, ordered by the given order</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="order"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> T FindFirst(<span style="color: #2b91af;">DetachedCriteria</span> criteria, <span style="color: #2b91af;">Order</span> order)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> FindFirst(criteria.AddOrder(order));</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

How often have you seen developers execute a query in code, only to use the count of the records without actually needing the returned records? We no longer need to beat the shit out of these developers:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns the total number of entities that match the given criteria</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">long</span> Count(<span style="color: #2b91af;">DetachedCriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> <span style="color: #2b91af;">Convert</span>.ToInt64(criteria.GetExecutableCriteria(Session)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetProjection(<span style="color: #2b91af;">Projections</span>.RowCountInt64()).UniqueResult());</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

In this case, NHibernates issues a simple select count... query based on the criteria you've provided. Nice huh?
We might as well throw in this one as well:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Returns true if at least one entity exists that matches the given criteria</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;returns&gt;&lt;/returns&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">bool</span> Exists(<span style="color: #2b91af;">DetachedCriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">return</span> Count(criteria) &gt; 0;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

And last, but certainly not least, you'll also want a way to delete entities from the database. How about this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Deletes the given entity</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="entity"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> Delete(T entity)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Session.Delete(entity);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> Deletes every entity that matches the given criteria</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;/summary&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: gray;">///</span><span style="color: green;"> </span><span style="color: gray;">&lt;param name="criteria"&gt;&lt;/param&gt;</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">public</span> <span style="color: blue;">void</span> Delete(<span style="color: #2b91af;">DetachedCriteria</span> criteria)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// a simple DELETE FROM ... WHERE ... would be much better, but i haven't found </span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// a way to do this yet with Criteria. So now it does two roundtrips... one for</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// the query, and one with all the batched delete statements (that is, if you've </span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: green;">// enabled CUD statement batching </span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">foreach</span> (T entity <span style="color: blue;">in</span> FindAll(criteria))</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; {</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; Delete(entity);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; }</p>
</div>
<p>

The first Delete method simply deletes the given entity.  The second method probably needs to be explained a bit more.  This method receives a query, and it deletes all the items that the query returns. As you can see from the comment, it would be better if it would perform a DELETE FROM ... WHERE instead of fetching the results of the query but i didn't find a way to do that with the criteria API. In a more advanced scenario, this might actually be better than simply issuing a large DELETE statement because you could offer a Delete method which also receives a block of code to execute before or after each delete is executed. Which opens the door to a lot of interesting opportunities. 
And that's it basically... I really haven't shown you that much code right? And what does this code offer us? We get create/update/delete functionality, and we also have some nice options for querying our data.  And since the Criteria API of NHibernate allows you to create powerful and complex queries, you can use it to create your queries and then you simply pass these criteria to the repository to fetch the data. Just so we're clear on this, you're not just limited to specifying which data you want to retrieve, but you can also tell NHibernate how you want to retrieve it because you can define fetching strategies for each association. This is a tremendously powerful feature which offers you a lot of flexibility in choosing the most optimal data fetching approaches, without being limited to what your DAL supports or having to spend a lot of code on it.
Let's wrap up this post with a small example of how you could use this repository class to execute a query you wrote yourself:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> criteria = <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">ProductCategory</span>&gt;()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span style="color: #2b91af;">Expression</span>.Like(<span style="color: #a31515;">"Name"</span>, <span style="color: #a31515;">"Test%"</span>));</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> categories = repository.FindAll(criteria);</p>
</div>
<p>

As you can see, this is really easy. The only effort basically lies within building the query, so as you're queries become more complex, this effort obviously increases.  
If you combine this repository approach with <a href="http://davybrion.com/blog/2008/06/the-query-batcher/">query batching</a>, you end up with an easy-to-use data layer which offers you all the flexibility you could want, while still allowing you to implement specifically tuned solutions to achieve excellent performance.  Also, keep in mind that this is only a very basic repository implementation. The Rhino Commons repository implementation offers even more functionality with a couple of extra options to boost performance.  I really can't think of a single good reason not to use this approach anymore.</p>
