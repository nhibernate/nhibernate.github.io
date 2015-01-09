---
layout: post
title: "Nhibernate and WPF: Models concept"
date: 2009-08-16 00:33:46 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["AOP", "Session", "WPF"]
redirect_from: ["/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-models-concept.aspx/", "/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-models-concept.html"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p><a href="http://jfromaniello.blogspot.com/2009/08/introducing-nhiberate-and-wpf.html">Part I: Introducing Nhibernate and WPF</a>     <br /><a href="http://jfromaniello.blogspot.com/2009/08/chinook-media-manager-core.html">Part II: Chinook Media Manager: The Core</a></p>  <h3>Introduction</h3>  <p>For this post I will use the concept of <a href="http://fabiomaulo.blogspot.com/">Fabio Maulo</a> called “Conversation-per-BussinesTransaction”. If you have not read, what are you waiting for?     <br /></p>  <h3>Definition</h3>  <p>This definition is extracted from Fabio’s <a href="http://fabiomaulo.blogspot.com/2008/12/conversation-per-business-transaction.html">post</a> and is very important that you understood it:</p>  <blockquote>   <p>When you read something about NHibernate-session-management is because we want abstract/”aspect” NH-session’s stuff from the code are using it. In general, or I hope so, you are using the session in something like a DAO/Repository and, in a use-case, you are calling more than one DAO/Repository. Open a new session in each DAO/Repository is an anti-pattern called session-per-call (or very closer to it). What we are searching is something to manage the session in an high-layer but without wire that layer with NHibernate. In a WEB environment it is pretty easy because we can manage the session using an implementation of a IHttpModule, or in the HttpApplication, “intercepting” the request (two patterns mentioned here). In a winForm, or WPF, aplication it is not so clear where the abstraction have place. In this post I will use an “artifact” named Model to represent the “abstraction-point” (in my mind the Model is the business-object that are using DAOs/Repository and domain-entities); in an MVC based application, probably, the abstraction have place in the Controller.</p> </blockquote>  <h3>Implementation</h3>  <p>We start defining an interface for our Use-case Model class as follows: </p>  <pre class="code"><span style="color: blue">public interface </span><span style="color: #2b91af">IAlbumManagerModel
    </span>{

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Search all albums from a given artist.
        </span><span style="color: gray">/// &lt;/summary&gt;
        /// &lt;param name=&quot;artist&quot;&gt;&lt;/param&gt;
        /// &lt;returns&gt;&lt;/returns&gt;
        </span>IEnumerable&lt;Album&gt; GetAlbumsByArtist(Artist artist);

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Persist an album.
        </span><span style="color: gray">/// &lt;/summary&gt;
        /// &lt;param name=&quot;album&quot;&gt;&lt;/param&gt;
        </span><span style="color: blue">void </span>SaveAlbum(Album album);

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Revert changes of a given album to his current persisted state.
        </span><span style="color: gray">/// &lt;/summary&gt;
        /// &lt;param name=&quot;album&quot;&gt;&lt;/param&gt;
        </span><span style="color: blue">void </span>CancelAlbum(Album album);

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Flush all changes to the database.
        </span><span style="color: gray">/// &lt;/summary&gt;
        </span><span style="color: blue">void </span>SaveAll();

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Cancel all changes.
        </span><span style="color: gray">/// &lt;/summary&gt;
        </span><span style="color: blue">void </span>CancelAll();
    }</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>As I say in my previous post this interface is defined in the “ChinookMediaManager.Domain”. 
  <br />The concrete implementation is defined in ChinookMediaManager.DomainImpl as follows: 

  <br /></p>

<pre class="code">[PersistenceConversational(MethodsIncludeMode = MethodsIncludeMode.Implicit)]
    <span style="color: blue">public class </span><span style="color: #2b91af">AlbumManagerModel </span>: IAlbumManagerModel
    {

        <span style="color: blue">private readonly </span>IAlbumRepository albumRepository;

        <span style="color: blue">public </span>AlbumManagerModel(IAlbumRepository albumRepository)
        {
            <span style="color: blue">this</span>.albumRepository = albumRepository;
        }

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Search all the albums from a given artist.
        </span><span style="color: gray">/// &lt;/summary&gt;
        /// &lt;param name=&quot;artist&quot;&gt;&lt;/param&gt;
        /// &lt;returns&gt;&lt;/returns&gt;
        </span><span style="color: blue">public </span>IEnumerable&lt;Album&gt; GetAlbumsByArtist(Artist artist)
        {
            <span style="color: blue">return </span>albumRepository.GetByArtist(artist);
        }

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Persist an album.
        </span><span style="color: gray">/// &lt;/summary&gt;
        /// &lt;param name=&quot;album&quot;&gt;&lt;/param&gt;
        </span><span style="color: blue">public void </span>SaveAlbum(Album album)
        {
            albumRepository.MakePersistent(album);
        }

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Revert changes of a given album to his original state.
        </span><span style="color: gray">/// &lt;/summary&gt;
        /// &lt;param name=&quot;album&quot;&gt;&lt;/param&gt;
        </span><span style="color: blue">public void </span>CancelAlbum(Album album)
        {
            albumRepository.Refresh(album);
        }

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Flush all changes to the database.
        </span><span style="color: gray">/// &lt;/summary&gt;
        </span>[PersistenceConversation(ConversationEndMode = EndMode.End)]
        <span style="color: blue">public void </span>SaveAll()
        { }

        <span style="color: gray">/// &lt;summary&gt;
        /// </span><span style="color: green">Cancel all changes.
        </span><span style="color: gray">/// &lt;/summary&gt;
        </span>[PersistenceConversation(ConversationEndMode = EndMode.Abort)]
        <span style="color: blue">public void </span>CancelAll()
        {
        }
    }</pre>
<a href="http://11011.net/software/vspaste"></a>

<pre class="brush: csharp;"><br /><br /></pre>

<p>Well, this is the non-invasive AOP way of doing with CpBT from unhaddins. 
  <br />The PersistenceCovnersational attribute tell us two things: 

  <br />- All methods are involved in the conversation if not explicitly excluded. 

  <br />– All methods ends with “Continue” if not explicitly changed. 

  <br />SaveAll end the conversation with EndMode.End, this means that the UoW will be flushed. 

  <br />For the other hand CancelAll end with Abort, this means that all changes are evicted and the conversation is not flushed.</p>

<h3>Testing the model</h3>

<p>Testing is very simple, all you need to do is to mock your repositories as follows: 
  <br /></p>

<pre class="code">[Test]
<span style="color: blue">public void </span>can_cancel_album()
{
    var repository = <span style="color: blue">new </span>Mock&lt;IAlbumRepository&gt;();
    var album = <span style="color: blue">new </span>Album();
    repository.Setup(rep =&gt; rep.Refresh(It.IsAny&lt;Album&gt;()))
              .AtMostOnce();

    var albumManagerModel = <span style="color: blue">new </span>AlbumManagerModel(repository.Object);

    albumManagerModel.CancelAlbum(album);

    repository.Verify(rep =&gt; rep.Refresh(album));
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>In this test I’m using the <a href="http://code.google.com/p/moq/">Moq</a> library. 

  <br />The other thing that we need to test is the conversation configuration, my first approach was to test the attributes, but owned by the fact that we can configure the CpBT in many ways (such as XML), this is my test:</p>

<pre class="code">[TestFixtureSetUp]
<span style="color: blue">public void </span>FixtureSetUp()
{
    conversationalMetaInfoStore.Add(<span style="color: blue">typeof </span>(AlbumManagerModel));
    metaInfo = conversationalMetaInfoStore.GetMetadataFor(<span style="color: blue">typeof</span>(AlbumManagerModel));
}

[Test]
<span style="color: blue">public void </span>model_represents_conversation()
{
    metaInfo.Should().Not.Be.Null();
    metaInfo.Setting.DefaultEndMode.Should().Be.EqualTo(EndMode.Continue);
    metaInfo.Setting.MethodsIncludeMode.Should().Be.EqualTo(MethodsIncludeMode.Implicit);
}

[Test]
<span style="color: blue">public void </span>cancel_all_abort_the_conversation()
{
    var method = Strong.Instance&lt;AlbumManagerModel&gt;
        .Method(am =&gt; am.CancelAll());

    var conversationInfo = metaInfo.GetConversationInfoFor(method);

    conversationInfo.ConversationEndMode
                    .Should().Be.EqualTo(EndMode.Abort);
}

[Test]
<span style="color: blue">public void </span>save_all_end_the_conversation()
{
    var method = Strong.Instance&lt;AlbumManagerModel&gt;
        .Method(am =&gt; am.SaveAll());

    var conversationInfo = metaInfo.GetConversationInfoFor(method);

    conversationInfo.ConversationEndMode
                    .Should().Be.EqualTo(EndMode.End);
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>I'm using a strongly typed way to get the MethodInfo extracted from this <a href="http://www.codeproject.com/KB/cs/Strong.aspx">example</a>.</p>
