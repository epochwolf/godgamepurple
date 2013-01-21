plugin_name         "Wave Back"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Makes the bot wave back if someone waves"

puts "HI!"

command "hello" do |channel, nick, message|
  connection.message channel, "Greetings!"
end

on "action" do |channel, nick, message|
  connection.action channel, "waves back" if message == "waves"
end