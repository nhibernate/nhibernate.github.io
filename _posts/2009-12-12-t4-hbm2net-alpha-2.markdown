---
layout: post
title: "T4 hbm2net alpha 2"
date: 2009-12-12 22:12:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["hbm2net", "T4"]
redirect_from: ["/blogs/nhibernate/archive/2009/12/12/t4-hbm2net-alpha-2.aspx/", "/blogs/nhibernate/archive/2009/12/12/t4-hbm2net-alpha-2.html"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}

<p>You can download from <a href="/media/p/546.aspx">here</a> a new version of the hbm2net T4 enabled. This version has a better command line parsing/error handling, and the configuration file to provide ( optionally ) is validate in order to report some meaningful error messages when needed. The utility is still command line, I suggest to use as a pre-build step in Visual Studio&nbsp; to generate your entities, or other code artifacts you need.</p>
<p>Unzip the files in a folder, and launch hbm2net:</p>
<p><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s1" alt="s1" src="/images/posts/2009/12/12/s1.png" width="589" border="0" height="263" /> </p>
<p>As you can see, the configuration file is now optional. If omitted, the default internal template is used, that will generate the code artifacts for the entities. You can specify an output directory for the files ( if omitted will be the current directory ) and a flag, &ndash;ct, to avoid generating files if target files are newer than sources. This is to suppress the reload message box in Visual Studio every time you compile if you forget an entity file opened. Then you can specify hbm files, with wildcards too. So, the simplest command line to generate mappings is:</p>
<p><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s2" alt="s2" src="/images/posts/2009/12/12/s2.png" width="590" border="0" height="137" /></p>
<p>If you want to use more generation step, you need to edit the configuration file, and inform hbm2net:</p>
<p><b>hbm2net &ndash;config:myconfig.xml *.hbm.xml</b></p>
<p>the configuration file is in the following format:</p>
<p><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s3" alt="s3" src="/images/posts/2009/12/12/s3.png" width="598" border="0" height="116" /></p>
<p>The generator nodes can be multiple: each different generator can point to a different template in order to produce different code artifacts.The second parameter, <b>output</b>, is the file name you will generate. This is parsed internally by the T4 engine itself, so you can play your strategy in combining the file name having the <b>clazz</b> object, an instance of <b>ClassMapping</b> representing the current <b>hbm</b> fragment. The presented parameter produces a file called <b><i>&lt;classname&gt;.generated.cs</i></b>, and is the default behavior. Please note the template is specified as <b>res://xxxx</b>: this means to lookup the template internally. You can specify a template with a regular path as well, plus, you can use <b>~</b>/xxx/yyy/mytemplate.tt to specify a path relative to the location where hbm2net is. A copy of <b>hbm2net.tt</b> is included in the zip however, so you can use as a starting point to create your generators.</p>
<h5>Some notes about T4.</h5>
<p>You will find the entire bible on that argument by starting <a href="http://msdn.microsoft.com/en-us/library/bb126468.aspx">here</a> or <a href="http://www.olegsych.com/">here</a>. I will show a snapshot of the hbm2net.tt of the current version:</p>
<p><img style="border-right-width: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px" title="s4" alt="s4" src="/images/posts/2009/12/12/s4.png" width="548" border="0" height="267" /></p>
<p>So, as you can see, very similar to the old asp stuff, not so different from NVelocity. The basic difference from other such engine is that we have reachable from inside the template any .NET type we can need. Furthermore, we can organize our generation with helpers by using the &lt;#+ #&gt; tags. Whit these tags we create a method inside the transformation class usable by the template itself. As an example, the <b>&lt;#=GetCommentForClass(clazz,1).TrimEnd()#&gt;</b> line call an helper function. In this case the body of this function is contained in the <a title="res://NHibernate.Tool.hbm2net.templates.common.tt" href="res://NHibernate.Tool.hbm2net.templates.common.tt"><b>res://NHibernate.Tool.hbm2net.templates.common.tt</b></a> file, but can be inlined with the template itself. Currently an object of type <b>ClassMapping</b> ( an internal hbm2net object used to represent a mapping fragment ) is passed to the template, as the field <b>clazz</b>. Sorry for the strange naming convention, I left something from the&nbsp; old original version, this maybe will change in future drops.</p>
