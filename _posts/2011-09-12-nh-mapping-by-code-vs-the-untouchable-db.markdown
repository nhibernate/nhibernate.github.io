---
layout: post
title: "NH Mapping by code VS the Untouchable DB"
date: 2011-09-12 08:30:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "mapping by code"]
redirect_from: ["/blogs/nhibernate/archive/2011/09/12/nh-mapping-by-code-vs-the-untouchable-db.aspx/"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p>Note: this is a cross post <a href="http://www.felicepollano.com/2011/09/09/NHMappingByCodeVSTheUntouchableDB.aspx">from my own blog</a>.</p>
<p>This post is an exercise, similar to <a href="/blogs/nhibernate/archive/2011/09/05/automatic-mapping-pluralize-table-names.aspx" target="_blank">this</a> and <a href="http://www.felicepollano.com/2011/09/01/UsingNH32MappingByCodeForAutomaticMapping.aspx">this</a> previous posts about using <a href="http://nhforge.org" target="_blank">NHibernate</a>&nbsp; mapping by code new features present form version 3.2. The source inspiring it is an <a href="http://ayende.com/blog/4695/nhibernate-complex-relationships" target="_blank">old post form</a> <a href="http://ayende.com/blog/" target="_blank">Ayende</a>, showing a non trivial requirement to map.</p>
<p>Here the DB model:</p>
<p> <img src="/images/posts/2011/09/12/image_2.png" /></p>
<p>And the wanted object model:</p>
<p> <img src="/images/posts/2011/09/12/image_4.png" /></p>
<p>So there is a lot of <a href="http://ayende.com/blog/4695/nhibernate-complex-relationships#comments" target="_blank">comments</a> about DB refactoring needing, or on needing to have the linking entity as a visible entity in the model, but:</p>
<ul>
<li>I like the idea of collapsing the linking entity. </li>
<li>I suppose that the DB is untouchable, as frequently happens. </li>
</ul>
<p>Ayende solves the trouble by the &lt;join/&gt; mapping having an entity spawning two tables, so Address will be represented by joining the Table Address and PeopleAddress.</p>
<p>This can be done very easily in Mapping by code too, lets see how:</p>
<p>&nbsp;</p>
<pre class="code"><span style="color: #2b91af">ModelMapper </span>mapper = <span style="color: blue">new </span><span style="color: #2b91af">ModelMapper</span>();
            mapper.Class&lt;<span style="color: #2b91af">Person</span>&gt;(m =&gt;
                {
                    m.Id(k =&gt; k.Id,g=&gt;g.Generator(<span style="color: #2b91af">Generators</span>.Native));
                    m.Table(<span style="color: #a31515">"People"</span>);
                    m.Property(k =&gt; k.Name);
                    m.Bag(k =&gt; k.Addresses, t =&gt; 
                            { 
                                t.Table(<span style="color: #a31515">"PeopleAddresses"</span>);
                                t.Key(c=&gt;c.Column(<span style="color: #a31515">"PersonId"</span>));
                                t.Inverse(<span style="color: blue">true</span>);
                                
                            }
                         ,rel=&gt;rel.ManyToMany(many=&gt;many.Column(<span style="color: #a31515">"AddressId"</span>))
                        );
                }

                );

            mapper.Class&lt;<span style="color: #2b91af">Address</span>&gt;(m =&gt;
                {
                    m.Id(k =&gt; k.Id, g =&gt; g.Generator(<span style="color: #2b91af">Generators</span>.Native));
                    m.Table(<span style="color: #a31515">"Addresses"</span>);
                    m.Property(p =&gt; p.City);

                     m.Join(<span style="color: #a31515;">"PeopleAddresses"</span>, z =&gt; <br />                    { <br />                      z.Property(p =&gt; p.IsDefault); <br />                      z.Property(p =&gt; p.ValidFrom);<br />                      z.Property(p =&gt; p.ValidTo);<br />                      z.Key(k =&gt; k.Column(<span style="color: #a31515;">"PersonId"</span>)); <br />                    });      
                }
                );</pre>
<p>That yield&nbsp; the following mapping:</p>
<pre class="code"><span style="color: blue">&lt;?</span><span style="color: #a31515">xml </span><span style="color: red">version</span><span style="color: blue">=</span>"<span style="color: blue">1.0</span>" <span style="color: red">encoding</span><span style="color: blue">=</span>"<span style="color: blue">utf-16</span>"<span style="color: blue">?&gt;
&lt;</span><span style="color: #a31515">hibernate-mapping </span><span style="color: red">xmlns:xsi</span><span style="color: blue">=</span>"<span style="color: blue">http://www.w3.org/2001/XMLSchema-instance</span>" <span style="color: red">xmlns:xsd</span><span style="color: blue">=</span>"<span style="color: blue">http://www.w3.org/2001/XMLSchema</span>" <span style="color: red">namespace</span><span style="color: blue">=</span>"<span style="color: blue">TestMappingByCode</span>" <span style="color: red">assembly</span><span style="color: blue">=</span>"<span style="color: blue">TestMappingByCode</span>" <span style="color: red">xmlns</span><span style="color: blue">=</span>"<span style="color: blue">urn:nhibernate-mapping-2.2</span>"<span style="color: blue">&gt;
  &lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Person</span>" <span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">People</span>"<span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">id </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Id</span>" <span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">Int32</span>"<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">native</span>" <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Name</span>" <span style="color: blue">/&gt;
    &lt;</span><span style="color: #a31515">bag </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Addresses</span>" <span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">PeopleAddresses</span>" <span style="color: red">inverse</span><span style="color: blue">=</span>"<span style="color: blue">true</span>"<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">key </span><span style="color: red">column</span><span style="color: blue">=</span>"<span style="color: blue">PersonId</span>" <span style="color: blue">/&gt;
      &lt;</span><span style="color: #a31515">many-to-many </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">Address</span>" <span style="color: red">column</span><span style="color: blue">=</span>"<span style="color: blue">AddressId</span>" <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">bag</span><span style="color: blue">&gt;
  &lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;
  &lt;</span><span style="color: #a31515">class </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Address</span>" <span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">Addresses</span>"<span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">id </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">Id</span>" <span style="color: red">type</span><span style="color: blue">=</span>"<span style="color: blue">Int32</span>"<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">generator </span><span style="color: red">class</span><span style="color: blue">=</span>"<span style="color: blue">native</span>" <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">id</span><span style="color: blue">&gt;
    &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">City</span>" <span style="color: blue">/&gt;
    &lt;</span><span style="color: #a31515">join </span><span style="color: red">table</span><span style="color: blue">=</span>"<span style="color: blue">PeopleAddresses</span>"<span style="color: blue">&gt;
      &lt;</span><span style="color: #a31515">key </span><span style="color: red">column</span><span style="color: blue">=</span>"<span style="color: blue">PersonId</span>" <span style="color: blue">/&gt;
      &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">IsDefault</span>" <span style="color: blue">/&gt;
      &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">ValidFrom</span>" <span style="color: blue">/&gt;
      &lt;</span><span style="color: #a31515">property </span><span style="color: red">name</span><span style="color: blue">=</span>"<span style="color: blue">ValidTo</span>" <span style="color: blue">/&gt;
    &lt;/</span><span style="color: #a31515">join</span><span style="color: blue">&gt;
  &lt;/</span><span style="color: #a31515">class</span><span style="color: blue">&gt;
&lt;/</span><span style="color: #a31515">hibernate-mapping</span><span style="color: blue">&gt;
</span></pre>
<p>&nbsp;</p>
<p>Exactly the ones that Ayende proposed. As you can see is pretty straightforward map even a not so common situation.</p>
