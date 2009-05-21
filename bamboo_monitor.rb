require 'rubygems'
require 'hpricot'
require 'open-uri'
<<<<<<< HEAD:bamboo_monitor.rb

require 'build'
require 'notifier'

class BambooMonitor 
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
		build_state = xmldoc.at("buildstate").inner_html
		build = nil
		if build_state =~ /Success/ 
			build = Build.new(Status::SUCCESS, parse_summary_success(xmldoc))
		elsif build_state =~ /Fail/
			build = Build.new(Status::FAILURE, parse_summary_failure(xmldoc))
		else
		  build = Build.new(Status::UNKNOWN, parse_summary_unknown(xmldoc))
		end
		@notifier.notify(build)
	end

	def parse_project_link(xmldoc)
		#project_name = xmldoc.at("projectname").inner_html
		#project_key = xmldoc.at("buildKey").inner_html
		#"<a href=\"" + @hostname + "/browse/" + project_key + "/latest" + "\">" + project_name + "</a>"
		xmldoc.at("buildkey").inner_html
=======
require 'build'

class BambooMonitor 
  attr_accessor :debug
  def initialize(properties)
#		@debug=true
    @properties = properties
  end
  
  def properties
    ["hostname","username","password","project_key"] 
  end

	def get_build_status()
		authenticate() if @auth.nil?
    xmldoc = parse_xml("getLatestBuildResults.action?auth=" + @auth + "&buildKey=" + @properties["project_key"])
		parse_build_status(xmldoc)
	end

	def parse_build_status(xmldoc)
		build_state = xmldoc.at("buildstate").inner_html
		status = nil
		summary = nil
		if build_state =~ /Success/ 
			status = Status::SUCCESS
			summary = parse_summary_success(xmldoc)
    elsif build_state =~ /Fail/
			status = Status::FAILURE
			summary = parse_summary_failure(xmldoc)
    else
      status = Status::UNKNOWN
			summary = parse_summary_unknown(xmldoc)
		end
		Build.new(status, summary)
	end

	def parse_project_link(xmldoc)
		projectname = xmldoc.at("projectname").inner_html
		projectkey = xmldoc.at("buildkey").inner_html
		"<a href=\"" + @properties["hostname"] + "/browse/" + projectkey + "/latest" + "\">" + projectname + "</a>"
>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:bamboo_monitor.rb
	end

	def parse_summary_success(xmldoc)
		summary = parse_project_link(xmldoc) 
<<<<<<< HEAD:bamboo_monitor.rb
		summary << " was successfully built with " << xmldoc.at("successfultestcount").inner_html << " tests."
#		summary << " was successfully built in " << xmldoc.at("builddurationdescription").inner_html 
#		summary << " with " << xmldoc.at("successfultestcount").inner_html << " tests. "
#		summary << "Reason: " << xmldoc.at("buildreason").inner_html << "."
=======
		summary << " was successfully built in " << xmldoc.at("builddurationdescription").inner_html 
		summary << " with " << xmldoc.at("successfultestcount").inner_html << " tests. "
		summary << "Reason: " << xmldoc.at("buildreason").inner_html << "."
>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:bamboo_monitor.rb
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

  def parse_xml(url)
<<<<<<< HEAD:bamboo_monitor.rb
		puts url
		Hpricot(open(url).read)
  end

  def authenticate
    doc = parse_xml(@auth_url)
    if doc.at("error") 
        raise "Authentication failure: " + doc.at("error").inner_html
    end
    @auth_key = doc.at("auth").inner_html
  end
=======
    doc = Hpricot(open(@properties["hostname"] + "/api/rest/" + url).read)
    if @debug
      puts "---debug---"
      puts doc
      puts "---debug---"
    end
    doc
  end

  def authenticate
    doc = parse_xml("login.action?username=" + @properties["username"] + "&password=" + @properties["password"])
    if doc.at("error") 
        raise "Authentication failure: " + doc.at("error").inner_html
    end
    @auth = doc.at("auth").inner_html
    if debug
      puts "auth: " + @auth
    end
  end
  
	def get_identifiers
    doc = parse_xml("listBuildNames.action?auth=" + @auth)
    identifiers = Array.new
    (doc/"build").each do |e|
        identifiers << (e/"key").inner_html + "|" + (e/"name").inner_html
    end
    identifiers
  end
  
>>>>>>> 6f9e6fab062f250bafde8e53537be7166390c516:bamboo_monitor.rb
end
