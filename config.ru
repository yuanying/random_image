$:.unshift(File.dirname(__FILE__) + '/lib')

require 'server'

run Sinatra::Application
