---
layout: post
title: "Encrypting password (or other strings) in NHibernate"
date: 2009-02-22 05:18:00 +1300
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: []
alias: ["/blogs/nhibernate/archive/2009/02/22/encrypting-password-or-other-strings-in-nhibernate.aspx"]
author: Gustavo
gravatar: 934c5a2299da30163f720bcd2ee826f4
---
{% include imported_disclaimer.html %}
<p>As you can read in every forum the solution to encrypting/decrypting a password is using an IUserType. Implementing an IUserType in NH is somewhat easy, so we added to uNHAddins a user type which will do the encryption.</p>
<p>The source code can be grabbed from <a href="http://code.google.com/p/unhaddins/" target="_blank">uNHAddins</a> <a href="http://unhaddins.googlecode.com/svn/trunk/" target="_blank">trunk</a>.</p>
<p>If you use it &ldquo;as is&rdquo; you will get an encryption using the symmetric algorithm DESCryptoServiceProvider. There is no special decision for this but to have some default option to do the job.</p>
<p>There are several ways to use the user type, the most common but less recommended (unless you are using it only once):</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property</span> <span style="color: #ff0000;">name</span>=<span style="color: #0000ff;">"Password"</span> <span style="color: #ff0000;">type</span>=<span style="color: #0000ff;">"</span><span style="color: #0000ff;">uNHAddIns.UserTypes.EncryptedString, uNHAddins</span><span style="color: #0000ff;">"</span> <span style="color: #0000ff;">/&gt;</span></pre>
</pre>
<p>
The preferred way will be using &lt;typedef&gt; to define the user type as in the following:</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">typedef</span> <span style="color: #ff0000;">class</span>=<span style="color: #0000ff;">"uNHAddIns.UserTypes.EncryptedString, uNHAddIns"</span> <span style="color: #ff0000;">name</span>=<span style="color: #0000ff;">"Encrypted"</span><span style="color: #0000ff;">&gt;</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">param</span> <span style="color: #ff0000;">name</span>=<span style="color: #0000ff;">"encryptor"</span><span style="color: #0000ff;">&gt;</span>uNhAddIns.UserTypes.uNHAddinsEncryptor, uNhAddIns<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">param</span><span style="color: #0000ff;">&gt;</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">&lt;</span><span style="color: #800000;">param</span> <span style="color: #ff0000;">name</span>=<span style="color: #0000ff;">"encryptionKey"</span><span style="color: #0000ff;">&gt;</span>myRGBKey<span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">param</span><span style="color: #0000ff;">&gt;</span></pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;/</span><span style="color: #800000;">typedef</span><span style="color: #0000ff;">&gt;</span></pre>
</pre>
<p>The parameters are optional but give you an easy option to extend the user type to use your own algorithm.</p>
<p>The encryptor paramater expects an implementation of IEncryptor, if you don&rsquo;t set it you get the uNHAddinsEncryptor implementation. Implementing the interface is very easy you just need to say how you encrypt and decrypt and if you want to use an external key set in the typedef parameters then you can get this using the EncryptionKey property.</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">public</span> <span style="color: #0000ff;">interface</span> IEncryptor</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">{</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">string</span> Encrypt(<span style="color: #0000ff;">string</span> password);</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">  <span style="color: #0000ff;">string</span> Decrypt(<span style="color: #0000ff;">string</span> encryptedPassword);</pre>
<pre style="margin: 0em; width: 100%; background-color: #ffffff;" size="12px" face="consolas,'Courier New',courier,monospace">  <span style="color: #0000ff;">string</span> EncryptionKey { <span style="color: #0000ff;">get</span>; <span style="color: #0000ff;">set</span>; }</pre>
<pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;">}</pre>
</pre>
<p>Using it now in your code is as easy as:</p>
<pre><pre style="margin: 0em; font-size: 12px; width: 100%; font-family: consolas,'Courier New',courier,monospace; background-color: #ffffff;"><span style="color: #0000ff;">&lt;</span><span style="color: #800000;">property</span> <span style="color: #ff0000;">name</span>=<span style="color: #0000ff;">"Password"</span> <span style="color: #ff0000;">type</span>=<span style="color: #0000ff;">"Encrypted"</span> <span style="color: #0000ff;">/&gt;</span></pre>
</pre>
<p>The Password property keeps being implemented as a string, so you don&rsquo;t touch your existing code.</p>
