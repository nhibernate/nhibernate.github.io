---
layout: post
title: "Using NH3.2 mapping by code for Automatic Mapping"
date: 2011-09-05 07:24:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["mapping", "mapping by code"]
redirect_from: ["/blogs/nhibernate/archive/2011/09/05/using-nh3-2-mapping-by-code-for-automatic-mapping.aspx"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p>Note: this is a cross post <a href="http://www.felicepollano.com/2011/09/01/UsingNH32MappingByCodeForAutomaticMapping.aspx" target="_blank">from my own blog</a>.</p>
<p>Since version 3.2.0 <a href="http://nhforge.org" target="_blank">NHibernate</a>&nbsp; has an embedded strategy for mapping by code, that basically comes from <a href="http://fabiomaulo.blogspot.com/" target="_blank">Fabio Maulo</a>&rsquo;s <a href="http://code.google.com/p/codeconform/" target="_blank">ConfORM</a>. With some reading at <a href="http://fabiomaulo.blogspot.com/2011/04/nhibernate-32-mapping-by-code.html" target="_blank">this</a> Fabio post,&nbsp; <a href="http://fabiomaulo.blogspot.com/search?updated-max=2011-07-19T13%3A34%3A00-03%3A00&amp;max-results=3" target="_blank">this other one</a>, <a href="http://fabiomaulo.blogspot.com/2011/07/nhibernate-playing-with-mapping-by-code.html" target="_blank">and this one too</a>, I wrote my own sample just to see what we can do.</p>
<p>Even if we can use mapping by code to map class by class the entire model, something more interesting can be done by writing some convention-based automatic mapper, that can help us even when we face legacy ( non code first ) databases with some (perverted) naming convention. </p>
<p>We have to consider first the <b><i>ModelMapper</i></b> class, this class in the NH mapping by code is the one responsible for driving the mapping generator. It provides a suite of events to intercept the actual generation of each elements in the mapping. By listening these event we can decorate the detail of the single element, for example the Id generator class, the SqlType, the <i>column name</i>, and so on. ModelMapper uses a <b><i>ModelInspector </i></b>to<b><i> </i></b>get the way we want to map each portion of the entity ( properties, many-to-one, collections ), or if we have a component, or a subclass and so on. We realize our AutoMapper class by deriving a ModelMapper and internally subscribing some events, and passing to it a custom ModelInspector ( we named it AutoModelInspector ).</p>
<p>Let&rsquo;s start with a very basic model:</p>
<p> <img src="http://www.felicepollano.com/public/WindowsLiveWriter/UsingN.2mappingbycodeforAutomaticMapping_D407/ultra%20simple%20model_thumb.png" /></p>
<p>&nbsp;</p>
<p>Basically an entity that unidirectionally associates with a referred one. Let&rsquo;s say we have these example database conventions:</p>
<ul>
<li>Identifier column are named <b>&ldquo;c&rdquo;+EntityName+&rdquo;Id&rdquo;</b> and are <b>autoincrement</b> </li>
<li>Column description are named <b>&ldquo;txt&rdquo;+EntityName+&rdquo;Descr&rdquo;</b> </li>
<li>Column of type string have to be prefixed with <b>&ldquo;txt&rdquo;</b> </li>
<li>Column of type string have to be <b>AnsiString</b> ( for DDL generation of CHAR instead of NChar ) </li>
<li>Foreign key column have to be called<b> &ldquo;c&rdquo;+ForeignEntityName+&rdquo;Id&rdquo;</b> </li>
</ul>
<p>So let&rsquo;s see how we wrote the custom model mapper:</p>
<pre class="code"><span style="color: blue">class </span><span style="color: #2b91af">AutoMapper</span>:<span style="color: #2b91af">ModelMapper
    </span>{
        <span style="color: blue">public </span>AutoMapper()
            : <span style="color: blue">base</span>(<span style="color: blue">new </span><span style="color: #2b91af">AutoModelInspector</span>())
        {
            <span style="color: green">//subscribe required ebvents for this simple strategy ...
            </span><span style="color: blue">this</span>.BeforeMapClass += <span style="color: blue">new </span>RootClassMappingHandler(AutoMapper_BeforeMapClass);
            <span style="color: blue">this</span>.BeforeMapProperty += <span style="color: blue">new </span>PropertyMappingHandler(AutoMapper_BeforeMapProperty);
            <span style="color: blue">this</span>.BeforeMapManyToOne += <span style="color: blue">new </span>ManyToOneMappingHandler(AutoMapper_BeforeMapManyToOne);
            <span style="color: green">//...
            //other events....
        </span>}
        
        <span style="color: blue">void </span>AutoMapper_BeforeMapManyToOne(IModelInspector modelInspector, <span style="color: #2b91af">PropertyPath </span>member, IManyToOneMapper propertyCustomizer)
        {
            <span style="color: green">//
            // name the column for many to one as
            // "c"+foreignEntityName+"id"
            //
            </span><span style="color: blue">var </span>pi = member.LocalMember <span style="color: blue">as </span><span style="color: #2b91af">PropertyInfo</span>;
            <span style="color: blue">if </span>(<span style="color: blue">null </span>!= pi)
            {
                propertyCustomizer.Column(k =&gt; k.Name(<span style="color: #a31515">"c"</span>+pi.PropertyType.Name+<span style="color: #a31515">"Id"</span>));
            }
        }

        <span style="color: blue">void </span>AutoMapper_BeforeMapProperty(IModelInspector modelInspector, <span style="color: #2b91af">PropertyPath </span>member, IPropertyMapper propertyCustomizer)
        {
            <span style="color: green">//
            // Treat description as a special case: "txt"+EntityName+"Descr"
            // but for all property of type string prefix with "txt"
            //
            </span><span style="color: blue">if </span>(member.LocalMember.Name == <span style="color: #a31515">"Description"</span>)
            {
                propertyCustomizer.Column(k =&gt;
                    {
                        k.Name(<span style="color: #a31515">"txt" </span>+ member.GetContainerEntity(modelInspector).Name + <span style="color: #a31515">"Descr"</span>);
                        k.SqlType(<span style="color: #a31515">"AnsiString"</span>);
                    }
                    );
            }
            <span style="color: blue">else
            </span>{
                <span style="color: blue">var </span>pi = member.LocalMember <span style="color: blue">as </span><span style="color: #2b91af">PropertyInfo</span>;
                
                <span style="color: blue">if </span>(<span style="color: blue">null </span>!= pi &amp;&amp; pi.PropertyType == <span style="color: blue">typeof</span>(<span style="color: blue">string</span>))
                {
                    propertyCustomizer.Column(k =&gt;
                    {
                        k.Name(<span style="color: #a31515">"txt" </span>+ member.LocalMember.Name);
                        k.SqlType(<span style="color: #a31515">"AnsiString"</span>);
                    }
                   );
                }
            }
        }
       
        <span style="color: blue">void </span>AutoMapper_BeforeMapClass(IModelInspector modelInspector, <span style="color: #2b91af">Type </span>type, IClassAttributesMapper classCustomizer)
        {
            <span style="color: green">//
            // Create the column name as "c"+EntityName+"Id"
            //
            </span>classCustomizer.Id(k =&gt; { k.Generator(<span style="color: #2b91af">Generators</span>.Native); k.Column(<span style="color: #a31515">"c" </span>+ type.Name + <span style="color: #a31515">"Id"</span>); });
        }

        
    }</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>&nbsp;</p>
<p>The event handlers apply the convention we said before. As we see we pass a special model inspector in the constructor, that is implemented as below:</p>
<pre class="code"><span style="color: blue">class </span><span style="color: #2b91af">AutoModelInspector</span>:IModelInspector
    {
        <span style="color: blue">#region </span>IModelInspector Members

       
        <span style="color: blue">public </span>IEnumerable&lt;<span style="color: blue">string</span>&gt; GetPropertiesSplits(<span style="color: #2b91af">Type </span>type)
        {
            <span style="color: blue">return new string</span>[0];
        }

        <span style="color: blue">public bool </span>IsAny(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return false</span>;
        }

        
        <span style="color: blue">public bool </span>IsComponent(<span style="color: #2b91af">Type </span>type)
        {
            <span style="color: blue">return false</span>;
        }

       
        <span style="color: blue">public bool </span>IsEntity(<span style="color: #2b91af">Type </span>type)
        {
            <span style="color: blue">return true</span>;
        }

       
        
        <span style="color: blue">public bool </span>IsManyToOne(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: green">//property referring other entity is considered many-to-ones...
            </span><span style="color: blue">var </span>pi = member <span style="color: blue">as </span><span style="color: #2b91af">PropertyInfo</span>;
            <span style="color: blue">if </span>(<span style="color: blue">null </span>!= pi)
            {
                <span style="color: blue">return </span>pi.PropertyType.FullName.IndexOf(<span style="color: #a31515">"MappingByCode"</span>) != -1;
            }
            <span style="color: blue">return false</span>;
        }

        <span style="color: blue">public bool </span>IsMemberOfComposedId(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return false</span>;
        }

        <span style="color: blue">public bool </span>IsMemberOfNaturalId(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return false</span>;
        }

      
        <span style="color: blue">public bool </span>IsPersistentId(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return </span>member.Name == <span style="color: #a31515">"Id"</span>;
        }

        <span style="color: blue">public bool </span>IsPersistentProperty(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return </span>member.Name != <span style="color: #a31515">"Id"</span>;
        }

        <span style="color: blue">public bool </span>IsProperty(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">if </span>(member.Name != <span style="color: #a31515">"Id"</span>) <span style="color: green">// property named id have to be mapped as keys...
            </span>{
                <span style="color: blue">var </span>pi = member <span style="color: blue">as </span><span style="color: #2b91af">PropertyInfo</span>;
                <span style="color: blue">if </span>(<span style="color: blue">null </span>!= pi)
                {
                    <span style="color: green">// just simple stading that if a property is an entity we have 
                    // a many-to-one relation type, so property is false
                    </span><span style="color: blue">if </span>(pi.PropertyType.FullName.IndexOf(<span style="color: #a31515">"MappingByCode"</span>) == -1)
                        <span style="color: blue">return true</span>;
                }

            }
            <span style="color: blue">return false</span>;
                
        }

        <span style="color: blue">public bool </span>IsRootEntity(<span style="color: #2b91af">Type </span>type)
        {
            <span style="color: blue">return </span>type.BaseType == <span style="color: blue">typeof</span>(<span style="color: blue">object</span>);
        }

       
        
        <span style="color: blue">public bool </span>IsTablePerClassSplit(<span style="color: #2b91af">Type </span>type, <span style="color: blue">object </span>splitGroupId, System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return false</span>;
        }

       
        <span style="color: blue">public bool </span>IsVersion(System.Reflection.<span style="color: #2b91af">MemberInfo </span>member)
        {
            <span style="color: blue">return false</span>;
        }

        <span style="color: blue">#endregion
    </span>}</pre>
<p>
<a href="http://11011.net/software/vspaste"></a></p>
<p>&nbsp;</p>
<p>As we say there is a bounch of <b>IsXXXXX</b> function, that are called for each portion of the class in order to know what to do with it. Our implementation is absolutely incomplete ( not implemented function omitted ), but it feet the simple requirement we stated. Then we can see how we actually realize the mapping:</p>
<pre class="code"><span style="color: blue">static void </span>Main(<span style="color: blue">string</span>[] args)
       {
           <span style="color: #2b91af">AutoMapper </span>mapper = <span style="color: blue">new </span><span style="color: #2b91af">AutoMapper</span>();
          
           <span style="color: green">//this line simple rely on the fact
           //all and just the entities are exported...
           </span><span style="color: blue">var </span>map = mapper.CompileMappingFor(<span style="color: #2b91af">Assembly</span>.GetExecutingAssembly().GetExportedTypes());

           <span style="color: green">//dump the mapping on the console
           </span><span style="color: #2b91af">XmlSerializer </span>ser = <span style="color: blue">new </span><span style="color: #2b91af">XmlSerializer</span>(map.GetType());
           ser.Serialize(<span style="color: #2b91af">Console</span>.Out, map);
       }</pre>
<p>Simple, isn&rsquo;t ?</p>
<p>The resulting map, as dumped on the console is:</p>
<p>
<img src="http://www.felicepollano.com/public/WindowsLiveWriter/UsingN.2mappingbycodeforAutomaticMapping_D407/image_thumb.png" /></p>
<p>&nbsp;</p>
<p>That fulfill the actually simple requirements. So is just a matter of recognize the convention and the exceptions, and let&rsquo;s go auto-mapping!</p>
