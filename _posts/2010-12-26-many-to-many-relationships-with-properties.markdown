---
layout: post
title: "Many-to-many relationships with properties"
date: 2010-12-26 11:52:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2010/12/26/many-to-many-relationships-with-properties.aspx"]
author: diegose
gravatar: f00318698e65fce00b7cbd612a466571
---
{% include imported_disclaimer.html %}
<p>There's a question that seems to appear at least once a month in StackOverflow or the <a href="https://groups.google.com/forum/#!forum/nhusers">NH users</a> group:</p>  <blockquote>   <p><em>How can I add properties to a many-to-many relationship?</em></p> </blockquote>  <p>The user of course means adding columns to the &quot;junction&quot; table used to store the many-to-many relationship, and being able to populate them without changing his object model.</p>  <p>That makes some sense from a relational perspective (a table is just a table after all), but not from an OOP one: <strong>a relationship does not have properties</strong>.</p>  <p>The easiest solution, of course, is to map the relationship as an entity, with regular one-to-many collections from both sides.</p>  <p>This would be the end of it... if it weren't for the fact that it's <strong>not</strong> what the user wants. If you dig a little further, you'll find that, in most of his use cases, the additional properties don't matter. They are used for auditing purposes, activation/deactivation, etc.</p>  <p>So, how can we code such a model? Answer: using LINQ-to-objects.</p>  <p>Let's consider a typical <strong>Users - Roles</strong> relationship (a user has many roles, a role is applied by many users).</p>  <p><em>Step 1: Create the entities</em></p>  <p>   <div style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px" id="scid:9D7513F9-C04C-4721-824A-2B34F0212519:f119f9c6-53a0-419c-ba56-f60a33879f1e" class="wlWriterEditableSmartContent"><pre style=" width: 640px; height: 576px;background-color:White;overflow: visible;;font-family:Consolas;font-size:12"><div><!--

Code highlighting produced by Actipro CodeHighlighter (freeware)
http://www.CodeHighlighter.com/

