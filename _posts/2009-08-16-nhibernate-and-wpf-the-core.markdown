---
layout: post
title: "Nhibernate and WPF: The core"
date: 2009-08-16 00:30:52 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["AOP", "Session", "WPF"]
alias: ["/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-the-core.aspx"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>   <br />Part I: <a href="http://jfromaniello.blogspot.com/2009/08/introducing-nhiberate-and-wpf.html">Introducing NHiberate and WPF: The ChinookMediaManager</a></p>  <h3>Introduction</h3>  <p>   <br />This is my second post about the Chinook Media Manager, an example application for NHibernate and WPF. In this post I will outline some concepts behind the architecture that I’ve chosen.</p>  <h3>Note</h3>  <p>Probably at some points you will feel that this is over-architected, YAGNI and so on. Yes, you are right I’m not trying to bind a grid to a collection of objects there are tons of samples on the net about that subject.    <br /></p>  <h3>The four musketeers</h3>  <p>The core of the application is composed of four components:</p>  <ul>   <li>ChinookMediaManager.Data: Contains the definition of repositories interfaces. </li>    <li>ChinookMediaManager.DataImpl: Contains the implementation of these repositories plus other nhibernate things that we will need to make work the implementation of repositories (like mappings). </li>    <li>ChinookMediaManager.Domain: Contains the domain classes plus model interfaces (we will focus on this concept latter) </li>    <li>ChinookMediaManager.DomainImpl: Contains the implementation of the models. </li> </ul>  <p>My base repository definition is as follows: </p>  <pre class="code"><span style="color: blue">public interface </span><span style="color: #2b91af">IRepository</span>&lt;T&gt; : IQueryable&lt;T&gt;
    {
        T Get(<span style="color: blue">object </span>id);
        T Load(<span style="color: blue">object </span>id);
        T MakePersistent(T entity);
        <span style="color: blue">void </span>Refresh(T entity);
        <span style="color: blue">void </span>MakeTransient(T entity);
    }</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>This means that a repository is a IQueryable&lt;T&gt; by itself and we can build queries in a more natural way. 
  <br />I have seen a lot of repositories implementations with methods Save, Update and Delete, there is nothing wrong with it, just that I think that MakePersistent (Save) and MakeTransient (Delete) better represents that functionality (I have stolen this terminology from a <a href="http://gustavoringel.blogspot.com/">Gustavo Ringel</a>’s example). 

  <br />You could find the implementation <a href="http://code.google.com/p/unhaddins/source/browse/trunk/Examples/uNHAddIns.Examples.WPF/ChinookMediaManager.Data.Impl/Repositories/Repository.cs">here</a>. 

  <br /></p>

<h3>Don’t touch “the domain”</h3>

<p>Working with WPF sometimes you will need that your entities implement INotifyPropertyChanged or IEditableObject for data binding. Although the implementation of those interfaces is simple, if you implement directly in your domain you will tie your domain to a presentation concern and also will end writing a lot of code. 
  <br />

  <br />So, I wrote an addin for nhibernate (unhaddins.wpf) that will help you to inject those behaviors without touching anything in your domain model.&#160; <br />

  <br />We only have to add the entity to the container as follows:</p>

<pre class="code">container.Register(Component.For&lt;Album&gt;()
    .NhibernateEntity()
    .AddNotificableBehavior()
    .LifeStyle.Transient);</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>If you need to add editable object behavior (read <a href="http://jfromaniello.blogspot.com/2009/07/ieditableobject-useful-interface.html">this</a> and <a href="http://jfromaniello.blogspot.com/2009/07/ieditableobject-another-behaviour-for.html">this</a>) you simple put “.AddEditableBehavior()”. 

  <br />If we want a transient instance we will request it to the container (or an object factory). In unhaddins we have got an artifact that allows nhibernate to instantiate entities from the container, read <a href="http://fabiomaulo.blogspot.com/2008/11/entities-behavior-injection.html">this</a> post from Fabio Maulo. 

  <br />

  <br />For INotifyCollectionChanged, unhaddins.wpf has a Collection Type Factory, we need to configure NHibernate as follows:</p>

<pre class="code">nhConfiguration.Properties[Environment.CollectionTypeFactoryClass] =
  <span style="color: blue">typeof </span>(WpfCollectionTypeFactory).AssemblyQualifiedName;</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>With this simple step all bag, sets and list (more coming up) of objects retrieved from NHibernate will implement INotifyCollectionChanged.</p>

<p>It goes without saying that this configuration is not in the domain. 
  <br />

  <br />As you can see, I don’t have to put presentations concerns inside <em>“the four musketeers”</em>. </p>

<p>In the next post I will talk about models and CpBT.</p>
