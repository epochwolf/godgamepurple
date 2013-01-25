plugin_name         "Tips"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Add custom commands to the bot"

@tips = KeyValueStore.new("plugins/tips.json")

command "add" do |c, n, tip, *msg|
  add_tip(c, n, tip, *msg)
end

command "remove" do |c, n, tip|
  remove_tip(c, n, tip)
end

command "tip" do |c, n, subcommand, tip, *args|
  case subcommand
  when "a", "add"    then add_tip(c, n, tip, *args)
  when "r", "remove" then remove_tip(c, n, tip)
  when "s", "show"   then show_tip(c, n, tip)
  when "c", "count"  then count_tip(c, n)
  when 'd', 'debug'  then puts @tips.inspect
  else message c, "Available sub commands: add [name] [message], remove [name], show [name], count"
  end 
end

def add_tip(c, n, tip, *msg)
  return message(c, "Already have a command with that name. Try something else?") if plugin_manager.commands.include? tip
  return message(c, "Bummer, someone else beat you to it!") if @tips[tip]
  @tips[tip] = msg.join " "
  message c, "Tip added."
end

def remove_tip(c, n, tip)
  return message(c, "I am disinclined to acquiesce to your request") if n.admin?  
  return message(c, "I'm rather attached to my commands. I'll have to decline.") if plugin_manager.commands.include? tip
  return message(c, "No tip by tha... ahem. Tip removed. :)") unless @tips[tip]
  @tips[tip] = nil
  message c, "Tip removed."
end

def show_tip(c, n, tip)
  return message(c, "No tip by that name.") unless msg = @tips[tip]
  message c, "#{tip}: #{msg}"
end

def count_tip(c, n)
  message c, "There are #{@tips.count} tips in the system."
end

on "command" do |cmd, c, n, *args|
  next if plugin_manager.commands.include? cmd
  next unless msg = @tips[cmd]

  msg = format_message(msg, c, n, *args)
  if msg =~ %r(^/me ) then 
    action c, msg[4..-1]
  else 
    message c, msg
  end
end

def format_message(msg, c, n, *args) 
  msg.dup.tap do |m|
    m.gsub!("{nick}", n.to_s)
    m.gsub!("{channel}", c.to_s)
    args.each_with_index{|v, i| m.gsub!("{arg#{i+1}}", v) }
    #m.gsub!(/\{arg\d+\}/, n.to_s)
  end
end