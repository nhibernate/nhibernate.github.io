---
layout: post
title: "Nhibernate and WPF: ViewModels and Views"
date: 2009-08-19 16:23:46 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["Session", "WPF"]
redirect_from: ["/blogs/nhibernate/archive/2009/08/19/nhibernate-and-wpf-viewmodels-and-views.aspx/", "/blogs/nhibernate/archive/2009/08/19/nhibernate-and-wpf-viewmodels-and-views.html"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>Part I: <a href="http://jfromaniello.blogspot.com/2009/08/introducing-nhiberate-and-wpf.html">Introducing NHiberate and WPF: The ChinookMediaManager</a>     <br />Part II: <a href="http://jfromaniello.blogspot.com/2009/08/chinook-media-manager-core.html">Nhibernate and WPF: The core</a>     <br />Part III: <a href="http://nhforge.org/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-models-concept.aspx">Nhibernate and WPF: Models concept</a></p>  <p>In this post I will introduce some concepts about the presentation layer of the Chinook Media Manager example.</p>  <h3>Prerequisites</h3>  <p>If you are new to the MVVM pattern I will strongly recommend you these blogs post:</p>  <ul>   <li><a href="http://blogs.msdn.com/johngossman/archive/2005/10/08/478683.aspx">Tales from the smart client – John Grossman.</a> </li>    <li><a href="http://msdn.microsoft.com/en-us/magazine/dd419663.aspx">WPF apps with the MVVM design pattern – By John Smith.</a> </li>    <li><a href="http://blogs.msdn.com/erwinvandervalk/archive/2009/08/14/the-difference-between-model-view-viewmodel-and-other-separated-presentation-patterns.aspx">The difference between Model-View-ViewModel and other separated presentation pattern – By Erwin van der Valk.</a> </li> </ul>  <h3>Introduction</h3>  <p>I will quote John Smith:</p>  <blockquote>   <p>The single most important aspect of WPF that makes MVVM a great pattern to use is the data binding infrastructure. By binding properties of a view to a ViewModel, you get loose coupling between the two and entirely remove the need for writing code in a ViewModel that directly updates a view.</p> </blockquote>  <p>This is the more important thing that you need to remember. Unlike the MVP pattern the viewmodel never updates the UI, the ui is automatically updated by the databinding infrastructure. Also you has to keep in mind that all in the MVVM is about databinding, even <strong>events</strong>. </p>  <p>I chose to separate Views and ViewModels in differents assembly, although I saw these two together in a bunch of samples. For the other hand the interfaces of the ViewModels are defined in the Views assembly.</p>  <h3>The “Album Manager” use case</h3>  <p>If we recall my first post the UI was this:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/albums_5F00_4848FF1C.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="albums" border="0" alt="albums" src="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/albums_5F00_thumb_5F00_1C533E31.png" width="476" height="384" /></a> </p>  <p>I will separate this use case in two views and viewmodels:</p>  <p><a href="http://nhforge.org/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/albumsred_5F00_28E60CAF.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="albumsred" border="0" alt="albumsred" src="/images/posts/2009/08/19/albumsred_5F00_thumb_5F00_16C1F142.png" width="476" height="384" /></a> </p>  <p>The main View is called AlbumManagerView and the view inside the red border is called “EditAlbumView”. The reason for why I’m doing this is clear: “I need somehow to separate the problem into smaller parts”. And as I say in the “<a href="http://nhforge.org/blogs/nhibernate/archive/2009/08/15/nhibernate-and-wpf-models-concept.aspx">Models concept</a>” post a use-case can expand multiples views.</p>  <p>To complicate things a bit, the user told us that would like to be able to simultaneously edit multiple albums. So, I will use the workspace sample of John Smith.</p>  <h3>The AlbumManager</h3>  <p>When I start to define a View, the first thing is the ViewModel interface, in this case:</p>  <pre class="code"><span style="color: blue">public interface </span><span style="color: #2b91af">IAlbumManagerViewModel </span>: <span style="color: #2b91af">INotifyPropertyChanged
</span>{
    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Setup the view, load the albums collection.
    </span><span style="color: gray">/// &lt;/summary&gt;
    /// &lt;param name=&quot;artist&quot;&gt;&lt;/param&gt;
    </span><span style="color: blue">void </span>SetUp(<span style="color: #2b91af">Artist </span>artist);

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Expose a bindable collection of albums.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">IEnumerable</span>&lt;<span style="color: #2b91af">Album</span>&gt; Albums { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Get or Set the selected album.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">Album </span>SelectedAlbum { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Open an edition workspace for editing the selected album.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>EditSelectedAlbumCommand { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Commit all the changes.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>SaveAllCommand { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">Discard all the changes.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>CancelAllCommand { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">WorkSpace open.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ObservableCollection</span>&lt;<span style="color: #2b91af">IEditAlbumViewModel</span>&gt; AlbumEditWorkspaces { <span style="color: blue">get</span>; }
}</pre>

<p>In the introduction I said that MVVM use databinding even for events . 
  <br />So, what is an ICommand?&#160; ICommand interface has three members: CanExecuteChanged, CanExecute and Execute. The object that is bound to this command (aka command source), disable itself if the command cann’t be executed. You can bind KeyGestures, MouseActions, buttons and so on. More on this topic <a href="http://msdn.microsoft.com/en-us/library/ms752308.aspx">here</a>.</p>

<p>The second step is to start writing a test for the concrete implementation of the viewmodel.&#160; <br /></p>

<pre class="code">[<span style="color: #2b91af">TestFixture</span>]
<span style="color: blue">public class </span><span style="color: #2b91af">AlbumManagerViewModelTest
</span>{
    [<span style="color: #2b91af">Test</span>]
    <span style="color: blue">public void </span>setup_viewmodel_should_work()
    {
        <span style="color: blue">var </span>albumManagerModel = <span style="color: blue">new </span><span style="color: #2b91af">Mock</span>&lt;<span style="color: #2b91af">IAlbumManagerModel</span>&gt;();

        <span style="color: blue">var </span>artist = <span style="color: blue">new </span><span style="color: #2b91af">Artist </span>{ Name = <span style="color: #a31515">&quot;John&quot; </span>};
        <span style="color: blue">var </span>albumList = <span style="color: blue">new </span><span style="color: #2b91af">List</span>&lt;<span style="color: #2b91af">Album</span>&gt; { <span style="color: blue">new </span><span style="color: #2b91af">Album</span>() { Artist = artist } };

        albumManagerModel.Setup(am =&gt; am.GetAlbumsByArtist(artist))
                         .Returns(albumList)
                         .AtMostOnce();


        <span style="color: blue">var </span>albumManagerVm = <span style="color: blue">new </span><span style="color: #2b91af">AlbumManagerViewModel</span>(albumManagerModel.Object, 
                                                       viewInsantiator.Object);

        <span style="color: blue">var </span>eventWasRaised = <span style="color: blue">false</span>;

        albumManagerVm.PropertyChanged +=
            (sender, args) =&gt;
            {
                <span style="color: green">//property changed should be raised AFTER the property change.
                </span><span style="color: blue">if </span>(<span style="color: #a31515">&quot;Albums&quot;</span>.Equals(args.PropertyName))
                {
                    albumManagerVm.Albums.Should().Be.SameInstanceAs(albumList);
                    eventWasRaised = <span style="color: blue">true</span>;    
                }
            };

        albumManagerVm.SetUp(artist);
        eventWasRaised.Should().Be.True();
        albumManagerModel.VerifyAll();

    }</pre>
<a href="http://11011.net/software/vspaste"></a>

<p></p>

<p>When I setup an “AlbumManagerViewModel”, it should call GetAlbumByArtist of my model, and put the result in the “Albums” property. Also the viewmodel should raise the PropertyChanged for the album property, AFTER the change in the property.</p>

<p>The implementation is very simple: 
  <br /></p>

<pre class="code"><span style="color: blue">public void </span>SetUp(<span style="color: #2b91af">Artist </span>artist)
{
    Albums = _albumManagerModel.GetAlbumsByArtist(artist);
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<pre class="code"><span style="color: blue">private </span><span style="color: #2b91af">IEnumerable</span>&lt;<span style="color: #2b91af">Album</span>&gt; _albums;
<span style="color: blue">public </span><span style="color: #2b91af">IEnumerable</span>&lt;<span style="color: #2b91af">Album</span>&gt; Albums
{
    <span style="color: blue">get </span>{ <span style="color: blue">return </span>_albums; }
    <span style="color: blue">private set
    </span>{
        _albums = <span style="color: blue">value</span>;
        OnPropertyChanged(<span style="color: #a31515">&quot;Albums&quot;</span>);
    }
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>To not getting bored with the code, the full implementation of the EditSelectedAlbumCommand is <a href="http://code.google.com/p/unhaddins/source/browse/trunk/Examples/uNHAddIns.Examples.WPF/ChinookMediaManager.ViewModels/AlbumManagerViewModel.cs">here</a>.</p>

<p>I will highlight interesting parts of this code:</p>

<pre class="code"><span style="color: blue">public </span><span style="color: #2b91af">ICommand </span>EditSelectedAlbumCommand
{
    <span style="color: blue">get
    </span>{
        <span style="color: blue">if </span>(_editSelectedAlbumCommand == <span style="color: blue">null</span>)
            _editSelectedAlbumCommand = <span style="color: blue">new </span><span style="color: #2b91af">RelayCommand</span>(
                o =&gt; EditSelectedAlbum(),
                o =&gt; SelectedAlbum != <span style="color: blue">null </span>&amp;&amp;!AlbumEditWorkspaces.Any(ae =&gt; ae.Album == SelectedAlbum));
        <span style="color: blue">return </span>_editSelectedAlbumCommand;
    }
}</pre>

<p><a href="http://11011.net/software/vspaste"></a>This is the EditSelectedAlbumCommand. In the instantiation of the command you see two lambdas. The first function is the code that should be called when the commandsource call Execute. The second is the CanExecute function, as you can see it returns false when:</p>

<ul>
  <li>There isn’t a selected album. </li>

  <li>There is another workspace editing the album. </li>
</ul>

<p>You can find the RelayCommand in the source.</p>

<p>The EditSelectedAlbum method looks as follows:</p>

<pre class="code"><span style="color: blue">private void </span>EditSelectedAlbum()
{
    <span style="color: green">//Resolve a new instance of EditAlbumViewModel
    </span><span style="color: blue">var </span>newWp = _viewFactory.ResolveViewModel&lt;<span style="color: #2b91af">IEditAlbumViewModel</span>&gt;();
    <span style="color: green">//Setup the new viewmodel.
    </span>newWp.SetUp(SelectedAlbum, _albumManagerModel);
    <span style="color: green">//subscribe to close request.
    </span>newWp.RequestClose += EditAlbumRequestClose;
    <span style="color: green">//add the new viewmodel to the workspace collection.
    </span>AlbumEditWorkspaces.Add(newWp);
    <span style="color: green">//set the new viewmodel as the active wp.
    </span>SetActiveWorkspace(newWp);
}</pre>

<pre class="code">Now, the view for this viewmodel is very easy:</pre>

<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">StackPanel</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">StackPanel </span><span style="color: red">Orientation</span><span style="color: blue">=&quot;Horizontal&quot; </span><span style="color: red">DockPanel.Dock</span><span style="color: blue">=&quot;Top&quot; &gt;
        &lt;</span><span style="color: #a31515">Button </span><span style="color: red">Command</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">EditSelectedAlbumCommand</span><span style="color: blue">}&quot; &gt;</span><span style="color: #a31515">Edit</span><span style="color: blue">&lt;/</span><span style="color: #a31515">Button</span><span style="color: blue">&gt;
        &lt;</span><span style="color: #a31515">Button</span><span style="color: blue">&gt;</span><span style="color: #a31515">Close</span><span style="color: blue">&lt;/</span><span style="color: #a31515">Button</span><span style="color: blue">&gt;
    &lt;/</span><span style="color: #a31515">StackPanel</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">ListBox </span><span style="color: red">Name</span><span style="color: blue">=&quot;AlbumsList&quot; 
         </span><span style="color: red">ItemsSource</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">Albums</span><span style="color: blue">}&quot; 
         </span><span style="color: red">DisplayMemberPath</span><span style="color: blue">=&quot;Title&quot;
         </span><span style="color: red">SelectedItem</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">SelectedAlbum</span><span style="color: blue">}&quot;
         </span><span style="color: red">DockPanel.Dock</span><span style="color: blue">=&quot;Top&quot; </span><span style="color: red">Height</span><span style="color: blue">=&quot;302&quot;&gt;
    &lt;/</span><span style="color: #a31515">ListBox</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">Button </span><span style="color: red">Command</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">SaveAllCommand</span><span style="color: blue">}&quot; &gt;</span><span style="color: #a31515">Save All</span><span style="color: blue">&lt;/</span><span style="color: #a31515">Button</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">Button </span><span style="color: red">Command</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">CancelAllCommand</span><span style="color: blue">}&quot; &gt;</span><span style="color: #a31515">Cancel All</span><span style="color: blue">&lt;/</span><span style="color: #a31515">Button</span><span style="color: blue">&gt;
&lt;/</span><span style="color: #a31515">StackPanel</span><span style="color: blue">&gt;
</span></pre>
<a href="http://11011.net/software/vspaste"></a>

<p>The “tabs” container is described in this peace of code:</p>

<pre class="code"><span style="color: blue">&lt;</span><span style="color: #a31515">Border </span><span style="color: red">Style</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">StaticResource </span><span style="color: red">MainBorderStyle</span><span style="color: blue">}&quot;&gt;
    &lt;</span><span style="color: #a31515">HeaderedContentControl 
      </span><span style="color: red">Content</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">Binding </span><span style="color: red">Path</span><span style="color: blue">=AlbumEditWorkspaces}&quot;
      </span><span style="color: red">ContentTemplate</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">StaticResource </span><span style="color: red">WorkspacesTemplate</span><span style="color: blue">}&quot;
      </span><span style="color: red">Header</span><span style="color: blue">=&quot;Workspaces&quot;
      </span><span style="color: red">Style</span><span style="color: blue">=&quot;{</span><span style="color: #a31515">StaticResource </span><span style="color: red">MainHCCStyle</span><span style="color: blue">}&quot;
      /&gt;
&lt;/</span><span style="color: #a31515">Border</span><span style="color: blue">&gt;</span></pre>

<h3>The EditAlbum </h3>

<p>I define the interface for the IEditAlbumViewModel as follows: 
  <br /></p>

<pre class="code"><span style="color: blue">public interface </span><span style="color: #2b91af">IEditAlbumViewModel </span>: <span style="color: #2b91af">INotifyPropertyChanged
</span>{
    <span style="color: blue">void </span>SetUp(<span style="color: #2b91af">Album </span>album, <span style="color: #2b91af">IAlbumManagerModel </span>albumManagerModel);

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">The album being edited.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">Album </span>Album { <span style="color: blue">get</span>; }
   
    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">The title of the tab.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: blue">string </span>DisplayName { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">The command to close the tab.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>CloseCommand { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">The command to save the album.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>SaveCommand { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">The command to add a new track to the album.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>AddNewTrackCommand { <span style="color: blue">get</span>; }

    <span style="color: gray">/// &lt;summary&gt;
    /// </span><span style="color: green">The command to delete the selected track.
    </span><span style="color: gray">/// &lt;/summary&gt;
    </span><span style="color: #2b91af">ICommand </span>DeleteSelectedTrackCommand { <span style="color: blue">get</span>; }

    <span style="color: #2b91af">Track </span>SelectedTrack { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }

    <span style="color: blue">event </span><span style="color: #2b91af">EventHandler </span>RequestClose;
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<p>The implementation is very straightforward, you can see <a href="http://code.google.com/p/unhaddins/source/browse/trunk/Examples/uNHAddIns.Examples.WPF/ChinookMediaManager.ViewModels/EditAlbumViewModel.cs">here</a>. One thing to mention is that I configure nhibernate to resolve all my collections with INotifyCollectionChanged, so I can add a new Track in my viewmodel and the datagrid bound to the tracks collection will be notified about that change.</p>

<h3>What’s next?</h3>

<p>We have several troubles with this application:</p>

<ul>
  <li>Error handling. Is simple, this is what the user see. We MUST handle unexpected exceptions, just think what would happen if we shutdown the database server. </li>

  <li>Asynchronous calls. For now we are freezing the UI thread with database and business layer operations. We need to build responsive UI’s </li>

  <li>Validation. I will add support to the NHibernate Validator. </li>

  <li>Conflict resolution for concurrency problems. </li>
</ul>

<h3>Do you want to see the app working?</h3>

<p><a href="http://www.screencast.com/t/dCrs2VJB">Here</a> you can see the full concept of &quot;Conversation per Business Transaction&quot; of <a href="http://fabiomaulo.blogspot.com/">Fabio Maulo</a> working.</p>


<p>The full source code project is <a href="http://code.google.com/p/unhaddins/">here</a>.</p>

<p>Special thanks to all the people mentioned in this post.</p>
