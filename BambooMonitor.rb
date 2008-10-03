require 'rubygems'
require 'hpricot'
require 'open-uri'

class BambooMonitor 
  @properties

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

  def get_identifiers
    action = build_url + "listBuildNames.action?auth=" + @auth
    xml = open(action).read
    doc = Hpricot(xml)
    identifiers = Array.new
    (doc/"build").each do |e|
        identifiers << (e/"key").inner_html + "|" + (e/"name").inner_html
    end
    identifiers
  end


  def get_build_status(identifier)
    action = build_url + "getLatestBuildResults.action?auth=" + @auth + "&buildKey=" + identifier 
    xml = open(action).read
    doc = Hpricot(xml)
    
    identifier + "|" + doc.at("buildstate").inner_html + "|" + doc.at("buildtestsummary").inner_html + "|" + url_to_latest_build(identifier)
  end

  def url_to_latest_build(identifier)
    @properties["hostname"] + "/browse/" + identifier + "/latest"
  end

  def build_url
    @properties["hostname"] + "/api/rest/"
  end
  
  def authenticate
    loginurl = build_url +  "login.action?username=" + @properties["username"] + "&password=" + @properties["password"]
	xml = open(loginurl).read
    doc = Hpricot(xml)
    if doc.at("error") 
        puts "An error occurred: " + doc.at("error").inner_html
        return false
    end
    @auth = doc.at("auth").inner_html
    puts "auth: " + @auth
  end
end
