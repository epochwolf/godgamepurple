require 'json'

# A very primitive way to store data. 
class KeyValueStore
  def initialize(file)
    @filename = File.absolute_path(file)
    @store = begin 
      JSON.load(File.read @filename) 
    rescue JSON::ParserError 
      nil 
    end
    @store = {} unless @store.is_a? Hash
  end

  def [](key)
    return unless key
    @store[key.to_s]
  end

  def []=(key, value)
    return unless key
    if value == nil
      @store.delete(key)
    else
      @store[key.to_s] = value
    end
    save!
  end

  def length
    @store.keys.count
  end

  alias :count :length

  def inspect
    {filename: @filename, store: @store}.inspect
  end

  def save!
    open @filename, 'w' do |io|
      io.write(JSON.dump(@store))
    end
  end
end