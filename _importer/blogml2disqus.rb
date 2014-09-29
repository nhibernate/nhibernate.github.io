# Copyright 2013 Andrew Maddison

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'rexml/document'
require 'uri'
require 'date'
require 'base64'
require 'cgi'
include REXML

module BlogMl2Discus

	class Post
		attr_accessor :oldLink
		attr_accessor :newLink
		attr_accessor :safeIdent
		attr_accessor :title
		attr_accessor :dateCreated
	end	

	class Comment
		attr_accessor :commentId
		attr_accessor :author
		attr_accessor :authorEmail
		attr_accessor :website
		attr_accessor :dateCreated
		attr_accessor :content
		attr_accessor :approved
		attr_accessor :website
	end
end
def getContent (element)
	text = element.text
	if !(text.nil? || text.empty? || text =~ /\S/)
		text = element.cdatas().first().to_s
	end
	if element.attributes["type"] == "base64"
		text = Base64.decode64(text)
	end
	return CGI.unescapeHTML(text)
end

def parsePostElement(blogMlPostElement)
	post = BlogMl2Discus::Post.new
	post.oldLink = blogMlPostElement.attributes["post-url"]
	post.newLink = "http://nhibernate.github.io" + post.oldLink.gsub(/(.*)(aspx)(.*)/, '\1html\3')
	path = URI::parse(post.newLink).path[1..-6] #remove leading slash (first char) and .html (last 5 chars)
	post.safeIdent = path.gsub("/","_")
	post.title = blogMlPostElement.elements["title"].text
	post.dateCreated = DateTime.parse(blogMlPostElement.attributes["date-created"]).strftime("%Y-%m-%d %H:%M:%S")
	return post 
end

def parseCommentElement(blogMlCommentElement)
	comment = BlogMl2Discus::Comment.new
	comment.commentId = blogMlCommentElement.attributes["id"]
	comment.author = blogMlCommentElement.attributes["user-name"]
	comment.authorEmail = blogMlCommentElement.attributes["user-email"]
	comment.dateCreated = DateTime.parse(blogMlCommentElement.attributes["date-created"]).strftime("%Y-%m-%d %H:%M:%S")
	contentElement = blogMlCommentElement.elements["content"]
	comment.content = getContent contentElement
	comment.approved = (blogMlCommentElement.attributes["approved"] == "true")
	comment.website = blogMlCommentElement.attributes["user-url"]
	return comment
end

module BlogMl2Discus
	source = "BlogML.xml"
	puts "Started..."
	file = File.new(source)
	doc = Document.new file

	dq_document = Element.new "channel"
	posts = []

	doc.elements.each("blog/posts/post") do |blogMlPostElement|
		post = parsePostElement(blogMlPostElement)

		dq_post = dq_document.add_element "item"
		dq_post.add_element("title").add_text post.title
		dq_post.add_element("link").add_text post.newLink
		dq_post.add_element("dsq:thread_identifier").add_text post.safeIdent
		dq_post.add_element("wp:post_date_gmt").add_text post.dateCreated

		blogMlPostElement.elements.each("comments/comment") do |commentElement|
			comment = parseCommentElement(commentElement)

			dq_comment = dq_post.add_element "wp:comment"
			dq_comment.add_element("wp:comment_id").add_text comment.commentId
			dq_comment.add_element("wp:comment_author").add_text comment.author
			dq_comment.add_element("wp:comment_author_url").add_text comment.website
			dq_comment.add_element("wp:comment_author_email").add_text comment.authorEmail
			dq_comment.add_element("wp:comment_author_IP") #BlogML (from subtext at least) doesn't have IP logged.
			dq_comment.add_element("wp:comment_date_gmt").add_text comment.dateCreated
			dq_comment.add_element("wp:comment_content").add_text comment.content
			dq_comment.add_element("wp:comment_approved").add_text comment.approved ? "1" : "0"
			
			message = ""
			if commentElement.attributes["user-email"] then
				message = commentElement.attributes["user-email"]
			else
				message =  "[no email]"
			end
		end
	end
	formatter = Formatters::Pretty.new
	newFile = File.open("Output.xml", 'w')
	newDocument = Document.new
	newDocument << XMLDecl.new("1.0")
	rssElement = newDocument.add_element("rss")
	rssElement.attributes["xmlns:content"] = "http://purl.org/rss/1.0/modules/content/"
	rssElement.attributes["xmlns:dsq"] = "http://www.disqus.com/"
	rssElement.attributes["xmlns:dc"] = "http://purl.org/dc/elements/1.1/"
	rssElement.attributes["xmlns:wp"] = "http://wordpress.org/export/1.0/"
	rssElement.add_element dq_document
	formatter.write(newDocument, newFile,)
	newFile.close
	puts "Finished, and maybe didn't explode"

end