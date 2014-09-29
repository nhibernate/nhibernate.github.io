---
layout: post
title: "NHibernate and WPF: Asynchronous calls"
date: 2009-11-23 01:48:18 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["WPF"]
alias: ["/blogs/nhibernate/archive/2009/11/22/nhibernate-and-wpf-asynchronous-calls.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>I will show in this article an approach to make an asynchronous call to the model, to prevent the user interface to freeze. If you read about WPF, you will see there is a lot of information and claims “don’t freeze the ui thread”, “build UI more responsiveness” and so on.</p>  <h2>What you should know</h2>  <p>NHibernate Sessions are not thread safe, so don’t use a single session in multiples threads. Conversation-per-Business-Transaction use the same session for a conversation. The end of the conversation flush the changes and close the session, the abort of the conversation discard changes and close the session.</p>  <p>You can’t update UI controls from a non-ui thread. Some people read this like “don’t set a ViewModel property from a non UI thread”. But this is not true, because it depends where do you raise the property changed notification thank to my friend <a href="http://schuager.com/">German Schuager</a> for reminding me <a href="http://devlicio.us/blogs/rob_eisenberg/archive/2009/09/08/dispelling-a-common-wpf-silverlight-myth.aspx">this post</a> from <a href="http://devlicio.us/blogs/rob_eisenberg">Rob Eisenberg</a>. However, I’m not using this trick for now.</p>  <p>Asynchronous code is <u><strong>HARD</strong></u> to unit test. I will like to separate the asynchronous code in few units more testable and test “in-sync”.</p>  <h1>The problem</h1>  <p>The load of the artist list is very slow and this causes the user interface to freeze. This is very irritating for the end user.</p>  <p>I will break the async problem in the following three steps:</p>  <ol>   <li>Preview: Before start the operation we want to let the user know that the operation is in-process with some message in the user interface or maybe an hourglass. </li>    <li>Process: The heavy operation. </li>    <li>Completed: The operation has ended and we want to show the result to the UI. </li> </ol>  <h1>Show me the code</h1>  <p>This my generic implementation of ICommand for make async calls.</p>  <pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">AsyncCommandWithResult</span>&lt;TParameter, TResult&gt;
        : IAsyncCommandWithResult&lt;TParameter, TResult&gt;
{
    <span style="color: blue">private readonly </span>Func&lt;TParameter, <span style="color: blue">bool</span>&gt; _canAction;
    <span style="color: blue">private readonly </span>Func&lt;TParameter, TResult&gt; _action;

    <span style="color: blue">public </span>AsyncCommandWithResult(Func&lt;TParameter, TResult&gt; action)
    {
        _action = action;
    }

    <span style="color: blue">public </span>AsyncCommandWithResult(
            Func&lt;TParameter, TResult&gt; action,
            Func&lt;TParameter, <span style="color: blue">bool</span>&gt; canAction)
    {
        _action = action;
        _canAction = canAction;
    }


    <span style="color: blue">public </span>Action&lt;TParameter, TResult&gt; Completed { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }
    <span style="color: blue">public </span>Action&lt;TParameter&gt; Preview { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }
    <span style="color: blue">public bool </span>BlockInteraction { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }

    <span style="color: blue">public void </span>Execute(<span style="color: blue">object </span>parameter)
    {
        <span style="color: green">//Execute Preview
        </span>Preview((TParameter)parameter);

        <span style="color: green">//This is the async actions to take... 
        </span>worker.DoWork += (sender, args) =&gt;
        {
            args.Result = _action((TParameter)parameter);

        };

        <span style="color: green">//When the work is complete, execute the postaction.
        </span>worker.RunWorkerCompleted += (sender, args) =&gt;
        {
            Completed((TParameter)parameter, (TResult)args.Result);
            CommandManager.InvalidateRequerySuggested();
        };

        <span style="color: green">//Run the async work.
        </span>worker.RunWorkerAsync();
    }

    [DebuggerStepThrough]
    <span style="color: blue">public bool </span>CanExecute(<span style="color: blue">object </span>parameter)
    {
        <span style="color: blue">if </span>(BlockInteraction &amp;&amp; worker.IsBusy)
            <span style="color: blue">return false</span>;

        <span style="color: blue">return </span>_canAction == <span style="color: blue">null </span>? <span style="color: blue">true </span>:
                _canAction((TParameter)parameter);
    }

    <span style="color: blue">public event </span>EventHandler CanExecuteChanged
    {
        <span style="color: blue">add </span>{ CommandManager.RequerySuggested += <span style="color: blue">value</span>; }
        <span style="color: blue">remove </span>{ CommandManager.RequerySuggested -= <span style="color: blue">value</span>; }
    }

    <span style="color: blue">public </span>TResult ExecuteSync(TParameter obj)
    {
        <span style="color: blue">return </span>_action(obj);
    }

    <span style="color: blue">private static readonly </span>BackgroundWorker worker
            = <span style="color: blue">new </span>BackgroundWorker();
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<h1>Testing the ViewModel</h1>

<p>Here you can see the test of the three steps. None of these test involves asynchronous calls.</p>

<pre class="code">[Test]
<span style="color: blue">public void </span>preview_of_load_list_should_show_status_info()
{
    var browseArtistVm = <span style="color: blue">new </span>BrowseArtistViewModel(
                <span style="color: blue">new </span>Mock&lt;IBrowseArtistModel&gt;().Object,
                <span style="color: blue">new </span>Mock&lt;IViewFactory&gt;().Object);
    
    browseArtistVm.LoadListCommand.Preview(<span style="color: blue">null</span>);
    browseArtistVm.Status.Should().Be.EqualTo(<span style="color: #a31515">&quot;Loading artists...&quot;</span>);
}

[Test(Description = <span style="color: #a31515">&quot;Check if the process call the model&quot;</span>)]
<span style="color: blue">public void </span>load_list_command_should_load_artists_coll()
{
    var artistModel = <span style="color: blue">new </span>Mock&lt;IBrowseArtistModel&gt;();

    var artists = <span style="color: blue">new </span>List&lt;Artist&gt; {<span style="color: blue">new </span>Artist {Name = <span style="color: #a31515">&quot;Jose&quot;</span>}};

    artistModel.Setup(am =&gt; am.GetAllArtists()).Returns(artists);

    var browseArtistVm = <span style="color: blue">new </span>BrowseArtistViewModel(
                            artistModel.Object, 
                            <span style="color: blue">new </span>Mock&lt;IViewFactory&gt;().Object);

    browseArtistVm.LoadListCommand.ExecuteSync(<span style="color: blue">null</span>);

    artistModel.VerifyAll();
}

[Test]
<span style="color: blue">public void </span>completed_of_load_l_should_load_the_list_and_change_status()
{
    var browseArtistVm = <span style="color: blue">new </span>BrowseArtistViewModel(
                <span style="color: blue">new </span>Mock&lt;IBrowseArtistModel&gt;().Object,
                <span style="color: blue">new </span>Mock&lt;IViewFactory&gt;().Object);

    var artists = <span style="color: blue">new </span>List&lt;Artist&gt;();

    browseArtistVm.LoadListCommand.Completed(<span style="color: blue">null</span>, artists);

    browseArtistVm.Artists.Should().Be.SameInstanceAs(artists);
    browseArtistVm.Status.Should().Be.EqualTo(<span style="color: #a31515">&quot;Finished&quot;</span>);
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<h1>Implementing the ViewModel</h1>

<p>The LoadListCommand of the ViewModel is:</p>

<pre class="code"><span style="color: blue">public virtual </span>IAsyncCommandWithResult&lt;<span style="color: blue">object</span>, IList&lt;Artist&gt;&gt; LoadListCommand
{
    <span style="color: blue">get
    </span>{
        <span style="color: blue">if </span>(_loadListCommand == <span style="color: blue">null</span>)
        {
            _loadListCommand = 
                <span style="color: blue">new </span>AsyncCommandWithResult&lt;<span style="color: blue">object</span>, IList&lt;Artist&gt;&gt;
                        (o =&gt; _browseArtistModel.GetAllArtists())
                        {
                            BlockInteraction = <span style="color: blue">true</span>,
                            Preview = o =&gt; Status = <span style="color: #a31515">&quot;Loading artists...&quot;</span>,
                            Completed = (o, artists) =&gt;
                                {
                                    Artists = artists;
                                    Status = <span style="color: #a31515">&quot;Finished&quot;</span>;
                                }
                        };
        }
        <span style="color: blue">return </span>_loadListCommand;
    }
}</pre>
<a href="http://11011.net/software/vspaste"></a>

<h1>Final conclusion</h1>

<p>You must to remember that an NHibernate Session should be used in only one thread. This model for Browsing Artists has only one method with EndMode = End. This means session-per-call, so each time I click the LoadCommand the model start a new conversation and session. If you have a ViewModel with multiples operations within the same Conversation better you use something else, or use AsyncCommand everywhere within the VM.</p>

<p>There are a lot of alternatives to this approach, here are some;</p>

<ul>
  <li><a href="http://msdn.microsoft.com/en-us/library/wewwczdw.aspx">Event-based asynchronous pattern</a>. </li>

  <li>Use background thread directly in your ViewModel. </li>
</ul>

<p>Use this only when you need it. You don’t have to do this everywhere. Some operations are very fast and inexpensive.</p>

<p>Divide and conquer; I really like this way of testing. Don’t bring asynchronous things to your unit tests.</p>
