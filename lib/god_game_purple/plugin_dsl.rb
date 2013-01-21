module GodGamePurple
class PluginDsl
  attr_accessor :name, :version, :author, :description
  def initialize(plugin, file)
    @plugin = plugin
    instance_eval File.read(file), file
  end

  def plugin
    @plugin
  end

  def plugin_manager
    plugin.manager
  end

  def connection 
    plugin_manager.connection
  end

  def event_engine
    plugin.manager.event_engine
  end

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

  def on(event_name, &blk)
    plugin.add_event(event_name, blk)
  end

  def once(event_name, &blk)
    warn "once isn't supported"
  end

  def off(event_name, blk)
    plugin.remove_event(event_name, blk)
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
end
end