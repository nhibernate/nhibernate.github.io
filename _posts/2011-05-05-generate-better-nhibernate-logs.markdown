---
layout: post
title: "Generate better NHibernate logs"
date: 2011-05-05 21:57:43 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["logging"]
redirect_from: ["/blogs/nhibernate/archive/2011/05/05/generate-better-nhibernate-logs.aspx/"]
author: jfromainello
gravatar: d1a7e0fbfb2c1d9a8b10fd03648da78f
---
{% include imported_disclaimer.html %}
<p>I will show you in this post two tricks you can do to enhance and add value to your nhibernate logs. </p>  <h1>Format Sql</h1>  <p>This is widely know trick, you can add a configuration setting to your hibernate.cfg.xml, app.config or web.config as follow:</p>  <pre class="brush: xml; wrap-line: false;">&lt;property name=&quot;hibernate.format_sql&quot; value=&quot;true&quot; /&gt;</pre>

<p>or you can simply do it in code:</p>

<pre class="brush: csharp; wrap-line: false;">config.DataBaseIntegration(db =&gt; db.LogFormatedSql = true)</pre>

<p>with this trick you will get nicely formated sql in your logs files.</p>

<h1>Logging the session identifier</h1>

<p>All nice, we have a bunch of sql logs, but we don’t know which queries belongs to which sessions. This might be useful when you are debugging an application with multiples threads or requests.</p>

<p>I found this trick inside NHibernate, the easy way I found so far is to add a log4net appender like this one:</p>

<pre class="brush: xml; wrap-line: false;">&lt;appender name=&quot;NHibernateAppender&quot; type=&quot;log4net.Appender.RollingFileAppender&quot;&gt;
  &lt;appendToFile value=&quot;true&quot;/&gt;
  &lt;datePattern value=&quot;yyyyMMdd&quot;/&gt;
  &lt;file value=&quot;./logs/NHibernate.log&quot;/&gt;
  &lt;layout type=&quot;log4net.Layout.PatternLayout&quot;&gt;
    &lt;conversionPattern value=&quot;%date Session id: %property{sessionId} - %message%newline&quot;/&gt;
  &lt;/layout&gt;
  &lt;rollingStyle value=&quot;Date&quot;/&gt;
&lt;/appender&gt;</pre>

<p>See the %property{sessionId} in the conversion pattern?</p>

<p>Well, in order to log something there you need to do two steps.</p>

<p>Add a class like this one:</p>

<pre class="brush: csharp; wrap-line: false;">public class SessionIdCapturer
{
    public override string ToString()
    {
        return SessionIdLoggingContext.SessionId.ToString();
    }
}</pre>

<p>Add the following code in some place at the application initialization:</p>

<pre class="brush: csharp; wrap-line: false;">ThreadContext.Properties[&quot;sessionId&quot;] = new SessionIdCapturer();</pre>

<p>That is all! I found this code inside a nhibernate test.. it is something not very known.</p>

<p>After doing so, your logs will look like:</p>

<pre>2011-05-05 18:35:59,899 Session id: 5e172068-5064-44b6-bf96-99362ca05c46 - 
    SELECT
        myFoo0_.AccountId as AccountId3_0_,
        myFoo0_.Name as Name3_0_,
        myFoo0_.Version as Version3_0_ 
    FROM
        MyFoo myFoo0_
    WHERE
        myFoo0_.AccountId=@p0;
    @p0 = 1 [Type: Int32 (0)]</pre>

<p>Another way to have this information (and much more) is to use the <a href="http://nhprof.com/">nhprof</a> tool.</p>
