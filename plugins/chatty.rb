plugin_name         "Chatty"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Provides some generic welcome messages"
plugin_autoload     false

on "join.self" do |c|
  message c, "Hi everyone!"
end

on "join" do |c, n|
  action c, "welcomes #{n}!"
end