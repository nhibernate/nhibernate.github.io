---
layout: post
title: "How-To: Using the N* Stack, part 2"
date: 2009-08-11 20:21:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "poid", "ASP.NET MVC"]
redirect_from: ["/blogs/nhibernate/archive/2009/08/11/how-to-using-the-n-stack-part-2.aspx"]
author: Jason Dentler
gravatar: 2aaf05c5e05389c501b4fd7451abecdb
---
{% include imported_disclaimer.html %}
<p>&nbsp;</p>
<div>
<p>Last Saturday, I posted the&nbsp;<a target="_blank" href="http://jasondentler.com/blog/2009/08/how-to-using-the-n-stack-part-1/">first part in a series</a>&nbsp;about building an&nbsp;<a target="_blank" href="http://www.asp.net/mvc/">ASP.NET MVC</a>&nbsp;application from the ground up using&nbsp;<a target="_blank" href="http://sourceforge.net/projects/nhibernate/">NHibernate</a>&nbsp;and&nbsp;<a target="_blank" href="http://ninject.org/">Ninject</a>. It dealt with setting up the structure of your solution and referencing some 3rd party assemblies.</p>
<p>In part 2, we&rsquo;re going to set up the persistence object model. The persistence object model is a set of objects that we use to persist (save) data to the database.</p>
<p><strong>Warning:</strong>&nbsp;This is a sample application. There are widely varying opinions on the correct structure for these types of applications. As with most advanced subjects in the ALT.NET space,&nbsp;<a target="_blank" href="http://ayende.com/Blog/Default.aspx">Ayende</a>&nbsp;has&nbsp;<a target="_blank" href="http://ayende.com/Blog/archive/2009/08/02/your-domain-model-isnrsquot-in-the-entity-relationship-diagram.aspx">some great information</a>&nbsp;on the difference between a persistence object model and a domain model. For the purposes of this series, they&rsquo;re the same thing.</p>
<p>First, we build the structure of our persistence model as plain old CLR objects (POCO). I like to do this in the Visual Studio class designer. It helps keep me focused on the high-level entities and relationships instead of wandering off to do detailed implementation code.</p>
<p>Here&rsquo;s the model we&rsquo;ll start with:</p>
<p><a href="http://jasondentler.com/blog/wp-content/uploads/2009/08/image6.png"><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" height="610" width="528" alt="image" border="0" src="http://jasondentler.com/blog/wp-content/uploads/2009/08/image_thumb6.png" title="image" /></a></p>
<p>Let&rsquo;s look at the relationships between courses and sections. We have a one to many relationship from a Course to it&rsquo;s Sections represented by an ICollection(Of Section) property in Course. We also have a many-to-one relationship from each section back to it&rsquo;s Course represented by the Course property on Section.</p>
<pre class="brush:vbnet">Public Class Course

    Public Property Sections() As ICollection(Of Section)
        Get

        End Get
        Set(ByVal value As ICollection(Of Section))

        End Set
    End Property

End Class

Public Class Section

    Public Property Course() As Course
        Get

        End Get
        Set(ByVal value As Course)

        End Set
    End Property

    'Other properties here...

End Class</pre>
<pre class="brush:csharp">public class Course
{

    public ICollection&lt;Section&gt; Sections {
        get { }

        set { }

    }

}

public class Section
{

    public Course Course {
        get { }

        set { }

    }

