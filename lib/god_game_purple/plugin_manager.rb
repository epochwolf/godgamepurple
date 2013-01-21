module GodGamePurple
class PluginManager
  attr_reader :connection, :event_engine

  def initialize(connection, plugins_folder)
    @connection = connection
    @event_engine = connection.event_engine
    @folder = plugins_folder
    @commands = {}
    @plugins = {}
    bind_command_event!
    load_plugins!
  end

  def commands
    @commands.keys
  end

  def add_command(name, blk)
    if @commands[name]
      event_engine.fire "plugin.warning", "Command #{name} already registered by another plugin."
    else
      @commands[name] = blk
      @event_engine.fire "manager.command_added", name, blk
    end
  end

  def remove_command(name)
    @commands.delete(name)
    @event_engine.fire "manager.command_removed", name
  end

  def add_event(name, blk)
    @event_engine.bind name, &blk
    @event_engine.fire "manager.add_event", name, blk
  end 

  def remove_event(name, blk)
    @event_engine.unbind name, blk
    @event_engine.fire "manager.remove_event", name, blk
  end

  def load_plugin(name)
    @plugins[name].try(:load!)
  end

  def unload_plugin(name)
    @plugins[name].try(:unload!)
  end

  def reload_plugins!
    @plugins.values.each(&:unload!)
    @plugins.clear
    load_plugins!
  end

  protected
  def load_plugins!
    Dir.glob(@folder + "/*.rb").each do |file|
      p = Plugin.new(self, file)
      @plugins[p.short_name] = p
    end
  end

  def bind_command_event!
    @event_engine.bind "command" do |command, channel, nick, *args|
      execute_command command, channel, nick, *args
    end
  end

  def execute_command(command, channel, nick, *args)
    if cmd_proc = @commands[command]
      cmd_proc.call(channel, nick, *args)
    end 
  end
end
end