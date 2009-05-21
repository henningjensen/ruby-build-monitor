require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'build'

class HudsonMonitor 
  def initialize(hostname, job, username=nil, password=nil)
		@notifier = Notifier.new
		configure(hostname, job, username, password)
  end

	def configure(hostname, job, username, password)
		@hostname = hostname
		@job = job
		@username = username
		@password = password
	end

	def get_build_status()
    xmldoc = parse_xml("/job/" + @job + "/lastBuild/api/xml")
		parse_build_status(xmldoc)
	end

	def parse_build_status(xmldoc)
		build_state = xmldoc.at("result")
		build = nil
		if build_state
			if build_state.inner_html =~ /SUCCESS/ 
				build = Build.new(Status::SUCCESS, parse_summary_success(xmldoc))
   		elsif build_state.inner_html =~ /FAILURE/
				build = Build.new(Status::FAILURE, parse_summary_failure(xmldoc))
    	else
      	build = Build.new(Status::UNKNOWN, parse_summary_unknown(xmldoc))
			end
		else
			building = xmldoc.at("building")
			if building
				build = Build.new(Status::UNKNOWN, @job + " is currently building")
			else
      	build = Build.new(Status::UNKNOWN, parse_summary_unknown(xmldoc))
			end
		end
		@notifier.notify(build)
	end

	def parse_project_link(xmldoc)
		url = xmldoc.at("url").inner_html
		"<a href=\"" + url + "\">" + @job + "</a>"
	end

	def parse_summary_success(xmldoc)
		parse_project_link(xmldoc) << " was successfully built."
	end

	def parse_summary_failure(xmldoc)
		parse_project_link(xmldoc) << " build failed."
	end

	def parse_summary_unknown(xmldoc)
		parse_project_link(xmldoc) << " was not built due to an error."
	end

  def parse_xml(url)
    doc = Hpricot(open(@hostname + url).read)
		puts doc
    doc
  end
end
