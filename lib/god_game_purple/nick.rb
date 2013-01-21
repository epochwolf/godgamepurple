module GodGamePurple
class Nick
  attr_reader :nick, :user, :host

  def initialize(nickstr)
    _, @nick, @user, @host = /^(.*?)(!(.*?)@(.*?))?$/.match(nickstr).to_a
  end

  def to_a
    [nick, user, host]
  end

  def to_s(full=false)
    full ? "#{nick}!#{user}@#{host}" : nick
  end

  def to_sym(*args)
    to_s(*args).to_sym
  end
end
end