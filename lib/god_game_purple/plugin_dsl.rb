module GodGamePurple
class PluginDsl
  def initialize(plugin, file)
    @plugin = plugin
    instance_eval File.read(file), file
  end

  # bot internals
  def plugin
    @plugin
  end

  def plugin_manager
    @_plugin_manager ||= plugin.manager
  end

  def bot_config 
    @_bot_config ||= connection.config
  end

  def connection 
    @_connection ||=plugin_manager.connection
  end

  def event_engine
    @_event_engine ||= plugin.manager.event_engine
  end

  # meta data
  def plugin_name(name)
    plugin.name = name
  end

  def plugin_author(author)
    plugin.author = author
  end

  def plugin_version(version)
    plugin.version = version
  end

  def plugin_description(description)
    plugin.description = description
  end

  def plugin_autoload(autoload)
    plugin.autoload = autoload
  end

  def plugin_config(filename)
    @_config = {}
    _kv_load!(filename)
  end

  # definitions
  def on(event_name, options={}, &blk)
    plugin.add_event(event_name, options, blk)
  end

  def once(event_name, options={}, &blk)
    options[:fire_once] = true
    on(event_name, options, &blk)
  end

  def off(event_object)
    plugin.remove_event(event_object)
  end

  def help(cmd_name, description)
    plugin.add_command_help(cmd_name, description)
  end

  def command(cmd_name, &blk)
    plugin.add_command(cmd_name, blk)
  end

  def uncommand(cmd_name)
    plugin.remove_command(cmd_name)
  end

  # useful commands
  def message(channel, message)
    connection.message channel, message
  end

  def action(channel, message)
    connection.action channel, message
  end

  def join(channel)
    connection.join channel
  end

  def part(channel)
    connection.part channel
  end
end
end