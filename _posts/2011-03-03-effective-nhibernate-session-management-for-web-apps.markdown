---
layout: post
title: "Effective NHibernate Session management for web apps"
date: 2011-03-03 04:09:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["SessionFactory", "Session", "Asp.Net", "ASP.NET MVC"]
redirect_from: 
  - "/blogs/nhibernate/archive/2011/03/03/effective-nhibernate-session-management-for-web-apps.aspx/"
  - "/blogs/nhibernate/archive/2011/03/03/effective-nhibernate-session-management-for-web-apps.html"
  - "/blogs/nhibernate/archive/2011/03/02/effective-nhibernate-session-management-for-web-apps.html"
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}

<p>In this post I’ll describe a mechanism to manage nhibernate session following the widely known patter “session-per-request”.</p>  <h1>Introduction</h1>  <p>The session-per-request pattern is very well defined and widely used; as follows</p>  <blockquote>   <p>A single <tt>Session</tt> and a single database transaction implement the processing of a particular request event (for example, a Http request in a web application).</p> </blockquote>  <h1>What do we have currently?</h1>  <p>The first thing you will notice when talking about nhibernate session management is a little interface inside NHibernate;</p>  <pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">interface</span> ICurrentSessionContext
{
    ISession CurrentSession();
}</pre>

<p><style type="text/css">





<!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style></p>

<p>The only purpose of the implementors is to store and retrieve the current session from somewhere. This class is used by the SessionFactory of nhibernate when calling the method GetCurrentSession().</p>

<p>There are lot of implementations of ICurrentSessionContext but for web the two more important are:</p>

<ul>
  <li>WebSessionContext inside NHibernate (namespace NHibernate.Context) </li>

  <li>WebSessionContext inside uNhAddIns.Web (namespace Session.Easier) </li>
</ul>

<p>They are pretty similar but the one inside uNhAddins supports multi-session-factory scenarios.</p>

<h1>Where do we init &amp; store the session?</h1>

<p>We have an <a href="http://code.google.com/p/unhaddins/source/browse/uNhAddIns/uNhAddIns.Web/NHSessionWebModule.cs">httpmodule</a> in uNhAddins which add handler for the BeginRequest as follows:</p>

<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/Untitleddrawing_2D00_2_5F00_2DCB97C5.png"><img style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" title="Untitleddrawing (2)" border="0" alt="Untitleddrawing (2)" src="/images/posts/2011/03/03/Untitleddrawing_2D00_2_5F00_thumb_5F00_50CBE368.png" width="433" height="378" /></a></p>

<h1>The problem</h1>

<p>Although the afore mentioned handler does not open a session and a transaction for images or JavaScript files there might be some request to pages that will not talk with the persistence and we don’t want a OpenSession/BeginTransaction there.</p>

<p><a href="http://ayende.com/Blog/archive/2009/08/16/what-is-the-cost-of-opening-a-session.aspx">Ayende already talked about this in his blog.</a> But the problem is that he only wrote about the Session which is really light to instantiate. The problem is how do we handle the scope of the transaction which is not so light?</p>

<h1>Alternative solutions</h1>

<p>There are currently three solutions for this problem:</p>

<ul>
  <li>Use BeginRequest/EndRequest to open/close the session. Handle the transaction with AOP – attributes. I am not sure but I think this is the case for the AutoTransaction facility of castle. </li>

  <li>To use Asp.Net MVC ActionFilters to Open/Close the session and the transaction. </li>

  <li>There is a third which is an <a href="http://nhprof.com/Learn/Alerts/DoNotUseImplicitTransactions">antipattern; using implicit transactions</a> for most of the cases and explicit for some others. </li>
</ul>

<p>The main problem with these approaches is that you need to explicitly put something to say that some piece of code will use a session/transaction. Even if you do it with AOP!</p>

<h1>My new solution</h1>

<p>My new solution is to store a Lazy&lt;ISession&gt; per request instead of an ISession. Initialize in the first usage and finalize in the EndRequest – only if it was used/opened.</p>

<p>The implementation I’ll show also support multi-session factories.</p>

