plugin_name         "System"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Provides basic admin functions to the bot"

@last_seen = {}

def admin?(nick)
  %w[epochwolf].include? nick.name 
end

# Available data objects
# connection - current connection
# plugin_manager - plugin manager
# events - event manager
# plugin - current plugin

help "commands", "Provides a list of commands."
command "commands" do |channel, nick, *args|
  connection.message channel, "Commands: #{plugin_manager.commands.keys.sort.join(', ')}"
end

command "join" do |_, nick, channel|
  unless channel.nil?
    if admin?(nick)
      message _, "Okay"
      join channel
    else
      message _, "Nope."
    end
  else
    action _, "stares blankly"
  end
end

command "part" do |_, nick, channel|
  if admin?(nick)
    message _, "Okay"
    part channel || _
  else
    message _, "Nope."
  end
end

command "quit" do |channel, nick|
  message channel, "I hope you enjoy my company. I'm not programmed for suicide."
end

command "about" do |c, n|
  connection.message c, "GodGamePurple 0.0.1 https://github.com/epochwolf/godgamepurple"
end

command "plugins" do |c, n, action, plugin|
  case action
  when "load"
    plugin_manager.load_plugin plugin
  when "unload"
    plugin_manager.unload_plugin plugin
  when "info"
    if plugin = plugin_manager.plugins[plugin]
      message c, "#{plugin.name} provides: #{plugin.commands.keys.join ", "}"
    else
      message c, "No plugin by that name."
    end
  when "list"
    message c, "Plugins: #{plugin_manager.plugins.keys.join ", "}"
  else 
    message c, "Available sub commands: load [plugin], unload [plugin], info [plugin], list"
  end
end