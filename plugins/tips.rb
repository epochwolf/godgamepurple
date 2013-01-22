plugin_name         "Tips"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Add custom commands to the bot"
plugin_config       "tips.yml"

command "add" do |c, n, tip, *msg|
  msg = msg.join " "
  if plugin_manager.commands.include? tip
    message c, "Already have a command with that name. Try something else?"
  elsif kv_read tip
    message c, "Bummer, someone else beat you to it!"
  else 
    kv_write tip, msg
    message c, "Tip added."    
  end
end

command "remove" do |c, n, tip|
  if plugin_manager.commands.include? tip
    message c, "I'm rather attached to my commands. I'll have to decline."
  elsif kv_read tip
    kv_write tip, nil
    message c, "Tip removed."
  else
    message c, "No tip by tha... ahem. Tip removed. :)"
  end
end

on "command" do |cmd, c, n, *args|
  next if plugin_manager.commands.include? cmd
  if msg = kv_read(cmd)
    message c, msg
  end
end