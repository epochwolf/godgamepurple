plugin_name         "System"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Provides basic admin functions to the bot"

@last_seen = {}

def admin?(nick)
  nick.admin?
end

# Available data objects
# connection - current connection
# plugin_manager - plugin manager
# events - event manager
# plugin - current plugin

help "commands", "Provides a list of commands."
command "commands" do |c, n, *args|
  connection.message c, "Commands: #{plugin_manager.commands.keys.sort.join(', ')}"
end

command "join" do |c, n, channel|
  unless channel.nil?
    if n.admin?
      message c, "Okay"
      join channel
    else
      message c, "Nope."
    end
  else
    action c, "stares blankly"
  end
end

command "part" do |c, n, channel|
  if n.admin?
    message c, "Okay"
    part channel || c
  else
    message c, "Nope."
  end
end

command "quit" do |c, n|
  message c, "I hope you enjoy my company. I'm not programmed for suicide."
end

command "about" do |c, n|
  connection.message c, "GodGamePurple 0.0.1 https://github.com/epochwolf/godgamepurple"
end

command "plugin" do |c, n, action, plugin|
  case action
  when "load" then   cmd_plugin_load(c, n, action, plugin)
  when "unload" then cmd_plugin_unload(c, n, action, plugin)
  when "info" then   cmd_plugin_info(c, n, action, plugin)
  when "list" then   cmd_plugin_list(c, n, action, plugin)
  else 
    message c, "Available sub commands: load [plugin], unload [plugin], info [plugin], list"
  end
end


def plugin_exists?(plugin)
  if plugin_manager.plugins[plugin]
    true
  else
    message c, "I couldn't find a plugin named \"#{plugin}\"."
    false
  end
end

def plugin_admin?(n)
  if n.admin?
    true
  else
    message c, "You don't get to play with my fiddly bits."
    false
  end
end

def cmd_plugin_load(c, n, action, plugin)
  return unless plugin_admin?(n)
  return unless plugin_exists?(plugin)
  plugin_manager.load_plugin plugin
  message c, "Okay"
end

def cmd_plugin_unload(c, n, action, plugin)
  return unless plugin_admin?(n)
  return unless plugin_exists?(plugin)
  unless ["system", "_reloader"].include?(plugin)
    plugin_manager.unload_plugin plugin
    message c, "Okay"
  else
    message c, "Um. That's a bad idea."
  end
end

def cmd_plugin_list(c, n, action, plugin)
  list = plugin_manager.plugins.map{|k, v| v.loaded? ? "#{k}" : "~#{k}"}.join ", "
  message c, "Plugins: #{list}"
end

def cmd_plugin_info(c, n, action, plugin)
  return unless plugin_exists?(plugin)
  message c, "#{plugin.name} provides: #{plugin.commands.keys.join ", "}"
end