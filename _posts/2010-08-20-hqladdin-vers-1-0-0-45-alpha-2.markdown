---
layout: post
title: "HqlAddin vers. 1.0.0.45 - Alpha 2"
date: 2010-08-20 00:41:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["HQL"]
redirect_from: ["/blogs/nhibernate/archive/2010/08/19/hqladdin-vers-1-0-0-45-alpha-2.aspx"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>Today I have released a new version of the HqlAddin project, the version is 1.0.0.<strike>45</strike>50 – Alpha 2 (a.k.a. Green Popotito). </p>  <p>Green Popotito comes with a new amazing feature, intellisense for properties and entities. This is a great work that comes from <a href="http://sourceforge.net/projects/faticalabshqled/">Felice Pollano’s NhWorkbench</a>, so kudos for him.</p>  <p>Before we continue, let me show you a short screencast of the tool; follow this <a href="http://www.screencast.com/users/JoseFR/folders/Jing/media/3817f5a4-093d-4a46-a94d-bf65b30fc51c" target="_blank">link</a>.</p>  <p><strong>How does this work?</strong></p>  <p>You have to export (with MEF) your configuration in any assembly, <strike>hql addin will look the output path of the startup project and if it find an <u>export</u> will import the information to give you intellisense.</strike> <strong><u>Just write an export on any project, the build path can be anywhere.</u></strong> Follows the instructions <a href="http://hqladdin.codeplex.com/wikipage?title=HowToAdvanceIntellisense">here</a>.</p>  <p>Any configuration of any version of NHibernate is ok. In order to update your intellisense (e.g. when you change your mappings) you will have to rebuild the solution ctrl + shift + b.</p>  <p></p>  <h3>How to use the hql files?</h3>  <p>You can read the full guide <a href="http://hqladdin.codeplex.com/wikipage?title=HowToHqlFiles&amp;referringTitle=Documentation">here</a>.</p>  <h3>Where do I get this?</h3>  <p>You can download from the <a href="http://hqladdin.codeplex.com/">main website</a> or simply from the Visual Studio Online Gallery of your Extension Manager. Read more <a href="http://hqladdin.codeplex.com/wikipage?title=Installation&amp;referringTitle=Documentation">here</a>.</p>  <h3></h3>  <h3>Provide feedback is mandatory</h3>  <p>Please get involved with the project, provide some feedback, thoughts, issues or anything!</p>
