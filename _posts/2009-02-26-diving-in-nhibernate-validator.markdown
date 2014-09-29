---
layout: post
title: "Diving in NHibernate.Validator"
date: 2009-02-26 14:46:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["validation", "HowTo", "fluent configuration", "Validator"]
alias: ["/blogs/nhibernate/archive/2009/02/26/diving-in-nhibernate-validator.aspx"]
author: fabiomaulo
gravatar: cd6db202ce94ed7e5f1fde30e702dc7f
---
{% include imported_disclaimer.html %}
<p>Surfing in the NET, to find some NHibernate.Validator (NHV) example, I saw that there are various things not so clear about how NHV is working. In this post I&rsquo;ll try to give you a more deep explication.</p>
<h4>Class validation definition</h4>
<p>In these examples I will use the follow simple class :</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">Customer<br /></span>{<br /><span style="color: blue">public string </span>FirstName { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br /><span style="color: blue">public string </span>LastName { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br /><span style="color: blue">public string </span>CreditCard { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>Using Attributes the definition look like the follow:</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">Customer<br /></span>{<br />[<span style="color: #2b91af">Length</span>(Min = 3, Max = 20)]<br /><span style="color: blue">public string </span>FirstName { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br /><br />[<span style="color: #2b91af">Length</span>(Min=3, Max = 60)]<br /><span style="color: blue">public string </span>LastName { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br /><br />[<span style="color: #2b91af">CreditCardNumber</span>]<br /><span style="color: blue">public string </span>CreditCard { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>Using XML mapping the configuration is :</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Customer</span>"<span style="color: blue">&gt;<br />&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">FirstName</span>"<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">length </span><span style="color: red">min</span><span style="color: blue">=</span>"<span style="color: blue">3</span>" <span style="color: red">max</span><span style="color: blue">=</span>"<span style="color: blue">20</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;<br />&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">LastName</span>"<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">length </span><span style="color: red">min</span><span style="color: blue">=</span>"<span style="color: blue">3</span>" <span style="color: red">max</span><span style="color: blue">=</span>"<span style="color: blue">60</span>"<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;<br />&lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">CreditCard</span>"<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">creditcardnumber</span><span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;<br />&lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;</span></pre>
<p>
<br /><a href="http://11011.net/software/vspaste"></a><strong><span style="text-decoration: underline;">NOTE:</span></strong> In this example I will use the NHV convention for XML Validation-Definition that mean the mapping file is an embedded resource, is in the same folder (namespace) of the class and its name is the name of the class followed by &ldquo;.nhv.xml&rdquo; (in this case Customer.nhv.xml).&nbsp; </p>
<p>Using fluent-interface configuration :</p>
<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">CustomerDef</span>: <span style="color: #2b91af">ValidationDef</span>&lt;<span style="color: #2b91af">Customer</span>&gt;<br />{<br /><span style="color: blue">public </span>CustomerDef()<br />{<br />   Define(x =&gt; x.FirstName).LengthBetween(3, 20);<br />   Define(x =&gt; x.LastName).LengthBetween(3, 60);<br />   Define(x =&gt; x.CreditCard).IsCreditCardNumber();<br />}<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>As you can see you have 3 ways to define validation constraints for a class. For each class, you must use at least one validation definition and at most two; this mean that you can even mix the &ldquo;Attribute way&rdquo; with one of the &ldquo;External&rdquo; ways (here <span style="text-decoration: underline;">&ldquo;external&rdquo;</span> mean that the validation is defined <span style="text-decoration: underline;">out-side</span> the class).</p>
<h4>The ValidatorEngine</h4>
<p>At first, the ValidatorEngine, is your entry-point. If you are using <a href="http://msdn.microsoft.com/en-us/library/aa288059(VS.71).aspx">Attributes</a>, you can do something like this:</p>
<pre class="code"><span style="color: blue">public void </span>WithOutConfigureTheEngine()<br />{<br /><span style="color: blue">var </span>customer = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"F"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: blue">var </span>ve = <span style="color: blue">new </span><span style="color: #2b91af">ValidatorEngine</span>();<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer), <span style="color: #2b91af">Is</span>.False);<br />}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>What happen behind the scene is:</p>
<p>JITClassMappingFactory:Reflection applied for Customer 
  <br />ReflectionClassMapping:For class Customer Adding member FirstName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member LastName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member CreditCard to dictionary with attribute CreditCardNumberAttribute</p>
<p>As you can see NHV is investigating the class to know all attributes. Now the same example <strong>using two instances of ValidatorEngine</strong></p>
<pre class="code"><span style="color: blue">var </span>customer = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"F"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: blue">var </span>ve1 = <span style="color: blue">new </span><span style="color: #2b91af">ValidatorEngine</span>();<br /><span style="color: #2b91af">Assert</span>.That(ve1.IsValid(customer), <span style="color: #2b91af">Is</span>.False);<br /><span style="color: blue">var </span>ve2 = <span style="color: blue">new </span><span style="color: #2b91af">ValidatorEngine</span>();<br /><span style="color: #2b91af">Assert</span>.That(ve2.IsValid(customer), <span style="color: #2b91af">Is</span>.False);</pre>
<p>What happen behind is:</p>
<p>JITClassMappingFactory:Reflection applied for Customer 
  <br />ReflectionClassMapping:For class Customer Adding member FirstName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member LastName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member CreditCard to dictionary with attribute CreditCardNumberAttribute</p>
<p>JITClassMappingFactory:Reflection applied for Customer 
  <br />ReflectionClassMapping:For class Customer Adding member FirstName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member LastName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member CreditCard to dictionary with attribute CreditCardNumberAttribute</p>
<p>Ups&hellip; NHV is investigating the same class two times.</p>
<p>Now again the same example but using <strong>only one ValidatorEngine instance</strong>:</p>
<pre class="code"><span style="color: blue">var </span>customer1 = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"F"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: blue">var </span>ve = <span style="color: blue">new </span><span style="color: #2b91af">ValidatorEngine</span>();<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer1), <span style="color: #2b91af">Is</span>.False);<br /><span style="color: blue">var </span>customer2 = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"Fabio"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer2), <span style="color: #2b91af">Is</span>.True);</pre>
<p>Here we are validating two instances of Customer class <strong>using the same ValidatorEngine</strong> and what happen behind is:</p>
<p>JITClassMappingFactory:Reflection applied for Customer 
  <br />ReflectionClassMapping:For class Customer Adding member FirstName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member LastName to dictionary with attribute LengthAttribute 
  <br />ReflectionClassMapping:For class Customer Adding member CreditCard to dictionary with attribute CreditCardNumberAttribute</p>
<p>As you can see, the class Customer, was investigated <strong>only one time</strong>, NHV are using reflection <strong>only one time</strong>.</p>
<p><em>Conclusion</em>: <strong>For performance issue, the ValidatorEngine instance should have the same lifecycle of your application</strong>.</p>
<h4>The XML convention</h4>
<p>As you probably know, I like, very much, all framework complying with rule &ldquo;DON&rsquo;T TOUCH MY CODE&rdquo; (more quite &ldquo;no invasive framework&rdquo;). With NHV you can define an &ldquo;external&rdquo; XML file as validation definition. The convention, come in place, when you configure the ValidatorEngine to use an &ldquo;External&rdquo; source for validation-definitions. The configuration in the application config file is:</p>
<pre class="code">    <span style="color: blue">&lt;</span><span style="color: #a31515">nhv-configuration </span><span style="color: red">xmlns</span><span style="color: blue">=</span>'<span style="color: blue">urn:nhv-configuration-1.0</span>'<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>'<span style="color: blue">default_validator_mode</span>'<span style="color: blue">&gt;</span>UseExternal<span style="color: blue">&lt;/</span><span style="color: #a31515">property</span><span style="color: blue">&gt;<br />&lt;/</span><span style="color: #a31515">nhv-configuration</span><span style="color: blue">&gt;<br /></span></pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>Given the above first class and embedding the file Customer.nhv.xml in the same namespace, I&rsquo;m going to run the follow test:</p>
<pre class="code"><span style="color: blue">var </span>ve = <span style="color: blue">new </span><span style="color: #2b91af">ValidatorEngine</span>();<br />ve.Configure();<br /><br /><span style="color: blue">var </span>customer1 = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"F"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer1), <span style="color: #2b91af">Is</span>.False);<br /><span style="color: blue">var </span>customer2 = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"Fabio"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer2), <span style="color: #2b91af">Is</span>.True);</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>What happen behind the scene is:</p>
<p>JITClassMappingFactory: - XML convention applied for Customer 
  <br />XmlClassMapping: - Looking for rules for property : FirstName 
  <br />XmlClassMapping: - Adding member FirstName to dictionary with attribute LengthAttribute 
  <br />XmlClassMapping: - Looking for rules for property : LastName 
  <br />XmlClassMapping: - Adding member LastName to dictionary with attribute LengthAttribute 
  <br />XmlClassMapping: - Looking for rules for property : CreditCard 
  <br />XmlClassMapping: - Adding member CreditCard to dictionary with attribute CreditCardNumberAttribute</p>
<p>As you can see, this time, the JITClassMappingFactory (JIT = Just In Time), are using <span style="color: #2b91af">XmlClassMapping</span> instead <span style="color: #2b91af">ReflectionClassMapping</span>. Again the validation definition investigation will be done only one time per <span style="color: #2b91af">ValidatorEngine</span> instance. </p>
<p>If you use XML you can even work without use the convention; in this case you must provide a more complete <span style="color: #800000">nhv-configuration</span> section declaring where are mappings files.</p>
<h4>The Fluent-Interface</h4>
<p>Details about configuration via fluent-interface are available <a href="http://fabiomaulo.blogspot.com/2009/02/nhibernatevalidator-fluent-interface.html">here</a>. To complete the example series, the test is this:</p>
<pre class="code"><span style="color: blue">var </span>config = <span style="color: blue">new </span><span style="color: #2b91af">FluentConfiguration</span>();<br />config<br />.SetDefaultValidatorMode(<span style="color: #2b91af">ValidatorMode</span>.UseExternal)<br />.Register&lt;<span style="color: #2b91af">CustomerDef</span>, <span style="color: #2b91af">Customer</span>&gt;();<br /><span style="color: blue">var </span>ve = <span style="color: blue">new </span><span style="color: #2b91af">ValidatorEngine</span>();<br />ve.Configure(config);<br /><br /><span style="color: blue">var </span>customer1 = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"F"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer1), <span style="color: #2b91af">Is</span>.False);<br /><span style="color: blue">var </span>customer2 = <span style="color: blue">new </span><span style="color: #2b91af">Customer </span>{ FirstName = <span style="color: #a31515">"Fabio"</span>, LastName = <span style="color: #a31515">"Fermani" </span>};<br /><span style="color: #2b91af">Assert</span>.That(ve.IsValid(customer2), <span style="color: #2b91af">Is</span>.True);</pre>
<p>What happen behind is:</p>
<p>OpenClassMapping:- For class Customer Adding member FirstName to dictionary with attribute LengthAttribute 
  <br />OpenClassMapping:- For class Customer Adding member LastName to dictionary with attribute LengthAttribute 
  <br />OpenClassMapping:- For class Customer Adding member CreditCard to dictionary with attribute CreditCardNumberAttribute 
  <br />StateFullClassMappingFactory:- Adding external definition for Customer</p>
