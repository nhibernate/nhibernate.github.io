---
layout: post
title: "Linq to NHibernate Progress Report - A Christmas Gift?"
date: 2009-12-17 00:00:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate"]
redirect_from: ["/blogs/nhibernate/archive/2009/12/17/linq-to-nhibernate-progress-report-a-christmas-gift.aspx/"]
author: srstrong
gravatar: be49dc22186b4215272ffa6a46599424
---
{% include imported_disclaimer.html %}
<p>Time for another progress report, and this one's a biggie :)</p>
<p>Barring a couple of pretty minor things that won't take much fixing, all the original Linq tests have now been ported over to the new provider and are all passing. That means the new provider is now (from the perspective of the tests, at least) in better shape that the version 1 provider. It can do everything the original provider could, plus a whole bunch more. A couple of example queries that now work just fine are:</p>
<p><code>&nbsp;&nbsp;from e in db.Employees<br />
&nbsp;&nbsp;from et in e.Territories<br />
&nbsp;&nbsp;where e.Address.City == "Seattle"<br />
&nbsp;&nbsp;select new {e.FirstName, e.LastName, et.Region.Description};<br /></code><br />
<code>&nbsp;&nbsp;from c in db.Customers<br />
&nbsp;&nbsp;join o in db.Orders on c.CustomerId equals o.Customer.CustomerId into orders<br />
&nbsp;&nbsp;select new {c.ContactName, OrderCount = orders.Average(x =&gt; x.Freight)};<br /></code><br />
<code>&nbsp;&nbsp;from o in db.Orders<br />
&nbsp;&nbsp;from p in db.Products<br />
&nbsp;&nbsp;join d in db.OrderLines on new {o.OrderId, p.ProductId} equals new {d.Order.OrderId, d.Product.ProductId}<br />
&nbsp;&nbsp; into details<br />
&nbsp;&nbsp;from d in details<br />
&nbsp;&nbsp;select new {o.OrderId, p.ProductId, d.UnitPrice}<br /></code><br />
<code>&nbsp;&nbsp;from c in db.Customers<br />
&nbsp;&nbsp;join o in db.Orders on c.CustomerId equals o.Customer.CustomerId<br />
&nbsp;&nbsp;group o by c into x<br />
&nbsp;&nbsp;select new { CustomerName = x.Key.ContactName, Order = x }<br /></code></p>
<p>(ignore whether those queries make any real sense, it's just the form of them that matters)</p>
<p>So, more importantly, what doesn't work? Well, out of the tests that we've currently got, not a huge amount. Some important areas that are missing are:</p>
<ul>
<li>Nested selects to produce hierarchical output. I've got some prototype code for doing this, so it will be supported at some point but isn't there right now. Of course, since NH already understands relationships, nested selects are far less important than they are for something like Linq to SQL.</li>
<li style="list-style: none"></li>
<li>Group joins that produce hierarchical output - these essentially boil down to the same code as the nested select case, so support for these will probably come at around the same time. Group joins that don't introduce a hierarchy should work just fine.</li>
<li style="list-style: none"></li>
<li>Set operations, such as Union and Intersect. Union you can obviously do yourself in client code with no particular overhead. Intersect would really be better in the provider :)</li>
<li style="list-style: none"></li>
<li>Left outer join style queries, such as:<br />
  <br />
  <code>from e in db.Employees<br />
  join o in db.Orders on e equals o.Employee into ords<br />
  from o in ords.DefaultIfEmpty()<br />
  select new {e.FirstName, e.LastName, Order = o};<br />
  <br /></code> This is a fairly widely used construct, so is close to top of the list for future support</li>
<li style="list-style: none"></li>
<li>Let expressions, such as:<br />
  <br />
  <code>from c in db.Customers<br />
  join o in db.Orders on c.CustomerId equals o.Customer.CustomerId into ords<br />
  let z = c.Address.City + c.Address.Country<br />
  from o in ords<br />
  select new {c.ContactName, o.OrderId, z};<br />
  <br /></code> Again, this is quite high on the TODO list.</li>
<li style="list-style: none"></li>
<li>Support for custom functions. This is actually fully implemented internally, but I just want to review the API usage before I tell you all how to use it - it probably needs a little cleanup from it's current state, but I don't anticipate any major changes.</li>
</ul>
<p>I've also got a number of TODOs, but mainly cleanup rather than functional, plus I need to work through the error handling to ensure that any queries that are passed in that the provider <strong>can't</strong> handle are rejected gracefully rather than just barfing (which is the likely case right now).</p>
<p>The only gotcha that I know of is a query that runs just fine but doesn't necessarily return the correct number of results. Specifically, queries like this:</p>
<p><code>&nbsp;&nbsp;from user in db.Users<br />
&nbsp;&nbsp;select new<br />
&nbsp;&nbsp;{<br />
&nbsp;&nbsp;&nbsp;&nbsp;user.Name,<br />
&nbsp;&nbsp;&nbsp;&nbsp;RoleName = user.Role.Name<br />
&nbsp;&nbsp;};<br /></code></p>
<p>Right now, this generates a <strong>join</strong> to the Role table, so any users that <strong>don't</strong> have a role are not returned. This differs from Linq to SQL where a <strong>left join</strong> is generated, giving a null RoleName for any users without a role. I believe the Linq to SQL implementation to be correct - the above query doesn't explicitly have any form of filtering (where clause, join clause etc), so you should get back all the users in the database. This one is top of the list, and hopefully will be fixed soon (it's not hard, I've just run out of time!).</p>
<p>In summary, I'm getting pretty happy with the state of the provider and think that it's now ready for general usage - although there are still some important query forms to support, I think there's sufficient there now to do useful work. If you've got good test coverage, then I'd even be happy for it to go live. If you don't have good coverage, then don't come crying to me :)</p>
<p>Of course, this is all in the trunk, so anyone wanting to play either needs to get the trunk source and build it, or take the much easier option of having <a href="http://www.hornget.net/packages/orm/nhibernate/nhibernate-trunk">Horn</a> do the work. Horn builds the trunk on a daily basis, so look for a package built after around 2300GMT on the 16/12/2009 (the package URL on Horn has the datetime stamp in it, so it's pretty easy to spot).</p>
<p>I'm on holiday for the next couple of weeks, and will only have intermittent internet access. However, ping me either by email or twitter with comments / bugs / suggestions, and I'll do my best to reply. Normal service (whatever that is) will return around Jan 4th.</p>
<div class="posttagsblock"><a rel="tag" href="http://technorati.com/tag/Linq">Linq</a>, <a rel="tag" href="http://technorati.com/tag/NHibernate">NHibernate</a></div>
