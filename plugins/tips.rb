plugin_name         "Tips"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Add custom commands to the bot"

@tips = KeyValueStore.new("plugins/tips.json")

command "add" do |c, n, tip, *msg|
  msg = msg.join " "
  if plugin_manager.commands.include? tip
    message c, "Already have a command with that name. Try something else?"
  elsif @tips[tip]
    message c, "Bummer, someone else beat you to it!"
  else 
    @tips[tip] = msg
    message c, "Tip added."    
  end
end

command "remove" do |c, n, tip|
  if n.admin?  
    if plugin_manager.commands.include? tip
      message c, "I'm rather attached to my commands. I'll have to decline."
    elsif @tips[tip]
      @tips[tip] = nil
      message c, "Tip removed."
    else
      message c, "No tip by tha... ahem. Tip removed. :)"
    end
  else
    message c, "I am disinclined to acquiesce to your request"
  end
end

command "tips" do |c, n|
  message c, "There are #{@tips.count} tips in the system."
end

command "debugtips" do |c, n|
  puts @tips.inspect
end

on "command" do |cmd, c, n, *args|
  puts "Tips: cmd"
  next if plugin_manager.commands.include? cmd
  puts "Tips: not a command, looking up"
  if msg = @tips[cmd]
    message c, msg
  end
end