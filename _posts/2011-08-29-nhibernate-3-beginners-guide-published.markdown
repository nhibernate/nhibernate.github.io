---
layout: post
title: "NHibernate 3 Beginners Guide published"
date: 2011-08-29 20:27:00 +1200
comments: true
published: true
categories: ["blogs", "nhibernate", "archive"]
tags: ["NHibernate", "NHibernate Documentation"]
alias: ["/blogs/nhibernate/archive/2011/08/29/nhibernate-3-beginners-guide-published.aspx"]
author: gabriel.schenker
gravatar: c6b14f5727ae60868a29322c6395bd4d
---
{% include imported_disclaimer.html %}
<p>Note: This post has been cross posted from my <a href="http://lostechies.com/gabrielschenker/2011/08/29/nhibernate-3-beginners-guide-published/">own blog</a> at Los Techies.</p>
<p>I am very pleased to announce that my book <a href="http://www.packtpub.com/nhibernate-3-beginners-guide/book">NHibernate 3 Beginners Guide</a> has finally been published. It is a wonderful feeling to finally have a book in my hands that cost me a couple of months of intense work. But I think the result is well worth it.</p>
<p>If you are interested in the book then there is also a <a href="http://www.packtpub.com/sites/default/files/6020OS-Chapter-3-Creating-a-%20Model.pdf?utm_source=packtpub&amp;utm_medium=free&amp;utm_campaign=pdf">free chapter</a> available for download.</p>
<p>I was lucky to have <a href="http://fabiomaulo.blogspot.com/">Fabio Maulo</a> and <a href="http://joseoncode.com/">Jos&eacute; F. Romaniello</a> as my reviewer, the former being the lead of the <a href="http://www.nhforge.org">NHibernate</a> project and the latter an active contributor to the the project.</p>
<p>My goal for this book has been to provide an easy to follow introduction to NHibernate 3.x. The text covers NHibernate up to version 3.1 GA and even references some of the new features of NHibernate 3.2 GA. It was very important to me to not use a data centric approach but rather choose a <strong>model first</strong> approach. </p>
<p>In this regard this book is NOT just an updated version of <a href="https://www.packtpub.com/nhibernate-2-beginners-guide/book">NHibernate 2 Beginners Guide</a> but rather a complete rewrite.</p>
<p>I also have paid attention to cover all foundational topics in a clear and concise way. In no way did I want to abandon the reader in the dust of uncertainty.</p>
<p>Let me provide you the list of chapters found in the book with a short introduction about the respective content of each chapter.</p>
<p><strong>Chapter 1, First Look&hellip;</strong> explains what NHibernate is and why we would use it in an application that needs to access data in a relational database. The chapter also briefly presents what is new in NHibernate 3.x compared to the version 2.x and discusses how one can get this framework. Links to various sources providing documentation and help are presented.</p>
<p><strong>Chapter 2, A First Complete Sample&hellip;</strong>walks through a simple yet complete sample where the core concepts of NHibernate and its usage are introduced.</p>
<p><strong>Chapter 3, Creating a Model&hellip;</strong> discusses what a domain model is and what building blocks constitute such a model. In an exercise the reader creates a domain model for a simple ordering system.</p>
<p><strong>Chapter 4, Defining the Database Schema&hellip;</strong>explains what a database schema is and describes in details the individual parts comprising such a schema. A schema for the ordering system is created in an exercise.</p>
<p><strong>Chapter 5, Mapping the Model to the Database&hellip;</strong>teaches how to bridge the gap between the domain model and the database schema with the aid of some wiring. This chapter presents four distinct techniques how the model can be mapped to the underlying database or vice versa. It is also shown how we can use NHibernate to automatically create the database schema by leveraging the meta-information contained in the domain model.</p>
<p><strong>Chapter 6, Sessions and Transactions&hellip;</strong>teaches how to create NHibernate sessions to communicate with the database and how to use transactions to group multiple tasks into one consistent operation which succeeds or fails as a whole. </p>
<p><strong>Chapter 7, Testing, Profiling, Monitoring and Logging&hellip;</strong>introduces how to test and profile our system during development to make sure we deliver a reliable, robust and maintainable application. It also shows how an application can be monitored in a productive environment and how it can log any unexpected or faulty behavior.</p>
<p><strong>Chapter 8, Configuration&hellip; </strong>explains how we can tell NHibernate which database to use, as well as provide it the necessary credentials to get access to the stored data. In addition to that many more settings for NHibernate to tweak and optimize the database access are explained in this chapter.</p>
<p><strong>Chapter 9, Writing Queries&hellip;</strong> discusses the various means how we can easily and efficiently query data from the database to create meaningful reports on screen or on paper.</p>
<p><strong>Chapter 10, Validating the data to persist&hellip;</strong>discusses why data collected by an application needs to be correct, complete and consistent. It shows how we can instrument NHibernate to achieve this goal through various validation techniques.</p>
<p><strong>Chapter 11, Common Pitfalls &ndash; Things to avoid&hellip;</strong> as the last chapter of this book presents the most common errors developers can make when using NHibernate to write or read data to and from the database. Each such pitfall is discussed in details and possible solutions to overcome the problems are shown.</p>
