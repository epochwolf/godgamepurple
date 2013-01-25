module GodGamePurple
class Nick
  attr_reader :name, :user, :host

  def initialize(nickstr)
    _, @name, @user, @host = /^(.*?)(!(.*?)@(.*?))?$/.match(nickstr).to_a
  end

  def to_a
    [name, user, host]
  end

  def to_s(full=false)
    full ? "#{name}!#{user}@#{host}" : name
  end

  def to_sym(*args)
    to_s(*args).to_sym
  end

  def admin?
    name == "epochwolf"
  end
end
end