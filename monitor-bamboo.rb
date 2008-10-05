require 'rubygems'
require 'hpricot'
require 'open-uri'

class BambooMonitor 
  attr_accessor :debug
  def initialize
    @properties = {"hostname" => "", "username" => "", "password" => ""} 
    @auth = ""
  end
  
  def properties
    ["hostname","username","password"] 
  end

  def configure(properties)
    @properties = properties
  end

  def print_config
    @properties.keys.each do |p|
      puts p + "=>" + @properties[p]
      end
  end

  def fetch_xml(action)
    doc = Hpricot(open(monitor_url() + action).read)
    if @debug
      puts "---debug---"
      puts doc
      puts "---debug---"
    end
    doc
  end

  def get_identifiers
    doc = fetch_xml("listBuildNames.action?auth=" + @auth)
    identifiers = Array.new
    (doc/"build").each do |e|
        identifiers << (e/"key").inner_html + "|" + (e/"name").inner_html
    end
    identifiers
  end

  def get_build_status(id)
    doc = fetch_xml("getLatestBuildResults.action?auth=" + @auth + "&buildKey=" + id)
    result = doc.at("buildstate").inner_html
    summary = doc.at("buildtestsummary").inner_html
    [id, result, summary, url_to_latest_build(id)]
  end

  def url_to_latest_build(identifier)
    @properties["hostname"] + "/browse/" + identifier + "/latest"
  end

  def monitor_url
    @properties["hostname"] + "/api/rest/"
  end
  
  def authenticate
    doc = fetch_xml("login.action?username=" + @properties["username"] + "&password=" + @properties["password"])
    if doc.at("error") 
        raise "Authentication failure: " + doc.at("error").inner_html
    end
    @auth = doc.at("auth").inner_html
    if debug
      puts "auth: " + @auth
    end
  end
end
