require 'sinatra/base'

require './app'
require './comments'

map('/') { run ROOM::Main }
map('/comments') { run Comment }