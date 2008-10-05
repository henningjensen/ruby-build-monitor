require 'BambooMonitor'
require 'GnomeNotifier'
monitor = BambooMonitor.new

properties = {
    "hostname" => "http://example.com/bamboo", 
    "username" => "henning", 
    "password" => "hello"}
monitor.configure(properties)

monitor.authenticate

notifier = GnomeNotifier.new

notifier.notify(monitor.get_build_status("EXAMPLE-CORE"))
puts "sleeping"
sleep(4)
notifier.notify(monitor.get_build_status("EXAMPLE-SITE"))
puts "sleeping"
sleep(4)
notifier.notify(monitor.get_build_status("EXAMPLE-CORE"))
puts "sleeping"
sleep(4)
notifier.notify(monitor.get_build_status("EXAMPLE-CORE"))
