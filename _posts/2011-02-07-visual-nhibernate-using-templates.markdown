---
layout: post
title: "Visual NHibernate – Using Templates"
date: 2011-02-07 23:51:00 -0300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "generators", "visual nhibernate"]
alias: ["/blogs/nhibernate/archive/2011/02/08/visual-nhibernate-using-templates.aspx"]
author: gareth
gravatar: bf3577d9d1dfe9ef620b5326e5970091
---
{% include imported_disclaimer.html %}
<p><a target="_blank" href="http://www.slyce.com/VisualNHibernate/">Visual NHibernate</a> can be customized in many ways. Today we&rsquo;ll look at the built-in template engine. You can easily create the exact output you need by tweaking the built-in templates or creating new custom templates.</p>
<p>Visual NHibernate currently has two built-in templates: </p>
<ul>
<li>The standard NHibernate template </li>
<li>The new <a target="_blank" href="http://www.sharparchitecture.net/">Sharp Architecture</a> template. </li>
</ul>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/editor_5F00_09CDAF73.png"><img height="338" width="585" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/editor_5F00_thumb_5F00_1F877203.png" alt="editor" border="0" title="editor" style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" /></a></p>
<h4>Template Editor</h4>
<p>The template editor enables you to specify how the generated files and folders should be laid out in the destination folder, WYSIWYG style. Script can be written to generate dynamic files, while static files such as images and DLLs can also be included in the output.</p>
<p>The code editor has IntelliSense and syntax-highlighting, as well as live feedback about errors. Compile errors are underlined in red squiggly lines. They also appear in the errors grid and cause the title-bar to change color from green to red.</p>
<p>Find and replace can be accessed via the standard keyboard shortcuts (Ctrl+F, Ctrl+Shift+F, Ctrl+H, Ctrl+Shift+H).</p>
<h4>Laying out folders and files</h4>
<p>Add the first folder or file by right-clicking the &lsquo;Output Folder&rsquo; node in the treeview.</p>
<p>Folders and files can have iterators. You can generate either a single file, or generate one file or folder per Entity, Table, Column, Component or View. If you select an iterator then you will have access to the iterator in script via a lowercase name, such as entity.Name or table.Name.</p>
<p>File-names and folder-names can be dynamic and can contain script:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_3B68812E.png"><img height="118" width="347" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_7D8BE9B1.png" alt="image" border="0" title="image" style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" /></a></p>
<h5><em>Folders</em></h5>
<p>Add a folder by right-clicking on the parent folder.</p>
<h5><em>Dynamic files</em></h5>
<p>A dynamic file is one in which the body is created dynamically via script. Add a file by right-clicking on the parent folder.</p>
<h5><em>Static files</em></h5>
<p>A static file is one that is distributed as-is. It can be an image file, a readme file, a DLL etc.</p>
<p>Static files need to be added to the Resources collection. To do this, select the Resources tab on the left then click the Add button to select the file.</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_29C87096.png"><img height="207" width="360" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0EAFA188.png" alt="image" border="0" title="image" style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" /></a></p>
<h4>Scripting</h4>
<p>Dynamic files output text. Create dynamic content by using either ASP-style delimiters &lt;%...%&gt; or T4-style delimiters &lt;#...#&gt;.</p>
<p>Select the delimiter style towards the top right corner of the screen.</p>
<h5><em>Writing output</em></h5>
<p>Dynamic text can be inserted into the document in a number of ways:</p>
<ol>
<li>Mixing script and output text, similar to ASP </li>
<li>Placeholders: &lt;%=entity.Name%&gt; </li>
<li>Write(text) </li>
<li>WriteLine(text) </li>
<li>WriteFormat(formatText, args) </li>
<li>WriteIf(boolean expression, trueText) </li>
<li>WriteIf(boolean expression, trueText, falseText) </li>
</ol>
<h5><em>Skipping files</em></h5>
<p>A dynamic file can be skipped via script by setting SkipThisFile = true and returning the reason. For example:</p>
<blockquote>
<div>
<pre id="codeSnippet" style="text-align: left; line-height: 12pt; background-color: #f4f4f4; margin: 0em; width: 100%; font-family: 'Courier New', courier, monospace; direction: ltr; color: black; font-size: 8pt; overflow: visible; border-style: none; padding: 0px;"><span style="color: #0000ff">if</span> (!Project.Settings.UseFluentNHibernate)<br />{<br />    SkipThisFile = <span style="color: #0000ff">true</span>;<br />    <span style="color: #0000ff">return</span> &ldquo;Project.Settings.UseFluentNHibernate <span style="color: #0000ff">is</span> <span style="color: #0000ff">false</span>&rdquo;;<br />}</pre>
</div>
</blockquote>
<h4>Testing</h4>
<p>Visual NHibernate has a smooth edit-test cycle, giving immediate feedback on your template and scripts. It also enables you to test individual entities, tables, views etc.</p>
<ol>
<li>Create your template script </li>
<li>Select the &lsquo;Test&rsquo; tab </li>
<li>If the file has an iterator, select the iterator you want to test with. Example: if you&rsquo;ve specified that one file should be created for each entity, then select an entity to test with. If the iterator is a table then a list of tables will be presented for you to make a selection.</li>
<li>Click the &lsquo;Test&rsquo; button to run the test. </li>
<li>The script will execute and display the generated text (file-body) or errors if they occur. </li>
</ol>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_6FF56544.png"><img height="251" width="316" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_12F5B0E8.png" alt="image" border="0" title="image" style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" /></a></p>
<h4>Scripting API</h4>
<p>The API available for scripting exposes all details about the current project. You have full access to all properties or entities, tables, relationships etc.</p>
<p>The editor has full IntelliSense and the API is easily discoverable:</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_07F88406.png"><img height="273" width="423" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_1B75BDDA.png" alt="image" border="0" title="image" style="background-image: none; border-right-width: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" /></a></p>
<p>Here&rsquo;s a small portion of the API:</p>
<ul>
<li><strong>CurrentFilePath:</strong> Gets or sets the path of the file being written. You can override the path specified in the filename editor via code. </li>
<li><strong>SkipThisFile:</strong> Set this to true to stop the current file from being generated. Return the reason for skipping. This reason will be displayed when testing this dynamic file. </li>
<li><strong>Project:</strong> Object containing all project-level variables, objects and settings. 
    
