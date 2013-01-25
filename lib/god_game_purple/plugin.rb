module GodGamePurple
class Plugin
  attr_accessor :short_name, :name, :version, :author, :description, :manager

  def initialize(manager, file)
    @filename = file
    @short_name = File.basename file, '.rb'
    @manager = manager
    @commands = {}
    @events = []
    @loaded = false
    @loadable = true
    load!
  end

  def add_command_help(name, description)
    nil # do nothing
  end

  def add_command(name, blk)
    @commands[name] = blk
    @manager.add_command(name, blk)
    @manager.event_engine.fire "plugin.add_command", short_name, name, blk
  end

  def remove_command(name)
    @manager.remove_command(name)
    @commands.delete(name)
    @manager.event_engine.fire "plugin.remove_command", short_name, name
  end

  def add_event(name, blk)
    @events << [name, blk]
    @manager.add_event(name, blk)
    @manager.event_engine.fire "plugin.add_event", short_name, name, blk
  end

  def remove_event(name, blk)
    @manager.remove_event(name, blk)
    @events.delete([name, blk])
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
    @events.dup.each{|name_blk| remove_event *name_blk }
    @loaded = false
    @manager.event_engine.fire "plugin.unloaded", short_name
  end

  protected
  def load_plugin_file!
    @dsl = PluginDsl.new(self, @filename)
    @loaded = true
  rescue StandardError => e
    @manager.event_engine.fire("plugin.error", @short_name, e.class.name, e.message, e.backtrace)
    @loaded = false
  end
end
end