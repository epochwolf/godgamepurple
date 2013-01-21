plugin_name         "Reloader"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Allows the user to reload plugins"

# This is a separate file so core plugins can be edited without causing too much mayhem.

command "reload" do |channel, nick, *args|
  plugin_manager.reload_plugins!
end