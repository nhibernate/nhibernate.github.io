---
layout: post
title: "Composite with only a Many-To-One = Bad Idea"
date: 2011-01-08 11:54:35 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping"]
redirect_from: ["/blogs/nhibernate/archive/2011/01/08/composite-with-only-a-many-to-one-bad-idea.aspx/", "/blogs/nhibernate/archive/2011/01/08/composite-with-only-a-many-to-one-bad-idea.html"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>I can’t count with one hand, how many times I’ve seen this mapping in my few years of using nhibernate:</p>  <pre class="code">  <span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">Profile</span>&quot;<span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">composite-id</span><span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">key-many-to-one </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">User</span>&quot; <span style="color: red">column</span><span style="color: blue">=</span>&quot;<span style="color: blue">UserId</span>&quot; <span style="color: red">class</span><span style="color: blue">=</span>&quot;<span style="color: blue">User</span>&quot; <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">composite-id</span><span style="color: blue">&gt;

    &lt;!-- </span><span style="color: green">properties </span><span style="color: blue">--&gt;
  &lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;
</span></pre>

<p>The explanation that comes when you ask is almost always:</p>

<blockquote>
  <p>Well… It is the only way you can use a many-to-one as a primary key.</p>
</blockquote>

<p>There are two things that you can see in that quote:</p>

<ul>
  <li>The developer found a workaround (and sometimes he is proud)</li>

  <li>He wants a many to one!</li>
</ul>

<p>&#160;</p>

<p>First of all, it is not a <strong>many</strong>-to-one, because you CAN’T have many profiles for one user. It is not a many-to-one, so we need to find a better way to tell nhibernate what we want.</p>

<p>On the other hand, it is not a composite-id if you only have <strong>one thing</strong>.</p>

<p>This kind of relationship is named “one-to-one” because you have only one profile for only one user. As you can read in the reference documentation ( <a href="http://nhforge.org/doc/nh/en/index.html#mapping-declaration-onetoone">here</a> ) :</p>

<blockquote>
  <p>There are two varieties of one-to-one association:</p>

  <ul>
    <li>
      <p>primary key associations</p>
    </li>

    <li>
      <p>unique foreign key associations</p>
    </li>
  </ul>
</blockquote>

<p>If we want to have such schema (UserId as the PK) we are talking about the first one.</p>

<p>The mapping is as follow:</p>

<pre class="code">  <span style="color: blue">&lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">UserProfile</span>&quot; <span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">id </span><span style="color: red">column</span><span style="color: blue">=</span>&quot;<span style="color: blue">Id</span>&quot;<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>&quot;<span style="color: blue">foreign</span>&quot;<span style="color: blue">&gt;
        &lt;</span><span style="color: #a31515">param </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">property</span>&quot;<span style="color: blue">&gt;</span>User<span style="color: blue">&lt;/</span><span style="color: #a31515">param</span><span style="color: blue">&gt;
      &lt;/</span><span style="color: #a31515">generator</span><span style="color: blue">&gt;
    &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;
    
    &lt;</span><span style="color: #a31515">one-to-one </span><span style="color: red">name</span><span style="color: blue">=</span>&quot;<span style="color: blue">User</span>&quot;
        <span style="color: red">class</span><span style="color: blue">=</span>&quot;<span style="color: blue">User</span>&quot;
        <span style="color: red">constrained</span><span style="color: blue">=</span>&quot;<span style="color: blue">true</span>&quot;<span style="color: blue">/&gt;
  &lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;
</span></pre>



<p>And the class is pretty easy too:</p>

<pre class="code"><span style="color: blue">public class </span><span style="color: #2b91af">UserProfile
</span>{
    <span style="color: blue">public int </span>Id { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }
    <span style="color: blue">public </span>User User { <span style="color: blue">get</span>; <span style="color: blue">set</span>; }
    <span style="color: green">//other properties
</span>}</pre>



<p>This tell nhibernate to use the id from User when inserting a Profile. There rest is like any other class.</p>

<p>If you want to get an UserProfile, without getting the user, you can execute: session.Get&lt;UserProfile&gt;(userId). </p>