--><span style="color: #008080;"> 1</span> <span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">class</span><span style="color: #000000;"> User
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> User()
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">    {
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">        _UserRoles </span><span style="color: #000000;">=</span><span style="color: #000000;"> </span><span style="color: #0000FF;">new</span><span style="color: #000000;"> List</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">UserRole</span><span style="color: #000000;">&gt;</span><span style="color: #000000;">();
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> </span><span style="color: #0000FF;">string</span><span style="color: #000000;"> Name { </span><span style="color: #0000FF;">get</span><span style="color: #000000;">; </span><span style="color: #0000FF;">set</span><span style="color: #000000;">; }
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    
</span><span style="color: #008080;">10</span> <span style="color: #000000;">    ICollection</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">UserRole</span><span style="color: #000000;">&gt;</span><span style="color: #000000;"> _UserRoles;
</span><span style="color: #008080;">11</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">protected</span><span style="color: #000000;"> </span><span style="color: #0000FF;">internal</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> ICollection</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">UserRole</span><span style="color: #000000;">&gt;</span><span style="color: #000000;"> UserRoles
</span><span style="color: #008080;">12</span> <span style="color: #000000;">    {
</span><span style="color: #008080;">13</span> <span style="color: #000000;">        </span><span style="color: #0000FF;">get</span><span style="color: #000000;"> { </span><span style="color: #0000FF;">return</span><span style="color: #000000;"> _UserRoles; }
</span><span style="color: #008080;">14</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">15</span> <span style="color: #000000;">}
</span><span style="color: #008080;">16</span> <span style="color: #000000;">
</span><span style="color: #008080;">17</span> <span style="color: #000000;"></span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">class</span><span style="color: #000000;"> Role
</span><span style="color: #008080;">18</span> <span style="color: #000000;">{
</span><span style="color: #008080;">19</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> Role()
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    {
</span><span style="color: #008080;">21</span> <span style="color: #000000;">        _UserRoles </span><span style="color: #000000;">=</span><span style="color: #000000;"> </span><span style="color: #0000FF;">new</span><span style="color: #000000;"> List</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">UserRole</span><span style="color: #000000;">&gt;</span><span style="color: #000000;">();
</span><span style="color: #008080;">22</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">23</span> <span style="color: #000000;">
</span><span style="color: #008080;">24</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> </span><span style="color: #0000FF;">string</span><span style="color: #000000;"> Description { </span><span style="color: #0000FF;">get</span><span style="color: #000000;">; </span><span style="color: #0000FF;">set</span><span style="color: #000000;">; }
</span><span style="color: #008080;">25</span> <span style="color: #000000;">
</span><span style="color: #008080;">26</span> <span style="color: #000000;">    ICollection</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">UserRole</span><span style="color: #000000;">&gt;</span><span style="color: #000000;"> _UserRoles;
</span><span style="color: #008080;">27</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">protected</span><span style="color: #000000;"> </span><span style="color: #0000FF;">internal</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> ICollection</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">UserRole</span><span style="color: #000000;">&gt;</span><span style="color: #000000;"> UserRoles
</span><span style="color: #008080;">28</span> <span style="color: #000000;">    {
</span><span style="color: #008080;">29</span> <span style="color: #000000;">        </span><span style="color: #0000FF;">get</span><span style="color: #000000;"> { </span><span style="color: #0000FF;">return</span><span style="color: #000000;"> _UserRoles; }
</span><span style="color: #008080;">30</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">31</span> <span style="color: #000000;">}
</span><span style="color: #008080;">32</span> <span style="color: #000000;">
</span><span style="color: #008080;">33</span> <span style="color: #000000;"></span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">class</span><span style="color: #000000;"> UserRole
</span><span style="color: #008080;">34</span> <span style="color: #000000;">{
</span><span style="color: #008080;">35</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> User User { </span><span style="color: #0000FF;">get</span><span style="color: #000000;">; </span><span style="color: #0000FF;">set</span><span style="color: #000000;">; }
</span><span style="color: #008080;">36</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> Role Role { </span><span style="color: #0000FF;">get</span><span style="color: #000000;">; </span><span style="color: #0000FF;">set</span><span style="color: #000000;">; }
</span><span style="color: #008080;">37</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> DateTime AssignedDate { </span><span style="color: #0000FF;">get</span><span style="color: #000000;">; </span><span style="color: #0000FF;">set</span><span style="color: #000000;">; }
</span><span style="color: #008080;">38</span> <span style="color: #000000;">}</span></div></pre><!-- Code inserted with Steve Dunn's Windows Live Writer Code Formatter Plugin.  http://dunnhq.com --></div>
</p>

<p><em>Step 2: Map them <em>(only one side shown; the other is exactly the same)</em></em></p>

<p>
  <div style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px" id="scid:9D7513F9-C04C-4721-824A-2B34F0212519:3a93f648-8aa5-461d-a58a-3433600bf2f7" class="wlWriterEditableSmartContent"><pre style=" width: 681px; height: 210px;background-color:White;overflow: visible;;font-family:Consolas;font-size:12"><div><!--

Code highlighting produced by Actipro CodeHighlighter (freeware)
http://www.CodeHighlighter.com/

--><span style="color: #008080;"> 1</span> <span style="color: #0000FF;">&lt;</span><span style="color: #800000;">class </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;User&quot;</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">id </span><span style="color: #FF0000;">...</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">...</span><span style="color: #0000FF;">&lt;/</span><span style="color: #800000;">id</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">property </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;Name&quot;</span><span style="color: #FF0000;"> </span><span style="color: #0000FF;">/&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">bag </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;UserRoles&quot;</span><span style="color: #FF0000;"> access</span><span style="color: #0000FF;">=&quot;nosetter.pascalcase-underscore&quot;</span><span style="color: #FF0000;">
</span><span style="color: #008080;"> 5</span> <span style="color: #FF0000;">       inverse</span><span style="color: #0000FF;">=&quot;true&quot;</span><span style="color: #FF0000;"> cascade</span><span style="color: #0000FF;">=&quot;all,delete-orphan&quot;</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">key </span><span style="color: #FF0000;">column</span><span style="color: #0000FF;">=&quot;UserId&quot;</span><span style="color: #FF0000;"> on-delete</span><span style="color: #0000FF;">=&quot;cascade&quot;</span><span style="color: #FF0000;"> </span><span style="color: #0000FF;">/&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">one-to-many </span><span style="color: #FF0000;">class</span><span style="color: #0000FF;">=&quot;UserRole&quot;</span><span style="color: #FF0000;"> </span><span style="color: #0000FF;">/&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;/</span><span style="color: #800000;">bag</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;"></span><span style="color: #0000FF;">&lt;/</span><span style="color: #800000;">class</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;">10</span> <span style="color: #000000;"></span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">class </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;UserRole&quot;</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;">11</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">id </span><span style="color: #FF0000;">...</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">...</span><span style="color: #0000FF;">&lt;/</span><span style="color: #800000;">id</span><span style="color: #0000FF;">&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;">12</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">many-to-one </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;User&quot;</span><span style="color: #FF0000;"> </span><span style="color: #0000FF;">/&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;">13</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">many-to-one </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;Role&quot;</span><span style="color: #FF0000;"> </span><span style="color: #0000FF;">/&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;">14</span> <span style="color: #000000;">  </span><span style="color: #0000FF;">&lt;</span><span style="color: #800000;">property </span><span style="color: #FF0000;">name</span><span style="color: #0000FF;">=&quot;AssignedDate&quot;</span><span style="color: #FF0000;"> </span><span style="color: #0000FF;">/&gt;</span><span style="color: #000000;">
</span><span style="color: #008080;">15</span> <span style="color: #000000;"></span><span style="color: #0000FF;">&lt;/</span><span style="color: #800000;">class</span><span style="color: #0000FF;">&gt;</span></div></pre><!-- Code inserted with Steve Dunn's Windows Live Writer Code Formatter Plugin.  http://dunnhq.com --></div>
</p>

<p>&#160;</p>

<p>As far as NHibernate is concerned, that is all there is. Now let's make it usable.</p>

<p><em>Step 3: Add the projection and method (one side shown)</em></p>

<div style="padding-bottom: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; float: none; padding-top: 0px" id="scid:9D7513F9-C04C-4721-824A-2B34F0212519:7dd6a4f6-9f62-4131-9856-621ab09dfdfc" class="wlWriterEditableSmartContent"><pre style=" width: 640px; height: 401px;background-color:White;overflow: visible;;font-family:Consolas;font-size:12"><div><!--

Code highlighting produced by Actipro CodeHighlighter (freeware)
http://www.CodeHighlighter.com/

--><span style="color: #008080;"> 1</span> <span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">class</span><span style="color: #000000;"> User
</span><span style="color: #008080;"> 2</span> <span style="color: #000000;">{
</span><span style="color: #008080;"> 3</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> IEnumerable</span><span style="color: #000000;">&lt;</span><span style="color: #000000;">Role</span><span style="color: #000000;">&gt;</span><span style="color: #000000;"> Roles
</span><span style="color: #008080;"> 4</span> <span style="color: #000000;">    {
</span><span style="color: #008080;"> 5</span> <span style="color: #000000;">        </span><span style="color: #0000FF;">get</span><span style="color: #000000;"> { </span><span style="color: #0000FF;">return</span><span style="color: #000000;"> from ur </span><span style="color: #0000FF;">in</span><span style="color: #000000;"> UserRoles select ur.Role; }
</span><span style="color: #008080;"> 6</span> <span style="color: #000000;">    }
</span><span style="color: #008080;"> 7</span> <span style="color: #000000;">
</span><span style="color: #008080;"> 8</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> </span><span style="color: #0000FF;">void</span><span style="color: #000000;"> Add(Role role)
</span><span style="color: #008080;"> 9</span> <span style="color: #000000;">    {
</span><span style="color: #008080;">10</span> <span style="color: #000000;">        var userRole </span><span style="color: #000000;">=</span><span style="color: #000000;"> </span><span style="color: #0000FF;">new</span><span style="color: #000000;"> UserRole
</span><span style="color: #008080;">11</span> <span style="color: #000000;">            {
</span><span style="color: #008080;">12</span> <span style="color: #000000;">                User </span><span style="color: #000000;">=</span><span style="color: #000000;"> </span><span style="color: #0000FF;">this</span><span style="color: #000000;">,
</span><span style="color: #008080;">13</span> <span style="color: #000000;">                Role </span><span style="color: #000000;">=</span><span style="color: #000000;"> role,
</span><span style="color: #008080;">14</span> <span style="color: #000000;">                AssignedDate </span><span style="color: #000000;">=</span><span style="color: #000000;"> DateTime.Now
</span><span style="color: #008080;">15</span> <span style="color: #000000;">            };
</span><span style="color: #008080;">16</span> <span style="color: #000000;">        UserRoles.Add(userRole);
</span><span style="color: #008080;">17</span> <span style="color: #000000;">        role.UserRoles.Add(userRole);
</span><span style="color: #008080;">18</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">19</span> <span style="color: #000000;">
</span><span style="color: #008080;">20</span> <span style="color: #000000;">    </span><span style="color: #0000FF;">public</span><span style="color: #000000;"> </span><span style="color: #0000FF;">virtual</span><span style="color: #000000;"> </span><span style="color: #0000FF;">void</span><span style="color: #000000;"> Remove(Role role)
</span><span style="color: #008080;">21</span> <span style="color: #000000;">    {
</span><span style="color: #008080;">22</span> <span style="color: #000000;">        var userRole </span><span style="color: #000000;">=</span><span style="color: #000000;"> UserRoles.Single(r </span><span style="color: #000000;">=&gt;</span><span style="color: #000000;"> r.Role </span><span style="color: #000000;">==</span><span style="color: #000000;"> role);
</span><span style="color: #008080;">23</span> <span style="color: #000000;">        UserRoles.Remove(userRole);
</span><span style="color: #008080;">24</span> <span style="color: #000000;">        role.UserRoles.Remove(userRole);
</span><span style="color: #008080;">25</span> <span style="color: #000000;">    }
</span><span style="color: #008080;">26</span> <span style="color: #000000;">}</span></div></pre><!-- Code inserted with Steve Dunn's Windows Live Writer Code Formatter Plugin.  http://dunnhq.com --></div>

<p>Voilà! That's all you need to use it.</p>

<p>Note that I made the <strong>UserRoles</strong> collection <strong>protected internal</strong>. If you have code that actually needs to manipulate it, you can expose it.</p>

<p>One small catch: you can't use the <strong>Roles</strong> projection in queries, because NHibernate knows nothing about it. Still, this should be enough for the expected use cases.</p>
