---
layout: post
title: "Part 6: Ninject and MVC or How to be a Web Ninja"
date: 2009-08-29 05:34:47 +1200
comments: true
published: true
categories: ["blog", "archives"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/08/28/part-6-ninject-and-mvc-or-how-to-be-a-web-ninja.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p><img style="border-right-width: 0px; margin: 10px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" border="0" alt="Ninject" align="left" src="http://kohari.org/wp-content/themes/thesis_151/custom/images/ninject-logo.png" />Nope. I don’t mean <a href="http://askaninja.com/" target="_blank">this guy</a>. He’s cool – well, maybe, maybe not - but I was thinking less comedic assassin and more dependency injection (DI.) <a href="http://ninject.org/" target="_blank">Ninject</a> is the illegitimate brain child of <a href="http://kohari.org/" target="_blank">Nate Kohari</a>, and the subject of today’s post. For those of you looking for another NHibernate fix, we’ll set up session-per-request in part 7.</p>  <p>If you’re new here, you can check out <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/" target="_blank">Part 1</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-2/" target="_blank">Part 2</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-3/" target="_blank">Part 3</a>, <a href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-4/" target="_blank">Part 4</a>, and <a href="http://jasondentler.com/blog/2009/08/part-5-fixing-the-broken-stuff/" target="_blank">Part 5</a> to catch up. Grab the latest source from the end of Part 5.</p>  <p>If you remember back in the part 1, I said we’d be using Ninject v1. I lied. We’ll be using v1.5. This is the version built by <a href="http://groups.google.co.uk/group/horn-development" target="_blank">horn</a>, and the version that includes Ninject.Framework.MVC.dll. Save yourself some time. Go get the source for horn, build it, and then let horn build Ninject, Fluent NHibernate, and MVCContrib. </p>  <p>Let’s talk about Ninject’s constructor dependency injection. Say you have an AccountBuilder object that builds up a user account object from some fields on a “new user” form and saves it to the database. That’s a pretty complicated task for just one object. You should split off the persistence responsibility to a DAO or Repository and the password hashing / encryption to a password service. The AccountBuilder doesn’t care how the DAO saves the data, just that it does. It also doesn’t care how the password is secured. AccountBuilder has a dependency on each of these services. If ever there was a time to code to interfaces, this is it. The constructor looks like this:</p>  <pre class="brush:vbnet">Public Sub New(DAO As ISaveUserAccounts, PwdHasher As IHashPasswords)</pre>

<pre class="brush:csharp">public AccountBuilder(ISaveUserAccounts DAO, IHashPasswords PwdHasher)</pre>

<p>The details of the constructor aren’t important, only the signature. AccountBuilder is a concrete type, meaning we can create an instance of it, so Ninject can auto self-bind it. We don’t have to tell Ninject ahead of time that it will be creating an AccountBuilder for us. When we ask Ninject to get an AccountBuilder for us, it checks to see if it has a binding for it (more on that in a minute). Since it doesn’t, it checks to see if it can create an object of type AccountBuilder. Since AccountBuilder isn’t abstract (MustInherit in VB.NET) or an interface, Ninject decides that it will just create an AccountBuilder for us. </p>

<p>it goes through all the constructors searching for one with the Inject attribute or the one with the most parameters. Once it’s decided on a constructor, it tries to resolve each of those parameters. Let’s say for a minute that instead of the interfaces, we had specified the actual concrete implementations as parameters. Ninject would resolve each of those the same way it is resolving AccountBuilder. It goes on and on recursively as deep as necessary to resolve each and every dependency until it has instances of DAO and PasswordHasher to use as parameters for the AccountBuilder constructor. Finally, it calls the constructor with those parameters and gives us our AccountBuilder. </p>

<p>Now, because we’ve coded to interfaces, we have to tell Ninject exactly which implementation of those interfaces we want to use. So, we tell Ninject that each time anything needs an ISaveUserAccounts, build up a new instance of UserAccountDAO. It has to be a new instance each time, because UserAccountDAO depends on NHibernate.ISession, which isn’t constant throughout the application. We’ll bind ISession to a Ninject provider. You’ll see an example of that in our application in part 7. The binding for ISaveUserAccounts looks like this:</p>

<pre class="brush:vbnet">        Bind(Of ISaveUserAccounts).To(Of UserAccountDAO)()</pre>

<pre class="brush:csharp">        Bind&lt;ISaveUserAccounts&gt;().To&lt;UserAccountDAO&gt;();</pre>

<p>The password hasher service can be handled a little differently. Let’s suppose for a minute that encryption algorithms can be fairly heavy-weight. We don’t want to build the algorithm over and over, possibly thousands or millions of times an hour on a popular site. Even if it doesn’t bring the site to a screeching halt, it would slow it down significantly. Since the algorithm is reusable, we’re only going to build one for our entire application. Of course, your first thought is “the evil singleton anti-pattern.” Would I do that to you? Well yes, but not intentionally. We are going to create an instance of our PasswordHasher and tell Ninject to pass it out anytime our application needs an implementation of IHashPasswords. The binding looks like this:</p>

<pre class="brush:vbnet">        Bind(Of IHashPasswords).ToConstant(New PasswordHasher)()</pre>

<pre class="brush:csharp">        Bind&lt;IHashPasswords&gt;().ToConstant(New PasswordHasher());</pre>

<p>Of course, if you use just one instance across your entire web, WPF, or multi-threaded application, PasswordHasher will almost certainly need to be thread-safe, but that’s another series of posts. </p>

<p>Now that Ninject knows what implementations to use for those parameters of our AccountBuilder constructor, it builds a new UserAccountDAO, grabs our one-and-only instance of PasswordHasher, calls the constructor and gives us our AccountBuilder. Of course, this is still a pretty basic example.</p>

<p>Now let’s look at <a href="http://www.asp.net/mvc/" target="_blank">ASP.NET MVC</a>. Up to this point in the series, we’ve talked a lot about the model. Now it’s time to talk about controllers. Controllers in an MVC application manage the flow of your application from view to view, call in to the model to perform actions, and pass data between the model and the views. </p>

<p>Suppose our AccountBuilder is actually a service consumed by our Account controller to carry out the work of registering a new user account. If you’re new to this, you may think that we’re just going to somehow pass in the Ninject kernel to our controller and get our AccountBuilder from there. While I don’t recommend it, you can do that. You’ll essentially end up with the ServiceLocator pattern. We’re going to take this to what may seem an illogical or even perverse extreme. Why not let Ninject build your controllers and inject all of your dependencies? You won’t have any ServiceLocator clutter in your controllers. At least as far as user code goes, the controller is near the bottom of the call stack. You’re in this perfect world where EVERYTHING is injected for you. Let that sink in for a minute. You don’t have to new up a single service ever again. Just ask for it in the constructor wherever you need it. Of course, that’s an absolute and absolutes are evil for the same reason singletons are – you can’t easily prove them with tests. </p>

<p>But wait, doesn’t ASP.NET MVC build the controllers? Yes it does, but it doesn’t have to. Deep inside the mother ship, apparently while hiding from that guy who invented the sealed keyword, <a href="http://haacked.com" target="_blank">Haacked</a> and Co.&#160; built all sorts of extension points in to ASP.NET MVC. One of these extension points happens to be the ability to replace the default controller factory using ControllerBuilder.Current.SetControllerFactory. Just supply the type of your new controller factory implementation. </p>

<p>So, you set up a controller factory to resolve the controllers using Ninject and register all of your controllers with the kernel, right? Wrong. Well, not exactly. Ninject.Framework.MVC has all of that pre-built for you – just use it. Ninject actually has an implementation of HttpApplication that will set up all of this for you. In your Global.asax codebehind file, inherit from Ninject.Framework.Mvc.NinjectHttpApplication. You’ll still have to register your routes. You also have to build the Ninject kernel with all of your ninject modules. </p>

<p>A ninject module is a class that sets up your bindings. So for instance, if you have a module for binding your DAO interfaces to their implementations, it might look something like this:</p>

<pre class="brush:vbnet">Public Class DaoModule
     Inherits StandardModule

     Public Overrides Sub Load()
          Bind(Of ISaveUserAccounts)().To(Of UserAccountDao)()
          Bind(Of ILookupUserAccounts)().To(Of UserAccountDao)()
          Bind(Of IUserAccountDao)().To(Of UserAccountDao)()
          Bind(Of ISaveContacts)().To(Of ContactDao)()
          ' and so on...
     End Sub

End Class</pre>

<pre class="brush:csharp">public class DaoModule : StandardModule
{
    public override void Load()
    {
        Bind&lt;ISaveUserAccounts&gt;().To&lt;UserAccountDAO&gt;();
        Bind&lt;ILookupUserAccounts&gt;().To&lt;UserAccountDAO&gt;();
        Bind&lt;IUserAccountDao&gt;().To&lt;UserAccountDAO&gt;();
        Bind&lt;ISaveContacts&gt;().To&lt;ContactDAO&gt;();
        // and so on...
    }
}</pre>

<p>Of course, we haven’t built any DAOs to bind yet. We haven’t built any controllers to bind yet either. That brings up another point. If there is a single point of constant change during the development of your application, it will most likely be the controllers. Will you always remember to bind new controllers as you build them? Yeah, neither will I. Wouldn’t it be nice if Ninject just went looking for them instead? That’s exactly what AutoControllerModule is for. Just point it at an assembly. It will find all of your controllers and wire them in to Ninject and its controller factory. </p>

<p>At this stage, our Global.asax codebehind looks something like this:</p>

<pre class="brush:vbnet">Imports Ninject.Framework.Mvc
Imports Ninject.Core

Public Class MvcApplication
    Inherits NinjectHttpApplication

    Protected Overrides Function CreateKernel() As Ninject.Core.IKernel
        Dim ControllerModule As New AutoControllerModule( _
            GetType(NStackExample.Controllers.BaseController).Assembly)
        Dim Kernel As IKernel = New StandardKernel(ControllerModule)
        Return Kernel
    End Function

    Protected Overrides Sub RegisterRoutes(ByVal routes As System.Web.Routing.RouteCollection)
        routes.IgnoreRoute(&quot;{resource}.axd/{*pathInfo}&quot;)

        ' MapRoute takes the following parameters, in order:
        ' (1) Route name
        ' (2) URL with parameters
        ' (3) Parameter defaults
        routes.MapRoute( _
            &quot;Default&quot;, _
            &quot;{controller}/{action}/{id}&quot;, _
            New With {.controller = &quot;Home&quot;, .action = &quot;Index&quot;, .id = &quot;&quot;} _
        )
    End Sub

End Class</pre>

<p>If you don’t want Ninject invading your application that deeply, with a good understanding of Ninject and controller factories, you can easily do all of this by hand. Still, I’m pretty confident Nate wrote better code and tests than most of us would have. </p>

<p>That’s it for part 6. In part 7, we’ll wire up <a href="http://nhforge.org" target="_blank">NHibernate</a> to Ninject, talk about our options for session handling in a web app, and set up session-per-request. With a bit of luck, part 7 will be out this weekend.&#160; </p>

<p>Once again, these are just my practices, not necessarily best practices. As always, feedback welcome, flames by appointment only. </p>

<p>Jason 
  <br />- 6 down, 52 to go. maybe. </p>
