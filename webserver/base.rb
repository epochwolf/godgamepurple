# sinatra app here. 
puts "WEBSERVER YO"

get '/' do
  haml :index
end