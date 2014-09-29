---
layout: post
title: "NHibernate and WPF: Test Databinding with Caliburn"
date: 2009-11-15 16:42:25 +1300
comments: true
published: true
categories: ["blog", "archives"]
tags: ["NHibernate", "WPF"]
alias: ["/blogs/nhibernate/archive/2009/11/15/nhibernate-and-wpf-test-databinding-with-caliburn.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>As I said before, for the Chinook Media Manager I’m not using neither <a href="http://www.codeplex.com/caliburn">Caliburn</a> nor <a href="www.codeplex.com/CompositeWPF">Prism</a>.     <br />But, whenever I found a limitation on the current tools, I start looking a solution elsewhere. This is how I meet Caliburn.Testability, a great tool.</p>  <h1>The problem</h1>  <p>We don’t know what would be the ViewModel for the View at design time. This is the reason why we don’t have intelliscence in XAML, and in general our databinding are not strongly typed in XAML. So, we can write “naem” instead of “Name”.</p>  <h1>The solution</h1>  <p>Caliburn has a great tool named “Caliburn Testability”, you can read the full <a href="http://devlicio.us/blogs/rob_eisenberg/archive/2009/10/30/nhprof-and-caliburn-testability.aspx">post here</a>. As <a href="http://devlicio.us/blogs/rob_eisenberg/">Rob Eisenberg</a> said, I take this one step farther to build an automatic test.</p>  <p>This is the code:</p>  <pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">DataBindingValidator
</span>{
    <span style="color: blue">private static </span><span style="color: #2b91af">BindingValidator </span>ValidatorFor(
            <span style="color: #2b91af">Type </span>guiElement, <span style="color: #2b91af">Type </span>presenterType)
    {
        <span style="color: blue">var </span>boundType = <span style="color: blue">new </span><span style="color: #2b91af">BoundType</span>(presenterType);
        <span style="color: blue">var </span>instance = (<span style="color: #2b91af">DependencyObject</span>)<span style="color: #2b91af">Activator</span>.CreateInstance(guiElement);
        <span style="color: #2b91af">IElement </span>element = <span style="color: #2b91af">Bound</span>.DependencyObject(instance, boundType);
        <span style="color: blue">return new </span><span style="color: #2b91af">BindingValidator</span>(element);
    }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Validate the bindings of a keyvalue pair 
    </span><span style="color: gray">/// </span><span style="color: green">where the key is the View type and the 
    </span><span style="color: gray">/// </span><span style="color: green">value is the ViewModel type.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: blue">public </span><span style="color: #2b91af">IEnumerable</span>&lt;<span style="color: #2b91af">ValidationResult</span>&gt;
            Validate(<span style="color: #2b91af">IDictionary</span>&lt;<span style="color: #2b91af">Type</span>, <span style="color: #2b91af">Type</span>&gt; viewViewModelDictionary)
    {
        <span style="color: blue">foreach </span>(<span style="color: blue">var </span>viewViewModel <span style="color: blue">in </span>viewViewModelDictionary)
        {
            <span style="color: #2b91af">BindingValidator </span>validator
                = ValidatorFor(viewViewModel.Key, viewViewModel.Value);
            <span style="color: #2b91af">ValidationResult </span>validatorResult = validator.Validate();
            <span style="color: blue">yield return </span>validatorResult;
        }
    }
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>This class validate a IDictionary&lt;Type, Type&gt;, the key is the “View” type, and the value is the ViewModel type. The View need to have a public constructor without args, this test will create an instance of the View. The ViewModel type could be a class, could be abstract and even an interface!</p>

<p>The test is really easy, if you are using Caliburn, you already have a IViewStrategy. The Chinook Media Manager use a convention based approach and I don’t have an special artifact for this purpose. So my test looks as follows:</p>

<p>&#160;</p>

<pre class="code">[<span style="color: #2b91af">TestFixture</span>]
<span style="color: blue">public class </span><span style="color: #2b91af">TestDataBindings
</span>{
    <span style="color: blue">private static </span><span style="color: #2b91af">Type </span>GetViewForViewModel(<span style="color: #2b91af">Type </span>viewModelType)
    {
        <span style="color: blue">string </span>viewName = viewModelType.Name.Replace(<span style="color: #a31515">&quot;ViewModel&quot;</span>, <span style="color: #a31515">&quot;View&quot;</span>);
        <span style="color: blue">string </span>viewFullName = <span style="color: blue">string</span>.Format(<span style="color: #a31515">&quot;ChinookMediaManager.GUI.Views.{0}, ChinookMediaManager.GUI&quot;</span>, viewName);
        <span style="color: #2b91af">Type </span>viewType = <span style="color: #2b91af">Type</span>.GetType(viewFullName, <span style="color: blue">true</span>);
        <span style="color: blue">return </span>viewType;
    }

    [<span style="color: #2b91af">Test</span>]
    <span style="color: blue">public void </span>AllDatabindingsAreOkay()
    {
        <span style="color: blue">bool </span>fail = <span style="color: blue">false</span>;
        <span style="color: blue">var </span>databindingValidator = <span style="color: blue">new </span><span style="color: #2b91af">DataBindingValidator</span>();

        <span style="color: #2b91af">Type </span>examplePresenterType = <span style="color: blue">typeof</span>(<span style="color: #2b91af">AlbumManagerViewModel</span>);

        <span style="color: blue">var </span>dictionary = examplePresenterType.Assembly.GetTypes()
                                            .Where(type =&gt; type.Namespace.EndsWith(<span style="color: #a31515">&quot;ViewModels&quot;</span>))
                                            .ToDictionary(vmType =&gt; GetViewForViewModel(vmType), vmType =&gt; vmType);

        

        <span style="color: blue">foreach </span>(<span style="color: blue">var </span>validationResult <span style="color: blue">in </span>databindingValidator.Validate(dictionary))
        {
            <span style="color: blue">if</span>(validationResult.HasErrors)
            {
                <span style="color: #2b91af">Console</span>.WriteLine(validationResult.ErrorSummary);
                fail = <span style="color: blue">true</span>;
            }
        }

        fail.Should().Be.False();
    }
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>If you have any error in your databinding this test will fail. This test also show you a list of the DataBinding errors in the console, and for each error the full path inside the View:</p>

<p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6D1D2B0A.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="image" border="0" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_40968BD5.png" width="885" height="115" /></a> </p>

<p>You can see here the “nesting level”, Album is a property of the EditAlbumViewModel, Title is a property in the Album type. Titl<u>o</u> doesn’t exist. EditAlbumView.Grid.TextBox is the full xaml path to the control holding the databinding. It show Grid and TextBox because these elements doesn’t have a name in xaml.</p>

<p>This is why I use Caliburn.Testability in Chinook Media Manager. </p>
