require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'build'

class HudsonMonitor 
  attr_accessor :debug
  def initialize(properties)
		@debug=true
    @properties = properties
  end
  
  def properties
    ["hostname","username","password","job"] 
  end

  def print_config
    @properties.keys.each do |p|
      puts p + "=>" + @properties[p]
      end
  end

	def get_build_status()
#		authenticate() if @auth.nil?
    xmldoc = parse_xml("job/" + @properties["job"] + "/lastSuccessfulBuild/api/xml")
		parse_build_status(xmldoc)
	end

	def parse_build_status(xmldoc)
		build_state = xmldoc.at("result").inner_html
		status = nil
		summary = nil
		if build_state =~ /SUCCESS/ 
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
		url = xmldoc.at("url").inner_html
		"<a href=\"" + url + "\">" + @properties["job"] + "</a>"
	end

	def parse_summary_success(xmldoc)
		summary = parse_project_link(xmldoc) 
		summary << " was successfully built in " << xmldoc.at("duration").inner_html 
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
    doc = Hpricot(open(@properties["hostname"] + url).read)
    if @debug
      puts "---debug---"
      puts doc
      puts "---debug---"
    end
    doc
  end

  def get_identifiers
    doc = parse_xml("listBuildNames.action?auth=" + @auth)
    identifiers = Array.new
    (doc/"build").each do |e|
        identifiers << (e/"key").inner_html + "|" + (e/"name").inner_html
    end
    identifiers
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
end
