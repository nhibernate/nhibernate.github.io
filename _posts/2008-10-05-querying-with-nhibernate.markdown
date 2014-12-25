---
layout: post
title: "Querying With NHibernate"
date: 2008-10-05 11:00:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["query", "querying"]
redirect_from: ["/blogs/nhibernate/archive/2008/10/05/querying-with-nhibernate.aspx/"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>NOTE: this was originally posted on <a target="_blank" href="http://davybrion.com/blog/2008/10/querying-with-nhibernate/">my own blog</a></p>
<p>&nbsp;</p>
<p>
A lot of people are rather skeptical when it comes to executing non-trivial queries with NHibernate. In this post, i want to explore some of the features that NHibernate offers to execute those kind of queries in an easy manner.
Now, the difference between easy, non-trivial and complex queries is different for everyone. So in the following example, the query that needs to be executed is not at all complex, but it isn't your typically way too simplistic example either. It does show some often occurring requirements for queries, but at the same time it's still small enough to grasp easily.
</p>
<p>Suppose we have the following 4 tables:</p>
<p>
<a href="http://davybrion.com/blog/wp-content/uploads/2008/10/querying_example_tables.png"><img src="/images/posts/2008/10/05/querying_example_tables.png" title="querying_example_tables" class="aligncenter size-full wp-image-481" height="371" width="499" /></a>
</p>
<p>
Now, suppose we have the following business requirement: if we discontinue a product, we want to inform all of the customers who've ever bought that product. 
</p>
<p>NHibernate offers a few options of retrieving the customers that once bought a given product. You could use the lazy loading capabilities to walk the object graph and keep the customers you need.  This approach would justify a punch in the face though.  That's just abusing lazy loading to achieve lazy coding, which is just wrong.  The correct way to fetch the data is to query for it in an efficient manner.
</p>
<p>Suppose that we would typically write the following SQL query to fetch the required data:
<code>
</code></p>
<pre>select<br />	customer.CustomerId,<br />	customer.CompanyName,<br />	customer.ContactName,<br />	customer.ContactTitle,<br />	customer.Address,<br />	customer.City,<br />	customer.Region,<br />	customer.PostalCode,<br />	customer.Country,<br />	customer.Phone,<br />	customer.Fax<br />from<br />	dbo.Customers customer<br />where<br />	customer.CustomerId in<br />		(select distinct CustomerId from Orders<br />		 where OrderId in (select OrderId from [Order Details] where ProductId = 24))</pre>
<p>

For the purpose of this example, let's just assume that the ProductId that we need is 24. Now, i'm far from a SQL guru so i don't know if this approach (using subqueries) is the best way to fetch this data.  We'll explore another possibility later on.  But for now, let's try to get NHibernate to generate a query like the one i just showed you.
First of all, let's focus on the following subquery:
</p>
<p>select OrderId from [Order Details] where ProductId = 24
</p>
<p>With NHibernate, we'd get the same thing like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> orderIdsCriteria = <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">OrderLine</span>&gt;()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetProjection(<span style="color: #2b91af;">Projections</span>.Distinct(<span style="color: #2b91af;">Projections</span>.Property(<span style="color: #a31515;">"Order.Id"</span>)))</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span style="color: #2b91af;">Restrictions</span>.Eq(<span style="color: #a31515;">"Product.Id"</span>, productId));</p>
</div>
<p>

This basically tells NHibernate to build a query which fetches each Orders' Id property for every Order that has an OrderLine which contains the given Product's Id.  Keep in mind that this doesn't actually fetch the Order Id's yet.
Now that we already have that part, let's focus on the next subquery:
</p>
<p>select distinct CustomerId from Orders
where OrderId in (select OrderId from [Order Details] where ProductId = 24)
</p>
<p>With NHibernate, we'd get the same thing like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> customerIdsFromOrdersForProductCriteria = <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">Order</span>&gt;()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetProjection(<span style="color: #2b91af;">Projections</span>.Distinct(<span style="color: #2b91af;">Projections</span>.Property(<span style="color: #a31515;">"Customer.Id"</span>)))</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span style="color: #2b91af;">Subqueries</span>.PropertyIn(<span style="color: #a31515;">"Id"</span>, orderIdsCriteria));</p>
</div>
<p>

This builds a query which returns the Customer Id for each Customer that ever ordered the given product.  Notice how we reuse the previous subquery in this Criteria.
Now we need to build a query that fetches the full Customer entities, but only for the Customers whose Id is in the resultset of the previous query:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> customersThatBoughtProductCriteria = <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">Customer</span>&gt;()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span style="color: #2b91af;">Subqueries</span>.PropertyIn(<span style="color: #a31515;">"Id"</span>, customerIdsFromOrdersForProductCriteria));</p>
</div>
<p>

That's pretty easy, right? This is the query that NHibernate sends to the database to fetch the data:
<code>
</code></p>
<pre>SELECT <br />   this_.CustomerId as CustomerId0_0_, <br />   this_.CompanyName as CompanyN2_0_0_, <br />   this_.ContactName as ContactN3_0_0_, <br />   this_.ContactTitle as ContactT4_0_0_, <br />   this_.Address as Address0_0_, <br />   this_.City as City0_0_, <br />   this_.Region as Region0_0_, <br />   this_.PostalCode as PostalCode0_0_, <br />   this_.Country as Country0_0_, <br />   this_.Phone as Phone0_0_, <br />   this_.Fax as Fax0_0_ <br />FROM dbo.Customers this_ <br />WHERE <br />   this_.CustomerId in <br />      (SELECT distinct this_0_.CustomerId as y0_ FROM dbo.Orders this_0_ <br />       WHERE this_0_.OrderId in <br />           (SELECT distinct this_0_0_.OrderId as y0_ FROM dbo.[Order Details] this_0_0_ WHERE  <br />            this_0_0_.ProductId = @p0));<br /></pre>
<p>

Apart from the aliases that were added, this looks exactly the same as the query i wrote manually.  
An extra benefit that i think is pretty important is that each part of the query is actually reusable. If you built an API that could give you each part of the entire query that you needed, then you could easily reuse each part whenever you needed it.  Duplication in queries is just as bad as duplication in code IMHO.
</p>
<p>Suppose you'd want to limit the amount of subqueries and use a join instead of the lowest level subquery.  If we'd write the query ourselves, it would look something like this:
<code>
</code></p>
<pre>select<br />	customer.CustomerId,<br />	customer.CompanyName,<br />	customer.ContactName,<br />	customer.ContactTitle,<br />	customer.Address,<br />	customer.City,<br />	customer.Region,<br />	customer.PostalCode,<br />	customer.Country,<br />	customer.Phone,<br />	customer.Fax<br />from<br />	dbo.Customers customer<br />where<br />	customer.CustomerId in <br />		(select o.customerId<br />		 from Orders o inner join [Order Details] line on line.OrderId = o.OrderId<br />		 where line.ProductId = 24)<br /></pre>
<p>

First, let's try to write the following query with NHibernate's Criteria API:
</p>
<p>select o.customerId 
from Orders o inner join [Order Details] line on line.OrderId = o.OrderId
where line.ProductId = 24
</p>
<p>
Since our Order class has an OrderLines collection that is mapped to the [Order Details] table, we can generate that part of the query like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> customerIdsFromOrdersForProductCriteria = <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">Order</span>&gt;()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .SetProjection(<span style="color: #2b91af;">Projections</span>.Distinct(<span style="color: #2b91af;">Projections</span>.Property(<span style="color: #a31515;">"Customer.Id"</span>)))</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .CreateCriteria(<span style="color: #a31515;">"OrderLines"</span>, <span style="color: #2b91af;">JoinType</span>.InnerJoin)</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span style="color: #2b91af;">Restrictions</span>.Eq(<span style="color: #a31515;">"Product.Id"</span>, productId));</p>
</div>
<p>

The final part remains the same:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">var</span> customersThatBoughtProductCriteria = <span style="color: #2b91af;">DetachedCriteria</span>.For&lt;<span style="color: #2b91af;">Customer</span>&gt;()</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; .Add(<span style="color: #2b91af;">Subqueries</span>.PropertyIn(<span style="color: #a31515;">"Id"</span>, customerIdsFromOrdersForProductCriteria));</p>
</div>
<p>

And the query that NHibernate generates looks like this:
<code>
</code></p>
<pre>SELECT <br />   this_.CustomerId as CustomerId0_0_, <br />   this_.CompanyName as CompanyN2_0_0_, <br />   this_.ContactName as ContactN3_0_0_, <br />   this_.ContactTitle as ContactT4_0_0_, <br />   this_.Address as Address0_0_, <br />   this_.City as City0_0_, <br />   this_.Region as Region0_0_, <br />   this_.PostalCode as PostalCode0_0_, <br />   this_.Country as Country0_0_, <br />   this_.Phone as Phone0_0_, <br />   this_.Fax as Fax0_0_ <br />FROM <br />   dbo.Customers this_ <br />WHERE <br />   this_.CustomerId in <br />      (SELECT distinct this_0_.CustomerId as y0_ <br />       FROM dbo.Orders this_0_ inner join dbo.[Order Details] orderline1_ on this_0_.OrderId = <br />       orderline1_.OrderId WHERE orderline1_.ProductId = @p0); <br /></pre>
<p>

Again, pretty easy right?
</p>
<p>The Criteria API's Projection features, combined with Subqueries and combining Criteria into larger Criteria offers you a lot of possibilities when it comes to querying.  This post only showed a very small part of what's available, but hopefully it's enough to point some people in the right direction. Now, NHibernate's criteria API is pretty powerful, but the learning curve is indeed somewhat steep. It does take a while to get used to it, and i certainly don't know everything there is to know about it either. But it's definitely worth investing some time into learning how to use it well.</p>
