plugin_name         "Chatty"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Provides some generic welcome messages"

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