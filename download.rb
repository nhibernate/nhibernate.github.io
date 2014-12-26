require 'net/http'
require 'open-uri'
require 'fileutils'

Dir[File.dirname(__FILE__) + '/doc/**/*.html'].each do |fname|
	fname.gsub!(File.dirname(__FILE__), '')
	fname = '.' + fname
	file = File.open(fname, "rb").read
	file.gsub!(/<img.+src="([^"]*)"/) do |capture|
		f = $1
		x = $1
		if f[0] == '/' 
			f = "http://nhforge.org" + f
		end
		if f.start_with?('../../')
			puts f
			f = "http://nhforge.org/" + f.slice(6, f.length)
		end
		#puts fname
		f_s = fname.gsub('.html', '').gsub('doc','images/doc') + f.slice(f.rindex('/'), f.length)
		if f_s.include?('anonymous.gif')
			f_s = '/images/anonymous.gif'
		end
		#puts f
		#puts f_s
		#f_s = $1.gsub('/','-').gsub(':','-')
		#puts f
		begin
		  	open(f, "rb") do |read_file|
		  		dirname = File.dirname('.'+f_s)
				unless File.directory?(dirname)
  					FileUtils.mkdir_p(dirname)
				end
	  			File.open('.'+f_s, "wb") do |saved_file|
					saved_file.write(read_file.read)
		    		saved_file.close
	    		end
	    		capture.gsub!(x,f_s)
		  	end
		rescue Exception => e
			puts e
			puts f
			begin
				puts 'trying ' + 'http://web.archive.org/web/0/' + f
			  	open('http://web.archive.org/web/0/' + f, "rb") do |read_file|
			  		dirname = File.dirname('.'+f_s)
					unless File.directory?(dirname)
	  					FileUtils.mkdir_p(dirname)
					end
		  			File.open('.'+f_s, "wb") do |saved_file|
						saved_file.write(read_file.read)
			    		saved_file.close
		    		end
		    		capture.gsub!(x,f_s)
		    		puts 'success'
			  	end
			rescue Exception => e
				puts e
			end

		end
		capture
	end
	File.open(fname, "wb") do |f|
		f.write(file)
		f.close
	end
end