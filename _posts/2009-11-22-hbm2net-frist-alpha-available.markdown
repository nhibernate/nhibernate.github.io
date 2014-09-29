---
layout: post
title: "hbm2net: first alpha ready"
date: 2009-11-22 22:43:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["hbm2net", "T4"]
alias: ["/blogs/nhibernate/archive/2009/11/22/hbm2net-frist-alpha-available.aspx"]
author: felicepollano
gravatar: bf8ff77ca000b80a2b19d07dbb257645
---
{% include imported_disclaimer.html %}
<p>I've just published a first drop of an hbm2net modified version to enable T4.<br />&nbsp;<br />You can find it <a href="/media/p/546.aspx">here</a> or <a href="https://sourceforge.net/projects/nhcontrib/files/NHibernate.Hbm2Net/hbm2net.zip/download">here</a>.<br /><br />Hbm2net is useful in generating the classes dto views or whatever you want starting from the hbm files.<br />The presented version supports code generation via T4, so you can use the same renderer with different templates to produce different codes artefacts.<br />To try it, please do the follow:</p>
<p>&nbsp;</p>
<ul>
<li>Unzip the file in a folder ( you will probably put that folder in your path variable to launch it from everywhere )</li>
<li>Launch<b> hbm2net --config:t4config.xml apple.hbm.xml</b></li>
</ul>
<p><br />You should see a directory named generated with the generated code.<br />Then you can start to play with the T4 file <b>hbm2net.tt</b> to do modification on it and see what happen, or adding additional generation<br />steps in t4config.xml:<br /><br /><br />&lt;?xml version="1.0" encoding="utf-8"?&gt;<br />&lt;codegen&gt;<br />&nbsp; &lt;generate renderer="NHibernate.Tool.hbm2net.T4.T4Render, NHibernate.Tool.hbm2net.T4" package=""&gt;<br />&nbsp;&nbsp;&nbsp; &lt;param name="template"&gt;~\hbm2net.tt&lt;/param&gt;<br />&nbsp;&nbsp;&nbsp; &lt;param name="output"&gt;clazz.GeneratedName+".generated.cs"&lt;/param&gt;<br />&nbsp; &lt;/generate&gt;<br /><br />&nbsp;&nbsp;&nbsp; .<b><i>.. add additional generate elements with different templates here</i></b>.<br /><br />&lt;/codegen&gt;<br /><br />Try it with your mapping files, but remember that the code generation process cannot guess types from classes, so<br />you will probably need to add the class attribute to some&nbsp; &lt;many-to-one/&gt; to specify<br />the type of the associations. The console message should WARN if some of this occour. Code generation<br />generally proceed anyway, but you wll find some missing fields in these cases.<br /><br />Next version will probably brea some things and became more friendly.<br /><br />Enjoy and let me know opinion/suggestions.</p>
