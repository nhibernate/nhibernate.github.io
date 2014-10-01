---
layout: post
title: "NHibernate IPreUpdateEventListener &amp; IPreInsertEventListener"
date: 2009-04-29 15:04:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["event listener"]
redirect_from: ["/blogs/nhibernate/archive/2009/04/29/nhibernate-ipreupdateeventlistener-amp-ipreinserteventlistener.aspx/"]
author: Ayende
gravatar: 730a9f9186e14b8da5a4e453aca2adfe
---
{% include imported_disclaimer.html %}
<p>NHibernate’s listeners architecture bring with it a lot of power to the game, but understanding how to use it some of the listeners properly may require some additional knowledge. In this post, I want to talk specifically about the pre update hooks that NHibernate provides.</p>  <p>Those allow us to execute our custom logic before the update / insert is sent to the database. On the face of it, it seems like a trivial task, but there are some subtleties that we need to consider when we use them.</p>  <p>Those hooks run awfully late in the processing pipeline, that is part of what make them so useful, but because they run so late, when we use them, we have to be aware to what we are doing with them and how it impacts the rest of the application.</p>  <p>Those two interface define only one method each:</p>  <p>bool OnPreUpdate(PreUpdateEvent @event) and bool OnPreInsert(PreInsertEvent @event), respectively.</p>  <p>Each of those accept an event parameter, which looks like this:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_2BCDB47B.png"><img title="image" style="border-top-width: 0px; display: inline; border-left-width: 0px; border-bottom-width: 0px; border-right-width: 0px" height="217" alt="image" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_30D5138C.png" width="331" border="0" /></a> </p>  <p>Notice that we have <em>two</em> representations of the entity in the event parameter. One is the entity instance, located in the Entity property, but the second is the dehydrated entity <em>state</em>, which is located in the State property.</p>  <p>In NHibernate, when we talk about the state of an entity we usually mean the values that we loaded or saved from the database, not the entity instance itself. Indeed, the State property is an array that contains the parameters that we will push into the ADO.Net Command that will be executed as soon as the event listener finish running. </p>  <p>Updating the state array is a little bit annoying, since we have to go through the persister to find appropriate index in the state array, but that is easy enough.</p>  <p>Here comes the subtlety, however. We <em>cannot</em> just update the entity state. The reason for that is quite simple, the entity state was extracted from the entity and place in the entity state, any change that we make to the entity state would <em>not </em>be reflected in the entity itself. That may cause the database row and the entity instance to go out of sync, and make cause a whole bunch of <em>really</em> nasty problems that you wouldn’t know where to begin debugging.</p>  <p>You have to update both the entity and the entity state in these two event listeners (this is not necessarily the case in other listeners, by the way). Here is a simple example of using these event listeners:</p>  <blockquote>   <pre><span style="color: #0000ff">public</span> <span style="color: #0000ff">class</span> AuditEventListener : IPreUpdateEventListener, IPreInsertEventListener
{
	<span style="color: #0000ff">public</span> <span style="color: #0000ff">bool</span> OnPreUpdate(PreUpdateEvent @<span style="color: #0000ff">event</span>)
	{
		var audit = @<span style="color: #0000ff">event</span>.Entity <span style="color: #0000ff">as</span> IHaveAuditInformation;
		<span style="color: #0000ff">if</span> (audit == <span style="color: #0000ff">null</span>)
			<span style="color: #0000ff">return</span> <span style="color: #0000ff">false</span>;

		var time = DateTime.Now;
		var name = WindowsIdentity.GetCurrent().Name;

		Set(@<span style="color: #0000ff">event</span>.Persister, @<span style="color: #0000ff">event</span>.State, &quot;<span style="color: #8b0000">UpdatedAt</span>&quot;, time);
		Set(@<span style="color: #0000ff">event</span>.Persister, @<span style="color: #0000ff">event</span>.State, &quot;<span style="color: #8b0000">UpdatedBy</span>&quot;, name);

		audit.UpdatedAt = time;
		audit.UpdatedBy = name;

		<span style="color: #0000ff">return</span> <span style="color: #0000ff">false</span>;
	}

	<span style="color: #0000ff">public</span> <span style="color: #0000ff">bool</span> OnPreInsert(PreInsertEvent @<span style="color: #0000ff">event</span>)
	{
		var audit = @<span style="color: #0000ff">event</span>.Entity <span style="color: #0000ff">as</span> IHaveAuditInformation;
		<span style="color: #0000ff">if</span> (audit == <span style="color: #0000ff">null</span>)
			<span style="color: #0000ff">return</span> <span style="color: #0000ff">false</span>;


		var time = DateTime.Now;
		var name = WindowsIdentity.GetCurrent().Name;

		Set(@<span style="color: #0000ff">event</span>.Persister, @<span style="color: #0000ff">event</span>.State, &quot;<span style="color: #8b0000">CreatedAt</span>&quot;, time);
		Set(@<span style="color: #0000ff">event</span>.Persister, @<span style="color: #0000ff">event</span>.State, &quot;<span style="color: #8b0000">UpdatedAt</span>&quot;, time);
		Set(@<span style="color: #0000ff">event</span>.Persister, @<span style="color: #0000ff">event</span>.State, &quot;<span style="color: #8b0000">CreatedBy</span>&quot;, name);
		Set(@<span style="color: #0000ff">event</span>.Persister, @<span style="color: #0000ff">event</span>.State, &quot;<span style="color: #8b0000">UpdatedBy</span>&quot;, name);

		audit.CreatedAt = time;
		audit.CreatedBy = name;
		audit.UpdatedAt = time;
		audit.UpdatedBy = name;

		<span style="color: #0000ff">return</span> <span style="color: #0000ff">false</span>;
	}

	<span style="color: #0000ff">private</span> <span style="color: #0000ff">void</span> Set(IEntityPersister persister, <span style="color: #0000ff">object</span>[] state, <span style="color: #0000ff">string</span> propertyName, <span style="color: #0000ff">object</span> <span style="color: #0000ff">value</span>)
	{
		var index = Array.IndexOf(persister.PropertyNames, propertyName);
		<span style="color: #0000ff">if</span> (index == -1)
			<span style="color: #0000ff">return</span>;
		state[index] = <span style="color: #0000ff">value</span>;
	}
}</pre>
</blockquote>

<p>And the result is <em>pretty</em> neat, I must say.</p>
