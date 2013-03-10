module GodGamePurple
class Event
  attr_reader :block
  attr_reader :events
  attr_reader :fire_once
  attr_reader :timeout
  attr_reader :bound_at

  def initialize(names, options={}, &blk)
    @events = String === names ? names.split('|') : names.map(&:to_s)
    @timeout = options[:timeout]
    @fire_once = options[:fire_once]
    @block = blk
    @bound = false
  end

  def call(*args)
    block.call(*args)
  end

  def bound?
    @bound
  end
  alias :on? :bound?

  def off?
    !bound?
  end

  # Called when the event added
  def bound!
    @bound = true
    @timeout_at = bound_at + timeout if timeout
  end

  # Called when the event removed
  def unbound!
    @bound = false
    @timeout_at = nil
  end

  def timed_out?
    Time.now > @timeout_at if @timeout_at
  end
end
end