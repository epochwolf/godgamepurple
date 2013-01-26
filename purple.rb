Dir.chdir(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__)+"/lib")

require "rubygems"
require "bundler/setup"
require 'god_game_purple'
require 'yaml'


config = YAML::load_file("config.yml")
puts config.inspect
auto_join = config.delete("channels")


connection = GodGamePurple::Connection.new(config)
connection.enable_event_trace!

event_engine = connection.event_engine
plugin_manger = GodGamePurple::PluginManager.new(connection, "plugins")
  
event_engine.bind("connected") do 
  connection.join auto_join
end

event_engine.bind("handled_exception") do |klass, message, trace|
  puts
  puts "ERROR: #{klass} -> #{message}"
  puts trace
  puts
end

Thread.start do 
  require 'sinatra/base'
  my_app = Sinatra.new do
    set :root, File.dirname(__FILE__) + '/webserver'

    get '/' do
      haml :index
    end
  end
  my_app.run!
end 


connection.run!