<ul>
<li><strong>Project.Settings:</strong> The Settings object allows access to the values of all settings on the Settings tab. </li>
<li><strong>Project.Entities:</strong> A collection of all entities. </li>
<li><strong>Project.Components:</strong> A collection of all components. </li>
<li><strong>Project.Tables:</strong> A collection of all tables. </li>
<li><strong>Project.Views:</strong> A collection of all views. </li>
<li><strong>Project.OutputFolder:</strong> The path of the output folder selected by the user. </li>
</ul>
</li>
</ul>
<h4>Extend your existing NHibernate projects</h4>
<p>Visual NHibernate can reverse-engineer your existing NHibernate Visual Studio projects. Your existing code becomes the model. This enables you to create new code based on your existing code. Create a new template, import your existing code, generate new code.</p>
<p><a href="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_7A722565.png"><img height="235" width="238" src="/cfs-file.ashx/__key/CommunityServer.Blogs.Components.WeblogFiles/nhibernate/image_5F00_thumb_5F00_0D46A910.png" alt="image" border="0" title="image" style="background-image: none; border-right-width: 0px; margin: 0px; padding-left: 0px; padding-right: 0px; display: inline; border-top-width: 0px; border-bottom-width: 0px; border-left-width: 0px; padding-top: 0px" /></a></p>
<h4>Conclusion</h4>
<p>Custom templates give you a tremendous amount of freedom and power. The best way to learn about the capabilities of templates is to inspect the built-in templates. Download <a target="_blank" href="http://www.slyce.com/VisualNHibernate/">Visual NHibernate</a>, have a play, and tell us what you think.</p>
