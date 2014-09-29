---
layout: post
title: "NHibernate 2.1.0 : Executable queries"
date: 2009-05-13 05:00:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "NH2.1", "querying", "HQL"]
alias: ["/blogs/nhibernate/archive/2009/05/13/nhibernate-2-1-0-executable-queries.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>[<a href="http://fabiomaulo.blogspot.com/">My blog</a>]</p>
<p>I&rsquo;m proud to announce NH2.1.0 is passing all tests (same of H3.3.1) for bulk actions using HQL.</p>
<p>Some HQL examples:</p>
<p><span style="color: #800000">insert into Animal (description, bodyWeight, mother) select description, bodyWeight, mother from Human</span></p>
<p><span style="color: #800000">insert into Pickup (id, Vin, Owner) select id, Vin, Owner from Car</span></p>
<p><span style="color: #800000">insert into Animal (description, bodyWeight) select h.description, h.bodyWeight from Human h where h.mother.mother is not null</span></p>
<p><span style="color: #800000">update Human h set h.description = 'updated' where exists (select f.id from h.friends f where f.name.last = 'Public' )</span></p>
<p><span style="color: #800000">update versioned IntegerVersioned set name = :name</span></p>
<p><span style="color: #800000">update Human set name.first = :correction where id = :id</span></p>
<p><span style="color: #800000">update Animal a set a.mother = (from Animal where id = 1) where a.id = 2</span></p>
<p><span style="color: #800000">update Animal set description = :newDesc where description = :desc</span></p>
<p><span style="color: #800000">update Animal set bodyWeight = bodyWeight + :w1 + :w2</span></p>
<p><span style="color: #800000">delete SimpleEntityWithAssociation e where size(e.AssociatedEntities ) = 0 and e.Name like '%'</span></p>
<p><span style="color: #800000">delete Animal where mother is not null</span></p>
<p><span style="color: #800000">delete from EntityWithCrazyCompositeKey e where e.Id.Id = 1 and e.Id.OtherId = 2</span></p>
<p>To understand what that mean think about that all executable-queries are working with &lt;<span style="color: #800000">subclass</span>&gt;, &lt;<span style="color: #800000">joined-subclass</span>&gt;, &lt;<span style="color: #800000">subclass</span>&gt; + &lt;<span style="color: #800000">join</span>&gt;, &lt;<span style="color: #800000">union-subclass</span>&gt;, various POID generators, versioned entities ad son on.</p>
<p>For example using the mapping of <a href="http://fabiomaulo.blogspot.com/2009/05/oh-beautiful-sql.html">this post</a> executing this</p>
<pre class="code"><span style="color: #a31515">insert into Animal (description, bodyWeight) select h.description, h.bodyWeight from Human h where h.mother.mother is not null</span></pre>
<p>the SQL is</p>
<p><span style="font-family: courier new">insert&nbsp; <br />&nbsp;&nbsp;&nbsp; into 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Animal 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ( description, body_weight ) select 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; human0_2_.description as col_0_0_, 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; human0_2_.body_weight as col_1_0_&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; from 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Human human0_&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inner join 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Mammal human0_1_&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; on human0_.mammal=human0_1_.animal&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; inner join 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Animal human0_2_&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; on human0_.mammal=human0_2_.id, 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Animal animal1_&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; where 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; human0_2_.mother_id=animal1_.id&nbsp; <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; and ( 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; animal1_.mother_id is not null 
    <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; )</span></p>
<p>&hellip; stock&hellip; stumb&hellip; stumb&hellip; stumb&hellip; stack&hellip; sfrfrfrfrfrfr &hellip; (the sound of &ldquo;goriziana&rdquo;).</p>
