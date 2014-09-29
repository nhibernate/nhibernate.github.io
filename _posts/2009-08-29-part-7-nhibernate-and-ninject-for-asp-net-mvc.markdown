---
layout: post
title: "Part 7: NHibernate and Ninject for ASP.NET MVC"
date: 2009-08-29 20:47:58 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["Burrow", "NHibernate", "ASP.NET MVC", "Ninject"]
alias: ["/blogs/nhibernate/archive/2009/08/29/part-7-nhibernate-and-ninject-for-asp-net-mvc.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>In <a href="http://jasondentler.com/blog/2009/08/part-6-ninject-and-mvc-or-how-to-be-a-web-ninja/" target="_blank">part 6</a>, I explained how to set up <a href="http://ninject.org/" target="_blank">Ninject</a> with <a href="http://www.asp.net/mvc/" target="_blank">ASP.NET MVC</a>. In this part, we’ll add <a href="http://nhforge.org" target="_blank">NHibernate</a> to the mix. Specifically, we’re going to set up session-per-request using a Ninject and bind all the necessary NHibernate interfaces.</p>  <p>Of course, for the sake of history, read up on <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">part 1</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">part 2</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-3/" target="_blank">part 3</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-4/" target="_blank">part 4</a>, <a href="http://jasondentler.com/blog/2009/08/part-5-fixing-the-broken-stuff/" target="_blank">part 5</a>, and <a href="http://jasondentler.com/blog/2009/08/part-6-ninject-and-mvc-or-how-to-be-a-web-ninja/" target="_blank">part 6</a>. <img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" border="0" align="left" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Components.SiteFiles/logos/NHLogoSmall.gif" width="240" height="56" /></p>  <p>If you aren’t familiar with NHibernate in an ASP.NET MVC application, the most common way to manage your sessions is to open one session per web request. Just about everything you need to know about session-per-request is explained in the content and comments of <a href="http://ayende.com/Blog/archive/2009/08/05/do-you-need-a-framework.aspx" target="_blank">this post</a> on Ayende’s blog, but I’ll summarize for you.</p>  <ul>   <li>While building a session factory may be a big operation, once it’s built, opening a session is lightweight. </li>    <li>Opening a session does not open a connection to the database </li>    <li>NHibernate has a built in method for doing session-per-request, but Ayende doesn’t use it for simple stuff and neither will we. When your application doesn’t do anything other than session-per-request, it’s just easier to do it this way. </li>    <li>Multiple business transactions and therefore multiple sessions in a single web request are usually not necessary, just because of how users tend to interact with the application. Even then, you can usually accomplish the same thing with multiple DB transactions on the same session. </li> </ul>  <p><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; margin-left: 0px; border-left-width: 0px; margin-right: 0px" border="0" alt="SessionPerConversation" align="left" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/SessionPerConversation_5F00_thumb_5F00_7345BC5F.png" width="240" height="172" /></p>  <p>NHibernate Burrow is available to help with complex session management in web apps where session per conversation is used. Basically, this allows you to span your NHibernate sessions across several web requests. Just a quick note: If you disregarded everyone’s advice and used Identity (integer auto-number) ID fields, Burrow won’t work for you. If you want more information, check out the Burrow posts on NHForge. Also,&#160; <a href="http://nhforge.org/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-models-concept.aspx" target="_blank">Jose Romaniello’s uses Conversation per Business Transaction</a> in his NHibernate and WPF series on NHForge.org. It’s definitely worth a read.</p>  <p>OK. Back to session-per-request. I’m taking a slightly different approach than Ayende. Even though opening a session is lightweight, I don’t like the idea of opening a session for requests that may not use NHibernate at all. For example, in an application I’m building at work, only about 7 views out of nearly 50 actually use an NHibernate session. That’s a lot of unused sessions. </p>  <p>First things first, we need to make a Ninject module for all of our NHibernate bindings. Where are we going to put it? We have two options. We could put it in NStackExample.Data with all of our NHibernate mappings and configuration. We could also put it in NStackExample.Web. Like Ayende, we will be storing the NHibernate session in the context of the current web request and relying on our application’s EndRequest event to close the session. Since we’re unfortunately coupled to the web application, we’ll put it in the web project. </p>  <ol>   <li>In the web project, make a new folder called Code. </li>    <li>Make a class in that folder called NHibernateModule. </li>    <li>NHibernateModule should inherit from Ninject.Core.StandardModule. </li> </ol>  <p>The process of configuring NHibernate is a lot of work and only needs to be done once. Since our configuration object also creates the session factory, another potentially heavy operation, we kill two birds with one stone. The binding for our NHibernate configuration looks like this:</p>  <pre class="brush:vbnet">    Public Overrides Sub Load()
        Dim Cfg As New NStackExample.Data.Configuration
        Cfg.Configure()

        Bind(Of NStackExample.Data.Configuration).ToConstant(Cfg)
    End Sub</pre>

<pre class="brush:csharp&quot;">    public override void Load()
    {
        NStackExample.Data.Configuration Cfg = new NStackExample.Data.Configuration()
        Cfg.Configure();

        Bind<nstackexample.data.configuration>().ToConstant(Cfg);
    }</pre>

<p>ToConstant bindings essentially create singletons, at least within the scope of our Ninject kernel. Unlike true singletons, this isn’t evil because our tests are free to mock, replace, and re-implement them as necessary. </p>

<p>Now that we have NHibernate configured and our session factory built, we need to bind our NHibernate session. The scope of our session is somewhat complex (per-request). We could use the OnePerRequestBehavior of Ninject, but that <a href="http://stackoverflow.com/questions/536007/ninject-oneperrequestbehaviour-doesnt-seem-to-work-correctly" target="_blank">requires the registration of an IIS HTTP module</a>. Instead, we’ll just bind it to a method and manage it ourselves. This method will create up to one session per request. If a particular request doesn’t require a session, Ninject will never call the method, so an unnecessary session won’t be created. If a particular request asks for a session more than once, perhaps to build more than one DAO, the method will create a single session and use it throughout the web request. Here’s what our module looks like with the binding for our session:</p>

<pre class="brush:vbnet">    Friend Const SESSION_KEY As String = &quot;NHibernate.ISession&quot;

    Public Overrides Sub Load()
        Dim Cfg As New Configuration
        Cfg.Configure()

        Bind(Of Configuration).ToConstant(Cfg)
        Bind(Of NHibernate.ISession).ToMethod(AddressOf GetRequestSession)
    End Sub

    Private Function GetRequestSession(ByVal Ctx As IContext) As NHibernate.ISession
        Dim Dict As IDictionary = HttpContext.Current.Items
        Dim Session As NHibernate.ISession
        If Not Dict.Contains(SESSION_KEY) Then
            'Create an NHibernate session for this request
            Session = Ctx.Kernel.Get(Of Configuration)().OpenSession()
            Dict.Add(SESSION_KEY, Session)
        Else
            'Re-use the NHibernate session for this request
            Session = Dict(SESSION_KEY)
        End If
        Return Session
    End Function</pre>

<pre class="brush:csharp">        internal const string SESSION_KEY = &quot;NHibernate.ISession&quot;;

        public override void Load()
        {
            Configuration Cfg = new Configuration();
            Cfg.Configure();

            Bind&lt;Configuration&gt;().ToConstant(Cfg);
            Bind&lt;NHibernate.ISession&gt;().ToMethod(x =&gt; GetRequestSession(x));
        }

        private NHibernate.ISession GetRequestSession(IContext Ctx)
        {
            IDictionary Dict = HttpContext.Current.Items;
            NHibernate.ISession Session;
            if (!Dict.Contains(SESSION_KEY)) 
            {
                // Create an NHibernate session for this request
                Session = Ctx.Kernel.Get&lt;Configuration&gt;().OpenSession();
                Dict.Add(SESSION_KEY, Session);
            } else {
                // Re-use the NHibernate session for this request
                Session = (NHibernate.ISession) Dict[SESSION_KEY];
            }
            return Session;
        }</pre>

<p>All we have left to do is dispose our session at the end of the request. Let's go back to the Global.asax codebehind.</p>

<pre class="brush:vbnet">    Private Sub MvcApplication_EndRequest(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.EndRequest
        If Context.Items.Contains(NHibernateModule.SESSION_KEY) Then
            Dim Session As NHibernate.ISession = Context.Items(NHibernateModule.SESSION_KEY)
            Session.Dispose()
            Context.Items(NHibernateModule.SESSION_KEY) = Nothing
        End If
    End Sub</pre>

<pre class="brush:csharp">        public MvcApplication()
        {
            this.EndRequest += MvcApplication_EndRequest;
        }


        private void MvcApplication_EndRequest(object sender, System.EventArgs e)
        {
            if (Context.Items.Contains(NHibernateModule.SESSION_KEY))
            {
                NHibernate.ISession Session = (NHibernate.ISession) Context.Items[NHibernateModule.SESSION_KEY];
                Session.Dispose();
                Context.Items[NHibernateModule.SESSION_KEY] = null;
            }
        }</pre>

<p>To illustrate how this will work, I’ve made several additions to the code download. I’ve added a BaseController and HomeController so we can begin to run our web application. I’ve also added a IStudentDao and ICourseDao interfaces to the core project and corresponding implementations in the Data project. I’ve bound the DAO interfaces to their corresponding implementations and added debug statements to output exactly what’s happening with our session. Finally, I’ve set up a constructor in HomeController making it dependent on IStudentDao and ICourseDao. </p>

<p>When we run our application, we see from the debug output that the session is created when we create our IStudentDao. The session is reused to create our ICourseDao. This gives us everything we need to create the HomeController. The web request executes. When the request ends, the session is disposed. If you remove one of the Dao dependencies from HomeController, you’ll see that our session is created. It’s not reused because nothing else needs a session. If you remove both of the Dao dependencies from HomeController, you’ll see that our session is never even created. Since we didn’t create a session, we don’t dispose it when the web request ends.</p>

<p>That’s all for part 7. In part 8, we’ll wrap the NHibernate transaction for use in our controllers project and build a real DAO or two. </p>

<p>Get your code here! We have <a href="http://www.jasondentler.com/downloads/NStackExample.Part7.VBNET.zip" target="_blank">VB.NET</a> and <a href="http://www.jasondentler.com/downloads/NStackExample.Part7.CSharp.zip" target="_blank">CSharp</a> flavored bits. </p>

<p>Jason 
  <br />- NHibernating Ninja Wannabe</p>
