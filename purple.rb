$:.unshift(File.dirname(__FILE__)+"/lib")
require "rubygems"
require "bundler/setup"
require 'god_game_purple'
require 'yaml'


config = YAML::load_file(File.dirname(__FILE__)+"/config.yml")
puts config.inspect
auto_join = config.delete("channels")


connection = GodGamePurple::Connection.new(config)
event_engine = connection.event_engine

event_engine.bind("motd_end") do 
  connection.join auto_join
end

event_engine.bind("privmsg.action") do |channel, nick, message|
  connection.action channel, "waves back" if message == "waves"
end

connection.enable_event_trace!
connection.run!