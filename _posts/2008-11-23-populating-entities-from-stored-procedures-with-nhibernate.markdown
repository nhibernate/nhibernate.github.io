---
layout: post
title: "Populating Entities From Stored Procedures With NHibernate"
date: 2008-11-23 14:37:00 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2008/11/23/populating-entities-from-stored-procedures-with-nhibernate.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Note: this was orginally posted on my <a target="_blank" href="http://davybrion.com/blog/2008/11/populating-entities-from-stored-procedures-with-nhibernate/">own blog</a>.</p>
<p>A short while ago we needed to fetch the data for some entities through a stored procedure for performance reasons.  We already use NHibernate in the typical way to fetch and modify the data of this entity type, but we just wanted something so we could also use the resultset of the stored procedure to populate the entities.  One of my team members spent some time figuring out how to get the data returned by the stored procedure into the entities without actually having to write the code ourselves.  Turns out this was pretty easy to do.  Let's go over the solution with a very simple example.
</p>
<p>
The stored procedure i'll use for the example is extremely simple, and you'd never need to use this technique for such a stupid procedure.  But in the situation we faced at work, the stored procedure was obviously a lot more complicated.  So the stored procedure for this example is just this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">ALTER PROCEDURE </span>[dbo].[GetProductsByCategoryId]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; @CategoryId <span style="color: blue;">int </span></p>
<p style="margin: 0px;"><span style="color: blue;">AS</span></p>
<p style="margin: 0px;"><span style="color: blue;">BEGIN</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">SET NOCOUNT ON</span>;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">SELECT </span>[ProductID]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[ProductName]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[SupplierID]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[CategoryID]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[QuantityPerUnit]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[UnitPrice]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[UnitsInStock]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[UnitsOnOrder]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[ReorderLevel]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Discontinued]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp; <span style="color: blue;">FROM </span>[Northwind].[dbo].[Products]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp;&nbsp; <span style="color: blue;">WHERE </span>[CategoryId] = @CategoryId</p>
<p style="margin: 0px;"><span style="color: blue;">END</span></p>
</div>
<p>
This just returns the product rows for the given CategoryId parameter.  Again, you'd never do this in real life but this simple procedure is just used as an example.
Now, the structure of the resultset that this procedure returns is identical to the structure that the Product entity is mapped to.  This makes it really easy to get this data into the Product entities.  Just add a named query to your mapping like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;</span><span style="color: #a31515;">sql-query</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">GetProductsByCategoryId</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return</span><span style="color: blue;"> </span><span style="color: red;">class</span><span style="color: blue;">=</span>"<span style="color: blue;">Product</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;">&nbsp; &nbsp; exec dbo.GetProductsByCategoryId :CategoryId</p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;/</span><span style="color: #a31515;">sql-query</span><span style="color: blue;">&gt;</span></p>
</div>
<p>
And this is all you need to do in code to get your list of entities from this stored procedure:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">IQuery</span> query = Session.GetNamedQuery(<span style="color: #a31515;">"GetProductsByCategoryId"</span>);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; query.SetInt32(<span style="color: #a31515;">"CategoryId"</span>, 1);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">IList</span>&lt;<span style="color: #2b91af;">Product</span>&gt; products = query.List&lt;<span style="color: #2b91af;">Product</span>&gt;();</p>
</div>
<p>
Is that easy or what?
Now, suppose that the stored procedure returns more columns than you've got mapped to the entity.  You can still use this approach as well, but then you'll need to specify which return values map to which properties in the entity like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;</span><span style="color: #a31515;">sql-query</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">GetProductsByCategoryId</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return</span><span style="color: blue;"> </span><span style="color: red;">class</span><span style="color: blue;">=</span>"<span style="color: blue;">Product</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">ProductID</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Id</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">ProductName</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Name</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">SupplierID</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Supplier</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">CategoryID</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Category</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">QuantityPerUnit</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">QuantityPerUnit</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitPrice</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitPrice</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitsInStock</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitsInStock</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitsOnOrder</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitsOnOrder</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">ReorderLevel</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">ReorderLevel</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Discontinued</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Discontinued</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;/</span><span style="color: #a31515;">return</span><span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;">&nbsp; &nbsp; exec dbo.GetProductsByCategoryId :CategoryId</p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;/</span><span style="color: #a31515;">sql-query</span><span style="color: blue;">&gt;</span></p>
</div>
<p>
Notice how the CategoryID and SupplierID columns are mapped to Category and Supplier properties, which in Product's mapping are mapped as Category and Supplier many-to-one types, so basically references of type Category and Supplier respectively.  NHibernate basically just takes care of all of the dirty work.</p>
