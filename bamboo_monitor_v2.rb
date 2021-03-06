=begin rdoc
Build monitor for Bamboo version 2.0+
=end
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'build'
require 'notifier'

class BambooMonitorV2
  def initialize(hostname, project_key, username=nil, password=nil)
		@notifier = Notifier.new
		configure(hostname, project_key, username, password)
  end
	
	def configure(hostname, project_key, username=nil, password=nil)
		@hostname = hostname

		@base_url = hostname + "/api/rest/"
		@build_url = @base_url + "getLatestBuildResults.action?buildKey=" + project_key
		if (username && password)
			@auth_url =  @base_url + "login.action?username=" + username + "&password=" + password 
		end
	end

	def get_build_status()
		if (@auth_url && @auth_key.nil?)
			authenticate()
			@build_url << "&auth=#{@auth_key}"
		end
		xmldoc = parse_xml(@build_url)
		puts xmldoc
		notify_build_status(xmldoc)
	end

	def notify_build_status(xmldoc)
		build = nil
		build_state = xmldoc.at("buildstate")
		if build_state
			if build_state.inner_html =~ /Success/ 
				build = Build.new(Status::SUCCESS, parse_summary_success(xmldoc))
			elsif build_state.inner_html =~ /Fail/
				build = Build.new(Status::FAILURE, parse_summary_failure(xmldoc))
			else
		  	build = Build.new(Status::UNKNOWN, parse_summary_unknown(xmldoc))
			end
		else
			build = Build.new(Status::UNKNOWN, parse_error(xmldoc))		
		end
		@notifier.notify(build)
	end

	def parse_project_link(xmldoc)
		project_name = xmldoc.at("projectname").inner_html
		project_key = xmldoc.at("buildkey").inner_html
		"<a href=\"" + @hostname + "/browse/" + project_key + "/latest" + "\">" + project_name + "</a>"
	end

	def parse_summary_success(xmldoc)
		summary = parse_project_link(xmldoc) 
		summary << " was successfully built in " << xmldoc.at("builddurationdescription").inner_html 
		summary << " with " << xmldoc.at("successfultestcount").inner_html << " tests. "
		summary << "Reason: " << xmldoc.at("buildreason").inner_html << "."
		summary
	end

	def parse_summary_failure(xmldoc)
		summary = parse_project_link(xmldoc) 
		summary << " build failed with " << xmldoc.at("failedtestcount").inner_html << " failed tests. " 
		summary << "Reason: " << xmldoc.at("buildreason").inner_html << "."
		summary
	end

	def parse_summary_unknown(xmldoc)
		summary = parse_project_link(xmldoc) 
		summary << " was not built due to an error. Build state is " << xmldoc.at("buildstate").inner_html << "." 
		summary
	end
	
	def parse_error(xmldoc)
		summary = "Build monitor failed: " 
		summary << xmldoc.at("error").inner_html
		summary
	end

  def parse_xml(url)
		puts url
		Hpricot(open(url).read)
  end

  def authenticate
    doc = parse_xml(@auth_url)
    if doc.at("error") 
			@notifier.notify(Build.new(Status::UNKNOWN, parse_error(doc)))
			exit
    end
    @auth_key = doc.at("auth").inner_html
  end
end
