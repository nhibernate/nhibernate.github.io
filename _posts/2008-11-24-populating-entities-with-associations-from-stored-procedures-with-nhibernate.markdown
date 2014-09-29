---
layout: post
title: "Populating Entities With Associations From Stored Procedures With NHibernate"
date: 2008-11-24 02:27:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2008/11/24/populating-entities-with-associations-from-stored-procedures-with-nhibernate.aspx"]
author: DavyBrion
gravatar: bb45e44f9e0c0b50551429d3feb214d1
---
{% include imported_disclaimer.html %}
<p>Note: this was originally posted on <a target="_blank" href="http://davybrion.com/blog/2008/11/populating-entities-with-associations-from-stored-procedures-with-nhibernate/">my own blog</a>.</p>
<p>In response to my last post where i showed how you could <a href="http://davybrion.com/blog/2008/11/populating-entities-from-stored-procedures-with-nhibernate/">fill entities with the resultset of a stored procedure</a>, i was asked if it was also possible to fill entities and their associations if the stored procedure returned all of the necessary data.  I looked into it, and it's possible, although it did take me some time to figure out how to actually do it.
</p>
<p>
First of all, here's the modified stored procedure:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">ALTER PROCEDURE </span>[dbo].[GetProductsByCategoryId]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; @CategoryId <span style="color: blue;">int </span></p>
<p style="margin: 0px;"><span style="color: blue;">AS</span></p>
<p style="margin: 0px;"><span style="color: blue;">BEGIN</span></p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">SET NOCOUNT ON</span>;</p>
<p style="margin: 0px;">&nbsp;</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; <span style="color: blue;">SELECT </span>[Products].[ProductID] <span style="color: blue;">as </span>"Product.ProductID"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[ProductName] <span style="color: blue;">as </span>"Product.ProductName"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[SupplierID] <span style="color: blue;">as </span>"Product.SupplierID"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[CategoryID] <span style="color: blue;">as </span>"Product.CategoryID"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[QuantityPerUnit] <span style="color: blue;">as </span>"Product.QuantityPerUnit"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[UnitPrice] <span style="color: blue;">as </span>"Product.UnitPrice"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[UnitsInStock] <span style="color: blue;">as </span>"Product.UnitsInStock"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[UnitsOnOrder] <span style="color: blue;">as </span>"Product.UnitsOnOrder"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[ReorderLevel] <span style="color: blue;">as </span>"Product.ReorderLevel"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Products].[Discontinued] <span style="color: blue;">as </span>"Product.Discontinued"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Categories].[CategoryID] <span style="color: blue;">as </span>"Category.CategoryID"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Categories].[CategoryName] <span style="color: blue;">as </span>"Category.CategoryName"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp; ,[Categories].[Description] <span style="color: blue;">as </span>"Category.Description"</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp; <span style="color: blue;">FROM </span>[Northwind].[dbo].[Products]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">inner join </span>[Northwind].[dbo].[Categories] </p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: blue;">on </span>[Products].[CategoryID] = [Categories].[CategoryID]</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp;&nbsp; <span style="color: blue;">WHERE </span>[Products].[CategoryId] = @CategoryId</p>
<p style="margin: 0px;"><span style="color: blue;">END</span></p>
</div>
<p>

As you can see, this returns all of the columns of the Products table, as well as the columns of the Categories table.  The goal is to let NHibernate execute this stored procedure, and use the returning data to give us a list of Product entities with a Category reference which is already set up with the proper data. 
The mapping of the named query now looks like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;</span><span style="color: #a31515;">sql-query</span><span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">GetProductsByCategoryId</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return</span><span style="color: blue;"> </span><span style="color: red;">alias</span><span style="color: blue;">=</span>"<span style="color: blue;">Product</span>"<span style="color: blue;"> </span><span style="color: red;">class</span><span style="color: blue;">=</span>"<span style="color: blue;">Product</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.ProductID</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Id</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.ProductName</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Name</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.CategoryId</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Category</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.SupplierID</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Supplier</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.QuantityPerUnit</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">QuantityPerUnit</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.UnitPrice</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitPrice</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.UnitsInStock</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitsInStock</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.UnitsOnOrder</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">UnitsOnOrder</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.ReorderLevel</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">ReorderLevel</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.Discontinued</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Discontinued</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;/</span><span style="color: #a31515;">return</span><span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-join</span><span style="color: blue;"> </span><span style="color: red;">alias</span><span style="color: blue;">=</span>"<span style="color: blue;">Category</span>"<span style="color: blue;"> </span><span style="color: red;">property</span><span style="color: blue;">=</span>"<span style="color: blue;">Product.Category</span>"<span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Category.CategoryId</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Id</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Category.CategoryName</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Name</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &nbsp; &lt;</span><span style="color: #a31515;">return-property</span><span style="color: blue;"> </span><span style="color: red;">column</span><span style="color: blue;">=</span>"<span style="color: blue;">Category.Description</span>"<span style="color: blue;"> </span><span style="color: red;">name</span><span style="color: blue;">=</span>"<span style="color: blue;">Description</span>"<span style="color: blue;"> /&gt;</span></p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &nbsp; &lt;/</span><span style="color: #a31515;">return-join</span><span style="color: blue;">&gt;</span></p>
<p style="margin: 0px;">&nbsp; &nbsp; exec dbo.GetProductsByCategoryId :CategoryId</p>
<p style="margin: 0px;"><span style="color: blue;">&nbsp; &lt;/</span><span style="color: #a31515;">sql-query</span><span style="color: blue;">&gt;</span></p>
</div>
<p>

We map each column of the Product table to its correct property of the Product class.  Notice that we defined the 'Product' alias for this part of the data.  Then we use the return-join element to map the joined properties to the 'Product.Category' property.  This might look a bit weird at first.  You have to specify the alias of the owning object (which in our case is the 'Product' alias), and then you need to specify the name of the property of the owning object upon which the other part of the data should be mapped (in our case, the 'Category' property of the 'Product' object).
Now we can retrieve the data like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">IQuery</span> query = Session.GetNamedQuery(<span style="color: #a31515;">"GetProductsByCategoryId"</span>);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; query.SetInt32(<span style="color: #a31515;">"CategoryId"</span>, 1);</p>
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">IList</span> results = query.List();</p>
</div>
<p>
 
I first tried to use the IQuery's generic List of T method which i had hoped would give me a generic list of Product entities.  But i couldn't get that working. So i tried the regular List method, and it turns out that NHibernate doesn't just give me a list of Product entities... it gives me a list where each item in the list is an object array where the first item in the array is the Product entity, and the second item is the Category.  Each Product entity's Category property references the correct Category instance though.  So you can get the product instances like this:
<code>
</code></p>
<div style="font-family: Consolas; font-size: 10pt; color: black; background: white;">
<p style="margin: 0px;">&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; <span style="color: #2b91af;">IEnumerable</span>&lt;<span style="color: #2b91af;">Product</span>&gt; products = results.Cast&lt;<span style="color: #2b91af;">Object</span>[]&gt;().Select(i =&gt; (<span style="color: #2b91af;">Product</span>)i[0]);</p>
</div>
<p>

There's probably an easier way to just get the list of Product entities from the named query, but i haven't found it yet :)</p>