    //Other properties here...

}</pre>
<p>Now that we have all of that built, there&rsquo;s a couple of small requirements to use these classes with NHibernate.</p>
<ol>
<li>All properties and methods must be overridable. That&rsquo;s virtual for your C# folks.</li>
<li>Unless you&rsquo;re using a dependency injection bytecode provider, you need a parameter-less constructor. If you don&rsquo;t know what a bytecode provider is, don&rsquo;t worry about it. We&rsquo;ll get in to it later on in the series. If you don&rsquo;t have any constructors, you&rsquo;re fine. There&rsquo;s an implied parameterless constructor. As soon as you add a constructor with parameters, you&rsquo;ll need to create one without parameters, just for NHibernate.</li>
<li><span style="text-decoration: line-through;">You need some sort of identity property for your database primary key. This can be inherited from a base class, which is exactly what we&rsquo;re going to do.</span>&nbsp;Edit: Not true. Thanks for the correction Ayende!</li>
<li>In the case of readonly properties, you have some options. You can tell NHibernate your naming convention for backing fields. I don&rsquo;t like this. I prefer to make my properties read/write and make the setter protected. If you&rsquo;re new to NHibernate, you&rsquo;ve probably never seen this before.
<pre class="brush:vbnet">Public Class Course
    Inherits Entity

    Private m_Sections As ICollection(Of Section) = New HashSet(Of Section)

    Public Overridable Property Sections() As ICollection(Of Section)
        Get
            Return m_Sections
        End Get
        Protected Set(ByVal value As ICollection(Of Section))
            m_Sections = value
        End Set
    End Property

End Class</pre>
<pre class="brush:csharp">public class Course : Entity
{

    private ICollection&lt;Section&gt; m_Sections = new HashSet&lt;Section&gt;();

    public virtual ICollection&lt;Section&gt; Sections {
        get { return m_Sections; }
        protected set { m_Sections = value; }
    }

}</pre>
<p>This is how I set up all of my collection properties. You can manipulate the contents of the collection, but you can't replace it with another instance without inheriting this class and overriding the property. If you were to make this property readonly, you'd have to configure NHibernate to write to m_Sections using reflection. It's sort of a pain, and completely unnecessary. This is easier and accomplishes the same end result.</p>
<p>Also, notice that we're inheriting from a class called Entity. More on that later.</p>
</li>
</ol>
<p>Let's talk about the database for a minute. Each of these entity classes will eventually become a database table. What will you use for your primary keys?&nbsp;<a target="_blank" href="http://fabiomaulo.blogspot.com/2009/02/nh210-generators-behavior-explained.html">Fabio Maulo</a>&nbsp;has a great post on the different NHibernate primary key generators. He also has&nbsp;<a target="_blank" href="http://fabiomaulo.blogspot.com/2008/12/identity-never-ending-story.html">this post</a>&nbsp;about why identity columns probably are not the best choice.</p>
<p>So what&rsquo;s a good choice? Well, that&rsquo;s a matter of opinion. Thanks to NHibernate, I don&rsquo;t go spelunking through the database much anymore, so I like guids. You really can use what you like, or rather, what your DBA likes.</p>
<p>Now, where are you going to put these primary keys in your objects? In my opinion, this is really a persistence detail &ndash; meaning your objects shouldn&rsquo;t really be dealing with it. That&rsquo;s why we&rsquo;re going to keep it hidden away in the base class. Remember, we&rsquo;re inheriting from Entity.</p>
<pre class="brush:vbnet">Public MustInherit Class Entity

    Private m_ID As Guid

    Public Overridable Property ID() As Guid
        Get
            Return m_ID
        End Get
        Protected Set(ByVal value As Guid)
            m_ID = value
        End Set
    End Property

End Class</pre>
<pre class="brush:csharp">public abstract class Entity
{

    private Guid m_ID;

    public virtual Guid ID {
        get { return m_ID; }
        protected set { m_ID = value; }
    }

}</pre>
<p>That&rsquo;s it for today&rsquo;s post. In part 3, we&rsquo;ll configure NHibernate and set up our database. For homework, we&rsquo;re going to flesh out the other properties in our persistence model. Check out the source code in&nbsp;<a target="_blank" href="http://jasondentler.com/downloads/NStackExample.Part2.VBNET.zip">Visual Basic.NET</a>&nbsp;or&nbsp;<a target="_blank" href="http://jasondentler.com/downloads/NStackExample.Part2.CSHARP.zip">C#.</a></p>
<p>(Reposted from my <a href="http://jasondentler.com/blog">blog</a>)</p>
</div>
<p>&nbsp;</p>
