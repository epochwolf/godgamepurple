plugin_name         "System"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Provides basic admin functions to the bot"

@last_seen = {}

# Available data objects
# connection - current connection
# plugin_manager - plugin manager
# events - event manager
# plugin - current plugin

help "commands", "Provides a list of commands."
command "commands" do |channel, nick, *args|
  connection.message channel, "Commands: #{plugin_manager.commands.keys.sort.join(', ')}"
end

command "author" do |channel, nick, *args|
  connection.message channel, "Author: #{plugin.author}"
end

help "slap($target)", "Hit $target with a trout."
command "slap" do |channel, nick, target, *args|
  connection.action channel, "smacks the everliving shit out of #{target}."
end

on "join.self" do |channel|
  connection.message channel, "Hi everyone!"
end

on "join" do |channel, nick|
  channel.action "welcomes #{nick}!"
end