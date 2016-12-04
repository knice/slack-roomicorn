require 'sinatra/base'

require './app'
require './comments'

map('/') { run Main }
map('/comments') { run Comment }