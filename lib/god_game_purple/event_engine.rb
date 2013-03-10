require 'set'

# Do not allow external input to define events because firing a non-existent event will create an entry in the events table. 
module GodGamePurple

class EventEngine
  def initialize(options={})
    reset_events!
    enable_debug! if options[:debug]
  end

  def fire(events, *args)
    each_event(events) do |event_name|
      @events[event_name].to_a.each do |event_object| 
        safe_call event_name, event_object, *args 
        remove event_object if event_object.fire_once
      end
      @events[:*].each{|p| p.call(event_name, *args) } if @debug
    end
    clean_up_timeouts!
  end

  def add(event_object)
    @timeouts << event_object if event_object.timeout
    event_object.events.each{|event_name| @events[event_name] << event_object }
    event_object.bound!
    return event_object
  end

  def remove(event_object)
    event_object.events.each{|event_name| @events[event_name].delete event_object }
    event_object.unbound!
    return event_object
  end
  alias :unbind :remove

  def clean_up_timeouts!
    @timeouts.collect(&:timed_out?).each{|e| remove(e) }
  end

  # events is "event|event2"
  # return value is an event object. 
  def bind(events, &callback)
    add Event.new(events.split("|"), &callback)
  end

  # events is "event|event2"
  # return value is an event object. 
  def bind_once(events, &callback)
    add(Event.new(events.split("|"), fire_once: true &callback))
  end

  def reset_events!
    @timeouts = []
    @events = Hash.new{|h, k| h[k] = Set.new }
  end

  def enable_debug!
    @debug = true
  end

  private
  def each_event(events, &blk)
    events.split('|').map{|name| name.strip }.each(&blk)
  end

  def safe_call(event, blk, *args)
    blk.call *args
  rescue StandardError => e
    raise if event == "handled_exception"
    fire "handled_exception", e.class.name, e.message, e.backtrace
  end
end
end
