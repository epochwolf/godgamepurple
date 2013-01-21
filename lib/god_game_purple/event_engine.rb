require 'set'

# Do not allow external input to define events because firing a non-existent event will create an entry in the events table. 
module GodGamePurple
class EventEngine
  def initialize(options={})
    reset_events!
    enable_debug! if options[:debug]
  end

  def fire(events, *args)
    each_event(events) do |name|
      @events[name].each{|p| p.call(*args) }
      @events[:*].each{|p| p.call(name, *args) } if @debug
    end
  end

  # events is "event|event2"
  # Returns the callback so you can unbind it later. 
  def bind(events, &callback)
    each_event(events) do |name|
      @events[name] << callback
    end
    return callback
  end

  # events is "event|event2"
  # if callback returns true, it is unbound. 
  # return value is the bound proc. 
  def bind_once(events, &callback)
    new_callback = proc do |*args|
      unbind(events, new_callback) if callback.call(*args)
    end
    bind(events, &new_callback)
  end

  # events is "event|event2"
  def unbind(events, callback)
    each_event(events) do |name|
      @events[name].delete(callback)
    end
  end


  # event_name can only be a single event. 
  def bound?(event_name, callback)
    @events[event_name.to_sym].include?(callback)
  end

  def reset_events!
    @events = Hash.new{|h, k| h[k] = Set.new }
  end

  def enable_debug!
    @debug = true
  end

  private
  def each_event(events, &blk)
    events.split(',').map{|name| name.strip.to_sym }.each(&blk)
  end
end
end
