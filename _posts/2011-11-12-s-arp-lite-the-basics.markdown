---
layout: post
title: "S#arp Lite: The Basics"
date: 2011-11-12 00:19:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["S#arp Lite"]
alias: ["/blogs/nhibernate/archive/2011/11/11/s-arp-lite-the-basics.aspx"]
author: bmccafferty
gravatar: 3ce3492b12738e1a6f3cb595e70dec96
---
{% include imported_disclaimer.html %}
<p><span style="font-weight: normal;"><i>[The motivations for releasing S#arp Lite, in relation to S#arp Architecture, are described <a href="http://devlicio.us/blogs/billy_mccafferty/archive/2011/10/26/s-arp-lite-like-beer-but-better.aspx">here</a>.]</i></span></p>
<h2><strong>What is S#arp Lite?</strong></h2>
<p><span style="font-weight: normal;"><i>S#arp Lite is an architectural framework for the development of well-designed, custom-built, ASP.NET MVC applications using NHibernate for data access.</i></span></p>
<p><span style="font-weight: normal;"><img border="0" src="http://devlicio.us/resized-image.ashx/__size/550x0/__key/CommunityServer.Blogs.Components.WeblogFiles/billy_5F00_mccafferty/SharpLite_5F00_Logo.png" style="border: 0; float: right;" width="350" />ASP.NET MVC 3 is a terrific platform for delivering web-based applications. &nbsp;But, similar to ASP.NET, it does not provide specific guidelines for how to best use it in different project contexts. &nbsp;That's certainly the point; it exists to provide a flexible platform which may be used in a variety of situations without being biased towards one architecture or another, beyond the fundamentals of Model-View-Controller. &nbsp;The benefit of this is that you can structure MVC projects almost anyway you'd like; the drawback is that it's possible to have almost no consistency among your organization's projects, even if they're all using ASP.NET MVC.</span></p>
<p><span style="font-weight: normal;">That's where <a href="https://github.com/codai/Sharp-Lite">S#arp Lite</a> comes in to play. &nbsp;S#arp Lite comes packaged with three primary assets to provide a turnkey solution for developing well-designed, MVC applications:</span></p>
<ul>
<li>A project template to facilitate the creation of new S#arp Lite projects, pre-configured to communicate with your database using NHibernate;</li>
<li>A set of reusable class libraries which encapsulates infrastructural concerns (including a base repository); and&nbsp;</li>
<li>Architectural guidance on how to build out a S#arp Lite project.</li>
</ul>
<p>
Currently, the architectural guidance is demonstrated via the sample project which has been included in the S#arp Lite release package. &nbsp;Architectural guidelines are also enforced by the direction of dependencies among the project layers. &nbsp;(This will be discussed in more detail below.)</p>
<p>The overall objective is to allow your development team to more easily develop ASP.NET MVC applications which adhere to well founded principles, such as <a href="http://www.infoq.com/minibooks/domain-driven-design-quickly">domain-driven design</a> and <a href="http://www.agiledata.org/essays/tdd.html">test-driven development</a>; without being bogged down with infrastructural setup and without sacrificing long-term maintainability and scalability of the solution.</p>
<p>As a quick side, the base repository class which S#arp Lite exposes is purposefully&nbsp;<i>very </i>simplistic. &nbsp;The base repository only includes the following methods:</p>
<ul>
<li>Get(id): &nbsp;returns an entity from the database having the Id provided,</li>
<li>GetAll(): &nbsp;returns an IQueryable&lt;&gt; which may be further filtered/transformed via LINQ,</li>
<li>SaveOrUpdate(entity): &nbsp;persists an entity to the database, and</li>
<li>Delete(entity): &nbsp;deletes an entity from the database.</li>
</ul>
<p>Keeping the base repository very light has greatly reduced bloat and places greater emphasis on the use of LINQ for retrieving results from GetAll(). &nbsp;We'll discuss this in more detail a bit later.</p>
<h2>Who is this intended for?</h2>
<p>The motivation for S#arp Lite came from working with many teams (including my own) who had been developing projects with <a href="https://github.com/sharparchitecture/Sharp-Architecture">S#arp Architecture</a>. &nbsp;To many, S#arp Architecture is simply too big of an architectural framework to easily get your head. &nbsp;When I used to discuss S#arp Architecture with teams who were considering using it, I would always suggest that their developers be very experienced and well versed with topics such as dependency inversion, low-level NHibernate, and domain-driven design.</p>
<p>The reality of business is that it's not likely that your team will be made up of all senior level developers who are all experts in these topics. &nbsp;S#arp Lite is intended to epitomize the underlying values of S#arp Architecture, strive to be equally scalable to larger projects, all while being tenable to a larger audience. &nbsp;In other words, you should be able to have a realistically skill-balanced team and still be able to successfully deliver a S#arp Lite application.</p>
<p>S#arp Lite is recommended for any mid-to-large sized ASP.NET MVC project. &nbsp;If you have a small mom &amp; pop store, you'd likely be better off using a less-tiered application setup. &nbsp;It scales well to very large projects. &nbsp;We're using it effectively on for applications which integrate with a half dozen other systems...so it certainly holds up to larger tasks as well.</p>
<h2>What does a S#arp Lite project look like?</h2>
<p>Creating a new S#arp Lite project is trivially simple:</p>
<ol>
<li>Download and unzip the <a href="https://github.com/codai/Sharp-Lite/downloads">S#arp Lite release package</a>&nbsp;from GitHub.</li>
<li>Follow the instructions within the <a href="https://github.com/codai/Sharp-Lite/blob/master/README.txt">README.txt</a> to creation your S#arp Lite project with <a href="http://opensource.endjin.com/templify/">Templify</a>&nbsp;(a brilliant little tool).</li>
</ol>
<p>After you've created a S#arp Lite project, you'll find the following directory structure under the root folder:</p>
<ul>
<li><strong>app</strong>: &nbsp;This folder holds the source of the project; i.e., the code that you're getting paid to write.</li>
<li><strong>build</strong>: &nbsp;This initially empty folder is a placeholder for your build-related artifacts, such as your "publish" folder, NAnt or MSBuild artifacts, etc.</li>
<li><strong>docs</strong>: &nbsp;This initially empty folder contains all of the documents for your project. &nbsp;Keeping them here keeps all of your docs checked in with the code.</li>
<li><strong>lib</strong>: &nbsp;This folder contains all of the DLL dependencies for your project, such as log4net.dll, SharpLite.Domain.dll, System.Web.Mvc.dll, etc.</li>
<li><strong>logs</strong>: &nbsp;This initially empty folder is intended to hold any generated log files. &nbsp;The generated project's web.config used this folder for dumping out log4net logs.</li>
<li><strong>tools</strong>: &nbsp;This initially empty folder is intended to hold any third party install files or other dependencies which the team may need to work on the project. &nbsp;For example, this is where we store the latest installation of Telerik ASP.NET MVC and NUnit, used by the project. &nbsp;Having all of your installable dependencies, checked in with the code, makes it much easier to get "the new guy" up and running quickly.</li>
</ul>
<p>The auto-generated folder structure is just a means to help keep your digital assets and solution files organized. &nbsp;The more interesting stuff is in the /app folder which houses the source code of the solution. &nbsp;Before we delve into the projects included in a S#arp Lite project, let's take a birds eye view of the overall architecture.</p>
<p><img src="http://devlicio.us/resized-image.ashx/__size/550x0/__key/CommunityServer.Blogs.Components.WeblogFiles/billy_5F00_mccafferty/SharpLiteArchitecture.png" border="0" style="border: 0;" /></p>
<p>The diagram above reflects the layers of a S#arp Lite project, implemented as separate class libraries and an ASP.NET MVC Web Project. &nbsp;Having the tiers in separate class libraries allows you to enforce the direction of dependency among them. &nbsp;For example, because YourProject.Tasks depends on YourProject.Domain, YourProject.Domain cannot have any direct dependencies on a calss within YourProject.Tasks. &nbsp;This singled-directional dependency helps to enforce how the architecture is to remain organized.</p>
<p>While the diagram above describes the basic purpose of each layer, it's most assistive to look at an example project to have a clearer understanding of the scope of responsibilities of each layer. &nbsp;Accordingly, let's examine the tiers of the MyStore example application which was included in the S#arp Lite release package.</p>
<h3>Examining the Layers of MyStore Sample Application</h3>
<p>The MyStore sample application, included in the release zip, demonstrates the use of S#arp Lite for a fairly typical CRUD (create/read/update/delete) application. &nbsp;It includes managing data and relationships such as one:one, one:many, many:many, and parent/child. &nbsp;Let's take a closer look at the relational model.</p>
<p><img border="0" src="http://devlicio.us/resized-image.ashx/__size/550x0/__key/CommunityServer.Blogs.Components.WeblogFiles/billy_5F00_mccafferty/MyStoreRelationalModel.png" style="border: 0;" /></p>
<p>The diagram above represents the relational object model, as implemented within a SQL Server database. &nbsp;It's a very simple model with basic relationships, but it still brings up a lot of interesting discussion points when we go to translate this relational model into the object-oriented design of our application.</p>
<p>For example, each customer entity contains address information (stored as StreetAddress and ZipCode in the Customers table); in the domain, we want the address information pulled out into a separate object called Address. &nbsp;Having this information as a separate object more easily allows us to add behavior to the Address object while keeping those concerns separate from the Customer object, such as integration with a USPS address validation service. &nbsp;(Arguably, such a service would be in a stand-alone service class, but you get the idea.)</p>
<p>As another example, the many:many Products_ProductCategories table shouldn't have a similarly named class in our object model; instead, we would expect Products to have a listing of ProductCategories and/or vice-versa.</p>
<p>The sample application includes examples of how all of this and mappings of the classes themselves have been achieved almost entirely via <a href="http://en.wikipedia.org/wiki/Convention_over_configuration">coding-by-convention</a>. &nbsp;Let's now look at the sample application, layer-by-layer, and interesting points along the way.</p>
<hr />
<h4>MyStore.Domain</h4>
<p>This layer of the application contains the heart of the application; it represents the core domain of our product. &nbsp;All the other layers exist simply to support the user's need to interact with the domain. &nbsp;In a S#arp Lite project, the domain layer contains four types of objects:</p>
<ul>
<li>Domain Objects</li>
<li>Query Objects</li>
<li>Query Interfaces</li>
<li>Custom Validators</li>
</ul>
<p>Let's review each in turn.</p>
<p><strong><i>Domain Objects</i></strong></p>
<p>Alright, so maybe this is a whole bunch of types of objects, but they all have the same purpose - they exist to implement the domain of our application. &nbsp;They consist of entities, value objects, services (e.g., calculators), factories, aggregates...all organized into modules, usually expressed as separate namespaces. &nbsp;(I highly recommend Eric Evans' <a href="http://www.amazon.com/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215">Domain-Driven Design</a>, Jimmy Nilsson's <a href="http://www.amazon.com/Applying-Domain-Driven-Design-Patterns-Examples/dp/0321268202">Applying Domain Driven Design and Patterns</a>, and <a href="http://www.amazon.com/Software-Development-Principles-Patterns-Practices/dp/0135974445">Agile Software Development</a> by Robert Martin to help guide you.) &nbsp;There are two namespaces in the sample project: &nbsp;the "ProductMgmt" namespace which contains everything related to product management, and the "root" namespace for, well, everything else. &nbsp;Your project will likely have others.</p>
<p>Let's now take a look at the Customer class within the sample project as an example of an entity. &nbsp;There are some important items to note:</p>
<ul>
<li>Customer inherits from Entity (which is from SharpLite.Domain.dll). &nbsp;The Entity base class A) signals that this class is a persisted object which has an associated table in the database, B) provides an Id property (no biggie there), and C) facilitates comparing two entities to each other. &nbsp;If two entities are of the same type and have the same Id, then you know they're the same object. &nbsp;But what if you're comparing two "transient" entities; i.e., two entities which have not yet been persisted to the database. &nbsp;As another example, how would you go about comparing a transient entity to entities that have been persisted.<br /><br />For this we need to compare "domain signatures." &nbsp;A domain signature is the fingerprint of what makes the entity unique <i>from a business perspective</i>. &nbsp;In other words, which property(s) of an object would make it identifiable without having an Id property? &nbsp;Looking at the Customer class, we see that there are two properties decorated with the attribute "DomainSignature." &nbsp;Furthermore, the class itself is decorated with the attribute "HasUniqueDomainSignature." &nbsp;This means that no two objects may exist having the same first and last name. &nbsp;(This will not be appropriate in all scenarios; but should reflect the domain signature of the object in the context of the application.) &nbsp;The described attributes are included in SharpLite.Domain.dll and support automatic validation of the class' domain signature. &nbsp;So if you try to add a new customer with the same first and last name as an existing customer, a validation message will let you know this is not allowed.<br />
<pre name="code" class="c#">[HasUniqueDomainSignature(...
public class Customer : Entity
{
    [DomainSignature]
    ...
    public virtual string FirstName { get; set; }</pre>
&nbsp;</li>
<li>The Customer class pulls encapsulates the address information from the Customers table into a separate Address class. &nbsp;Interestingly, NHibernate "loquacious" mapping (aka - code by convention) automatically maps the related table columns into this "component" object.</li>
<li>Customer has an IList of Orders with a protected setter; the collection is initialized in the constructor. &nbsp;This is done for two reasons: &nbsp;1) by design, the collection will <i>never</i>&nbsp;be null (which avoids a lot of object reference exception avoidance), and 2) we don't have to worry about NHibernate losing its pointer to the original collection loaded from the database. &nbsp;This collection "pattern" is simply good practice for exposing/protecting the collection.<br />
<pre name="code" class="c#">public class Customer : Entity
{
    public Customer() {
        Orders = new List<order>();
    }

    public virtual IList<order> Orders { get; protected set; }</order></order></pre>
</li>
<li>Validation is enforced with standard, .NET <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.dataannotations.aspx">data annotations</a>. &nbsp;No need for NHibernate.Validator or other validation mechanism when it's all available via the .NET library. &nbsp;And whenever you run into limitations, you can simply create a custom validator.</li>
</ul>
<p><i style="font-weight: bold;">Query Objects</i></p>
<p>Regularly, we need to filter information returned from the database. &nbsp;For example, we may just want to return "active" customers vs. all the customers in the database. &nbsp;For performance reasons, it's obviously better to put as much filtering work on the shoulders of the database. &nbsp;Before LINQ providers, it was difficult to find the appropriate balance between filtering on the domain side or filtering on the database side. &nbsp;But with LINQ and IQueryable, filtering can be developed within the domain while it's still executed on the database. &nbsp; Brilliant! &nbsp;To facilitate this, every repository (e.g., IRepository&lt;Customer&gt;) exposes the method GetAll() which returns IQueryable&lt;&gt;.</p>
<p>The abso-friggin-spectacular side effect of this is that we can avoid having specialty "repository" methods which exist simply to hide away the details of the underlying data-access mechanism. &nbsp;There are two kinds of query objects in a S#arp Lite project:</p>
<ul>
<li><strong>Specification Query Objects</strong>: &nbsp;Specification query objects take a list and filter the results down to a smaller list, based on some criteria. &nbsp;In the sample project, the specification query class, MyStore.Domain.FindActiveCustomers, provides an extension method to IQueryable&lt;&gt; with any filter parameters passed in to the method. &nbsp;Alternatively, the query object could be a POCO class, accepting an IQueryable&lt;&gt; and filtering, accordingly. &nbsp;The benefit to setting up the specification query object as an extension, albeit, with additional indirection, is that multiple queries may be chained, all while taking advantage of IQuerable&lt;&gt;'s delayed querying (i.e., only one query will be sent to the database even if you chain multiple queries.<br />
<pre name="code" class="c#">public static class FindActiveCustomersExtension
{
    public static IQueryable<customer> FindActiveCustomers(this IQueryable<customer> customers) {
        return customers.FindActiveCustomers(MINIMUM_ORDERS_TO_BE_CONSIDERED_ACTIVE);
    }

    public static IQueryable<customer> FindActiveCustomers(this IQueryable<customer> customers, int minimumOrders) {
        return customers.Where(c =&gt;
            c.Orders.Count &gt;= minimumOrders);
    }

    private const int MINIMUM_ORDERS_TO_BE_CONSIDERED_ACTIVE = 3;
}</customer></customer></customer></customer></pre>
To me, the real beauty in this is that the query object may live in the domain, and be tested as a first class citizen of the domain, without introducing any dependencies to the underlying data-access layer (whether that be NHibernate, Entity Framework, etc.).&nbsp;&nbsp;&nbsp;</li>
<li><strong>Report Query Objects</strong>: &nbsp;Report query objects take a list, filtering if necessary, transforming and returning the results as a DTO or list of DTOs. &nbsp;Imagine that you have a summary dashboard in your application; e.g., a page which shows how many orders each customer has placed and what is each customer's most frequently purchased product. &nbsp;In this scenario, we'd ultimately like a list of DTOs containing each customer's name, his/her order count, and his/her favorite product. &nbsp;There are a few options to tackling this:
<ul>
<li>Create a DB stored procedure, binding the results to the DTOs list (and thus put processing logic onto the DB),</li>
<li>Use NHibernate Criteria, HQL or named query to retrieve the results (and tightly couple your data-access code to NHibernate),</li>
<li>Traverse the object model on the domain side to collate the information (can you say <a href="http://use-the-index-luke.com/sql/join/nested-loops-join-n1-problem">n+1</a>?), or</li>
<li>Use clean and simple, data-access agnostic LINQ (and keep it in the domain).</li>
</ul>
<br />2 points if you guess which one I'm leaning towards.  Let's look MyStore.Domain.Queries.QueryForCustomerOrderSummariesExtension for an example:
<pre name="code" class="c#">public static class QueryForCustomerOrderSummariesExtension
{
    public static IQueryable<customerordersummarydto> QueryForCustomerOrderSummaries(this IQueryable<customer> customers) {
        return from customer in customers
                select new CustomerOrderSummaryDto() {
                    FirstName = customer.FirstName,
                    LastName = customer.LastName,
                    OrderCount = customer.Orders.Count
                };
    }
}</customer></customerordersummarydto></pre>
Again, the advantage of this is that it can live within the domain layer and act as a reusable reporting query without introducing dependencies to the underlying data-access layer.
</li>
</ul>
<p>You have a lot of flexibility on how you use query objects and where they live. &nbsp;For example, you could use an ad-hoc report query (i.e., a LINQ query not encapsulated by a class) which lives within a method in the tasks layer. &nbsp;Although I'd advise against it, you could even use an ad-hoc query within a controller's method. &nbsp;So the provided samples are just that, samples of a particular approach. &nbsp;What's most important is to agree as a team how you'll encapsulate and organize query objects. &nbsp;In the sample project, queries are encapsulated as query objects and stored within a "Queries" folder - one folder per namespace.</p>
<p><strong><strong>Query Interfaces</strong></strong></p>
<p>In the <i>very </i>unlikely event that you need to leverage the data-access mechanism directly, instead of LINQing IQueryable, the domain layer may also contain any query interfaces which define a query to be implemented by the data-access layer. &nbsp;(This is akin to creating custom repository interfaces in S#arp Architecture.)</p>
<p>The disadvantages to this approach are three-fold:</p>
<ul>
<li>It introduces a layer of indirection to the developer,</li>
<li>It more tightly couples your code to the underlying data-access layer (since some of your application's logic is now <i>in</i> the data-access layer), and</li>
<li>It becomes trickier to unit test the query since you need an in-memory or live database to test the implementation.</li>
</ul>
<p>But, I can foresee that there may be a situation where this is necessary if you have a very complicated query, need to leverage NHibernate detached queries, or simply can't do what needs to be done via LINQ. &nbsp;Accordingly, three steps would need to be taken to support the query:</p>
<ol>
<li>Define the query interface in YourAppProject.Domain (e.g.,&nbsp;MyStore.Domain.ProductMgmt.Queries.IQueryForProductOrderSummaries.cs),</li>
<li>Implement the concrete query class in YourAppProject.NHibernateProvider (e.g.,&nbsp;MyStore.NHibernateProvider.Queries.QueryForProductOrderSummaries.cs), and</li>
<li>Register the implementation with the IoC to resolve requests to the interface (e.g.,&nbsp;MyStore.Init.DependencyResolverInitializer).</li>
</ol>
<p>Obviously, not as clean as using Specification and Report Query Objects, but available if absolutely necessary.</p>
<p><strong><span></span>Custom Validators</strong></p>
<p>As discussed previously, S#arp Lite uses .NET's data annotations for supporting validation. &nbsp;(You could use something else, like <a href="/wikis/validator/nhibernate-validator-1-0-0-documentation.aspx">NHibernate.Validator</a> if you prefer.) &nbsp;The data annotations are added directly to entity classes, but could instead be added to form DTOs if you feel that entities shouldn't act as form validation objects as well.</p>
<p>Sometimes, data annotations aren't powerful enough for the needs of your domain; e.g., if you want to compare two properties. &nbsp;Accordingly, you can develop <a href="http://odetocode.com/blogs/scott/archive/2011/02/21/custom-data-annotation-validator-part-i-server-code.aspx">custom validators</a> and store them within a "Validators" folder. &nbsp;If the custom validator is specific to a class, and never reused, then I'll usually just add the custom validator class as a private subclass to the class which uses it. &nbsp;In this way, the class-specific validator is neatly tucked away, only accessible by the class which needs it. &nbsp;S#arp Lite uses a custom validator to determine if an object is a duplicate of an existing object, using its domain signature: &nbsp;\SharpLiteSrc\app\SharpLite.Domain\Validators\HasUniqueDomainSignatureAttribute.cs.</p>
<p><strong>
</strong></p>
<hr />
<p><strong>
</strong></p>
<h4><strong>MyStore.Tasks</strong></h4>
<p><strong>
</strong></p>
<p>This layer of the application contains the task-coordination logic, reacting to commands sent from, e.g., a controller in the presentation layer. &nbsp;(This layer is also described as a <a href="http://martinfowler.com/eaaCatalog/serviceLayer.html">Service Layer</a> in Martin Fowler's <a href="http://www.amazon.com/Patterns-Enterprise-Application-Architecture-Martin/dp/0321127420">PoEAA</a>.) &nbsp;For example, let's assume that your application integrates with a number of other applications. &nbsp;This layer would communicate with all of the other applications (preferably via interfaces), collating the information, and handing it off to the domain layer for performing domain logic on the data. &nbsp;As a simpler example, if your domain layer contains some kind of FinancialCalculator class, the tasks layer would gather the information needed by the calculator, from repositories or other sources, and pass the data via a method to FinancialCalculator.</p>
<p>As a secondary responsibility, the tasks layer returns data, as view-models, DTOs, or entities, to the presentation layer. &nbsp;For example, the presentation layer may need to show a listing of customers along with Create/Edit/Delete buttons if the logged in user has sufficient rights to do so. &nbsp;The tasks layer would get the listing of customers to show and would determine what security access the user has; it would then return a view model containing the customers listing along with a bool (or security object) describing if the user has rights to modify the data.</p>
<p>It's important to note the difference between the logic found within the tasks layer and that found within the domain layer. &nbsp;The tasks layer should contain minimal logic to coordinate activities among services (e.g., repositories, web services, etc.) and the domain layer (e.g., calculator services). &nbsp;Think of the tasks layer as an effective boss (does that exist?)...the boss helps to facilitate communications among the team and tells the team members what to do, but doesn't do the job itself.</p>
<p>The tasks layer contains two kinds of objects:</p>
<ul>
<li>Task Objects</li>
<li>View Models</li>
</ul>
<p><strong><i>Task Objects</i></strong></p>
<p>These are the tasks themselves. &nbsp;The most common kind of task is coordinating CUD logic (CRUD without the read). &nbsp;It's so common, in fact, that S#arp Lite projects includes a (completely customizable) BaseEntityCudTasks class to encapsulate this common need. &nbsp;Looking at the sample project, you can see how&nbsp;BaseEntityCudTasks&nbsp;is extended and used; e.g., within MyStore.Tasks.ProductMgmt.ProductCudTasks.</p>
<p>As the project grows, the task-layer responsibilities will inevitably grow as well. &nbsp;For example, on a current project which integrates with multiple external applications, a task class pulls schedule information from Primavera 6, cost information from Prism, and local data from the database via a repository. &nbsp;It then passes all of this information to a MasterReportGenerator class which resides in the domain. &nbsp;Accordingly, although the task class is non-trivial, it's simply pulling data from various sources, leaving it up to the domain to the heavy processing of the data.</p>
<p>It's important to note that a task object's service dependencies (repositories, web services, query interfaces, etc.) should be injected via <a href="/blogs/billy_mccafferty/archive/2009/11/09/dependency-injection-101.aspx">dependency injection</a>. &nbsp;This facilitates the ability to unit test the task objects with <a href="http://martinfowler.com/articles/mocksArentStubs.html">stubbed/mocked</a> services. &nbsp;With MVC 3, setting up dependency injection is very simple and makes defining your task objects dependencies a breeze:</p>
<pre name="code" class="c#">public ProductCategoryCudTasks(IRepository&lt;ProductCategory&gt; productCategoryRepository) : base(productCategoryRepository) {
    _productCategoryRepository = productCategoryRepository;
}</pre>
<p>Here we see that the&nbsp;<span>ProductCategoryCudTasks class requires a&nbsp;</span><span>IRepository&lt;ProductCategory&gt; injected into it, which will be provided at runtime by the IoC container or by you when unit testing.</span></p>
<p><strong><i>View Models</i></strong></p>
<p>A view model class encapsulates information to be shown to the user. &nbsp;It doesn't say <i>how</i>&nbsp;the data should be displayed, only <i>what</i>&nbsp;data should be displayed. &nbsp;Frequently, it'll also include supporting information for the presentation layer to then decide <i>how</i>&nbsp;the information is displayed; e.g., permissions information.</p>
<p>There's a lot of debate about where view model classes should reside. &nbsp;In my projects, I keep them in the tasks layer, with one ViewModels folder per namespace. &nbsp;But arguably, view model classes could live in a separate class library; that's for your team to decide at the beginning of a project.</p>
<hr />
<p><strong>MyStore.Web</strong></p>
<p>There's not much to say here. &nbsp;A S#arp Lite project uses all out-of-the-box MVC 3 functionality for the presentation layer, defaulting to Razor view engines, which you may change if preferred. &nbsp;The only S#arp Lite-isms (totally a word) in this layer are as follows:</p>
<ul>
<li>MyStore.Web.Global.asax invokes <code>DependencyResolverInitializer.Initialize();</code> to initialize the IoC container (discussed below),</li>
<li>MyStore.Web.Global.asax uses&nbsp;SharpModelBinder to act as the preferred form/model binder, and</li>
<li>Web.config includes an HttpModule to leverage a <a href="/blogs/nhibernate/archive/2011/03/03/effective-nhibernate-session-management-for-web-apps.aspx">session-per-request, NHibernate HTTP module</a>, found within the S#arp Lite source at \SharpLiteSrc\app\SharpLite.NHibernateProvider\Web\SessionPerRequestModule.cs.</li>
</ul>
<p>SharpModelBinder extends the basic form/model binding with capabilities to populate relationships. &nbsp;For example, suppose you have a Product class with a many:many relationship to ProductCategory. &nbsp;When editing the Product, the view could include a list of checkboxes for associating the product with one or more product categories. &nbsp;SharpModelBinder looks for such associations in the form and populates the relationships when posted to the controller; i.e., the Product which gets posted to the controller will have its ProductCategories populated, containing one ProductCategory for each checkbox that was checked. &nbsp;You can take a look at MyStore.Web/Areas/ProductMgmt/Views/Products/Edit.cshtml as an example.</p>
<p>Like task objects, controllers also accept dependencies via injection; e.g.&nbsp;MyStore.Web.Areas.ProductMgmt.Controllers.ProductsController.cs:</p>
<pre name="code" class="c#">public ProductsController(IRepository&lt;Product&gt; productRepository,
    ProductCudTasks productMgmtTasks, IQueryForProductOrderSummaries queryForProductOrderSummaries) {

    _productRepository = productRepository;
    _productMgmtTasks = productMgmtTasks;
    _queryForProductOrderSummaries = queryForProductOrderSummaries;
}</pre>
<p>In the example above, the controller requires an instance of&nbsp;<span>IRepository&lt;Product&gt;,&nbsp;</span><span>ProductCudTasks, and&nbsp;</span><span>IQueryForProductOrderSummaries passed to its constructor from the IoC container. &nbsp;</span>IQueryForProductOrderSummaries&nbsp;is an example of using a query interface, defined in the domain, for providing data-access layer specific needs. &nbsp;It's a very exceptive case and has only been included for illustrive purposes. &nbsp;You'd almost always be able to use specification and report query objects instead...or simply LINQ right off of&nbsp;IRepository&lt;Product&gt;.GetAll().</p>
<p>If you'd like to learn more about dependency injection in ASP.NET MVC 3, check out <a href="http://bradwilson.typepad.com/blog/2010/07/service-location-pt1-introduction.html">Brad Wilson's series of posts</a>&nbsp;on the subject. &nbsp;And for learning more about the basics of developing in the web layer, Steve Sanderson's <a href="http://www.amazon.com/Pro-ASP-NET-MVC-3-Framework/dp/1430234040/ref=sr_1_1?ie=UTF8&amp;qid=1321046999&amp;sr=8-1">Pro ASP.NET MVC 3 Framework</a>&nbsp;is a great read.</p>
<hr />
<h4><strong>MyStore.Init</strong></h4>
<p>This nearly anemic layer has one responsibility: &nbsp;perform generic, application initialization logic. &nbsp;Specifically, the initialization code included with a S#arp Lite project initializes the IoC container (<a href="http://structuremap.net/structuremap/">StructureMap</a>) and invokes the initialization of the NHibernate session factory. &nbsp;Arguably, this layer is so thin that its responsibilities could easily be subsumed by MyStore.Web. &nbsp;The great advantage to pulling the initialization code out into a separate class library is that MyStore.Web requires far fewer dependencies. &nbsp;Note that MyStore has no reference to NHibernate.dll nor to StructureMap.dll. &nbsp;Accordingly, there is very little coupling&nbsp;(i.e., none)&nbsp;to these dependencies from the web layer...we like that. &nbsp;Among other things, this prevents anyone from invoking an NHibernate-specific function from a controller. &nbsp;This, in turn, keeps the controllers very decoupled from the underlying data-access mechanism as well.</p>
<hr />
<h4>MyStore.NHibernateProvider</h4>
<p>The next stop on our tour of the layers of a S#arp Lite project is the NHibernate provider layer. &nbsp;With S#arp Architecture, this layer would frequently get quite sizable with custom repositories and named queries. &nbsp;With the alternative use of query objects and LINQ on IQueryable&lt;&gt;, this class library should remain very thin. &nbsp;This class library contains three kinds of objects:</p>
<ul>
<li>NHibernate Initializer,</li>
<li>NHibernate Conventions,</li>
<li>Mapping Overrides, and</li>
<li>(very&nbsp;occasionally) Query Implementations.</li>
</ul>
<p>Let's look at each in turn.</p>
<p><strong><i>NHibernate Initializer</i></strong></p>
<p>NHibernate 3.2.0 introduces a built-in fluent API for configuration and mapping classes, nicknamed&nbsp;<a href="/wikis/howtonh/a-fully-working-skeleton-for-sexy-loquacious-nh.aspx">NHibernate's "Loquacious" API</a>. &nbsp;This is a direct&nbsp;<a href="http://lostechies.com/jamesgregory/2011/04/13/me-on-nhibernate-3-2/">affront</a>&nbsp;to <a href="http://fluentnhibernate.org/">Fluent NHibernator</a> which (as much as I have truly loved it...a sincere thank you to James Gregory) I feel is headed for obsolescence with these capabilities now being built right in to NHibernate. &nbsp;NHibernate 3.2's Loquacious API isn't yet as powerful as Fluent NHibernate, but will get there soon as more of <a href="http://code.google.com/p/codeconform/">ConfORM</a> is ported over to Loquacious API. &nbsp;On with the show...</p>
<p>There is one NHibernate initialization class with a S#arp Lite project; e.g.,&nbsp;MyStore.NHibernateProvider.NHibernateInitializer.cs. &nbsp;This class sets the connection string (from web.config), sets the dialect, tells NHibernate where to find mapped classes, and invokes convention setup (discussed next). &nbsp;Initializing NHibernate is very expensive and should only be performed once when the application starts. &nbsp;Accordingly, take heed of this if you decide to switch out the IoC initialization code (in MyStore.Init) with another IoC container.</p>
<p><strong><i>NHibernate Conventions</i></strong></p>
<p>The beauty of conventions is that we no longer need to include a class mapping (HBM or otherwise) for mapping classes to the database. &nbsp;We simply define conventions, adhere to those conventions, and NHibernate knows which table/columns to go to for what. &nbsp;S#arp Lite projects come prepackaged with the following, <i>customizable</i> conventions:</p>
<ul>
<li>Table names are a plural form of the entity name. &nbsp;E.g., if the entity is Customer, the table is Customers.</li>
<li>Every entity has an Id property mapped to an "Id" identity column (which can easily be changed to HiLo, Guid, or otherwise).</li>
<li>Primitive type column names are the same name as the property. &nbsp;E.g., if the property is FirstName, the column name is FirstName.</li>
<li>Foreign keys (associations) are the name of the property suffixed with "Fk." &nbsp;E.g., if the property is Order.WhoPlacedOrder, the column name (in the Orders table) is WhoPlacedOrderFk with a foreign key to the respective type's table (e.g., Customers).</li>
</ul>
<p>There is typically just one convention-setup class in a S#arp Lite project; e.g., MyStore.NHibernateProvider.Conventions. &nbsp;The only convention that isn't supported "out of the box" is a many:many relationship, which we'll discuss more below.</p>
<p><strong><i>Mapping Overrides</i></strong></p>
<p>There are times when conventions don't hold up. &nbsp;Examples include:</p>
<ul>
<li>Many-to-many relationships,</li>
<li>Enum as a property type,&nbsp;</li>
<li>Legacy databases which don't stick to (your) conventions, and&nbsp;</li>
<li>Anytime a convention is not followed for one reason or another.</li>
</ul>
<p>On the upside, this isn't too many cases...but we need to be able to handle the exceptions. &nbsp;Any exceptions to the conventions are defined as "mapping overrides." &nbsp;Examples of overrides may be found in MyStore.NHibernateProvider/Overrides. &nbsp;To make things easy, if an override needs to be added, simply implement MyStore.NHibernateProvider.Overrides.IOverride and include your override code. &nbsp;The MyStore.NHibernateProvider.Conventions class looks through the assembly for any classes which implements IOverride and applies them in turn. &nbsp;As a rule, I create one override class for each respective entity which requires an override.</p>
<p><strong><i>Query Implementations</i></strong></p>
<p>Lastly, the .NHibernateProvider layer contains any NHibernate-specific queries, which are implementations of respective query interfaces defined in the .Domain layer. &nbsp;97.6831% of the time, this will not be necessary as querying via LINQ, off of IQueryable&lt;&gt;, is the preferred approach to querying. &nbsp;But in the rare case that you need to implement a query using NHibernate Criteria, HQL, or otherwise, this is the layer to house it. &nbsp;A sample has been included as&nbsp;MyStore.NHibernateProvider.Queries.QueryForProductOrderSummaries.</p>
<hr />
<h4>MyStore.Tests</h4>
<p>At the end of our tour of the layers of a S#arp Lite project is the .Tests layer. &nbsp;This layer holds all of the unit tests for the project. &nbsp;S#arp Lite projects are generated with two unit tests out of the box:</p>
<ul>
<li>MyStore.Tests.NHibernateProvider.MappingIntegrationTests.CanGenerateDatabaseSchema(): &nbsp;This unit tests initializes NHibernate and generates SQL to reflect those mappings. &nbsp;This is a great test to run to verify that a class is being mapped to the database as expected; i.e., you can look at the generated SQL (in the Text Output tab in NUnit) to verify how a class is being mapped. &nbsp;As a side-benefit, you can copy the generated SQL and run it to make modifications to the database. &nbsp;Finally, the unit tests saves the generated SQL into /app/MyStore.DB/Schema/UnitTestGeneratedSchema.sql for additional reference.</li>
<li>MyStore.Tests.NHibernateProvider.MappingIntegrationTests.CanConfirmDatabaseMatchesMappings(): &nbsp;This unit tests initializes NHibernate and verifies that every entity maps successfully to the database. &nbsp;If you have a missing column, this test will let you know. &nbsp;It doesn't test everything, such as many-to-many relationships, but certainly 97.6831% of everything else.</li>
</ul>
<p>For an introduction to test-driven development, read Kent Beck's&nbsp;<a href="http://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530">Test Driven Development: By Example</a>. &nbsp;Going a step further, go with Gerard Meszaros' <a href="http://www.amazon.com/xUnit-Test-Patterns-Refactoring-Code/dp/0131495054/ref=sr_1_1?s=books&amp;ie=UTF8&amp;qid=1321055197&amp;sr=1-1">xUnit Test Patterns</a> and Michael Feathers' <a href="http://www.amazon.com/Working-Effectively-Legacy-Michael-Feathers/dp/0131177052/ref=sr_1_1?s=books&amp;ie=UTF8&amp;qid=1321055177&amp;sr=1-1">Working Effectively with Legacy Code</a>.</p>
<p>In S#arp Architecture, SQLLite was used to provide an in-memory database for testing custom repository methods. &nbsp;Since custom repositories have been mostly relegated to&nbsp;obsolescence, keeping SQLLite testing built-in to S#arp Lite would have been overkill and has been removed to keep things simpler. &nbsp;(Besides, you can always look at the S#arp Architecture code for that functionality if needed.)</p>
<h2>What's in the S#arp Lite Libraries?</h2>
<p>Most of what's relevant in the S#arp Lite class libraries has already been discussed while going through the sample project, but let's take a moment to see what all is in the reusalbe, S#arp Lite class libraries.</p>
<h4>SharpLite.Domain</h4>
<p>This class library provides support for the domain layer of your S#arp Lite project.</p>
<ul>
<li>ComparableObject.cs: &nbsp;Provides robust, hash code generator for any object which inherits from it. &nbsp;(It's much trickier to implement than you think. ;)</li>
<li>DomainSignatureAttribute.cs: &nbsp;An attribute used to decorate properties which make up a class' domain signature.</li>
<li>EntityWithTypedId (defined in Entity.cs): &nbsp;Provides a (non-mandatory)&nbsp;generic&nbsp;base class for your entities, including an Id property and the inclusion of domain signature properties when comparing like objects. &nbsp;It takes a single, generic parameter declaring the type of the Id property; e.g., int or Guid.</li>
<li>Entity.cs: &nbsp;Provides an&nbsp;EntityWithTypedId base class with an Id assumed to be of type int.</li>
<li>IEntityWithTypedId.cs: &nbsp;Provides an interface which may be used to implement your own entity base class.</li>
<li>/DataInterfaces/IDbContext.cs: &nbsp;Exposes an interface for controlling transactions.</li>
<li>/DataInterfaces/IEntityDuplicateChecker.cs: &nbsp;Exposes an interface for checking if an entity is a duplicate of one already in the database.</li>
<li>/DataInterfaces/IRepository.cs: &nbsp;Exposes a very basic repository including Get, GetAll (returning IQueryable), SaveorUpdate, and Delete.</li>
<li>/Validators/HasUniqueDomainSignatureAttribute.cs: &nbsp;An attribute which may be used to decorate a class to ensure that duplicates do not exist in the database having the same domain signature.</li>
</ul>
<h4><strong>SharpLite.EntityFrameworkProvider</strong></h4>
<p>The idea of this library is to provide a pluggable replacement for the NHibernateProvider (discussed next), if the team so chooses. &nbsp;This library has not been fully developed yet. &nbsp;Let me know if you're interested in contributing with this effort.</p>
<h4><strong>SharpLite.NHibernateProvider</strong></h4>
<p>This infrastructural class library provides everything necessary for S#arp Lite projects to communicate with the database via NHibernate.</p>
<ul>
<li>DbContext.cs: &nbsp;Implements IDbContext for transaction management.</li>
<li>EntityDuplicateChecker.cs: &nbsp;Implements&nbsp;IEntityDuplicateChecker for checking for entity duplicates.</li>
<li>LazySessionContext.cs: &nbsp;Supports NHibernate open-session-in-view; <a href="/blogs/nhibernate/archive/2011/03/03/effective-nhibernate-session-management-for-web-apps.aspx">originally written by&nbsp;Jose Romaniello</a>.</li>
<li>Repository.cs: &nbsp;Provides a minimalist base repository...feel free to extend as needed.</li>
<li>/Web/SessionPerRequestModule.cs: &nbsp;Provides the HTTP module in support of NHibernate open-session-in-view.</li>
</ul>
<h4>SharpLite.Web</h4>
<p>This class library provides MVC-specific needs for S#arp Lite projects...which consists entirely of SharpModelBinder.cs. &nbsp;This may be viewed as completely optional for your use in S#arp Lite projects.</p>
<ul>
<li>/Mvc/ModelBinder/EntityCollectionValueBinder.cs: &nbsp;Used by SharpModelBinder for translating a collection of inputs from the form into a collection of entities bound to the containing object.</li>
<li>/Mvc/ModelBinder/EntityRetriever.cs: &nbsp;Used by SharpModelBinder related classes for retrieving an entity from the database without knowing which repository to use <i>a priori</i>.</li>
<li>/Mvc/ModelBinder/EntityValueBinder.cs: &nbsp;Used by SharpModelBinder for translating a drop-down selection into an entity association bound to the containing object.</li>
<li>/Mvc/ModelBinder/SharpModelBinder.cs: &nbsp;Extends the ASP.NET MVC model binder with additional capabilities for populating associations with entities from the database.</li>
</ul>
<p>&nbsp;</p>
<p>Well, that's it in a nutshell for now. &nbsp;I sincerely hope that S#arp Lite will prove helpful to you and your team in developing well-designed, maintainable ASP.NET MVC applications that scale well as the project evolves. &nbsp;This architectural framework reflects lessons learned from years of <span style="text-decoration: line-through;">experience</span> blood, sweat, &amp; tears and countless ideas shamelessly stolen from those much smarter than I.</p>
<p>Enjoy!<br />Billy McCafferty<br /><a href="http://devlicio.us/blogs/billy_mccafferty">http://devlicio.us/blogs/billy_mccafferty</a>&nbsp;</p>
