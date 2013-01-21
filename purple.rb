$:.unshift(File.dirname(__FILE__)+"/lib")
require "rubygems"
require "bundler/setup"
require 'god_game_purple'
require 'yaml'


config = YAML::load_file(File.dirname(__FILE__)+"/config.yml")
puts config.inspect
auto_join = config.delete("channels")


connection = GodGamePurple::Connection.new(config)
connection.enable_event_trace!

event_engine = connection.event_engine
plugin_manger = GodGamePurple::PluginManager.new(connection, File.dirname(__FILE__)+"/plugins")
  
event_engine.bind("connected") do 
  connection.join auto_join
end

event_engine.bind("handled_exception") do |klass, message, trace|
  puts
  puts "ERROR: #{klass} -> #{message}"
  puts trace
  puts
end

connection.run!