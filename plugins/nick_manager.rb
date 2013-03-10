plugin_name         "Nick Manager"
plugin_author       "epochwolf"
plugin_version      "0.0.1"
plugin_description  "Nick management tools"

on "nick_error.in_use" do 
  connection.change_nick(bot_config.alternative_nick!)
end