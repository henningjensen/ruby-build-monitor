#!/usr/bin/ruby

require 'BambooMonitor'

monitor = BambooMonitor.new

properties = {"hostname" => "http://example.com/bamboo", "username" => "myusername", "password"=>"mypassword"}
monitor.configure(properties)

monitor.authenticate

puts "-----------------------"
puts monitor.get_identifiers
puts "-----------------------"

puts monitor.get_build_status "EXAMPLE-TRUNK"
