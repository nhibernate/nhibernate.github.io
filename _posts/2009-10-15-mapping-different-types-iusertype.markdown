---
layout: post
title: "Mapping different types - IUserType"
date: 2009-10-15 18:21:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "IUserType"]
redirect_from: ["/blogs/nhibernate/archive/2009/10/15/mapping-different-types-iusertype.aspx/"]
author: krzysztof.kozmic
gravatar: fab7062ee87e12adc67846764e6be668
---
{% include imported_disclaimer.html %}
<p>Recently I had a problem with the application I&rsquo;ve been working on. One of entity types in my domain had a property of type <i>uint</i>. Not a big deal, until you want to store it in Microsoft SQL Server database which <a target="_blank" href="http://msdn.microsoft.com/en-us/library/ms187752.aspx">does not support unsigned types</a>. I&rsquo;ve been scratching my head for a moment and then I found a solution &ndash; let&rsquo;s map it as <i>long</i> in our database. Since <i>long</i> can represent any legal value of <i>uint</i>, we should be all good, right? So let&rsquo;s do it.</p>
<div class="csharpcode">
<div class="csharpcode">
<pre class="alt"><span class="kwrd">public</span> <span class="kwrd">class</span> ClassWithUintProperty</pre>
<pre>{</pre>
<pre class="alt">    <span class="kwrd">private</span> Guid Id { get; set; }</pre>
<pre>    <span class="kwrd">public</span> <span class="kwrd">virtual</span> <span class="kwrd">uint</span> UintProp { get ;set; }</pre>
<pre class="alt">}</pre>
</div>
<style type="text/css"><!--
[CDATA[



.csharpcode, .csharpcode pre

{

	font-size: small;

	color: black;

	font-family: consolas, "Courier New", courier, monospace;

	background-color: #ffffff;

	/*white-space: pre;*/

}

.csharpcode pre { margin: 0em; }

.csharpcode .rem { color: #008000; }

.csharpcode .kwrd { color: #0000ff; }

.csharpcode .str { color: #006080; }

.csharpcode .op { color: #0000c0; }

.csharpcode .preproc { color: #cc6633; }

.csharpcode .asp { background-color: #ffff00; }

.csharpcode .html { color: #800000; }

.csharpcode .attr { color: #ff0000; }

.csharpcode .alt 

{

	background-color: #f4f4f4;

	width: 100%;

	margin: 0em;

}

.csharpcode .lnum { color: #606060; }
--></style>
</div>
<p>
<style type="text/css"><!--
<![CDATA[





.csharpcode, .csharpcode pre

{

	font-size: small;

	color: black;

	font-family: consolas, "Courier New", courier, monospace;

	background-color: #ffffff;

	/*white-space: pre;*/

}

.csharpcode pre { margin: 0em; }

.csharpcode .rem { color: #008000; }

.csharpcode .kwrd { color: #0000ff; }

.csharpcode .str { color: #006080; }

.csharpcode .op { color: #0000c0; }

.csharpcode .preproc { color: #cc6633; }

.csharpcode .asp { background-color: #ffff00; }

.csharpcode .html { color: #800000; }

.csharpcode .attr { color: #ff0000; }

.csharpcode .alt 

{

	background-color: #f4f4f4;

	width: 100%;

	margin: 0em;

}

.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">="1.0"</span>?<span class="kwrd">&gt;</span></pre>
<pre><span class="kwrd">&lt;</span><span class="html">hibernate-mapping</span> <span class="attr">xmlns</span><span class="kwrd">="urn:nhibernate-mapping-2.2"</span></pre>
<pre class="alt">                   <span class="attr">assembly</span><span class="kwrd">="NHibernate.Test"</span></pre>
<pre>                   <span class="attr">namespace</span><span class="kwrd">="NHibernate.Test"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">  <span class="kwrd">&lt;</span><span class="html">class</span> <span class="attr">name</span><span class="kwrd">="ClassWithUintProperty"</span><span class="kwrd">&gt;</span></pre>
<pre>    <span class="kwrd">&lt;</span><span class="html">id</span> <span class="attr">name</span><span class="kwrd">="Id"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="UIntProp"</span> <span class="attr">not-null</span><span class="kwrd">="true"</span> <span class="attr">type</span><span class="kwrd">="long"</span> <span class="kwrd">/&gt;</span></pre>
<pre>  <span class="kwrd">&lt;/</span><span class="html">class</span><span class="kwrd">&gt;</span></pre>
<pre class="alt"><span class="kwrd">&lt;/</span><span class="html">hibernate-mapping</span><span class="kwrd">&gt;</span></pre>
</div>
<p>
<style type="text/css"><!--
<![CDATA[





.csharpcode, .csharpcode pre

{

	font-size: small;

	color: black;

	font-family: consolas, "Courier New", courier, monospace;

	background-color: #ffffff;

	/*white-space: pre;*/

}

.csharpcode pre { margin: 0em; }

.csharpcode .rem { color: #008000; }

.csharpcode .kwrd { color: #0000ff; }

.csharpcode .str { color: #006080; }

.csharpcode .op { color: #0000c0; }

.csharpcode .preproc { color: #cc6633; }

.csharpcode .asp { background-color: #ffff00; }

.csharpcode .html { color: #800000; }

.csharpcode .attr { color: #ff0000; }

.csharpcode .alt 

{

	background-color: #f4f4f4;

	width: 100%;

	margin: 0em;

}

.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>&nbsp;</p>
<h3>&nbsp;</h3>
<h3>"Houston, we've had a problem"</h3>
<p>All good. At least until you try to fetch saved value from the database. When you do, you&rsquo;re up for an unpleasant surprise:</p>
<blockquote>
<p>System.InvalidCastException: Specified cast is not valid.</p>
<p>NHibernate.PropertyAccessException: Invalid Cast (check your mapping for property type mismatches); setter of NHibernate.Test.UIntAsLong</p>
</blockquote>
<p>The exception is a result of how NHibernate optimizes property access and quirks of mixing different conversion operators (unboxing and numeric conversion in this case) and are not really interesting. What&rsquo;s important, is that we approached the problem from the wrong angle.</p>
<p>What we&rsquo;re dealing with here, is inability of our database engine to deal with datatype in our model, which we were trying to solve by pushing this onto NHibernate without telling it something is &lsquo;&rdquo;wrong&rdquo;. While NHibernate is smart, it&rsquo;s working based on a set of explicit information, so what we need to do, is to be explicit about what we want it to do.</p>
<p>There are two places where we can tell NHibernate about it.</p>
<ul>
<li>IUserType, which will explicitly handle the mapping from <i>uint</i> in our model to <i>long</i> in the DB </li>
<li>custom Dialect which will basically lie to NHibernate telling it &ldquo;yeah, sure this DB supports <i>uint</i>s &ndash; whole dozens of &lsquo;em!&rdquo; and do some work under the covers to live up to its promise. (not shown in this post). </li>
</ul>
<p>&nbsp;</p>
<h3>Enter IUserType</h3>
<p><a target="_blank" href="/doc/nh/en/index.html#mapping-types-custom">IUserType</a> is an extension point in NHibernate that let&rsquo;s you plug in to the mapping process and handle it yourself. The interface is quite big, but there&rsquo;s very little real logic there:</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">public</span> <span class="kwrd">class</span> UIntAsLong:IUserType</pre>
<pre>{</pre>
<pre class="alt">        <span class="kwrd">public</span> SqlType[] SqlTypes</pre>
<pre>        {</pre>
<pre class="alt">            get { <span class="kwrd">return</span> <span class="kwrd">new</span>[] { SqlTypeFactory.Int64 }; }</pre>
<pre>        }</pre>
<pre class="alt">&nbsp;</pre>
<pre>        <span class="kwrd">public</span> Type ReturnedType</pre>
<pre class="alt">        {</pre>
<pre>            get { <span class="kwrd">return</span> <span class="kwrd">typeof</span>( <span class="kwrd">uint</span> ); }</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">bool</span> IsMutable</pre>
<pre>        {</pre>
<pre class="alt">            get { <span class="kwrd">return</span> <span class="kwrd">false</span>; }</pre>
<pre>        }</pre>
<pre class="alt">&nbsp;</pre>
<pre>        <span class="kwrd">public</span> <span class="kwrd">int</span> GetHashCode( <span class="kwrd">object</span> x )</pre>
<pre class="alt">        {</pre>
<pre>            <span class="kwrd">if</span>( x == <span class="kwrd">null</span> )</pre>
<pre class="alt">            {</pre>
<pre>                <span class="kwrd">return</span> 0;</pre>
<pre class="alt">            }</pre>
<pre>            <span class="kwrd">return</span> x.GetHashCode();</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">object</span> NullSafeGet( IDataReader rs, <span class="kwrd">string</span>[] names, <span class="kwrd">object</span> owner )</pre>
<pre>        {</pre>
<pre class="alt">            <span class="kwrd">object</span> obj = NHibernateUtil.UInt32.NullSafeGet( rs, names0 );</pre>
<pre>            <span class="kwrd">if</span>( obj == <span class="kwrd">null</span> )</pre>
<pre class="alt">            {</pre>
<pre>                <span class="kwrd">return</span> <span class="kwrd">null</span>;</pre>
<pre class="alt">            }</pre>
<pre>            <span class="kwrd">return</span> (<span class="kwrd">uint</span>)obj;</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">void</span> NullSafeSet( IDbCommand cmd, <span class="kwrd">object</span> <span class="kwrd">value</span>, <span class="kwrd">int</span> index )</pre>
<pre>        {</pre>
<pre class="alt">            Debug.Assert( cmd != <span class="kwrd">null</span>);</pre>
<pre>            <span class="kwrd">if</span>( <span class="kwrd">value</span> == <span class="kwrd">null</span> )</pre>
<pre class="alt">            {</pre>
<pre>                ((IDataParameter)cmd.Parametersindex).Value = DBNull.Value;</pre>
<pre class="alt">            }</pre>
<pre>            <span class="kwrd">else</span></pre>
<pre class="alt">            {</pre>
<pre>                var uintValue = (<span class="kwrd">uint</span>)<span class="kwrd">value</span>;</pre>
<pre class="alt">                ( (IDataParameter) cmd.Parametersindex ).Value = (<span class="kwrd">long</span>) uintValue;</pre>
<pre>            }</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">object</span> DeepCopy( <span class="kwrd">object</span> <span class="kwrd">value</span> )</pre>
<pre>        {</pre>
<pre class="alt">            <span class="rem">// we can ignore it...</span></pre>
<pre>            <span class="kwrd">return</span> <span class="kwrd">value</span>;</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">object</span> Replace( <span class="kwrd">object</span> original, <span class="kwrd">object</span> target, <span class="kwrd">object</span> owner )</pre>
<pre>        {</pre>
<pre class="alt">            <span class="rem">// we can ignore it...</span></pre>
<pre>            <span class="kwrd">return</span> original;</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">object</span> Assemble( <span class="kwrd">object</span> cached, <span class="kwrd">object</span> owner )</pre>
<pre>        {</pre>
<pre class="alt">            <span class="rem">// we can ignore it...</span></pre>
<pre>            <span class="kwrd">return</span> cached;</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">public</span> <span class="kwrd">object</span> Disassemble( <span class="kwrd">object</span> <span class="kwrd">value</span> )</pre>
<pre>        {</pre>
<pre class="alt">            <span class="rem">// we can ignore it...</span></pre>
<pre>            <span class="kwrd">return</span> <span class="kwrd">value</span>;</pre>
<pre class="alt">        }</pre>
<pre>&nbsp;</pre>
<pre class="alt">        <span class="kwrd">bool</span> IUserType.Equals( <span class="kwrd">object</span> x, <span class="kwrd">object</span> y )</pre>
<pre>        {</pre>
<pre class="alt">            <span class="kwrd">return</span> <span class="kwrd">object</span>.Equals( x, y );</pre>
<pre>        }</pre>
<pre class="alt">} </pre>
</div>
<p>
<style type="text/css"><!--
<![CDATA[





.csharpcode, .csharpcode pre

{

	font-size: small;

	color: black;

	font-family: consolas, "Courier New", courier, monospace;

	background-color: #ffffff;

	/*white-space: pre;*/

}

.csharpcode pre { margin: 0em; }

.csharpcode .rem { color: #008000; }

.csharpcode .kwrd { color: #0000ff; }

.csharpcode .str { color: #006080; }

.csharpcode .op { color: #0000c0; }

.csharpcode .preproc { color: #cc6633; }

.csharpcode .asp { background-color: #ffff00; }

.csharpcode .html { color: #800000; }

.csharpcode .attr { color: #ff0000; }

.csharpcode .alt 

{

	background-color: #f4f4f4;

	width: 100%;

	margin: 0em;

}

.csharpcode .lnum { color: #606060; }
--></style>
</p>
<p>There are really two parts of the code that are interesting. SqlTypes / ReturnedType properties which tell NHibernate which types to expect on both sides of the mapping, and the NullSafeGet / NullSafeSet methods which perform the actual conversion.</p>
<p>Now we just need to plug our custom user type to the mapping, and it goes like this:</p>
<div class="csharpcode">
<pre class="alt"><span class="kwrd">&lt;?</span><span class="html">xml</span> <span class="attr">version</span><span class="kwrd">="1.0"</span>?<span class="kwrd">&gt;</span></pre>
<pre><span class="kwrd">&lt;</span><span class="html">hibernate-mapping</span> <span class="attr">xmlns</span><span class="kwrd">="urn:nhibernate-mapping-2.2"</span></pre>
<pre class="alt">                   <span class="attr">assembly</span><span class="kwrd">="NHibernate.Test"</span></pre>
<pre>                   <span class="attr">namespace</span><span class="kwrd">="NHibernate.Test"</span><span class="kwrd">&gt;</span></pre>
<pre class="alt">  <span class="kwrd">&lt;</span><span class="html">class</span> <span class="attr">name</span><span class="kwrd">="ClassWithUintProperty"</span><span class="kwrd">&gt;</span></pre>
<pre>    <span class="kwrd">&lt;</span><span class="html">id</span> <span class="attr">name</span><span class="kwrd">="Id"</span><span class="kwrd">/&gt;</span></pre>
<pre class="alt">    <span class="kwrd">&lt;</span><span class="html">property</span> <span class="attr">name</span><span class="kwrd">="UIntProp"</span> <span class="attr">not-null</span><span class="kwrd">="true"</span> <span class="attr">type</span><span class="kwrd">="Foo.Namespace.UIntAsLong, Foo.Assembly"</span> <span class="kwrd">/&gt;</span></pre>
<pre>  <span class="kwrd">&lt;/</span><span class="html">class</span><span class="kwrd">&gt;</span></pre>
<pre class="alt"><span class="kwrd">&lt;/</span><span class="html">hibernate-mapping</span><span class="kwrd">&gt;</span></pre>
</div>
<p>
<style type="text/css"><!--
<![CDATA[





.csharpcode, .csharpcode pre

{

	font-size: small;

	color: black;

	font-family: consolas, "Courier New", courier, monospace;

	background-color: #ffffff;

	/*white-space: pre;*/

}

.csharpcode pre { margin: 0em; }

.csharpcode .rem { color: #008000; }

.csharpcode .kwrd { color: #0000ff; }

.csharpcode .str { color: #006080; }

.csharpcode .op { color: #0000c0; }

.csharpcode .preproc { color: #cc6633; }

.csharpcode .asp { background-color: #ffff00; }

.csharpcode .html { color: #800000; }

.csharpcode .attr { color: #ff0000; }

.csharpcode .alt 

{

	background-color: #f4f4f4;

	width: 100%;

	margin: 0em;

}

.csharpcode .lnum { color: #606060; }]]
--></style>
</p>
<p>&nbsp;</p>
