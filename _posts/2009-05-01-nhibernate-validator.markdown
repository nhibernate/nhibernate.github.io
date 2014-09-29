---
layout: post
title: "NHibernate Validator"
date: 2009-05-01 08:28:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["validation", "Validator"]
alias: ["/blogs/nhibernate/archive/2009/05/01/nhibernate-validator.aspx"]
---
<!-- more -->
{% include imported_disclaimer.html %}
<p>Validation is one of those things that goes hand in hand with data access. I guess it is not much of surprise that one of the contrib projects for NHibernate is extensive validation support.</p>  <p>True, there are about as many validation frameworks as there are ToDo applications, but NHibernate Validator bring something special to the table, it brings tight integration with NHibernate itself and:</p>  <blockquote>   <p>“…multi-layered data validation, where constraints are expressed in a single place and checked in various different layers of the application.”</p> </blockquote>  <p>I am sorry, I just love this quote. :-)</p>  <p>Anyway, let me jump right it and show you what I mean by that.</p>  <p>We can initialize the validation framework using <a href="http://nhforge.org/wikis/validator/nhibernate-validator-1-0-0-documentation.aspx">several ways</a>, but probably the easier would be:</p>  <blockquote>   <pre>var configuration = <span style="color: #0000ff">new</span> Configuration()
	.Configure(&quot;<span style="color: #8b0000">hibernate.cfg.xml</span>&quot;);

var engine = <span style="color: #0000ff">new</span> ValidatorEngine();
engine.Configure(<span style="color: #0000ff">new</span> NHVConfigurationBase());

ValidatorInitializer.Initialize(configuration, engine);</pre>
</blockquote>

<p>And now, all we need to do is set the validation attributes on our the entities, and we are done:</p>

<blockquote>
  <pre>[NotNullNotEmpty]
[Length(25)]
<span style="color: #0000ff">public</span> <span style="color: #0000ff">virtual</span> <span style="color: #0000ff">string</span> Title</pre>
</blockquote>

<p>At this point, several very interesting things are going to happen. First, if we ask NHibernate to generate the schema for us we are going to get the following:</p>

<table cellspacing="0" cellpadding="2" width="400" border="0"><tbody>
    <tr>
      <td valign="top" width="200">Before using NHV</td>

      <td valign="top" width="200">After using NHV</td>
    </tr>

    <tr>
      <td valign="top" width="200">
        <pre><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=create&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">create</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=table&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">table</a> Blogs (
  Id <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=INT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">INT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=IDENTITY&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">IDENTITY</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NOT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">NOT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NULL&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">NULL</a>,
   <strong>Title </strong><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NVARCHAR&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99"><strong>NVARCHAR</strong></a><strong>(255) </strong><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99"><strong>null</strong></a><strong>,</strong>
   Subtitle <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NVARCHAR&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">NVARCHAR</a>(255) <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">null</a>,
   AllowsComments <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=BIT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">BIT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">null</a>,
   CreatedAt <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=DATETIME&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">DATETIME</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">null</a>,
   <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=primary&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">primary</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=key&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">key</a> (Id)
)</pre>
      </td>

      <td valign="top" width="200">
        <pre><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=create&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">create</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=table&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">table</a> Blogs (
   Id <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=INT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">INT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=IDENTITY&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">IDENTITY</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NOT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">NOT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NULL&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">NULL</a>,
   <strong>Title </strong><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NVARCHAR&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99"><strong>NVARCHAR</strong></a><strong>(25) </strong><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=not&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99"><strong>not</strong></a><strong> </strong><a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99"><strong>null</strong></a><strong>,</strong>
   Subtitle <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=NVARCHAR&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">NVARCHAR</a>(255) <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">null</a>,
   AllowsComments <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=BIT&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">BIT</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">null</a>,
   CreatedAt <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=DATETIME&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">DATETIME</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=null&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">null</a>,
   <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=primary&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">primary</a> <a style="color: #0000ff" href="http://search.microsoft.com/default.asp?so=RECCNT&amp;siteid=us%2Fdev&amp;p=1&amp;nq=NEW&amp;qu=key&amp;IntlSearch=&amp;boolean=PHRASE&amp;ig=01&amp;i=09&amp;i=99">key</a> (Id)
)</pre>
      </td>
    </tr>
  </tbody></table>

<p>Note the title column, where before we used the default values (null and 255) we are now using the values defined in the validation scheme. That is what we mean when we say that we can get pretty multi layered data validation.</p>

<p>That is not the end of it, however, NHibernate Validator is hooking up into the NHibernate engine, and if we tried to save the following, we will get a validation exception:</p>

<blockquote>
  <pre>s.Save(<span style="color: #0000ff">new</span> Blog
{
	Title = <span style="color: #0000ff">new</span> <span style="color: #0000ff">string</span>('*',255),
});</pre>
</blockquote>

<p>And, obviously, we support a way to extract all the validation errors from the entity:</p>

<blockquote>
  <pre>var invalidValues = engine.Validate(blog);
<span style="color: #0000ff">foreach</span> (var invalidValue <span style="color: #0000ff">in</span> invalidValues)
{
	Console.WriteLine(
        &quot;<span style="color: #8b0000">{0}: {1}</span>&quot;,
		invalidValue.PropertyName, 
		invalidValue.Message);
}</pre>
</blockquote>

<p>NHibernate Validator also support all the other things that you would expect from validation frameworks, the ability to create your own constraints (including the ability to embed them in the database schema!), i18n, XML only configuration, if you want to keep your entities clear of attributes, etc.</p>

<p>This has been truly just a tidbit, to whet your appetite. </p>

<p>You can learn more about NH Validator <a href="http://nhforge.org/wikis/validator/nhibernate-validator-1-0-0-documentation.aspx">here</a>.</p>