<p>Here the JITClassMappingFactory don&rsquo;t is working; NHV is using the <span style="color: #2b91af">StateFullClassMappingFactory</span> during configuration, the JITClassMappingFactory will come in play only after <em>configuration-time</em>. Again the validation definition investigation will be done only one time per <span style="color: #2b91af">ValidatorEngine</span> instance.</p>
<h4>The SharedEngineProvider</h4>
<p>Perhaps this is the real motivation of this post. As I said above, <strong>the ValidatorEngine, should have the same lifecycle of your application</strong>, the v<em>alidation</em> is a cross-cutting-concern and you need to use it from different tiers. In my opinion the better definition of SharedEngineProvider is :</p>
<p><strong>The SharedEngineProvider is the service locator for the ValidatorEngine</strong>.</p>
<p>If you are using NHibernate.Validator, especially with its integration with NHibernate, <strong><span style="text-decoration: underline;">you should define an implementation of ISharedEngineProvider </span></strong>to ensure that, in all your tiers, you are using exactly the same constraints and to avoid more than one ValidatorEngine instances.</p>
<p>The interface is really trivial:</p>
<pre class="code"><span style="color: gray">/// &lt;summary&gt;<br />/// </span><span style="color: green">Contract for Shared Engine Provider<br /></span><span style="color: gray">/// &lt;/summary&gt;<br /></span><span style="color: blue">public interface </span><span style="color: #2b91af">ISharedEngineProvider<br /></span>{<br /><span style="color: gray">/// &lt;summary&gt;<br />/// </span><span style="color: green">Provide the shared engine instance.<br /></span><span style="color: gray">/// &lt;/summary&gt;<br />/// &lt;returns&gt;</span><span style="color: green">The validator engine.</span><span style="color: gray">&lt;/returns&gt;<br /></span><span style="color: #2b91af">ValidatorEngine </span>GetEngine();<br />}</pre>
<p>To configure the SharedEngineProvider you can use the application config or the NHibernate.Validator.Cfg.<span style="color: #2b91af">Environment</span> class before any other task (regarding NHV). Any other configuration will be ignored (in fact you don&rsquo;t have anything to configure the SharedEngineProvider trough <span style="color: #2b91af">FluentConfiguration</span>). </p>
<p>A good way to implements a SharedEngineProvider is using your preferred <a href="http://en.wikipedia.org/wiki/Inversion_of_control">IoC container</a>, or using <a href="http://www.codeplex.com/CommonServiceLocator">CommonServiceLocator</a>. The SharedEngineProvider is used, where available, by the two listeners for NHibernate integration. A generic configuration look like:</p>
<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">nhv-configuration </span><span style="color: red">xmlns</span><span style="color: blue">=</span>'<span style="color: blue">urn:nhv-configuration-1.0</span>'<span style="color: blue">&gt;<br />   &lt;</span><span style="color: #a31515">shared_engine_provider </span><span style="color: red">class</span><span style="color: blue">=</span>'<span style="color: blue">NHibernate.Validator.Event.NHibernateSharedEngineProvider, NHibernate.Validator</span>'<span style="color: blue">/&gt;<br />&lt;/</span><span style="color: #a31515">nhv-configuration</span><span style="color: blue">&gt;<br /></span></pre>
<p>You should change the class if you want use your own implementation of ISharedEngineProvider. <strong>The usage of your own implementation is strongly recommended</strong> especially in WEB and even more if you are using an IoC container.</p>
<p><a href="http://fabiomaulo.blogspot.com/">Fabio Maulo.</a></p>