<p>The ICurrentSessionContext looks as follows:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">class</span> LazySessionContext : ICurrentSessionContext
{
    <span class="kwrd">private</span> <span class="kwrd">readonly</span> ISessionFactoryImplementor factory;
    <span class="kwrd">private</span> <span class="kwrd">const</span> <span class="kwrd">string</span> CurrentSessionContextKey = <span class="str">&quot;NHibernateCurrentSession&quot;</span>;

    <span class="kwrd">public</span> LazySessionContext(ISessionFactoryImplementor factory)
    {
        <span class="kwrd">this</span>.factory = factory;
    }

    <span class="rem">/// &lt;summary&gt;</span>
    <span class="rem">/// Retrieve the current session for the session factory.</span>
    <span class="rem">/// &lt;/summary&gt;</span>
    <span class="rem">/// &lt;returns&gt;&lt;/returns&gt;</span>
    <span class="kwrd">public</span> ISession CurrentSession()
    {
        Lazy&lt;ISession&gt; initializer;
        var currentSessionFactoryMap = GetCurrentFactoryMap();
        <span class="kwrd">if</span>(currentSessionFactoryMap == <span class="kwrd">null</span> || 
            !currentSessionFactoryMap.TryGetValue(factory, <span class="kwrd">out</span> initializer))
        {
            <span class="kwrd">return</span> <span class="kwrd">null</span>;
        }
        <span class="kwrd">return</span> initializer.Value;
    }

    <span class="rem">/// &lt;summary&gt;</span>
    <span class="rem">/// Bind a new sessionInitializer to the context of the sessionFactory.</span>
    <span class="rem">/// &lt;/summary&gt;</span>
    <span class="rem">/// &lt;param name=&quot;sessionInitializer&quot;&gt;&lt;/param&gt;</span>
    <span class="rem">/// &lt;param name=&quot;sessionFactory&quot;&gt;&lt;/param&gt;</span>
    <span class="kwrd">public</span> <span class="kwrd">static</span> <span class="kwrd">void</span> Bind(Lazy&lt;ISession&gt; sessionInitializer, ISessionFactory sessionFactory)
    {
        var map = GetCurrentFactoryMap();
        map[sessionFactory] = sessionInitializer;
    }

    <span class="rem">/// &lt;summary&gt;</span>
    <span class="rem">/// Unbind the current session of the session factory.</span>
    <span class="rem">/// &lt;/summary&gt;</span>
    <span class="rem">/// &lt;param name=&quot;sessionFactory&quot;&gt;&lt;/param&gt;</span>
    <span class="rem">/// &lt;returns&gt;&lt;/returns&gt;</span>
    <span class="kwrd">public</span> <span class="kwrd">static</span> ISession UnBind(ISessionFactory sessionFactory)
    {
        var map = GetCurrentFactoryMap();
        var sessionInitializer = map[sessionFactory];
        map[sessionFactory] = <span class="kwrd">null</span>;
        <span class="kwrd">if</span>(sessionInitializer == <span class="kwrd">null</span> || !sessionInitializer.IsValueCreated) <span class="kwrd">return</span> <span class="kwrd">null</span>;
        <span class="kwrd">return</span> sessionInitializer.Value;
    }

    <span class="rem">/// &lt;summary&gt;</span>
    <span class="rem">/// Provides the CurrentMap of SessionFactories.</span>
    <span class="rem">/// If there is no map create/store and return a new one.</span>
    <span class="rem">/// &lt;/summary&gt;</span>
    <span class="rem">/// &lt;returns&gt;&lt;/returns&gt;</span>
    <span class="kwrd">private</span> <span class="kwrd">static</span> IDictionary&lt;ISessionFactory, Lazy&lt;ISession&gt;&gt; GetCurrentFactoryMap()
    {
        var currentFactoryMap = (IDictionary&lt;ISessionFactory,Lazy&lt;ISession&gt;&gt;)
                                HttpContext.Current.Items[CurrentSessionContextKey];
        <span class="kwrd">if</span>(currentFactoryMap == <span class="kwrd">null</span>)
        {
            currentFactoryMap = <span class="kwrd">new</span> Dictionary&lt;ISessionFactory, Lazy&lt;ISession&gt;&gt;();
            HttpContext.Current.Items[CurrentSessionContextKey] = currentFactoryMap;
        }
        <span class="kwrd">return</span> currentFactoryMap;
    }
}</pre>

<p><style type="text/css">





<!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style></p>

