---
layout: post
title: "How-To: Using the N* stack, part 1"
date: 2009-08-11 20:02:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "MVCContrib", "ASP.NET MVC", "Fluent NHibernate", "jQuery", "Ninject"]
alias: ["/blogs/nhibernate/archive/2009/08/11/how-to-using-the-n-stack-part-1.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>&nbsp;</p>
<div>
<p>This is the first post in a series where I show you step-by-step how to get your first ASP.NET MVC website up off the ground. By the end of this series, we&rsquo;ll have a working web application for registering community college students. More importantly, you'll have a template you can easily follow for your own projects.</p>
<p>In this first post, I&rsquo;ll show you how to set up your visual studio solution.</p>
<p>In this series, we&rsquo;ll use these tools:</p>
<ul>
<li><strong><a href="http://www.asp.net/mvc/" target="_blank">ASP.NET MVC</a></strong>&nbsp;is a free, fully Microsoft-supported product that, unlike ASP.NET WebForms, gives you complete control over your application. You can use the Web Platform Installer or download the MSI installer package directly.</li>
<li><strong><a href="http://www.codeplex.com/MVCContrib" target="_blank">MVCContrib</a></strong>&nbsp;&ndash; This is the contrib project for ASP.NET MVC. It adds additional functionality to and makes ASP.NET MVC easier to use.</li>
<li><strong><a href="http://jquery.com/" target="_blank">jQuery</a></strong>&nbsp;&ndash; This is an open-source javascript library that does just about everything, and supports every major modern browser out there. Yes, you hate javascript. You&rsquo;re going to love jQuery. I promise. This is included in the ASP.NET MVC download.</li>
<li><strong><a href="http://sourceforge.net/projects/nhibernate/" target="_blank">NHibernate 2,1</a></strong>&nbsp;is a well-known, mature, open source object relational mapper (ORM). It helps you get on with writing you application, instead of spending days, weeks, or even months writing a data access layer.</li>
<li><strong><a href="http://fluentnhibernate.org/downloads" target="_blank">Fluent NHibernate</a></strong>&nbsp;&ndash; This is a library for configuring NHibernate using an english-like syntax. It saves you from hacking through dozens of XML configuration files. Scroll to the bottom of the downloads page and get the latest compiled binaries.</li>
<li><strong><a href="http://ninject.org/" target="_blank">Ninject</a></strong>&nbsp;is my personal favorite dependency injection (DI) / inversion of control (IoC) framework. It allows you to automatically wire up services to your objects. If you&rsquo;ve never done DI or IoC before, you&rsquo;re going to have a great &ldquo;ah-ha!&rdquo; moment. We&rsquo;ll be using version 1.</li>
</ul>
<p>You will also need:</p>
<ul>
<li>.NET Framework 3.5 SP1</li>
<li>Visual Studio 2008 SP1. The Web Dev Express version may also work. I haven&rsquo;t tried it.</li>
<li>The latest version of NUnit</li>
<li>Any major database supported by NHibenate. This can range from Oracle to SQL Server to MySQL to SQLite. I&rsquo;ll be using SQL server in my examples, but if you have a favorite, you can easily use that instead.</li>
</ul>
<p>I also suggest you get some kind of source control. You&rsquo;ll want to play around and experiment as we go along.</p>
<p>OK. You&rsquo;ve downloaded all of that? Good. Let&rsquo;s talk terminology for a minute.</p>
<ul>
<li><strong>MVC</strong>&nbsp;stands for&nbsp;<strong>Model-View-Controller</strong>. This separation of responsibilities allows you greater flexibility to adapt and change your application.</li>
<li><strong>Model</strong>&nbsp;&ndash; This term refers to all of your entities &ndash; your business objects. In terms of a billing application, this would be your invoices, invoice items, customers, products, etc. &ndash; all of the &ldquo;real-world things&rdquo; your application represents.</li>
<li><strong>View</strong>&nbsp;&ndash; Each view presents a specific business object in a specific way. For example, you may have a view for editing customer data and another for displaying an invoice. You can also think of views as the pages that make up your application.</li>
<li><strong>Controller</strong>&nbsp;&ndash; Controllers are the glue that bind a view to a specific entity in your model. They are also responsible for all of the flow of your application from page to page.</li>
<li><strong>Inversion of Control</strong>&nbsp;(<strong>IoC</strong>) is the concept that your objects do not explicitly create the services that they need. Instead, they get them from some container of services. Hence, the inversion. Your classes don&rsquo;t specify a specific implementation of the service, only the type of service they need &ndash; an interface. This loose coupling allows you to easily swap out implementations of those services without having to touch every class that uses them. I&rsquo;ve seen two major flavors of IoC: Service Locator and Dependency Injection.</li>
<li>A&nbsp;<strong>Service Locator</strong>&nbsp;is a central container where you specify which implementations of each service your application will use. Your objects request service implementations from the service locator. A service locator is typically a singleton, which is why I don&rsquo;t like it.</li>
<li><strong>Dependency Injection</strong>&nbsp;(<strong>DI</strong>) is a method of wiring your objects to the services they depend on as the object is built. These services are typically passed in as parameters on the object&rsquo;s constructor. The object itself is built by the DI framework, in this case, Ninject. The process of building dependencies can be many layers deep. The<a href="http://dojo.ninject.org/Dependency%20Injection%20By%20Hand.ashx" target="_blank">Ninject Dojo</a>&nbsp;has a great tutorial on dependency injection. If you&rsquo;re new to IoC, it&rsquo;s a great place to start learning. Once you have the &ldquo;ah ha!&rdquo; moment, the migraine will stop and you&rsquo;ll never look at code the same again. I promise.</li>
</ul>
<h3>Setting up the solution</h3>
<p><em>Disclaimer: This is how I have learned to set up my projects. I&rsquo;m sure others have differing opinions. I&rsquo;d love to hear them. I don&rsquo;t claim to be an expert, just a curious professional looking to improve.</em></p>
<p>Setting up the project is fairly straight-forward. We&rsquo;ll do almost everything through Visual Studio. Just follow these steps.</p>
<ol>
<li>
<h4>Create the solution and web project</h4>
<p>In Visual Studio, start a new ASP.NET MVC Web Application. This template is added to Visual Studio when you install ASP.NET MVC. I&rsquo;ll be calling my solution NStackExample.<a href="http://jasondentler.com/blog/wp-content/uploads/2009/08/image.png"><br /><img title="image" src="http://jasondentler.com/blog/wp-content/uploads/2009/08/image_thumb.png" border="0" alt="image" width="534" height="293" style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a></p>
<p>There&rsquo;s a few things to note here. First, we&rsquo;re creating a solution directory. Second, notice how we&rsquo;ve appended .Web to the name of our web project, but not the solution.</p>
<p>This web project will contain all of the views. Despite the implied direction from Microsoft through the ASP.NET MVC template, it won&rsquo;t contain the model or the controllers.</p>
</li>
<li>
<h4>Create a library directory</h4>
<p>Inside your solution directory, create a directory for all 3rd party libraries used in your project. I call mine Solution Items. The name you give it isn&rsquo;t as important as the fact that you have one. So, in the example shown above, I would create the directory C:\Users\Jason\Documents\Visual Studio 2008\Projects\NStackExample\Solution items. Copy these 15 assemblies to the library directory:</p>
<ul>
<li>From MVCContrib:
<ul>
<li>MVCContrib.dll</li>
<li>Microsoft.Web.Mvc.dll</li>
<li>System.Web.Abstractions.dll</li>
<li>System.Web.Mvc.dll</li>
<li>System.Web.Routing.dll</li>
</ul>
</li>
<li>From NHibernate:
<ul>
<li>Antlr3.Runtime.dll</li>
<li>Iesi.Collections.dll</li>
<li>log4net.dll</li>
<li>NHibernate.dll</li>
<li>Castle.Core.dll</li>
<li>Castle.DynamicProxy2.dll</li>
<li>NHibernate.Bytecode.Castle.dll</li>
</ul>
</li>
<li>FluentNHibernate.dll from Fluent NHibernate</li>
<li>From Ninject:
<ul>
<li>Ninject.Core.Dll</li>
<li>Ninject.Framework.Mvc.Dll</li>
</ul>
</li>
</ul>
</li>
<li>
<h4>Create the core project</h4>
<p>This is your main project. It will contain your model, as well as interfaces for any services and strategies your application will use. It will not contain the implementation of any of those services. Those go in separate, easily replaceable assemblies.</p>
<p>Add a new &ldquo;Class Library&rdquo; project to your solution. We&rsquo;ll call this project NStackExample.Core.</p>
<p>Now, right click on the project and select properties, then click on the Application tab on the side. In the root namespace field, remove .Core.</p>
<p><img title="image" src="http://jasondentler.com/blog/wp-content/uploads/2009/08/image_thumb2.png" border="0" alt="image" width="554" height="57" /><br />We&rsquo;re doing this so our entities will be named NStackExample.Entity1, NStackExample.Entity2, etc. but the assembly will be NStackExample.Core.dll, which better describes it&rsquo;s purpose.</p>
</li>
<li>
<h4>Create the controller project</h4>
<p>Next, create another project specifically for the controllers of your MVC project. We&rsquo;re going to call it NStackExample.Controllers. Yes, the Microsoft ASP.NET MVC project template already has a folder for them. We&rsquo;re not going to use that folder because I think they should be better separated from the content of your website.</p>
</li>
<li>
<h4>Clean up your projects</h4>
<p>Delete all of these:</p>
<ul>
<li>The Class.vb or Class.cs files in the Core and Controllers projects.</li>
<li>In the NStackExample.Web project, delete:
<ul>
<li>The Controllers folder and all of it's contents.</li>
<li>The Models folder</li>
<li>The Microsoft AJAX script libraries in the Scripts folder</li>
<li>The Home and Account folders inside the Views folder</li>
<li>The LogOnUserControl in the Views folder</li>
</ul>
</li>
</ul>
<p><img title="image" src="http://jasondentler.com/blog/wp-content/uploads/2009/08/image_thumb4.png" border="0" alt="image" width="410" height="771" /></p>
</li>
<li>
<h4>Set up your references</h4>
<p>This is pretty straight forward.</p>
<ol>
<li>First, in your web project, remove the references to System.Web.Abstractions, System.Web.Mvc, and System.Web.Routing.</li>
<li>Next, in your web project, from the library directory we created in step 2, add references to these 10 assemblies:
<ul>
<li>log4net.dll</li>
<li>Microsoft.Web.Mvc.dll</li>
<li>MvcContrib.dll</li>
<li>NHibernat.Bytecode.Castle.dll</li>
<li>NHibernate.dll</li>
<li>Ninject.Core.dll</li>
<li>Ninject.Framework.Mvc.dll</li>
<li>System.Web.Abstractions.dll</li>
<li>System.Web.Mvc.dll</li>
<li>System.Web.Routing.dll</li>
</ul>
</li>
<li>In the web project, add references to the controllers project and the core project.</li>
<li>In the controllers project, add references to these 3 assemblies:
<ul>
<li>log4net.dll</li>
<li>MvcContrib.dll</li>
<li>System.Web.Mvc.dll</li>
</ul>
</li>
<li>In the controllers project, add a reference to the core project.</li>
</ol></li>
</ol>
<p>Did you notice how we didn&rsquo;t add any references in our core project? That&rsquo;s intentional. When a project needs to reference your model or service interfaces, you don&rsquo;t want to have required dependencies on other libraries and frameworks.</p>
<p>That&rsquo;s it. Your solution is set up and you&rsquo;re ready to start coding. In the next post, we&rsquo;ll start building the model.</p>
<p>Jason</p>
<p>- Blogged-out for the night</p>
<p>(Reposted from <a href="http://jasondentler.com/blog">my blog</a>)</p>
<p>Corrections:<br />Ninject.Framework.Mvc.dll is not included in the precompiled Ninject download. You can get the source code from the Ninject trunk and compile it yourself, or you can snag the dll from the source code in part 2.&nbsp;</p>
</div>
<p>&nbsp;</p>
