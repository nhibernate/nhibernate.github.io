---
layout: post
title: "uNHAddins conversation additions"
date: 2009-02-22 05:18:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/02/22/unhaddins-conversation-additions.aspx"]
author: Gustavo
gravatar: 934c5a2299da30163f720bcd2ee826f4
---
{% include imported_disclaimer.html %}
<p>Well <a href="http://www.fabiomaulo.blogspot.com/" target="_blank">Fabio</a> and i discussed some ideas&hellip;as always i only started thinking about how to implement them and he already had a complete solution for the things being discussed.</p>
<p>At least to feel I collaborate I will resume some of the things Fabio had been working on. </p>
<p>I added the new features to my <a href="http://unhaddins.googlecode.com/svn/trunk/Examples/uNHAddins.Examples.SessionManagement/" target="_blank">sample project</a> which was previously described <a href="http://gustavoringel.blogspot.com/2009/02/unhaddins-persistence-conversation-part_08.html" target="_blank">here</a> so i could play a little with tests. I also did it only looking at the code and svn log to feel how descriptive it was by itself.</p>
<p>Well, there are some things very new and some things that where missing an implementation...</p>
<p>First of all the <span style="color: #000000;">MethodsIncludeMode</span> property for the <span style="color: #000000;">PersistenceConversational</span> attribute is working, you can set it to <span style="font-style: italic">Implicit </span>or <span style="font-style: italic">Explicit</span>. <span style="font-style: italic">Implicit </span>will asume every public virtual method is part of a persistence conversation and will use the defaults if you don&rsquo;t mark it as <span style="color: #000000;">PersistenceConversation </span>with your own properties. <span style="font-style: italic">Explicit </span>will consider only methods marked by you as part of the conversation.</p>
<p>Next we had a <span style="color: #000000;">DefaultEndMode </span>which was there but was not plugged in, now you can use it so every conversation will use as the default, if you want to do crazy things like set every method with <span style="color: #000000;">EndMode</span>.End, well, it is easy to do it even if not so right :)</p>
<p>Last but not least we can now set a <span style="color: #000000;">ConversationConfigurationInterceptor </span>either explicitly or injecting it using meantime the CastleAdapter. This means for example I can subscribe to every event of the conversation and explicitly do something if needed without doing a lot of work like i did in <a href="http://gustavoringel.blogspot.com/2009/02/changing-default-conversation-factory.html">this post</a></p>
<p>The way to set an explicit Interceptor is having a class that inherits from <span style="color: #000000;">IConversationCreationInterceptor </span>which will have to implement the Configure method which receives a conversation, there you attach your events to the conversation and it is done. In the [<span style="color: #000000;">PersistenceConversational</span>] attribute you just set <span style="font-style: italic; color: #000000;">ConversationCreationInterceptor </span><span style="font-style: italic">= typeof(MyInterceptor)</span></p>
<p>The DI way is creating a generic interceptor class that inherits from <span style="color: #000000;">IConversationCreationInterceptorConvention</span>&lt;T&gt; where T : class, the implementation is the same and it can be associated to a model implementing a generic class which receives a model and implements the interface. This will work if the property <span style="color: #000000;">UseConversationCreationInterceptorConvention of PersistenceConversational is </span>set to true (which is the default).</p>
<p>Well you can look at the code to see it working.</p>
