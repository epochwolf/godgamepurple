plugin_name         "Updater"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Assumes the bot is a git clone and tries to update itself."

command "update" do |c, n|
  next unless n.admin?
  message c, "Here it goes..."
  begin 
    `git pull`
  rescue Errno::ENOENT
    message c, "Uh oh... git broke."
  else
    message c, "Pulled latest code. Reloading plugins."
    plugin_manager.reload_plugins!
    message c, "Done."
    # Code to restart the bot if we want to do that in the future.
    #IO.popen("kill #{Process.pid} && ruby purple.rb&")
  end
end

