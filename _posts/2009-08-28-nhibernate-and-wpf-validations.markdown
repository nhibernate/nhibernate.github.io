---
layout: post
title: "Nhibernate and WPF: Validations"
date: 2009-08-28 01:06:36 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["validation", "Castle", "uNHAddins", "Validator", "WPF"]
redirect_from: ["/blogs/nhibernate/archive/2009/08/27/nhibernate-and-wpf-validations.aspx/"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>Part I: <a href="http://jfromaniello.blogspot.com/2009/08/introducing-nhiberate-and-wpf.html">Introducing NHiberate and WPF: The ChinookMediaManager</a>     <br />Part II: <a href="http://jfromaniello.blogspot.com/2009/08/chinook-media-manager-core.html">Nhibernate and WPF: The core</a>     <br />Part III: <a href="http://nhforge.org/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-models-concept.aspx">Nhibernate and WPF: Models concept</a>     <br />Part IV :<a href="http://jfromaniello.blogspot.com/2009/08/nhibernate-and-wpf-viewmodels-and-views.html">Nhibernate and WPF: ViewModels and Views</a></p>  <p>In this post I will show you an easy way to handle validations in WPF.</p>  <p>In System.ComponentModel we have an interesting interface named <a href="http://msdn.microsoft.com/en-us/library/system.componentmodel.idataerrorinfo.aspx">IDataErrorInfo</a>.     <br />This interface has two members:</p>  <ul>   <li>IDataErrorInfo.Item: Gets the error message for the property with the given name. </li>    <li>IDataErrorInfo.Error: Gets an error message indicating what is wrong with this object. </li> </ul>  <p>The interesting side of this interface is that if we implement this in our domain classes, the presentation layer will automatically resolved certain things.</p>  <blockquote>   <p>Side note: This interface was made with DataTables in mind. </p> </blockquote>  <h4>Validation Framework</h4>  <p>I really like NHibernateValidator, in the same way that I like NHibernate. But, in uNhAddIns we have a main principle: “those two are just options”, so you can change whenever you want to use anything else (<a href="http://msdn.microsoft.com/en-us/library/cc309509.aspx">Validation Application Block</a>, <a href="http://www.codeplex.com/ValidationFramework">Validation Framework</a>, <a href="http://www.castleproject.org/ActiveRecord/documentation/v1rc1/manual/validators.html">Castle Validators</a>, <a href="http://www.codeplex.com/xval">xVal</a>).</p>  <p>For that matter, <a href="http://fabiomaulo.blogspot.com/">Fabio Maulo</a> developed a simple interface named <a href="http://code.google.com/p/unhaddins/source/browse/trunk/uNhAddIns/uNhAddIns.Adapters/IEntityValidator.cs">IEntityValidator</a>, this is part now of the uNhAddIns.Adapters project. If you want to use Nhibernate Validator the EntityValidator is already implemented <a href="http://code.google.com/p/unhaddins/source/browse/#svn/trunk/uNhAddIns/uNhAddIns.NHibernateValidator">here</a>. If you want to use another validator framework please implement the interface and send us the patch ;-).</p>  <h4>How To </h4>  <p>Implementing IDataErrorInfo directly in domain classes is a waste of time and also is too much invasive, because will end with a dependency in the IEntityValidator. Since we already know how to build injectable behavior we can address this problem in the same way.</p>  <p>I build a new DynamicProxy IInterceptor you could see the implementation <a href="http://code.google.com/p/unhaddins/source/browse/trunk/uNhAddIns/uNhAddIns.ComponentBehaviors.Castle/DataErrorInfoInterceptor.cs">here</a>.</p>  <p>The configuration of the Album entity, now looks as follows:</p>  <pre class="code">container.Register(<span style="color: #2b91af">Component</span>.For&lt;<span style="color: #2b91af">Album</span>&gt;()
                                    .NhibernateEntity()
                                    .AddDataErrorInfoBehavior()
                                    .AddNotificableBehavior()
                                    .LifeStyle.Transient);</pre>

<p>&#160;</p>

<p>The configuration of Nhibernate.Validator is very easy and <a href="http://nhforge.org/wikis/howtonh/setup-nhv-fluently-with-your-ioc-container.aspx">I don’t want to repeat myself</a>. 

  <br />Then you need to register an IEntityValidator as follows:</p>

<pre class="code">container.Register(<span style="color: #2b91af">Component</span>.For&lt;<span style="color: #2b91af">IEntityValidator</span>&gt;()
                            .ImplementedBy&lt;<span style="color: #2b91af">EntityValidator</span>&gt;());</pre>

<p>You have three way to write validations with NHibernate Validator: Xml, Fluent and Attributes. This is aleady very well explained in this <a href="http://fabiomaulo.blogspot.com/2009/02/diving-in-nhibernatevalidator.html">post</a>.</p>

<p>In the VIEW the only thing that we need to enable is the ValidateOnDataErrors attribute, this is an example textbox:</p>

<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">TextBox </span><span style="color: red">Text</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">Path</span><span style="color: blue">=Album.Title, </span><span style="color: red">ValidatesOnDataErrors</span><span style="color: blue">=true}&quot; /&gt;</span></pre>

<p>I’ve a shared a resource for views, as follows:</p>

<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">Style </span><span style="color: red">TargetType</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">x</span><span style="color: blue">:</span><span style="color: #a31515">Type </span><span style="color: red">TextBox</span><span style="color: blue">}&quot;&gt;
    &lt;</span><span style="color: #a31515">Style.Triggers</span><span style="color: blue">&gt;
        &lt;</span><span style="color: #a31515">Trigger </span><span style="color: red">Property</span><span style="color: blue">=&quot;Validation.HasError&quot; </span><span style="color: red">Value</span><span style="color: blue">=&quot;true&quot;&gt;
            &lt;</span><span style="color: #a31515">Setter </span><span style="color: red">Property</span><span style="color: blue">=&quot;ToolTip&quot;
            </span><span style="color: red">Value</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">RelativeSource</span><span style="color: blue">={</span><span style="color: #a31515">RelativeSource </span><span style="color: red">Self</span><span style="color: blue">}, 
                   </span><span style="color: red">Path</span><span style="color: blue">=(Validation.Errors)[</span>0<span style="color: blue">].ErrorContent}&quot;/&gt;
        &lt;/</span><span style="color: #a31515">Trigger</span><span style="color: blue">&gt;
    &lt;/</span><span style="color: #a31515">Style.Triggers</span><span style="color: blue">&gt;
&lt;/</span><span style="color: #a31515">Style</span><span style="color: blue">&gt;</span></pre>
<a href="http://11011.net/software/vspaste"></a>This means: “textbox should display validation errors in tooltip”. 

<br />

<br />This is all. What?, you don’t believe me. 

<br />

<br />

<h3>See the behavior in action</h3>
See the screencast <a href="http://www.screencast.com/t/wSG2lhGbiJ6F">here</a>. 

<p>Oh, and I almost forgot, this behavior <a href="http://www.asp.net/Learn/mvc/tutorial-37-cs.aspx">should also work in ASP.NET Mvc</a>.</p>
