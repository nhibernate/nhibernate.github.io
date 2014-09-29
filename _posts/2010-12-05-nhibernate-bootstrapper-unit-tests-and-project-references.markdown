---
layout: post
title: "NHibernate Bootstrapper: Unit Tests and Project References"
date: 2010-12-05 15:59:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "Criteria", "linq"]
alias: ["/blogs/nhibernate/archive/2010/12/05/nhibernate-bootstrapper-unit-tests-and-project-references.aspx"]
author: jwdavidson
gravatar: 7b8c11bc19a524da9aac988120936d9a
---
{% include imported_disclaimer.html %}
<p>This post is the second one about the NHibernate Bootstrapper. <a target="_blank" href="/blogs/nhibernate/archive/2010/07/11/nhibernate-bootstrapper-unitofwork-and-sessionperrequest.aspx">The first is located here</a>. The first post set up the project structure, introduced the generic DAO, and demonstrated the SessionPerRequest implementation in an IHttpModule. This post will factor the reference to NHibernate out of the web application project and cover some unit testing techniques.&nbsp; Programmers that are not familiar with <a target="_blank" href="http://en.wikipedia.org/wiki/Solid_(object-oriented_design)">SOLID</a> should review the Wikipedia page and the references there. The first post noted that the version of NHibernate Bootstrapper presented there was not suitable for use in anything other than a demonstration program. The version of the solution discussed in this post is suitable for use in a small-scale system where there no more than 15 classes involved. The version following this post should be suitable for even the largest deployments, though there will be at least one additional post that refines the capabilities of an enterprise ready solution. The project sources are in a zip file located <a target="_blank" href="https://public.me.com/jw_davidson/NHibernateBootstrap_V2.0.zip">here</a> and are updated to use the NHibernate 3.0.0 GA release.</p>
<h3>PresentationManager</h3>
<p>The solution in the first post used NHibernate references in the web application project. In this version of the solution those references have been moved to the presenter project. Now the solution is taken on the characteristics of the Model-View-Presenter (MVP) , discussed by Martin Fowler <a target="_blank" href="http://www.martinfowler.com/eaaDev/uiArchs.html">here</a>, and later refined into a <a target="_blank" href="http://www.martinfowler.com/eaaDev/SupervisingPresenter.html">Supervising Presenter</a> and <a target="_blank" href="http://www.martinfowler.com/eaaDev/PassiveScreen.html">Passive View</a>. The solution employed here follows the Passive View pattern, where the view has no direct interaction with the model. The solution builds on 2 Code Project articles, originally released in Jul 2006. The first reference used is <a target="_blank" href="http://www.codeproject.com/KB/architecture/ModelViewPresenter.aspx">Model View Presenter with ASP.Net</a> by Bill McCafferty and the second is <a target="_blank" href="http://www.codeproject.com/KB/architecture/Advanced_MVP.aspx">Advancing the Model-View-Presenter Pattern &ndash; Fixing the Common Problems</a> by Acoustic. There are a number of reasons for using the MVP pattern, but the most important of them is the enabling of testing. The second half of this post will show how it becomes possible to test the code behind of an aspx page.</p>
<p>In the first post the BusinessServices project, that would hold the presenters, was empty. Now there is a Presentation Manager and a Presenter classes. The PresentationManager is able to register the view of the ASP.Net page and associate it with the correct presenter. It is also remarkable in that it automatically instantiates the correct presenter for use by the ASP.Net page. This is done in the LoadPresenter method. The auto-instantiation is how ASP.Net pages are able to function with only a reference to the PresenterTypeAttribute in the web application project.</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:b87679f5-54da-4ba8-a1af-675406b4b213" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PresentationManager.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> Infrastructure;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BusinessServices</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">PresentationManager</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> T RegisterView&lt;T&gt;(<span style="color:#2b91af">Type</span> presenterType, <span style="color:#2b91af">IView</span> myView) <span style="color:#0000ff">where</span> T : <span style="color:#2b91af">Presenter</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> RegisterView&lt;T&gt;(presenterType, myView, <span style="color:#0000ff">null</span>);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> T RegisterView&lt;T&gt;(<span style="color:#2b91af">Type</span> presenterType, <span style="color:#2b91af">IView</span> view, <span style="color:#2b91af">IHttpSessionProvider</span> httpSession) <span style="color:#0000ff">where</span> T : <span style="color:#2b91af">Presenter</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> (LoadPresenter(presenterType, view, httpSession)) <span style="color:#0000ff">as</span> T;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> <span style="color:#0000ff">void</span> RegisterView(<span style="color:#2b91af">Type</span> presenterType, <span style="color:#2b91af">IView</span> view)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RegisterView(presenterType, view, <span style="color:#0000ff">null</span>);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">static</span> <span style="color:#0000ff">void</span> RegisterView(<span style="color:#2b91af">Type</span> presenterType, <span style="color:#2b91af">IView</span> view, <span style="color:#2b91af">IHttpSessionProvider</span> httpSession)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LoadPresenter(presenterType, view, httpSession);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">static</span> <span style="color:#2b91af">Object</span> LoadPresenter(<span style="color:#2b91af">Type</span> presenterType, <span style="color:#2b91af">IView</span> view, <span style="color:#2b91af">IHttpSessionProvider</span> httpSession)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">int</span> arraySize = ((httpSession == <span style="color:#0000ff">null</span>) ? 1 : 2);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Object</span>[] constructorParams = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Object</span>[arraySize];</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;constructorParams[0] = view;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (arraySize.Equals(2))</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;constructorParams[1] = httpSession;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> <span style="color:#2b91af">Activator</span>.CreateInstance(presenterType, constructorParams);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>The PresenterTypeAttribute is what each page uses to drive SelfRegister. This is the mechanism that ties the individual web pages to the appropriate presenter in an automated fashion. This is one aspect of a poor man&rsquo;s Inversion of Control without requiring a separate container to hold the various dependencies.</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:2d3ca1d6-8372-409a-8d21-9ddd21115f53" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PresenterTypeAttribute.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Text;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BusinessServices</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//[AttributeUsage(AttributeTargets.All, Inherited = true)]</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">PresenterTypeAttribute</span> : <span style="color:#2b91af">Attribute</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">Type</span> _presenterType;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> PresenterTypeAttribute(<span style="color:#2b91af">Type</span> presenterType)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_presenterType = presenterType;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#2b91af">Type</span> PresenterType</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _presenterType; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _presenterType = <span style="color:#0000ff">value</span>; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<h3>Revised Web Application Project</h3>
<p>The code behind for the web page has been revised to work with a presenter. You will note that a large amount of code that was in the original code behind file has now been commented out, as it has been revised slightly and moved to the the PersonPresenter class. The code behind file is now left with just event declarations, a number of properties and the occasional method for working with gridview or dropdown controls and the Page_Load event. All that remains in the code behind are methods and properties that are referencing System.Web, while the various presenter classes have no reference to System.Web. It is important to note that the removal of the reference to System.Web in the presenter classes is what enables a high degree of code coverage in the Unit Tests.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:c205af0b-8bc8-4b46-9cb6-6de13c501dfc" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Default.aspx.cs (Part 1)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Web.UI;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Web.UI.WebControls;</li>
<li><span style="color:#0000ff">using</span> BusinessServices;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BusinessServices.Interfaces;</li>
<li><span style="color:#0000ff">using</span> BusinessServices.Presenters;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> DataServices.Person;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> WebNHibernate</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">PresenterType</span>(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">PersonPresenter</span>))]</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">partial</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">_Default</span> : <span style="color:#2b91af">BasePage</span>, <span style="color:#2b91af">IPersonView</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">GridViewBtnEvent</span> OnEditCommand;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">GridViewBtnEvent</span> OnDeleteCommand;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnRefreshPersonGrid;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnSaveEditPerson;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnClearEditPerson;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//added event for presenter</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyEvent</span> OnPageLoadNoPostback;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//private ISession m_session = null;</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> Page_Load(<span style="color:#0000ff">object</span> sender, <span style="color:#2b91af">EventArgs</span> e)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//added for the presenter</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">base</span>.SelfRegister(<span style="color:#0000ff">this</span>);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//OnEditCommand += new GridViewBtnEvent(_view_OnEditCommand);</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//OnDeleteCommand += new GridViewBtnEvent(_view_OnDeleteCommand);</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//OnRefreshPersonGrid += new EmptyBtnEvent(_view_OnRefreshPersonGrid);</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//OnSaveEditPerson += new EmptyBtnEvent(_view_OnSaveEditPerson);</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//OnClearEditPerson += new EmptyBtnEvent(_view_OnClearEditPerson);</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//if (m_session == null)</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;m_session = SessionManager.SessionFactory.GetCurrentSession();</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!Page.IsPostBack)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//added line below for presenter</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OnPageLoadNoPostback();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//IList&lt;PersonDto&gt; gvData = Get_PersonData();</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//Fill_gvPerson(gvData);</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:5bc58955-a373-4e5b-af1f-4f1c34babbb0" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Default.aspx.cs (Part 2)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> gvPerson_OnRowCommand(<span style="color:#0000ff">object</span> sender, <span style="color:#2b91af">GridViewCommandEventArgs</span> e)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Guid</span> id = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>(gvPerson.DataKeys[<span style="color:#2b91af">Convert</span>.ToInt32(e.CommandArgument)].Value.ToString());</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (e.CommandName == <span style="color:#a31515">"EditRow"</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OnEditCommand(id);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span> <span style="color:#0000ff">if</span> (e.CommandName == <span style="color:#a31515">"DeleteRow"</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OnDeleteCommand(id);</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//public void _view_OnEditCommand(Guid id)</span></li>
<li><span style="color:#008000">//{</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;if (m_session == null)</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = SessionManager.SessionFactory.GetCurrentSession();</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;PersonDAOImpl dao = new PersonDAOImpl(m_session);</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;Person pers = dao.GetByID(id);</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtPersonIdValue = pers.Id.ToString();</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtFirstNameValue = pers.FirstName;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtLastNameValue = pers.LastName;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtEmailValue = pers.Email;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtUserIdValue = pers.UserID;</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;pers = null;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;dao = null;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//}</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//public void _view_OnDeleteCommand(Guid id)</span></li>
<li><span style="color:#008000">//{</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;if (m_session == null)</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = SessionManager.SessionFactory.GetCurrentSession();</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;PersonDAOImpl dao = new PersonDAOImpl(m_session);</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;using (var tx = m_session.BeginTransaction())</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;{</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dao.Delete(id);</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;}</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;dao = null;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;_view_OnRefreshPersonGrid();</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//}</span></li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:19e1af1a-1ed6-4c21-9e41-210d8c97e036" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Default.aspx.cs (Part 3)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#008000">//public void _view_OnRefreshPersonGrid()</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//{</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;IList&lt;PersonDto&gt; gvData = Get_PersonData();</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;Fill_gvPerson(gvData);</span></li>
<li><span style="color:#008000">//}</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//public void _view_OnSaveEditPerson()</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//{</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;if (m_session == null)</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = SessionManager.SessionFactory.GetCurrentSession();</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;Guid editId = new Guid();</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;Person editPers = new Person();</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;if (!string.IsNullOrEmpty(txtPersonIdValue))</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editId = new Guid(txtPersonIdValue);</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;PersonDAOImpl dao = new PersonDAOImpl(m_session);</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;using (var tx = m_session.BeginTransaction())</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;{</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;if (editId.ToString().Length == 36)</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers = dao.GetByID(editId);</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.FirstName = txtFirstNameValue;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.LastName = txtLastNameValue;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.Email = txtEmailValue;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.UserID = txtUserIdValue;</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers = dao.Save(editPers);</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;}</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;editPers = null;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;dao = null;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;_view_OnRefreshPersonGrid();</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;_view_OnClearEditPerson();</span></li>
<li><span style="color:#008000">//}</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//public void _view_OnClearEditPerson()</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//{</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtPersonIdValue = null;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtFirstNameValue = null;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtLastNameValue = null;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtEmailValue = null;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;txtUserIdValue = null;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//}</span></li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:aff824c0-d04a-426b-8b0d-88a26f850221" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Default.aspx.cs (Part 4)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> btnRefresh_Click(<span style="color:#0000ff">object</span> sender, <span style="color:#2b91af">EventArgs</span> e)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;OnRefreshPersonGrid();</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> btnSave_Click(<span style="color:#0000ff">object</span> sender, <span style="color:#2b91af">EventArgs</span> e)</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;OnSaveEditPerson();</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> btnClear_Click(<span style="color:#0000ff">object</span> sender, <span style="color:#2b91af">EventArgs</span> e)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;OnClearEditPerson();</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> Fill_gvPerson(<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; data)</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;gvPerson.DataSource = data;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;gvPerson.DataBind();</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//public IList&lt;PersonDto&gt; Get_PersonData()</span></li>
<li><span style="color:#008000">//{</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;IList&lt;PersonDto&gt; retVal = null;</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;if (m_session == null)</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = SessionManager.SessionFactory.GetCurrentSession();</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;ICriteria crit = m_session.CreateCriteria(typeof(Person));</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;PersonDAOImpl dao = new PersonDAOImpl(m_session);</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;IList&lt;Person&gt; people = dao.GetByCriteria(crit);</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;retVal = (from person in people</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;select new PersonDto</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PersonID = person.Id,</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FirstName = person.FirstName,</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LastName = person.LastName,</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Email = person.Email,</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UserID = person.UserID</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}).ToList&lt;PersonDto&gt;();</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;crit = null;</span></li>
<li><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;dao = null;</span></li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;people = null;</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#008000">//&nbsp;&nbsp;&nbsp;&nbsp;return retVal;</span></li>
<li><span style="color:#008000">//}</span></li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:65eef155-a0e6-442d-8755-8d6f70a2ac2e" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">Default.aspx.cs (Part 5)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtPersonIdValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> txtPersonID.Text; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { txtPersonID.Text = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtFirstNameValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> txtFirstName.Text; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { txtFirstName.Text = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtLastNameValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> txtLastName.Text; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { txtLastName.Text = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtEmailValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> txtEmail.Text; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { txtEmail.Text = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtUserIdValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> txtUserID.Text; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { txtUserID.Text = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<h3>BasePage</h3>
<p>The web project has had a BasePage class added to reuse element and methods common to more than just a single web page. This includes the SelfRegister method and various properties for RequestString, RequestUrl and IsPostBack. These are sample functions which have common utility throughout all the web pages. It is here that additional utility methods and functions with similar commonality would be added.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:25ecec0b-901b-48ad-a3ae-1d4a417748ce" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">BasePage.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Specialized;</li>
<li><span style="color:#0000ff">using</span> BusinessServices;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">namespace</span> WebNHibernate</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">BasePage</span> : System.Web.UI.<span style="color:#2b91af">Page</span>, <span style="color:#2b91af">IView</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _requestUrl;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> T RegisterView&lt;T&gt;() <span style="color:#0000ff">where</span> T : <span style="color:#2b91af">Presenter</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> <span style="color:#2b91af">PresentationManager</span>.RegisterView&lt;T&gt;(<span style="color:#0000ff">typeof</span>(T), <span style="color:#0000ff">this</span>, <span style="color:#0000ff">new</span> <span style="color:#2b91af">HttpSessionProvider</span>());</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> SelfRegister(System.Web.UI.<span style="color:#2b91af">Page</span> page)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (page != <span style="color:#0000ff">null</span> &amp;&amp; page <span style="color:#0000ff">is</span> <span style="color:#2b91af">IView</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">object</span>[] attributes = page.GetType().GetCustomAttributes(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">PresenterTypeAttribute</span>), <span style="color:#0000ff">true</span>);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (attributes != <span style="color:#0000ff">null</span> &amp;&amp; attributes.Length &gt; 0)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">foreach</span> (<span style="color:#2b91af">Attribute</span> viewAttribute <span style="color:#0000ff">in</span> attributes)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (viewAttribute <span style="color:#0000ff">is</span> <span style="color:#2b91af">PresenterTypeAttribute</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PresentationManager</span>.RegisterView((viewAttribute <span style="color:#0000ff">as</span> <span style="color:#2b91af">PresenterTypeAttribute</span>).PresenterType,</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page <span style="color:#0000ff">as</span> <span style="color:#2b91af">IView</span>, <span style="color:#0000ff">new</span> <span style="color:#2b91af">HttpSessionProvider</span>());</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">break</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#2b91af">NameValueCollection</span> RequestString</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> Request.QueryString; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> RequestUrl</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> Request.RawUrl;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _requestUrl = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">bool</span> IsPostback</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> <span style="color:#0000ff">this</span>.IsPostBack; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<h3>PersonPresenter</h3>
<p>The PersonPresenter class now inherits the code that was commented out in the code behind file. It must also setup event listeners for events that will be raised from the web page. It is these event listeners that improve the testability of the solution, as now this functionality can be unit tested separate from any System.Web dependency. At this point the various presenters have a reference to NHibernate and work directly with the data access layer. The next iteration of the bootstrapper will refactor the presenter and place a data services layer between the presenter and the data access layer. The presenter will then no longer reference NHibernate.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:7d07adf1-9f15-4b40-a73b-7aa5c52d2f72" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenter.cs (Part 1)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate;</li>
<li><span style="color:#0000ff">using</span> NHibernateDAO;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernateDAO.DAOImplementations;</li>
<li><span style="color:#0000ff">using</span> DataServices.Person;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> DomainModel.Person;</li>
<li><span style="color:#0000ff">using</span> Infrastructure;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BusinessServices.Interfaces;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BusinessServices.Presenters</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">PersonPresenter</span> : <span style="color:#2b91af">Presenter</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">ISession</span> m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> PersonPresenter(<span style="color:#2b91af">IPersonView</span> view)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <span style="color:#0000ff">this</span>(view, <span style="color:#0000ff">null</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{ }</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> PersonPresenter(<span style="color:#2b91af">IPersonView</span> view, <span style="color:#2b91af">IHttpSessionProvider</span> httpSession)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: <span style="color:#0000ff">base</span>(view, httpSession)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.OnEditCommand += <span style="color:#0000ff">new</span> <span style="color:#2b91af">GridViewBtnEvent</span>(_view_OnEditCommand);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.OnDeleteCommand += <span style="color:#0000ff">new</span> <span style="color:#2b91af">GridViewBtnEvent</span>(_view_OnDeleteCommand);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.OnRefreshPersonGrid += <span style="color:#0000ff">new</span> <span style="color:#2b91af">EmptyBtnEvent</span>(_view_OnRefreshPersonGrid);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.OnSaveEditPerson += <span style="color:#0000ff">new</span> <span style="color:#2b91af">EmptyBtnEvent</span>(_view_OnSaveEditPerson);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.OnClearEditPerson += <span style="color:#0000ff">new</span> <span style="color:#2b91af">EmptyBtnEvent</span>(_view_OnClearEditPerson);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.OnPageLoadNoPostback += <span style="color:#0000ff">new</span> <span style="color:#2b91af">EmptyEvent</span>(_personView_OnPageLoadNoPostback);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _personView_OnPageLoadNoPostback()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; gvData = Get_PersonData();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_personView.Fill_gvPerson(gvData);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:d09457d4-b769-4853-b707-f67bb576077a" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenter.cs (Part 2)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _view_OnEditCommand(<span style="color:#2b91af">Guid</span> id)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> dao = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;DomainModel.Person.<span style="color:#2b91af">Person</span> pers = dao.GetByID(id);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtPersonIdValue = pers.Id.ToString();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtFirstNameValue = pers.FirstName;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtLastNameValue = pers.LastName;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtEmailValue = pers.Email;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtUserIdValue = pers.UserID;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;pers = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;dao = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _view_OnDeleteCommand(<span style="color:#2b91af">Guid</span> id)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> dao = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dao.Delete(id);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;dao = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_view_OnRefreshPersonGrid();</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _view_OnRefreshPersonGrid()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; gvData = Get_PersonData();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_personView.Fill_gvPerson(gvData);</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:b7e2d6d0-49f9-4728-b8ab-c3b484eb9d0d" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenter.cs (Part 3)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _view_OnSaveEditPerson()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Guid</span> editId = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> editPers = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Person</span>();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!<span style="color:#0000ff">string</span>.IsNullOrEmpty(_personView.txtPersonIdValue))</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editId = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>(_personView.txtPersonIdValue);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> dao = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> ((editId != <span style="color:#0000ff">null</span>) &amp;&amp; (!editId.Equals(System.<span style="color:#2b91af">Guid</span>.Empty))) <span style="color:#008000">//was a bug here</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers = dao.GetByID(editId);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.FirstName = _personView.txtFirstNameValue;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.LastName = _personView.txtLastNameValue;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.Email = _personView.txtEmailValue;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers.UserID = _personView.txtUserIdValue;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;editPers = dao.Save(editPers);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;editPers = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;dao = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_view_OnRefreshPersonGrid();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_view_OnClearEditPerson();</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> _view_OnClearEditPerson()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtPersonIdValue = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtFirstNameValue = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtLastNameValue = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtEmailValue = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_personView.txtUserIdValue = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:a89a7aac-d47a-47b3-a512-6a7c17b9d67e" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenter.cs (Part 4)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; Get_PersonData()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _personView = <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; retVal = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> dao = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = dao.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retVal = (<span style="color:#0000ff">from</span> person <span style="color:#0000ff">in</span> people</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">select</span> <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDto</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;PersonID = person.Id,</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;FirstName = person.FirstName,</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;LastName = person.LastName,</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Email = person.Email,</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;UserID = person.UserID</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}).ToList&lt;<span style="color:#2b91af">PersonDto</span>&gt;();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;crit = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;dao = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retVal;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#2b91af">IPersonView</span> personView</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> <span style="color:#0000ff">base</span>.GetView&lt;<span style="color:#2b91af">IPersonView</span>&gt;(); }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>The interface for the PersonView web page has also had to be revised. Here the methods that are commented out have had the implementations moved from the web page to the presenter. One new event has been added for the presenter.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:de494a79-160f-4b71-a667-e9f2c4176186" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">IPersonView.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> DataServices.Person;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BusinessServices.Interfaces</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">interface</span> <span style="color:#2b91af">IPersonView</span> : <span style="color:#2b91af">IView</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">event</span> <span style="color:#2b91af">GridViewBtnEvent</span> OnEditCommand;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">event</span> <span style="color:#2b91af">GridViewBtnEvent</span> OnDeleteCommand;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnRefreshPersonGrid;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnSaveEditPerson;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnClearEditPerson;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//the event below had to be added for the presenter</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyEvent</span> OnPageLoadNoPostback;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//void _view_OnEditCommand(Guid id);</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//void _view_OnDeleteCommand(Guid id);</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//void _view_OnRefreshPersonGrid();</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//void _view_OnSaveEditPerson();</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//void _view_OnClearEditPerson();</span></li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">string</span> txtPersonIdValue { <span style="color:#0000ff">get</span>; <span style="color:#0000ff">set</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">string</span> txtFirstNameValue { <span style="color:#0000ff">get</span>; <span style="color:#0000ff">set</span>; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">string</span> txtLastNameValue { <span style="color:#0000ff">get</span>; <span style="color:#0000ff">set</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">string</span> txtEmailValue { <span style="color:#0000ff">get</span>; <span style="color:#0000ff">set</span>; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">string</span> txtUserIdValue { <span style="color:#0000ff">get</span>; <span style="color:#0000ff">set</span>; }</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">void</span> Fill_gvPerson(<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; data);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#008000">//IList&lt;PersonDto&gt; Get_PersonData();</span></li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<h3>Data Access Objects Improvements</h3>
<p>The data access objects have been expanded to include support for NHibernate LINQ, which is now part of the core. Also support for selection of an unique object has been included, rather than always returning an IList. This means that there has been an update to the IRead.cs file as shown below.</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:9c544314-49ea-4fe2-b3e5-934df1ab97b8" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">IRead.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Text;</li>
<li><span style="color:#0000ff">using</span> DomainModel;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> NHibernateDAO</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">interface</span> <span style="color:#2b91af">IRead</span>&lt;TEntity&gt; <span style="color:#0000ff">where</span> TEntity : <span style="color:#2b91af">Entity</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity GetByID(<span style="color:#2b91af">Guid</span> ID);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;TEntity&gt; GetByCriteria(<span style="color:#2b91af">ICriteria</span> criteria);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity GetUniqByCriteria(<span style="color:#2b91af">ICriteria</span> criteria);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;TEntity&gt; GetByQueryable(<span style="color:#2b91af">IQueryable</span>&lt;TEntity&gt; queryable);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity GetUniqByQueryable(<span style="color:#2b91af">IQueryable</span>&lt;TEntity&gt; queryable);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>The implementation file for the data access objects has been revised to include the implementation details for LINQ and unique object support.</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:97028b4c-6ac8-4409-9227-743eec62889a" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">GenericDAOImpl.cs (Pt 1)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
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
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> TEntity GetByID(<span style="color:#2b91af">Guid</span> ID)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity retval;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval = m_Session.Get&lt;TEntity&gt;(ID);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retval;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> m_Session.Get&lt;TEntity&gt;(ID);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:598c70fc-4dff-47b9-9869-f64de78fa126" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">GenericDAOImpl.cs (Pt 2)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
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
<li><span style="color:#0000ff">public</span> TEntity GetUniqByCriteria(<span style="color:#2b91af">ICriteria</span> criteria)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity retval;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval = criteria.UniqueResult&lt;TEntity&gt;();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retval;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> criteria.UniqueResult&lt;TEntity&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:e6915aec-5fa6-4fd8-84b2-8fa5bfd68e6e" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">GenericDAOImpl.cs (Pt 3)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
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
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> TEntity GetUniqByQueryable(<span style="color:#2b91af">IQueryable</span>&lt;TEntity&gt; queryable)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;TEntity retval;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;retval = queryable.Single&lt;TEntity&gt;();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> retval;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> queryable.Single&lt;TEntity&gt;();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:467b4de6-bc73-4700-8625-506fdb7af897" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">GenericDAOImpl.cs (Pt 4)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> TEntity Save(TEntity entity)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!m_Session.Transaction.IsActive)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_Session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_Session.SaveOrUpdate(entity);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_Session.SaveOrUpdate(entity);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> entity;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<h3>&nbsp;</h3>
<h3>Unit Test</h3>
<p>The unit testing capabilities of the solution have been expanded. It starts with a fake PersonView class in the unit test project that includes functionality similar to that in the web page, but implemented without any reference to System.Web</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:b1024b57-18cd-4ccc-967d-bb776b3e544e" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonView.cs (Part 1)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> BusinessServices;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BusinessServices.Interfaces;</li>
<li><span style="color:#0000ff">using</span> BusinessServices.Presenters;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> DataServices.Person;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BootstrapperUnitTests.Views</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">PresenterType</span>(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">PersonPresenter</span>))]</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">PersonView</span> : <span style="color:#2b91af">BaseView</span>, <span style="color:#2b91af">IPersonView</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">bool</span> blnRegistered = <span style="color:#0000ff">false</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _txtPersonID;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _txtFirstName;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _txtLastName;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _txtEmail;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _txtUserID;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">static</span> <span style="color:#0000ff">bool</span> postBack;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; _gvPerson;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">GridViewBtnEvent</span> OnEditCommand;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">GridViewBtnEvent</span> OnDeleteCommand;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnRefreshPersonGrid;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnSaveEditPerson;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyBtnEvent</span> OnClearEditPerson;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">event</span> <span style="color:#2b91af">EmptyEvent</span> OnPageLoadNoPostback;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> PersonView()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;postBack = <span style="color:#0000ff">false</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">base</span>.SelfRegister(<span style="color:#0000ff">this</span>);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;blnRegistered = <span style="color:#0000ff">true</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">///</span><span style="color:#008000"> </span><span style="color:#808080">&lt;summary&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">///</span><span style="color:#008000"> This is used by the test subsystem to avoid the self-registry action and allow normal</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">///</span><span style="color:#008000"> object creation.</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">///</span><span style="color:#008000"> </span><span style="color:#808080">&lt;/summary&gt;</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#808080">///</span><span style="color:#008000"> </span><span style="color:#808080">&lt;param name="noRegister"&gt;&lt;/param&gt;</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> PersonView(<span style="color:#0000ff">bool</span> noRegister)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;blnRegistered = <span style="color:#0000ff">false</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;postBack = <span style="color:#0000ff">false</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:1ff49c92-7a51-4a4e-ae08-5d8130df4674" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonView.cs (Part 2)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> Fill_gvPerson(<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; data)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_gvPerson = data;</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">protected</span> <span style="color:#0000ff">internal</span> <span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; GvPerson</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _gvPerson; }</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnEditCommand(<span style="color:#2b91af">Guid</span> id)</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;OnEditCommand(id);</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnDeleteCommand(<span style="color:#2b91af">Guid</span> id)</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;OnDeleteCommand(id);</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnRefreshPersonGrid()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;OnRefreshPersonGrid();</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnSaveEditPerson()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (_txtUserID != <span style="color:#0000ff">null</span>)</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;OnSaveEditPerson();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnClearEditPerson()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;OnClearEditPerson();</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnPageLoadNoPostback()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;OnPageLoadNoPostback();</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:b21e10e1-f01e-448d-9a7b-1b70cadf62f0" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonView.cs (Part 3)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtPersonIdValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _txtPersonID; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _txtPersonID = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtFirstNameValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _txtFirstName; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _txtFirstName = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtLastNameValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _txtLastName; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _txtLastName = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtEmailValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _txtEmail; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _txtEmail = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> txtUserIdValue</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _txtUserID; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _txtUserID = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">bool</span> <span style="color:#2b91af">IView</span>.IsPostback</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> </li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (!postBack)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;postBack = <span style="color:#0000ff">true</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> <span style="color:#0000ff">false</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">else</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> <span style="color:#0000ff">true</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>BasePage.cs must also be copied to the unit test project, and it also no longer references System.Web. It is renamed to BaseView.cs in the actual solution. You will note that the property IsPostBack throws a NotImplementedException, but it could be set to a read/write property and provide values through an external property setter in the tests.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:91b0366b-fee6-4930-875b-844407f5e0c1" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">BaseView.cs</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Collections.Specialized;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Linq;</li>
<li><span style="color:#0000ff">using</span> System.Text;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BusinessServices;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BootstrapperUnitTests</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">BaseView</span> : <span style="color:#2b91af">IView</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#0000ff">string</span> _requestUrl;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">NameValueCollection</span> _queryString = <span style="color:#0000ff">new</span> <span style="color:#2b91af">NameValueCollection</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> T RegisterView&lt;T&gt;() <span style="color:#0000ff">where</span> T : <span style="color:#2b91af">Presenter</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">return</span> <span style="color:#2b91af">PresentationManager</span>.RegisterView&lt;T&gt;(<span style="color:#0000ff">typeof</span>(T), <span style="color:#0000ff">this</span>, <span style="color:#0000ff">null</span>);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">protected</span> <span style="color:#0000ff">void</span> SelfRegister(<span style="color:#2b91af">IView</span> page)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (page != <span style="color:#0000ff">null</span> &amp;&amp; page <span style="color:#0000ff">is</span> <span style="color:#2b91af">IView</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">object</span>[] attributes = page.GetType().GetCustomAttributes(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">PresenterTypeAttribute</span>), <span style="color:#0000ff">true</span>);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (attributes != <span style="color:#0000ff">null</span> &amp;&amp; attributes.Length &gt; 0)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">foreach</span> (<span style="color:#2b91af">Attribute</span> viewAttribute <span style="color:#0000ff">in</span> attributes)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">if</span> (viewAttribute <span style="color:#0000ff">is</span> <span style="color:#2b91af">PresenterTypeAttribute</span>)</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PresentationManager</span>.RegisterView((viewAttribute <span style="color:#0000ff">as</span> <span style="color:#2b91af">PresenterTypeAttribute</span>).PresenterType,</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;page <span style="color:#0000ff">as</span> <span style="color:#2b91af">IView</span>, <span style="color:#0000ff">null</span>);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">break</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#2b91af">NameValueCollection</span> RequestString</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _queryString; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">string</span> RequestUrl</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">return</span> _requestUrl; }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">set</span> { _requestUrl = <span style="color:#0000ff">value</span>; }</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">bool</span> IsPostback</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">get</span> { <span style="color:#0000ff">throw</span> <span style="color:#0000ff">new</span> <span style="color:#2b91af">NotImplementedException</span>(); }</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>The tests themselves have been expanded and now show a considerably increased code coverage. In doing so the tests are now a combination of unit tests and integration tests, but I would argue that this is desirable as it increases the overall reliability of the solution, which is the purpose of automated tests.</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:fec18d45-5ad3-4586-8edc-3afc547c1350" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 1)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> NUnit.Framework;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> DomainModel.Person;</li>
<li><span style="color:#0000ff">using</span> NHibernate;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate.Context;</li>
<li><span style="color:#0000ff">using</span> NHibernateDAO;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernateDAO.DAOImplementations;</li>
<li><span style="color:#0000ff">using</span> BootstrapperUnitTests.Views;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BootstrapperUnitTests.TestData;</li>
<li><span style="color:#0000ff">using</span> BusinessServices.Interfaces;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BusinessServices.Presenters;</li>
<li><span style="color:#0000ff">using</span> DataServices.Person;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li><span style="color:#0000ff">namespace</span> BootstrapperUnitTests.PresenterTests</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">TestFixture</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">PersonPresenterTests</span></li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">ISession</span> m_session;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">TestFixtureSetUp</span>]</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> TestFixtureSetup()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">var</span> session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.OpenSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">CallSessionContext</span>.Bind(session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">TestFixtureTearDown</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> TestFixtureTeardown()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">var</span> session = <span style="color:#2b91af">CallSessionContext</span>.Unbind(<span style="color:#2b91af">SessionManager</span>.SessionFactory);</li>
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
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Dispose();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:0253bdc8-1d9d-4f48-a59b-e39dd25fa957" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 2)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> View_OnEditCommandTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(1);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp =<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pp._view_OnEditCommand(people[0].Id);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = _pp.personView;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsTrue(<span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>(_pv.txtPersonIdValue).Equals(people[0].Id));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsTrue(_pv.txtUserIdValue.Equals(people[0].UserID));</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:28cca321-414c-43bb-abce-3d242388b123" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 3)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnEditCommandTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(1);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnEditCommand(people[0].Id);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsTrue(<span style="color:#0000ff">new</span> <span style="color:#2b91af">Guid</span>(_pv.txtPersonIdValue).Equals(people[0].Id));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsTrue(_pv.txtUserIdValue.Equals(people[0].UserID));</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:241a06f7-7a17-4679-9740-589416723f59" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 4)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> View_OnDeleteCommandTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(1);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = _pp.personView;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pp._view_OnDeleteCommand(people[0].Id);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.AreEqual(people.Count, 0);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:50f8a62f-076c-4a1b-ab73-9082d8827018" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 5)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnDeleteCommandTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(1);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnDeleteCommand(people[0].Id);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.AreEqual(people.Count, 0);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:831c154b-958e-4c28-a52c-35ba9983b96b" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 6)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> View_OnClearEditPerson()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = _pp.personView;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtFirstNameValue = <span style="color:#a31515">"testData"</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pp._view_OnClearEditPerson();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsNullOrEmpty(_pv.txtFirstNameValue);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">Test</span>]</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnClearEditPerson()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtFirstNameValue = <span style="color:#a31515">"testData"</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnClearEditPerson();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsNullOrEmpty(_pv.txtFirstNameValue);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> Get_PersonDataTest()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsInstanceOf&lt;<span style="color:#2b91af">PersonPresenter</span>&gt;(_pp);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li> </li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">PersonDto</span>&gt; pers = _pp.Get_PersonData();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(pers.Count, 3);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:f1445c7b-12cc-4dd5-a5e8-34479402d209" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 7)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnPageLoadNoPostbackTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnPageLoadNoPostback();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(_pvc.GvPerson.Count, 3);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:f75afdb0-536c-4213-9488-04084124c8e2" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt 8)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> View_OnRefreshPersonGridTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = _pp.personView;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnRefreshPersonGrid();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(_pvc.GvPerson.Count, 3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:40878cfe-ab22-4ecf-b300-f32f424de88d" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenter.cs (Pt 9)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnRefreshPersonGridTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnRefreshPersonGrid();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(_pvc.GvPerson.Count, 3);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
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
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:b3529696-8f55-4f96-a710-f87d99593483" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt10)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> View_OnSaveEditPersonNewTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = _pp.personView;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtPersonIdValue = <span style="color:#a31515">""</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtFirstNameValue = <span style="color:#a31515">"Mary"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtLastNameValue = <span style="color:#a31515">"Johnston"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtEmailValue = <span style="color:#a31515">"some@email"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtUserIdValue = <span style="color:#a31515">"mj1"</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pp._view_OnSaveEditPerson();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:44ea6842-4800-47d3-a2b3-92d42dcfdc15" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresneterTests.cs (Pt11)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnSaveEditPersonNewTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtPersonIdValue = <span style="color:#a31515">""</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtFirstNameValue = <span style="color:#a31515">"Mary"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtLastNameValue = <span style="color:#a31515">"Johnston"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtEmailValue = <span style="color:#a31515">"some@email"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtUserIdValue = <span style="color:#a31515">"mj1"</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnSaveEditPerson();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:706dee03-b53e-49f4-ad6a-830186640738" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt12)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> View_OnSaveEditPersonExistingTest()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(1);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonPresenter</span> _pp = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonPresenter</span>(<span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>(<span style="color:#0000ff">false</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = _pp.personView;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtPersonIdValue = people[0].Id.ToString();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtFirstNameValue = people[0].FirstName;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtLastNameValue = people[0].LastName;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtEmailValue = people[0].Email;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtUserIdValue = <span style="color:#a31515">"differentUser"</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pp._view_OnSaveEditPerson();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_pp = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:494b9cab-e8a9-4d30-af6c-3f5ef52e1405" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonPresenterTests.cs (Pt13)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> FireEvent_OnSaveEditPersonExistingTest()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(1);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IPersonView</span> _pv = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonView</span>();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtPersonIdValue = people[0].Id.ToString();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtFirstNameValue = people[0].FirstName;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtLastNameValue = people[0].LastName;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtEmailValue = people[0].Email;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv.txtUserIdValue = <span style="color:#a31515">"differentUser"</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonView</span> _pvc = _pv <span style="color:#0000ff">as</span> <span style="color:#2b91af">PersonView</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pvc.FireEvent_OnSaveEditPerson();</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pv = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_pvc = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<p>Unit tests have also been included for an unique object and also for the added NHibernate LINQ capabilities</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:27285490-e990-46ad-bd9d-b3d61e09595b" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTest.cs (Pt 1)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
<li><span style="color:#0000ff">using</span> System;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Collections.Generic;</li>
<li><span style="color:#0000ff">using</span> System.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> System.Text;</li>
<li><span style="color:#0000ff">using</span> DomainModel.Person;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernateDAO;</li>
<li><span style="color:#0000ff">using</span> NHibernateDAO.DAOImplementations;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NUnit.Framework;</li>
<li><span style="color:#0000ff">using</span> NHibernate;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> NHibernate.Context;</li>
<li><span style="color:#0000ff">using</span> NHibernate.Linq;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">using</span> BootstrapperUnitTests.TestData;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">namespace</span> BootstrapperUnitTests</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">TestFixture</span>]</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">class</span> <span style="color:#2b91af">PersonDAOImplTests</span></li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">private</span> <span style="color:#2b91af">ISession</span> m_session;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">TestFixtureSetUp</span>]</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> TestFixtureSetup()</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">var</span> session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.OpenSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">CallSessionContext</span>.Bind(session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">TestFixtureTearDown</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> TestFixtureTeardown()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">var</span> session = <span style="color:#2b91af">CallSessionContext</span>.Unbind(<span style="color:#2b91af">SessionManager</span>.SessionFactory);</li>
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
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;session.Dispose();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
</ol> </div>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:1202f449-2eea-4999-8825-ccd865ae3ccf" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTests.cs (Pt 2)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
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
<li>&nbsp;</li>
<li style="background: #f3f3f3">[<span style="color:#2b91af">Test</span>]</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonCriteriaQueryTestWithTx()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 3);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:922c45bf-24f2-40f3-a0f7-5825f740197a" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTest.cs (Pt 3)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonDeleteTestWithTx()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session.FlushMode = <span style="color:#2b91af">FlushMode</span>.Commit;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> _person = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Person</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person.FirstName = <span style="color:#a31515">"John"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person.LastName = <span style="color:#a31515">"Davidson"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;_person.Email = <span style="color:#a31515">"jwdavidson@gmail.com"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person.UserID = <span style="color:#a31515">"jwd"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> newPerson;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;newPerson = daoPerson.Save(_person);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.AreEqual(_person, newPerson);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Console</span>.WriteLine(<span style="color:#a31515">"Person ID: {0}"</span>, newPerson.Id);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Int32</span> pers = 0;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.Greater(people.Count, 0);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;pers = people.Count;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Console</span>.WriteLine(<span style="color:#a31515">"Count After Add: {0}"</span>, pers);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daoPerson.Delete(newPerson);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;newPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#0000ff">var</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Console</span>.WriteLine(<span style="color:#a31515">"Count after Delete: {0}"</span>, people.Count);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsTrue(pers.Equals(people.Count + 1));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;_person = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:6734dc8a-c2b4-49eb-b3f3-40e4a00ae313" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTests.cs (Pt 4)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
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
<li>&nbsp;</li>
<li style="background: #f3f3f3">[<span style="color:#2b91af">Test</span>]</li>
<li><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonCriteriaQueryTestWithoutTx()</li>
<li style="background: #f3f3f3">{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 3);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:5db9c3d2-c4a1-475d-9313-c057989304e6" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTest.cs (Pt 5)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonLinqQueryTestWithTx()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IQueryable</span>&lt;<span style="color:#2b91af">Person</span>&gt; qry = <span style="color:#0000ff">from</span> p <span style="color:#0000ff">in</span> m_session.Query&lt;<span style="color:#2b91af">Person</span>&gt;() <span style="color:#0000ff">select</span> p;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#2b91af">ITransaction</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByQueryable(qry);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 3);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonLinqQueryWhereTestWithTx()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">string</span> userid = <span style="color:#a31515">"jwd2"</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IQueryable</span>&lt;<span style="color:#2b91af">Person</span>&gt; qry = <span style="color:#0000ff">from</span> p <span style="color:#0000ff">in</span> m_session.Query&lt;<span style="color:#2b91af">Person</span>&gt;() <span style="color:#0000ff">where</span> p.UserID == userid <span style="color:#0000ff">select</span> p;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">using</span> (<span style="color:#2b91af">ITransaction</span> tx = m_session.BeginTransaction())</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByQueryable(qry);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;tx.Commit();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 1);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:24cfefcd-ef60-4667-a9c8-3aead4b11d22" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTests.cs (Pt 6)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px; white-space: nowrap">
<li>[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3"><span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonLinqQueryTestWithoutTx()</li>
<li>{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonTestData</span> ptd = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonTestData</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.CreatePersonEntries(3);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IQueryable</span>&lt;<span style="color:#2b91af">Person</span>&gt; qry = <span style="color:#0000ff">from</span> p <span style="color:#0000ff">in</span> m_session.Query&lt;<span style="color:#2b91af">Person</span>&gt;() <span style="color:#0000ff">select</span> p;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByQueryable(qry);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.GreaterOrEqual(people.Count, 3);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;ptd.RemoveAllPersonEntries();</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;ptd = <span style="color:#0000ff">null</span>;</li>
<li>}</li>
</ol> </div>
</div>
</div>
<div class="wlWriterEditableSmartContent" id="scid:9ce6104f-a9aa-4a17-a79f-3a39532ebf7c:e6ff1a59-3655-4582-8ff2-b99fc8b758a9" style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px">
<div style="border: #000080 1px solid; color: #000; font-family: 'Courier New', Courier, Monospace; font-size: 10pt">
<div style="background: #000080; color: #fff; font-family: Verdana, Tahoma, Arial, sans-serif; font-weight: bold; padding: 2px 5px">PersonDAOImplTests.cs (Pt 7)</div>
<div style="background: #ddd; overflow: auto"> <ol style="background: #ffffff; margin: 0 0 0 2.5em; padding: 0 0 0 5px;">
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[<span style="color:#2b91af">Test</span>]</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#0000ff">public</span> <span style="color:#0000ff">void</span> PersonDeleteTestWithoutTx()</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#2b91af">SessionManager</span>.SessionFactory.GetCurrentSession();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session.FlushMode = <span style="color:#2b91af">FlushMode</span>.Commit;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> _person = <span style="color:#0000ff">new</span> <span style="color:#2b91af">Person</span>();</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_person.FirstName = <span style="color:#a31515">"John"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_person.LastName = <span style="color:#a31515">"Davidson"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_person.Email = <span style="color:#a31515">"jwdavidson@gmail.com"</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_person.UserID = <span style="color:#a31515">"jwd"</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">PersonDAOImpl</span> daoPerson = <span style="color:#0000ff">new</span> <span style="color:#2b91af">PersonDAOImpl</span>(m_session);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Person</span> newPerson = daoPerson.Save(_person);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.AreEqual(_person, newPerson);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Console</span>.WriteLine(<span style="color:#a31515">"Person ID: {0}"</span>, newPerson.Id);</li>
<li style="background: #f3f3f3">&nbsp;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">ICriteria</span> crit = m_session.CreateCriteria(<span style="color:#0000ff">typeof</span>(<span style="color:#2b91af">Person</span>));</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">IList</span>&lt;<span style="color:#2b91af">Person</span>&gt; people = daoPerson.GetByCriteria(crit);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.Greater(people.Count, 0);</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Int32</span> pers = people.Count;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Console</span>.WriteLine(<span style="color:#a31515">"Count After Add: {0}"</span>, pers);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daoPerson.Delete(newPerson);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;newPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = daoPerson.GetByCriteria(crit);</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Console</span>.WriteLine(<span style="color:#a31515">"Count after Delete: {0}"</span>, people.Count);</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#2b91af">Assert</span>.IsTrue(pers.Equals(people.Count + 1));</li>
<li>&nbsp;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;people = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_person = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;daoPerson = <span style="color:#0000ff">null</span>;</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;m_session = <span style="color:#0000ff">null</span>;</li>
<li style="background: #f3f3f3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li>&nbsp;&nbsp;&nbsp;&nbsp;}</li>
<li style="background: #f3f3f3">}</li>
</ol> </div>
</div>
</div>
<h3>Summary </h3>
<h3></h3>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>This solution retains all the functionality as was included in the original solution, but it has now been placed in an architecture that improves testability and simplifies the creation of functionality as each element now has a clear project where it belongs within the solution. The next evolution of the bootstrapper will investigate data service usage and more complex mappings. However this version of the bootstrapper is now appropriate to use for simple projects with NHibernate where the domain model is relatively simple.</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>If you remember back to the code behind file discussion there were still methods that remained for working with the gridview and drop down controls on the web page. These could be moved up to the presenter if these controls were redesigned as composite controls in a separate project in the solution so that they were no longer inherited through System.Web.</p>
