module GodGamePurple
class Plugin
  attr_accessor :short_name, :name, :version, :author, :description, :manager, :autoload

  def initialize(manager, file)
    @filename = file
    @short_name = File.basename file, '.rb'
    @manager = manager
    @commands = {}
    @events = []
    @autoload = true
    @loaded = false
    @loadable = true
    load!
  end

  def add_command_help(name, description)
    nil # do nothing
  end

  def add_command(name, blk)
    @commands[name] = blk
    @manager.add_command(name, blk) if @loaded || @autoload
    @manager.event_engine.fire "plugin.add_command", short_name, name, blk
  end

  def remove_command(name)
    @manager.remove_command(name)
    @commands.delete(name)
    @manager.event_engine.fire "plugin.remove_command", short_name, name
  end

  def add_event(name, options, blk)
    e = Event.new(name, options, &blk)
    @events << e
    @manager.add_event(e) if @loaded || @autoload
    @manager.event_engine.fire "plugin.add_event", short_name, name, blk
  end

  def remove_event(event_object)
    @manager.remove_event(event_object)
    @events.delete(event_object)
    @manager.event_engine.fire "plugin.remove_event", short_name, name, blk
  end

  def loaded?
    @loaded
  end

  def load!
    return if @loaded
    load_plugin_file!
    @manager.event_engine.fire "plugin.loaded", short_name if @loaded
  end

  def unload!
    return unless @loaded
    @commands.keys.each{|key| remove_command key }
    @events.dup.each{|event_object| remove_event *event_object }
    @loaded = false
    @manager.event_engine.fire "plugin.unloaded", short_name
  end

  protected
  def load_plugin_file!
    @dsl = PluginDsl.new(self, @filename)
    @manager.event_engine.fire "plugin.parsed", short_name
    @loaded = @autoload
  rescue StandardError => e
    @manager.event_engine.fire("plugin.error", @short_name, e.class.name, e.message, e.backtrace)
    @loaded = false
  end
end
end