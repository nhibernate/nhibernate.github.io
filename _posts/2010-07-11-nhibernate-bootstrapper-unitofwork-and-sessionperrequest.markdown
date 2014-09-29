---
layout: post
title: "NHibernate Bootstrapper: UnitOfWork and SessionPerRequest"
date: 2010-07-11 21:17:00 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2010/07/11/nhibernate-bootstrapper-unitofwork-and-sessionperrequest.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>This is the first sample in a series of blogs about NHibernate in ASP.Net environment. This version gives a user new to NHibernate the absolute minimum pieces to start a well architected application. A number of the pieces necessary for an enterprise-capable application are not yet included, but the foundation has been laid. Source code and starter solution described in this post are available at <a target="_blank" href="http://public.me.com/jw_davidson/NHibernateBootstrap_V1.0.zip">NHibernateBootstrap Download</a>. </p>
<p>The key pieces in this sample are demonstrations of the correct UnitOfWork pattern, using the NHibernate ISession based object with its transaction support. A DataAccessObject / Repository is also introduced that uses features from both styles of implementations and is also intended to work with Query Objects. The <em>Web.Config</em> file includes a starter configuration for NHibernate, using the LinFu proxy. The connection between the web application and NHibernate demonstrates a best practice, where the Session Per Request pattern is initialized in an<em> IHttpModule</em> -<em> RequestHttpModule.cs</em>. This is an implementation base on the<em> ManagedWebSessionContext</em>, and shows how to bind and unbind the session correctly.  </p>
<p>This web application sample is not a best practices sample for ASP.Net development, but future blogs will add features, especially where they take advantage of an NHibernate implementation. Some of the implementation of the Person page is not following normal Microsoft recommended methods, and appear to be more complex than necessary. These changes are part of a further foundation and will allow the page to be transformed later where more than 95% of the logic normally encapsulated in the page behind code becomes testable. Initially there will be some references to NHibernate in the Web Application project, but this is not a recommended practice - later modifications will move these references so that they are in the BusinessServices project.  </p>
<p>The one other item included in this sample is the Unit Test project. This test project connects to NHibernate using the <em>ThreadStaticSessionContext</em>. Each Test Fixture initializes its own <em>ISession</em> object and uses the same session object for all tests in that fixture. The app.config file for the test project, which configures the NHibernate support, is located in the bin/debug directory.  </p>
<h3>Solution Architecture</h3>
<p>The Bootstrapper uses a multi-project structure and a library at the solution level to hold all the files:  </p>
<ul>
<li>
<p>NHibernate Bootstrap Solution  </p>
<ul>
<li>
<p>SharedLibs - a folder containing all external reference dll's and associated files</p>
</li>
<li>
<p>BootstrapperUnitTests Project - holds unit tests</p>
</li>
<li>
<p>Infrastructure Project - holds high level Interface and class files that may be used in multiple projects in the solution</p>
</li>
<li>
<p>DomainModel Project - holds the object model for the solution</p>
</li>
<li>
<p>NHibernateDAO Project - the persistence layer, gets data into and out of the database based on the object model and holds the mapping files</p>
</li>
<li>
<p>DataServices Project - isolates the persistence layer from the rest of the application</p>
</li>
<li>
<p>BusinessServices Project - provides an integration of the business logic with the data and controls the flow of information to and from the presentation layer</p>
</li>
<li>
<p>WebNHibernate Project - provides a web based presentation layer</p>
</li>
</ul>
</li>
</ul>
<p>Jason Dentler has written a <a href="/blogs/nhibernate/search.aspx?q=dentler">series of blogs</a> about using NHibernate, and I am borrowing from his discussion on <a href="/blogs/nhibernate/archive/2009/09/07/part-8-daos-repositories-or-query-objects.aspx">DAOs, Repositories or Query Objects</a>. The basic setup of the persistence layer uses a DAO-type FindBy approach augmented with support for QueryObjects. It is not my intent to discuss this approach now, but to cover it in a later post.  </p>
<p>The purpose of this post is to discuss the<em> ISession</em> object and how to use it directly as a UnitOfWork, without an additional wrapper. The second purpose is to present a recommended solution for the SessionPerRequest architecture for an ASP.Net application.  </p>
<h3>SessionPerRequest Implementation</h3>
<p>The SessionPerRequest implementation is recommended as a best practice to ensure that NHibernate is the most responsive and utilizes the least possible resources in the Web Server environment. The <a href="/doc/nh/en/index.html#architecture-current-session">NHibernate.Context.ICurrentSessionContext</a> is discussed in the reference document: <a href="/doc/nh/en/index.html">NHibernate - Relational Persistence for Idiomatic .NET</a>. The appropriate choices for a web application are either <em>ManagedWebSessionContext</em> or the <em>WebSessionContext</em>. <em><span style="text-decoration: underline;">(@Fabio: Can you explain the difference between the 2 - I have reviewed the code and see that ManagedWebSessionContext supports a GetExistingSession() - Does the WebSessionContext need to be explicitly bound and unbound in each request?)</span></em>  </p>
<p>Numerous examples of using<em> ManagedWebSessionContext</em> use the <em>Global.asax</em> to connect the NHibernate context to the web server. This is a bad practice in that it means the web application must have a direct reference to NHibernate<em>.Context</em> in order to work. It is instead recommended that an<em> IHttpModule</em> be created, and that the binding module be in the same project where the NHibernate reference is - in this sample that would be the NHibernateDOA project. This serves to isolate NHibernate from the web application entirely. All that is required is that the web application bin directory have a copy of the NHibernate dlls.  </p>
<p>The code for the <em>IHttpModule</em> is shown below:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:414f7b62-23ae-4819-a023-72ab652c0b8e" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">RequestHttpModule.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Web;</li>
<li><span style="color:#0000ff">using</span> NHibernate;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate.Context;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> NHibernateDAO</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">RequestHttpModule</span> : <span style="color:#2b91af">IHttpModule</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> Dispose()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> Init(<span style="color:#2b91af">HttpApplication</span> context)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;context.BeginRequest += <span style="color:#0000ff">new</span> <span style="color:#2b91af">EventHandler</span>(context_BeginRequest);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;context.EndRequest += <span style="color:#0000ff">new</span> <span style="color:#2b91af">EventHandler</span>(context_EndRequest);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> context_BeginRequest(<span style="color:#2b91af">Object</span> sender, <span style="color:#2b91af">EventArgs</span> e)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ManagedWebSessionContext</span>.Bind(<span style="color:#2b91af">HttpContext</span>.Current, <span style="color:#2b91af">SessionManager</span>.SessionFactory.OpenSession());</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> context_EndRequest(<span style="color:#2b91af">Object</span> sender, <span style="color:#2b91af">EventArgs</span> e)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ISession</span> session = <span style="color:#2b91af">ManagedWebSessionContext</span>.Unbind(</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">HttpContext</span>.Current, <span style="color:#2b91af">SessionManager</span>.SessionFactory);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (session != <span style="color:#0000ff">null</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (session.Transaction != <span style="color:#0000ff">null</span> &amp;&amp; session.Transaction.IsActive)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Transaction.Rollback();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Flush();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Close();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<pre>&nbsp;</pre>
<p>The use of the <em>ManagedWebSessionContext</em> is fairly straight forward. It is important to note that this file has a reference to <em>System.Web</em>, which should be the only reference to this library outside of the the WebApplication itself. It is undesirable to reference the System.Web library external to the web application project as it will make testing of those components with that reference very difficult. 
</p>
<p>The <em>context_EndRequest</em> also contains a <em>Rollback</em> call, which will ensure that any pending transactions are terminated without writing to the database if your application has an unhandled error. 
</p>
<p>In order for the custom <em>IHttpModule</em> to be active in the web server it must be registered in the <em>Web.Config</em> file:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:f11002f6-2104-46f3-b594-f04027adc010" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Register RequestHttpModule</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">httpModules</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">add</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">RequestHttpModule</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">type</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">NHibernateDAO.RequestHttpModule, NHibernateDAO</span>"<span style="color:#0000ff">/&gt;</span></li>
<li>&nbsp;&nbsp;<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">httpModules</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">&lt;/</span><span style="color:#a31515">system.web</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">&lt;</span><span style="color:#a31515">system.webServer</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">modules</span><span style="color:#0000ff"> </span><span style="color:#ff0000">runAllManagedModulesForAllRequests</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">true</span>"<span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">add</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">RequestHttpModule</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">type</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">NHibernateDAO.RequestHttpModule, NHibernateDAO</span>"<span style="color:#0000ff">/&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">modules</span><span style="color:#0000ff">&gt;</span></li>
<li><span style="color:#0000ff">&lt;/</span><span style="color:#a31515">system.webServer</span><span style="color:#0000ff">&gt;</span></li>
</ol>
</div>
</div>
</div>
<p>I have included the <em>IHttpModule</em> reference twice. The first time is for configurations of the web server using Classic Mode and the second is for IIS 7 Integrated Pipeline. See <a href="http://msdn.microsoft.com/en-us/library/ms227673.aspx">http://msdn.microsoft.com/en-us/library/ms227673.aspx</a> 
</p>
<p>The final item necessary to make this work is an addition to the NHibernate configuration file. It is necessary to add the property</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:e8d24772-e3f6-4aca-9ee6-44fdf9e55fde" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">NHibernate ContextSession</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">current_session_context_class</span>"<span style="color:#0000ff">&gt;</span>NHibernate.Context.ManagedWebSessionContext, NHibernate<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
</ol>
</div>
</div>
</div>
<pre>&nbsp;</pre>
<p>This is shown below in the Web.Config described in the Minimal Configuration section. 
</p>
<h3>ISession UnitOfWork and Transactions</h3>
<p>The proper management of database connections is a key component of ensuring a highly responsive web application in ASP.Net. <a href="/doc/nh/en/index.html#transactions">http://nhforge.org/doc/nh/en/index.html#transactions</a> gives some guidance, but does not provide any code samples or say what the recommended practice should be. This lack of direction is partly due to the possible scope of applications for NHibernate in general. However, in an ASP.Net environment the rules are fairly simple. First, you should SessionPerRequest as detailed above. Second, all database access should be wrapped in a transaction and that transaction should be committed when the connection to the database can be released. There is an almost infinite variation of implementations for these requirements in samples on the Internet. Invariably, programmers try to encapsulate the<em> ISession</em> object and transaction in a UnitOfWork class. While many of these samples are not incorrect in there implementation, some are, and many do not provide any additional functionality or save lines of code, when compared to a proper implementation of the bare <em>ISession</em> object.&nbsp; </p>
<p>First some sample <em>GenericDAO</em> code (again, thanks to Jason Dentler, who provided the basic pattern). The declaration for the class:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:db42bbea-8b3d-46c0-9dc3-5c2baf8775ef" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Declaration for GenericDAOImp</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Text;</li>
<li><span style="color:#0000ff">using</span> DomainModel;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> NHibernateDAO</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">GenericDAOImpl</span>&lt;TEntity&gt; : <span style="color:#2b91af">IRead</span>&lt;TEntity&gt;, <span style="color:#2b91af">ISave</span>&lt;TEntity&gt; <span style="color:#0000ff">where</span> TEntity : <span style="color:#2b91af">Entity</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> GenericDAOImpl(<span style="color:#2b91af">ISession</span> Session)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_Session = Session;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> <span style="color:#0000ff">readonly</span> <span style="color:#2b91af">ISession</span> m_Session;</li>
</ol>
</div>
</div>
</div>
<p>A DAO implementation for NHibernate will usually have a <em>GetByID</em>, and this is no exception:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:e8a58be6-5ff1-42b6-811a-a759cabf2bbd" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Function GetByID</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> TEntity GetByID(<span style="color:#2b91af">Guid</span> ID)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity retval;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval = m_Session.Get&lt;TEntity&gt;(ID);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retval;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> m_Session.Get&lt;TEntity&gt;(ID);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<p>The less normal GetBy query mechanism, is more normally part of a repository architecture, but makes for some very flexible code here:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:447eaed2-dd2c-4ccd-b36d-db1ca0e52ac0" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">GetBy Query Functions</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#2b91af">IList</span>&lt;TEntity&gt; GetByCriteria(<span style="color:#2b91af">ICriteria</span> criteria)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;TEntity&gt; retval;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval = criteria.List&lt;TEntity&gt;();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retval;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> criteria.List&lt;TEntity&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> <span style="color:#2b91af">IList</span>&lt;TEntity&gt; GetByQueryable(<span style="color:#2b91af">IQueryable</span>&lt;TEntity&gt; queryable)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;TEntity&gt; retval;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval = queryable.ToList&lt;TEntity&gt;();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retval;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> queryable.ToList&lt;TEntity&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<p>The Save function is the last part of the <em>GenericDAOImpl</em> class (note that there is no Delete function, as this capability is only exposed in the specific DAO classes actually requiring that function, rather than as a generic capability):</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:67e8d403-650a-439a-b284-a0c3194f5be2" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Save Function</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> TEntity Save(TEntity entity)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_Session.SaveOrUpdate(entity);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_Session.SaveOrUpdate(entity);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> entity;</li>
<li style="background: #f3f3f3">}</li>
</ol>
</div>
</div>
</div>
<p>&nbsp;</p>
<p>Each method in the <em>GenericDAO</em> class has 2 paths: one where the caller has wrapped the call in a transaction, and the other where no transaction was specified in the call. (Note: It is not necessary to check <em>m_session.Transaction != null</em> as the transaction will never be null if the <em>ISession</em> instance is valid, and the <em>ISession</em> instance must be valid to use the <em>GenericDAO</em> implementation.) It is left as an exercise for the reader to build a function to query using HQL. 
</p>
<p>An example test is shown below, first without an explicit transaction and then with a transaction:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:8bd4ac1a-3d02-4f0a-804d-753df200703d" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonSaveTestWithoutTX</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonSaveTestWithoutTx()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> _person = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Person</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person.FirstName = <span style="color:#a31515">"John"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person.LastName = <span style="color:#a31515">"Davidson"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person.Email = <span style="color:#a31515">"jwdavidson@gmail.com"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person.UserID = <span style="color:#a31515">"jwd"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> newPerson = daoPerson.Save(_person);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.AreEqual(_person, newPerson);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;newPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol>
</div>
</div>
</div>
<pre><pre>&nbsp;</pre>
<pre>Now with a transaction included in the test method:</pre>
<pre>&nbsp;</pre>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:b8fcad52-4d1b-4065-88f6-f00e44d7dbed" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonSaveTestWithTX</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonSaveTestWithTx()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> _person = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Person</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person.FirstName = <span style="color:#a31515">"John"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person.LastName = <span style="color:#a31515">"Davidson"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person.Email = <span style="color:#a31515">"jwdavidson@gmail.com"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person.UserID = <span style="color:#a31515">"jwd"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> newPerson = daoPerson.Save(_person);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.AreEqual(_person, newPerson);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol>
</div>
</div>
</div>
</pre>
<pre>&nbsp;</pre>
<p>There are 2 additional lines of code in the sample with a direct call to the transaction. Any other UnitOfWork implementation cannot improve on this and still work correctly. 
</p>
<h3>Minimal NHibernate Configuration</h3>
<p>NHibernate needs a program to read the configuration and initialize the <em>SessionFactory</em>. This is called the <em>SessionManager.cs </em>is shown below the configuration and unit test setup code. 
</p>
<p>The <em>web.config</em> file holds the configuration details as shown below:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:914e4788-8faa-4c4d-8bc2-65b8c202c863" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">NHibernate in Web.Config</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">&lt;</span><span style="color:#a31515">configSections</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">section</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">hibernate-configuration</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">type</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">NHibernate.Cfg.ConfigurationSectionHandler,NHibernate</span>"<span style="color:#0000ff">/&gt;</span></li>
<li><span style="color:#0000ff">&lt;/</span><span style="color:#a31515">configSections</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3"><span style="color:#0000ff">&nbsp;&nbsp;&lt;</span><span style="color:#a31515">hibernate-configuration</span><span style="color:#0000ff"></span><span style="color:#ff0000">xmlns</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">urn:nhibernate-configuration-2.2</span>"<span style="color:#0000ff"> &gt;</span></li>
<li>&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">session-factory</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">NHibernate.Bootstrapper</span>"<span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">connection.driver_class</span>"<span style="color:#0000ff">&gt;</span>NHibernate.Driver.SqlClientDriver<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">connection.connection_string</span>"<span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Data Source=.\SQLEXPRESS;Initial Catalog=NHibernateBootstrapper;Integrated Security=True;Pooling=True</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">show_sql</span>"<span style="color:#0000ff">&gt;</span>false<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">adonet.batch_size</span>"<span style="color:#0000ff">&gt;</span>10<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">dialect</span>"<span style="color:#0000ff">&gt;</span>NHibernate.Dialect.MsSql2008Dialect<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">use_outer_join</span>"<span style="color:#0000ff">&gt;</span>true<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">command_timeout</span>"<span style="color:#0000ff">&gt;</span>60<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">query.substitutions</span>"<span style="color:#0000ff">&gt;</span>true 1, false 0, yes 'Y', no 'N'<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">proxyfactory.factory_class</span>"<span style="color:#0000ff">&gt;</span>NHibernate.ByteCode.LinFu.ProxyFactoryFactory, NHibernate.ByteCode.LinFu<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">current_session_context_class</span>"<span style="color:#0000ff">&gt;</span>NHibernate.Context.ManagedWebSessionContext, NHibernate<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">generate_statistics</span>"<span style="color:#0000ff">&gt;</span>false<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">property</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">session-factory</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3"><span style="color:#0000ff">&lt;/</span><span style="color:#a31515">hibernate-configuration</span><span style="color:#0000ff">&gt;</span></li>
</ol>
</div>
</div>
</div>
<pre>&nbsp;</pre>
<p>The Unit Test project has a similar configuration, but it is stored in an <em>app.config</em> file in the bin directory with some minor changes. The <em>show_sql</em> property is set to true, causing the sql to be output in the NUnit console display. The second change is that the property <em>current_session_context_class</em> is set to <em>ThreadStaticSessionContext</em>. In this case the current context needs it own setup:</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:a1c5af1e-85a3-40ff-84ed-1672a0867bbc" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Setup / Teardown for UnitTest</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">private</span> <span style="color:#2b91af">ISession</span> m_session;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>[<span style="color:#2b91af">TestFixtureSetUp</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> TestFixtureSetup()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">var</span> session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.OpenSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">CallSessionContext</span>.Bind(session);</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">[<span style="color:#2b91af">TestFixtureTearDown</span>]</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> TestFixtureTeardown()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">var</span> session = <span style="color:#2b91af">CallSessionContext</span>.Unbind(<span style="color:#2b91af">SessionManager</span>.SessionFactory);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (session != <span style="color:#0000ff">null</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (session.Transaction != <span style="color:#0000ff">null</span> &amp;&amp; session.Transaction.IsActive)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Transaction.Rollback();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Flush();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Close();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;session.Dispose();</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<pre></pre>
<p>I waited to show the SessionManager.cs code, as it was necessary to understand how the Unit Tests work with the NHibernate DAO classes, in a nearly transparent manner. This SessionManager.cs was adapted from a blog post by Petter Wiggle. The reference post titled &lsquo;<a href="http://pwigle.wordpress.com/2008/11/21/nhibernate-session-handling-in-aspnet-the-easy-way/">NHibernate Session handling in ASP.NET &ndash; the easy way</a>&rsquo; is one of the examples of how <strong><span style="text-decoration: underline;">not</span></strong> to implement SessionPerRequest as it uses the <em>Global.asax</em> file for initialization, rather than correctly using an <em>IHttpModule</em>. Now for the code (split into 3 section to ensure that it will print correctly):</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:2012d280-81b3-4f74-a358-a03869c86045" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">SessionManager.cs (Part 1)</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.IO;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Linq;</li>
<li><span style="color:#0000ff">using</span> System.Text;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate;</li>
<li><span style="color:#0000ff">using</span> NHibernate.Cfg;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">namespace</span> NHibernateDAO</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">sealed</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">SessionManager</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">readonly</span> <span style="color:#2b91af">ISessionFactory</span> sessionFactory;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> <span style="color:#2b91af">ISessionFactory</span> SessionFactory</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> Instance.sessionFactory; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">ISessionFactory</span> GetSessionFactory()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> sessionFactory;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> <span style="color:#2b91af">SessionManager</span> Instance</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> <span style="color:#2b91af">NestedSessionManager</span>.sessionManager; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> <span style="color:#2b91af">ISession</span> OpenSession()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> Instance.GetSessionFactory().OpenSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol>
</div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:28a19f0c-63d4-44d9-ba79-5a6c671f8f73" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">SessionMnager.cs (Part 2)</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">private</span> SessionManager()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (sessionFactory == <span style="color:#0000ff">null</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Configuration</span> configuration;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (<span style="color:#2b91af">AppDomain</span>.CurrentDomain.BaseDirectory.Contains(<span style="color:#a31515">"UnitTest"</span>))</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;configuration = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Configuration</span>().Configure(<span style="color:#2b91af">Path</span>.Combine(<span style="color:#2b91af">AppDomain</span>.CurrentDomain.BaseDirectory, <span style="color:#a31515">"app.config"</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;log4net.Config.<span style="color:#2b91af">XmlConfigurator</span>.ConfigureAndWatch(<span style="color:#0000ff">new</span> <span style="color:#2b91af">FileInfo</span>(<span style="color:#2b91af">Path</span>.Combine(<span style="color:#2b91af">AppDomain</span>.CurrentDomain.BaseDirectory, <span style="color:#a31515">"app.config"</span>)));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;configuration = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Configuration</span>().Configure(<span style="color:#2b91af">Path</span>.Combine(<span style="color:#2b91af">AppDomain</span>.CurrentDomain.BaseDirectory, <span style="color:#a31515">"web.config"</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;log4net.Config.<span style="color:#2b91af">XmlConfigurator</span>.ConfigureAndWatch(<span style="color:#0000ff">new</span> <span style="color:#2b91af">FileInfo</span>(<span style="color:#2b91af">Path</span>.Combine(<span style="color:#2b91af">AppDomain</span>.CurrentDomain.BaseDirectory, <span style="color:#a31515">"web.config"</span>)));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//Configuration configuration = new Configuration().Configure();</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (configuration == <span style="color:#0000ff">null</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">throw</span> <span style="color:#0000ff">new</span> <span style="color:#2b91af">InvalidOperationException</span>(<span style="color:#a31515">"NHibernate configuration is null."</span>);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;configuration.AddAssembly(<span style="color:#a31515">"NHibernateDAO"</span>);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sessionFactory = configuration.BuildSessionFactory();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (sessionFactory == <span style="color:#0000ff">null</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">throw</span> <span style="color:#0000ff">new</span> <span style="color:#2b91af">InvalidOperationException</span>(<span style="color:#a31515">"Call to BuildSessionFactory() returned null."</span>);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:17cc8e34-2208-49fb-9073-1d5f4cef71a7" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">SessionManager.cs (Part 3)</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">class</span> <span style="color:#2b91af">NestedSessionManager</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">internal</span> <span style="color:#0000ff">static</span> <span style="color:#0000ff">readonly</span> <span style="color:#2b91af">SessionManager</span> sessionManager = <span style="color:#0000ff">new</span> <span style="color:#2b91af">SessionManager</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol>
</div>
</div>
</div>
<p>The <em>SessionManager</em> gets its configuration data from the Unit Test project if "UnitTest" is in the application directory name, otherwise it performs a normal configuration and uses the web.config for the Web Application. It is that easy. 
</p>
<h3>Application Domain Setup</h3>
<p>The map file is one method to notify NHibernate of the class to table mapping. Other methods are ConfORM or FluentNHibernate, but the map file was the first mechanism. Remember to set the Build Action for your map files to Embedded Resource so that they are included in the assembly file to be read by the <em>SessionManager</em> in the initialization process.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:6c773bcf-d0e2-4023-9ed4-dd6fa9c3a57e" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Person.hbm.xml</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">&lt;?</span><span style="color:#a31515">xml</span><span style="color:#0000ff"> </span><span style="color:#ff0000">version</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">1.0</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">encoding</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">utf-8</span>"<span style="color:#0000ff"> ?&gt;</span></li>
<li style="background: #f3f3f3"><span style="color:#0000ff">&lt;</span><span style="color:#a31515">hibernate-mapping</span><span style="color:#0000ff"> </span><span style="color:#ff0000">xmlns</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">urn:nhibernate-mapping-2.2</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">assembly</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">DomainModel</span>"</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff"></span><span style="color:#ff0000">namespace</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">DomainModel.Person</span>"<span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">class</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Person</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">table</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Person</span>"<span style="color:#0000ff"> &gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">id</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Id</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">column</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Person_ID</span>"<span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">generator</span><span style="color:#0000ff"> </span><span style="color:#ff0000">class</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">guid.comb</span>"<span style="color:#0000ff">/&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">id</span><span style="color:#0000ff">&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">FirstName</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">column</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">First_Name</span>"<span style="color:#0000ff"> /&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">LastName</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">column</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Last_Name</span>"<span style="color:#0000ff"> /&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Email</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">column</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">Email</span>"<span style="color:#0000ff"> /&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">&lt;</span><span style="color:#a31515">property</span><span style="color:#0000ff"> </span><span style="color:#ff0000">name</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">UserID</span>"<span style="color:#0000ff"> </span><span style="color:#ff0000">column</span><span style="color:#0000ff">=</span>"<span style="color:#0000ff">User_ID</span>"<span style="color:#0000ff">/&gt;</span></li>
<li>&nbsp;&nbsp;<span style="color:#0000ff">&lt;/</span><span style="color:#a31515">class</span><span style="color:#0000ff">&gt;</span></li>
<li style="background: #f3f3f3"><span style="color:#0000ff">&lt;/</span><span style="color:#a31515">hibernate-mapping</span><span style="color:#0000ff">&gt;</span></li>
</ol>
</div>
</div>
</div>
&nbsp;
<p>Here you can see the table diagram for the Person table in the SQL Server database. 
</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Person_5F00_6C727450.png"><img height="133" width="240" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Person_5F00_thumb_5F00_1EF5D1C3.png" alt="Person" border="0" title="Person" style="border-right-width: 0px; margin: 0px 0px 0px 50px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> 
</p>
<p>The class diagram for the <em>Person</em> class shows how the map file uses both the table and the class definition to make NHibernate able to persist an instance of the <em>Person</em> class. Also note that the <em>Person</em> Class inherits from the <em>Entity</em> class.
</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/PersonCls_5F00_3640D634.png"><img height="240" width="133" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/PersonCls_5F00_thumb_5F00_6C624E83.png" alt="PersonCls" border="0" title="PersonCls" style="border-right-width: 0px; margin: 0px 0px 0px 50px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> 
</p>
<p>I have borrowed the <em>Entity</em> class from the implementation of Jason Dentler, described earlier. This <em>Entity</em> class is slightly different from a number of Id providers used by NHibernate persistence classes in that it makes the setter for the Id property &lsquo;protected&rsquo;, rather than &lsquo;public&rsquo;. This means that the application code is not able to directly set the Id of a class instance, but that it can only be set by the DAO implementation. As a result the application is forced to use Data Transfer Objects (dto) to communicate from the UI to the persistence classes.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:a8eed277-946d-430f-b55f-8821b0c8da87" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Entity.cs</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Text;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> DomainModel</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">abstract</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">Entity</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">Guid</span> m_ID;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">virtual</span> <span style="color:#2b91af">Guid</span> Id</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> m_ID; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> <span style="color:#0000ff">set</span> { m_ID = <span style="color:#0000ff">value</span>; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol>
</div>
</div>
</div>
<p>&nbsp;</p>
<p>The PersonDto class diagram is shown below. The PersonID property maps to the Person.Id property of the persistence class, with all other properties lining up as expected.
</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/PersonDtoCls_5F00_312E72B8.png"><img height="240" width="117" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/PersonDtoCls_5F00_thumb_5F00_3AA7312E.png" alt="PersonDtoCls" border="0" title="PersonDtoCls" style="border-right-width: 0px; margin: 0px 0px 0px 50px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" /></a> 
</p>
<p>The next 3 code snippets show how a dto is used to move data from a persistence class to a dto and then use that dto to populate a DataGrid. The function<em> Get_PersonData</em> fills a persistence class from the database using the <em>ICriteria</em> based <em>GetByCriteria</em> query and then uses a LINQ to Object function to fill the dto. Then the dto is passed to the DataGrid and then it is data bound in the method <em>Fill_gvPerson</em>. </p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:0e7efa7d-498b-40b4-ae57-3b0f960c2c87" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Function Get_PersonData()</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; Get_PersonData()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; retVal = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (m_session == <span style="color:#0000ff">null</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> dao = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = dao.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;retVal = (<span style="color:#0000ff">from</span> person <span style="color:#0000ff">in</span> people</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">select</span> <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDto</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PersonID = person.Id,</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FirstName = person.FirstName,</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LastName = person.LastName,</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Email = person.Email,</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UserID = person.UserID</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}).ToList&lt;<span style="color:#2b91af">PersonDto</span>&gt;();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;crit = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;dao = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retVal;</li>
<li style="background: #f3f3f3">}</li>
</ol>
</div>
</div>
</div>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:6e9a45e2-7a07-40e8-8afc-b21aa694bad4" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Calling GetPersonData()</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">if</span> (!Page.IsPostBack)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; gvData = Get_PersonData();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;Fill_gvPerson(gvData);</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:80d24230-04c0-4ca5-add7-de8335d46042" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Fill Grid with DTO Data</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> Fill_gvPerson(<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; data)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;gvPerson.DataSource = data;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;gvPerson.DataBind();</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<p>&nbsp;</p>
<p>The method _view_OnSaveEditPerson demonstrates the necessary steps to get data out of a dto and then to persist the user inputs. First it checks the value of txtPersonIdValue to determine if the data is from an instance that exists in the persistence layer, or is it a new instance &ndash; indicated by an empty value. Next the persistence class Person instance is fill using a GetByID function from the DAO implementation and then the data from the form fields is copy to the Person instance. Finally the Person instance is now saved.
</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:8ecee0ef-be65-4fde-b2ae-96a1af2f3ae0" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Save Entity from Form Data</div>
<div style="background: #ddd; overflow: auto">
<ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _view_OnSaveEditPerson()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (m_session == <span style="color:#0000ff">null</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Guid</span> editId = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> editPers = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Person</span>();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!<span style="color:#0000ff">string</span>.IsNullOrEmpty(txtPersonIdValue))</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editId = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>(txtPersonIdValue);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> dao = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (editId.ToString().Length == 36)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers = dao.GetByID(editId);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.FirstName = txtFirstNameValue;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.LastName = txtLastNameValue;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.Email = txtEmailValue;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.UserID = txtUserIdValue;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers = dao.Save(editPers);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;editPers = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;dao = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_view_OnRefreshPersonGrid();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_view_OnClearEditPerson();</li>
<li>}</li>
</ol>
</div>
</div>
</div>
<h3>Next Steps</h3>
<p>While the sample solution is useful, it is definitely not enterprise ready. The main problem with this solution is that the Web Application has a knowledge of the persistence layer. The next step is to factor these calls to the BusinessServices project. Doing that will reduce the interdependencies and will increase the overall testability of the full application, as it is almost impossible to properly unit test code in the Web Application itself. Additionally further decoupling can be achieved by ensuring that all calls to the persistence layer are done through the DataServices layer.</p>