<p>The new HttpModule is:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">class</span> NHibernateSessionModule : IHttpModule
{
    <span class="kwrd">private</span> HttpApplication app;
    <span class="kwrd">private</span> ISessionFactoryProvider sfp;

    <span class="kwrd">public</span> <span class="kwrd">void</span> Init(HttpApplication context)
    {
        app = context;
        sfp = (ISessionFactoryProvider) 
                  context.Application[SessionFactoryProvider.Key];
        context.BeginRequest += ContextBeginRequest;
        context.EndRequest += ContextEndRequest;
    }

    <span class="kwrd">private</span> <span class="kwrd">void</span> ContextBeginRequest(<span class="kwrd">object</span> sender, EventArgs e)
    {
        <span class="kwrd">foreach</span> (var sf <span class="kwrd">in</span> sfp.GetSessionFactories())
        {
            var localFactory = sf;
            LazySessionContext.Bind(
                <span class="kwrd">new</span> Lazy&lt;ISession&gt;(() =&gt; BeginSession(localFactory)), 
                sf);
        }
    }

    <span class="kwrd">private</span> <span class="kwrd">static</span> ISession BeginSession(ISessionFactory sf)
    {
        var session = sf.OpenSession();
        session.BeginTransaction();
        <span class="kwrd">return</span> session;
    }

    <span class="kwrd">private</span> <span class="kwrd">void</span> ContextEndRequest(<span class="kwrd">object</span> sender, EventArgs e)
    {
        <span class="kwrd">foreach</span> (var sf <span class="kwrd">in</span> sfp.GetSessionFactories())
        {
            var session = LazySessionContext.UnBind(sf);
            <span class="kwrd">if</span> (session == <span class="kwrd">null</span>) <span class="kwrd">continue</span>;
            EndSession(session);
        }
    }

    <span class="kwrd">private</span> <span class="kwrd">static</span> <span class="kwrd">void</span> EndSession(ISession session)
    {
        <span class="kwrd">if</span>(session.Transaction != <span class="kwrd">null</span> &amp;&amp; session.Transaction.IsActive)
        {
            session.Transaction.Commit();
        }
        session.Dispose();
    }

    <span class="kwrd">public</span> <span class="kwrd">void</span> Dispose()
    {
        app.BeginRequest -= ContextBeginRequest;
        app.EndRequest -= ContextEndRequest;
    }
}</pre>

<p><style type="text/css">





<!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style></p>

<p>You can see here how we bind to the Lazy<isession> to the current context and the initializer. The BeginSession method initializes a session and a transaction.</isession></p>

<p>The UnBind method returns a session only if the Lazy<isession> was initialized. If it returns something we properly commit the transaction and dispose the session.</isession></p>

<p>The ISessionFactoryProvider is:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">interface</span> ISessionFactoryProvider
{
    IEnumerable&lt;ISessionFactory&gt; GetSessionFactories();
}</pre>

<p><style type="text/css">





<!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style></p>

<p>and the SessionFactoryProvider is just an store for the constant:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">class</span> SessionFactoryProvider
{
    <span class="kwrd">public</span> <span class="kwrd">const</span> <span class="kwrd">string</span> Key = <span class="str">&quot;NHibernateSessionFactoryProvider&quot;</span>;
}</pre>

<p><style type="text/css">





<!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style></p>

<p>I didn't write an implementation for ISessionFactoryProvider because I’m using <a href="http://docs.castleproject.org/Windsor.Typed-Factory-Facility-interface-based-factories.ashx">castle typed factories</a>.</p>

<p>The <a href="http://docs.castleproject.org/Windsor.Installers.ashx">IWindsorInstaller</a> for castle looks as follows:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">class</span> NHibernateInstaller : IWindsorInstaller
{
    <span class="preproc">#region</span> IWindsorInstaller Members

    <span class="kwrd">public</span> <span class="kwrd">void</span> Install(IWindsorContainer container, IConfigurationStore store)
    {
        container.Register(Component.For&lt;ISessionFactory&gt;()
                               .UsingFactoryMethod(k =&gt; BuildSessionFactory()));

        container.Register(Component.For&lt;NHibernateSessionModule&gt;());

        container.Register(Component.For&lt;ISessionFactoryProvider&gt;().AsFactory());
        
        container.Register(Component.For&lt;IEnumerable&lt;ISessionFactory&gt;&gt;()
                                    .UsingFactoryMethod(k =&gt; k.ResolveAll&lt;ISessionFactory&gt;()));

        HttpContext.Current.Application[SessionFactoryProvider.Key]
                        = container.Resolve&lt;ISessionFactoryProvider&gt;();
    }

    <span class="preproc">#endregion</span>

    <span class="kwrd">public</span> ISessionFactory BuildSessionFactory()
    { 
        var config = <span class="kwrd">new</span> Configuration().Configure();
        <span class="rem">//your code here :)</span>
        <span class="kwrd">return</span> config.BuildSessionFactory();
    }
}</pre>

<p><style type="text/css">





<!--
.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }
--></style></p>

<p>The only thing you have to do in NHibernate is to tell which is the CurrentSessionContextClass as follows:</p>

<p>configuration.Properties[Environment.CurrentSessionContextClass]
  <br />&#160;&#160;&#160; = typeof (LazySessionContext).AssemblyQualifiedName;

  <br /></p>





<h1>Working with multiples session factories</h1>

<p>When working with multiples session factories, the way to go is to name your components in the container:</p>

<pre class="csharpcode">container.Register(Component.For&lt;ISessionFactory&gt;()
                            .UsingFactoryMethod(...)
                            .Named(<span class="str">&quot;MySf1&quot;</span>));</pre>

