---
layout: post
title: "NHibernate and WPF: The GuyWire"
date: 2009-11-07 19:12:52 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "WPF"]
alias: ["/blogs/nhibernate/archive/2009/11/07/nhibernate-and-wpf-the-guywire.aspx"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p><strong><em>Note: I owe this knowledge to my friend <a href="http://fabiomaulo.blogspot.com/">Fabio Maulo</a>, so I would like to thank him for teaching me and letting me share.</em></strong> </p>  <h1>Introduction</h1>  <p>I will show you in this post a nice way to configure your IoC container and some other aspects of your applications. I assume for this article that you have good knowledge of dependency injection and inversion of control.</p>  <h1>The problem</h1>  <p>There was a time when we used to configure our containers with xml, and all was fine. Then we started to use fluent and strongly typed interfaces and a problem became more frequent and acute. Basically, when we use a fluent interface, we do something like this:</p>  <pre class="brush: csharp;">container.Register(Component.For&lt;IAlbumRepository&gt;()
                       .ImplementedBy&lt;AlbumRepository&gt;()
                       .LifeStyle.Transient);</pre>

<p>IAlbumRepository is in Chinook.Data and AlbumRepository is in Chinook.Data.Impl.&#160; <br />The problem is not *how* but <strong><u>*where*</u></strong>. Where do you do this? </p>

<p>Most people will say “The startup project”. One of the goal that we look when using IoC is:</p>

<blockquote>
  <p>..decoupling of the execution of a certain task from implementation.</p>
</blockquote>

<p>Pay attention to the “Decoupling” part. If you want “decoupling”: Why do you add all those references in your startup project?</p>

<p>This is a <a href="http://www.ndepend.com/">NDepend</a> extracted graph of the Northwind example that comes with <a href="http://www.sharparchitecture.net/">Sharp Architecture</a>:</p>

<p><img border="0" src="http://content.screencast.com/users/JoseFR/folders/Jing/media/82a585f2-6ae5-4f3b-ba29-fc3f283be6ad/2009-10-26_1333.png" width="585" height="336" /></p>

<p>&#160;</p>

<p>If you look at the Northwind.Web assembly you will see that it has a reference even to NHibernate. It has a reference to Northwind.Data (repositories that use NHibernate). The contract interface of repositories is in Northwind.Core. Also you can see that the start up project need a reference to Castle Container. If I want a loosely coupled solution, I don’t want some of those references.</p>

<p>Pay atention; the northwind example of Sharp Architecture is a very good example, is a good architecture, and this is neither a complain nor a criticism. I’m pretty sure that it defines interfaces and implementations separately, as I’m pretty sure that controllers depends upon IRepositories. But, I think it has a problem at reference level. The main problem is because the initialization of the container is in a wrong place. You could see the initialization script <a href="http://github.com/codai/Sharp-Architecture/blob/master/src/NorthwindSample/app/Northwind.Web/CastleWindsor/ComponentRegistrar.cs">here</a>.</p>

<p>So, what I’m looking for is:</p>

<ul>
  <li>I don’t want references to concrete implementations in my startup project. </li>

  <li>I don’t want to depend upon a specific IoC container technology. </li>

  <li>And finally I don’t want to configure my container in the startup project, its is another “aspect” of my application like the repositories! </li>
</ul>

<p></p>

<h1>The Solution</h1>

<p>The solution is very simple. Take the container initialization to another place. </p>

<p>We used to call this place “The GuyWire”, in italian “Cavo Portante”, in spanish “Cable Maestro”:</p>

<blockquote>
  <p>A <b>guy-wire</b> or <b>guy-rope</b> is a tensioned cable designed to add stability to structures</p>
</blockquote>

<p>Two simple rules to remember:</p>

<ol>
  <li>In order to configure service and implementers fluently, the GuyWire will reference everything. </li>

  <li>Because the guy-wire reference everything, the GuyWire can not be referenced. </li>
</ol>

<p>The guywire is an excellent place to “configure” the whole application. I used to separate the configuration in different aspects. Here some examples:</p>

<ul>
  <li>ORM configuration </li>

  <li>Constraint Validator configuration </li>

  <li>Repositories configuration </li>

  <li>Entities configuration </li>

  <li>ViewModel configuration </li>

  <li>Controllers configuration </li>

  <li>Views configuration </li>
</ul>

<p>You can explore the configurators of ChinookMediaManager <a href="http://code.google.com/p/unhaddins/source/browse/#svn/trunk/Examples/uNHAddIns.Examples.WPF/ChinookMediaManager.GuyWire/Configurators">here</a>.</p>

<h2>How does it works?</h2>

<p>The guywire project has an special “Output Path”:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_53062B8B.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="image" border="0" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_6AC28453.png" width="552" height="255" /></a> </p>

<p>So, the path is the “Startup” project.</p>

<p>Secondly, in the App.Config, I have a config like this:</p>

<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">appSettings</span><span style="color: blue">&gt;
  &lt;</span><span style="color: #a31515">add </span><span style="color: red">key</span><span style="color: blue">=</span>&quot;<span style="color: blue">GuyWire</span>&quot; <span style="color: red">value</span><span style="color: blue">=</span>&quot;<span style="color: blue">ChinookMediaManager.GuyWire.GeneralGuyWire, ChinookMediaManager.GuyWire</span>&quot; <span style="color: blue">/&gt;
&lt;/</span><span style="color: #a31515">appSettings</span><span style="color: blue">&gt;</span></pre>
<a href="http://11011.net/software/vspaste"></a>

<p>And finally, in my App.Xaml.cs:</p>

<pre class="code"><span style="color: blue">public partial class </span><span style="color: #2b91af">App </span>: Application
{
    <span style="color: blue">private readonly </span>IGuyWire guyWire = ApplicationConfiguration.GetGuyWire();

    <span style="color: blue">public </span>App()
    {
        guyWire.Wire();
    }

    <span style="color: blue">protected override void </span>OnStartup(StartupEventArgs e)
    {
        <span style="color: blue">var </span>viewFactory = ServiceLocator.Current.GetInstance&lt;IViewFactory&gt;();
        viewFactory.ShowView&lt;BrowseArtistViewModel&gt;();
    }

    <span style="color: blue">protected override void </span>OnExit(ExitEventArgs e)
    {
        guyWire.Dewire();
        <span style="color: blue">base</span>.OnExit(e);
    }
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>The interface IGuyWire and other classes needed for doing this, are in unhaddins.</p>

<p>The reference graph of the Chinook Media Manager, is as follows:</p>

<p>&#160;</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_4961041A.png"><img style="border-bottom: 0px; border-left: 0px; display: inline; border-top: 0px; border-right: 0px" title="image" border="0" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_4FAA6B59.png" width="578" height="593" /></a> </p>

<p>&#160;</p>

<p>&#160;</p>

<p>&#160;</p>

<h2>A last word about the Configurators</h2>

<p>I really like the idea of have different parts of the application configuration in separated classes. I used to reuse this configurators alone in my Tests. But, as a I said before, the guywire should not be referenced by any project. So, my trick is add the configurator as a “linked file” to the test project:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6BBD04E1.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="image" border="0" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_400C3AE5.png" width="243" height="117" /></a> </p>

<p>And this is a sample:</p>

<pre class="code">[<span style="color: #2b91af">TestFixture</span>]
<span style="color: blue">public class </span><span style="color: #2b91af">AlbumValidationFixture
</span>{
    <span style="color: blue">private </span><span style="color: #2b91af">IWindsorContainer </span>container;

    [<span style="color: #2b91af">TestFixtureSetUp</span>]
    <span style="color: blue">public void </span>FixtureSetUp()
    {
        container = <span style="color: blue">new </span><span style="color: #2b91af">WindsorContainer</span>();
        <span style="color: blue">var </span>configurator = <span style="color: blue">new </span><span style="color: #2b91af">NHVConfigurator</span>();
        configurator.Configure(container);
    }

    [<span style="color: #2b91af">Test</span>]
    <span style="color: blue">public void </span>title_constraints()
    {
        GetConstraint&lt;<span style="color: #2b91af">Album</span>, <span style="color: #2b91af">NotEmptyAttribute</span>&gt;(a =&gt; a.Title)
            .Message
            .Should().Be.EqualTo(<span style="color: #a31515">&quot;Title should not be null.&quot;</span>);

        GetConstraint&lt;<span style="color: #2b91af">Album</span>, <span style="color: #2b91af">LengthAttribute</span>&gt;(a =&gt; a.Title)
            .Should().Be.OfType&lt;<span style="color: #2b91af">LengthAttribute</span>&gt;()
            .And.ValueOf.Message.Should().Be.EqualTo(<span style="color: #a31515">&quot;Title should not exceed 200 chars.&quot;</span>);
            
        
    }
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>I will not talk about this long break in the series. If you are interested in Wpf and Nhibernate, you should be happy because; <strong><u>I'M BACK</u>!</strong></p>
