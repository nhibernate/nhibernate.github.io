---
layout: post
title: "Not So Hidden Gems of NHibernate – Formula Discriminators"
date: 2010-05-15 20:49:53 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
redirect_from: ["/blogs/nhibernate/archive/2010/05/15/not-so-hidden-gems-of-nhibernate-formula-discriminators.aspx/", "/blogs/nhibernate/archive/2010/05/15/not-so-hidden-gems-of-nhibernate-formula-discriminators.html"]
author: tehlike
gravatar: c9c2937ea2b0d5472a33a23b5df78814
---
{% include imported_disclaimer.html %}
<p>A friend of mine, <a href="http://www.cprieto.com/">Cristian Prieto</a>, told me that he didn’t know how to do mapping of some entities to (in his terms) an evil legacy database. </p>  <p>There were two entities: <strong>Advertiser </strong>and <strong>Affiliate. </strong>As I said, this was a crazy legacy database. Both shares the same table with only one difference: If an entity is <strong>Affiliate</strong>, then it’s <strong>affiliate_id </strong>column will have a value, otherwise, a non-empty <strong>advertiser_id</strong> means it’s an Advertiser. Both cannot be the same at the same time.</p>  <p>Having gone through <strong>NHibernate code</strong> a while ago, I remember being able to discriminate on an expression (or in NH terms: Formula). I wasn’t sure about it, but Cristian verified that there is such thing that exists, and you can use it for such thing.</p>  <p>Here is the description of <strong>formula discriminator </strong>from <a href="http://www.nhforge.org/doc/nh/en/index.html#mapping-declaration-discriminator">the documentation</a>.</p>  <pre class="brush: xml;">&lt;discriminator
        column=&quot;discriminator_column&quot;  
        type=&quot;discriminator_type&quot;      
        force=&quot;true|false&quot;             
        insert=&quot;true|false&quot;            
        formula=&quot;arbitrary SQL expression&quot;
/&gt;</pre>

<p><em><tt>formula</tt> (optional) <strong>an arbitrary SQL expression</strong> that is executed when a type has to be evaluated. Allows content-based discrimination</em></p>

<p>Bingo! “an arbitrary sql expression” is just what we wanted.</p>

<p>Going back to Cristian’s problem, we can now use this:</p>

<pre class="brush: xml;">&lt;discriminator 
        type=&quot;Int32&quot; 
        formula=&quot;(case when not affiliate_id is null then 0 else 1 end)&quot;
/&gt;</pre>
The rest is left as an exercise for the reader (I always wanted to say this!) 