<p><style type="text/css">


.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }</style></p>

<p>Then you can start naming your Daos and explicitly overriden whenever they are injected:</p>

<pre class="csharpcode">container.Register(Component.For(<span class="kwrd">typeof</span>(IDao&lt;&gt;))
                            .ImplementedBy(<span class="kwrd">typeof</span>(Dao&lt;&gt;))
                            .ServiceOverrides(ServiceOverrides.ForKey(<span class="str">&quot;sessionFactory&quot;</span>).Eq(MySf1))
                            .Named(<span class="str">&quot;SalesDao&quot;</span>));

container.Register(Component.For(<span class="kwrd">typeof</span>(IMyService&lt;&gt;))
                            .ImplementedBy(<span class="kwrd">typeof</span>(MyService&lt;&gt;))
                            .ServiceOverrides(ServiceOverrides.ForKey(<span class="str">&quot;dao&quot;</span>).Eq(MyDao1)));</pre>

<p><style type="text/css">


.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }</style></p>

<p>Another way is to have a factory like this one:</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">interface</span> IDaoFactory
{
     IDao&lt;T&gt; GetSalesDao();
     IDao&lt;T&gt; GetCMSDao();
}</pre>
<style type="text/css">


.csharpcode, .csharpcode pre
{
	font-size: small;
	color: black;
	font-family: consolas, "Courier New", courier, monospace;
	background-color: #ffffff;
	/*white-space: pre;*/
}
.csharpcode pre { margin: 0em; }
.csharpcode .rem { color: #008000; }
.csharpcode .kwrd { color: #0000ff; }
.csharpcode .str { color: #006080; }
.csharpcode .op { color: #0000c0; }
.csharpcode .preproc { color: #cc6633; }
.csharpcode .asp { background-color: #ffff00; }
.csharpcode .html { color: #800000; }
.csharpcode .attr { color: #ff0000; }
.csharpcode .alt 
{
	background-color: #f4f4f4;
	width: 100%;
	margin: 0em;
}
.csharpcode .lnum { color: #606060; }</style>

<p>This will work out of the box with castle typed factories, following the pattern Get[Dao component name]. With other containers you will have to implement the interface. </p>

<p>Remember also that NHibernate lets you name your session factory through the configuration, that is sometimes useful.</p>

<h1>How to use the ISession from my code?</h1>

<p>The same way I do since long time ago;</p>

<pre class="csharpcode"><span class="kwrd">public</span> <span class="kwrd">class</span> Dao&lt;T&gt; : IDao&lt;T&gt;
{
    <span class="kwrd">private</span> <span class="kwrd">readonly</span> ISessionFactory sessionFactory;

    <span class="kwrd">public</span> Dao(ISessionFactory sessionFactory)
    {
        <span class="kwrd">this</span>.sessionFactory = sessionFactory;
    }

    <span class="kwrd">public</span> <span class="kwrd">void</span> Save(T transient)
    {
        sessionFactory.GetCurrentSession().Save(transient);
    }

    //Other methods</pre>

<p>Injecting the ISessionFactory instead an ISession has the following advantages:</p>

<ul>
  <li>It is very handy to use stateless session or a short lived session in some methods for some queries through OpenStatelessSession/OpenSession </li>

  <li>The lifestyle of the Dao is not tied to the Session.&#160; It could be even singleton.</li>
</ul>

<h1>Other session managements</h1>

<p>In unhaddins there are various contexts;</p>

<ul>
  <li>PerThread </li>

  <li>ConversationalPerThread </li>

  <li>Web </li>
</ul>

<p>And ways to hook such contexts;</p>

<ul>
  <li>In winforms; for use with the pattern Conversation per Business transaction.</li>

  <li>In WCF; an OperationBehavior </li>

  <li>In web an httpmodule</li>
</ul>

<p>It is up to you to choose the combination. For instance when doing WCF that will run inside iis, you can use the operationbehavior + web. But when you do WCF out of IIS, you can use OperationBehavior + PerThread.</p>

<p>The important thing about this is that your DAOs are exactly the same despite the management you use.</p>

<h1>Notes</h1>

<p>-For non-.Net 4 projects; as <a href="http://twitter.com/rbirkby">Richard Birkby</a> points out you can use the <a href="https://github.com/tgiphil/Mono-Class-Libraries/blob/ab6da0a6a290b73db812bd080ceae00f57670c2c/mcs/class/corlib/System/Lazy.cs">Lazy&lt;T&gt; inside Mono</a>.</p>

<h1>Finally</h1>

<p>I hope you find this useful. </p>

<p>This code is not going to be in uNhAddins for now. You can copy&amp;paste all the code from this <a href="https://gist.github.com/852307">gist</a>.</p>
