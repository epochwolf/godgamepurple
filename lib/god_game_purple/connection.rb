require 'socket'

module GodGamePurple
class Connection
  attr_reader :server, :port, :nick, :username, :realname, :password, :event_engine, :debug, :trigger

  def initialize(options={})
    @server   = options["server"]    or raise ArgumentError, "Missing server option"
    @port     = options["port"]      or "6667"
    @nick     = options["nick"]      or raise ArgumentError, "Missing nick option"
    @username = options["username"]  or "purple"
    @realname = "Game God Purple"
    @password = options["password"]
    @debug    = options["debug"]
    @trigger  = options["trigger"]
    @nicks = {}
    @channels = {}
    @event_engine = options[:event_engine] || GodGamePurple::EventEngine.new(debug: options[:debug])
    enable_debug! if @debug
  end

  def run!
    connect!
    handshake!
    @running = true
    while @running do
      receive!
    end
  end

  def connect!
    @last_ping = Time.now
    @socket.close if @socket
    @socket = TCPSocket.open(server, port)
  rescue SystemCallError => e
    puts "Unable to connect: #{e.message}"
    exit
  end

  def raw(str)
    str = str.strip
    if str.bytesize > 510
      event "connection.send_error", "Attempted to send message exceeding 512 bytes."
    elsif str.empty?
      event "connection.send_error", "Attempted to send empty message."
    else
      event_engine.fire("connection.send", str)
      @socket.puts(str)
    end
  end

  def handshake!
    raw "PASS #{password}" if password
    change_nick(nick)
    raw "USER #{nick} #{username} example.com #{server} :#{realname}"
  end

  def quit(message)
    @running = false
    raw "QUIT :#{message}"
  end

  def mode(*args)
    raw "MODE #{args.join(" ")}"
  end

  def change_nick(nick)
    raw "NICK #{nick}"
  end

  def privmsg(channel, message)
    raw "PRIVMSG #{channel} :#{message}"
  end

  def action(channel, message)
    raw "PRIVMSG #{channel} :\001ACTION #{message}\001"
  end

  def join(*channels)
    raw "JOIN #{channels.join ","}"
  end

  def part(*channels)
    raw "PART #{channels.join ","}"
  end

  def topic(channel, topic=nil)
    if topic
      raw "TOPIC #{channel} :#{topic}"
    else
      raw "TOPIC #{channel}"
    end
  end

  def receive!
    str = @socket.gets
    event "connection.receive", str
    parse_message str
  end

  def parse_message(str)
    *tokens, body = tokenize_message(str)
    return if handle_ping(*tokens, body)

    case tokens[1]
    when 'PRIVMSG' then 
      nick = parse_nick tokens[0]
      channel = parse_channel tokens[2]
      if body.start_with?("\x01ACTION")
        event "action", channel, nick, body[8..-2] # the end of the body has a \x01 on it
      else
        if body.start_with?(trigger)
          cmd, *args = body[trigger.length..-1].split(' ')
          event "command", cmd, channel, nick, *args
        else
          event "message", channel, nick, body
        end
      end
    when 'JOIN' then 
      nick = parse_nick(tokens[0])
      channel = parse_channel(tokens[2])
      if self.nick == nick.name
        event "join.self", channel
      else
        event "join", channel, nick
      end
    # responses
    when '376' then event "motd.end" # Good event to hook stuff
    when '332' then event "topic", parse_channel(tokens[3]), body
    when '332' then event "names", parse_channel(tokens[3]), body
    when '366' then event "names.end", parse_channel(tokens[3])
    # errors
    when "432"  then event "nick_error, nick_error.invalid", parse_nick(tokens[3])
    when "433"  then event "nick_error, nick_error.in_use", parse_nick(tokens[3])
    when "436"  then event "nick_error, nick_error.collision", parse_nick(tokens[3])
    when "437"  then # Netsplit time out protection
      if tokens[3] =~ %r"^[#%%&+]"
        event "channel_error, channel_error.unavailable", parse_channel(tokens[3])
      else
        event "nick_error, nick_error.unavailable", parse_nick(tokens[3])
      end
    else
      event "connection.unknown_packet", str
    end
  end

  def enable_debug!
    @debug = true
    event_engine.enable_debug!
    event_engine.bind("connection.open"       ){ debug "Connection opened to #{server} on port #{port}" }
    event_engine.bind("connection.send"       ){|str| debug " Server << #{str}" }
    event_engine.bind("connection.send_error" ){|str| debug " Server <<ERR #{str} " }
    event_engine.bind("connection.receive"    ){|str| debug " Server >> #{str}" }
    event_engine.bind("connection.timeout"    ){ debug "Lost connection to the server." }
    event_engine.bind("ping"){|server, last_ping| debug "Warning: More than 5 minutes since last ping" if Time.now - @last_ping > 600 }
  end

  def enable_event_trace!
    enable_debug! unless @debug
    event_engine.bind("*"){|event, *args| debug "  Event -> #{event.inspect}, #{args.inspect}" unless event =~ /^connection\./ }
  end

  protected

  def event(*args)
    event_engine.fire(*args)
  end
  
  def debug(str)
    puts str
  end

  def tokenize_message(str)
    str = str[0] == ":" ? str[1..-1] : str #strip leading colon
    str, after_colon = str.split(':', 2)
    return *str.split, after_colon ? after_colon.strip : nil
  end

  def parse_nick(str)
    GodGamePurple::Nick.new(str)
  end

  def parse_channel(str)
    GodGamePurple::Channel.new(str)
  end

  def handle_ping(*tokens)
    return false unless tokens[0] == "PING"
    server = tokens[2]
    raw "PONG #{server}"
    event "ping", server, @last_ping
    @last_ping = Time.now
    return true
  end
end
end