#!/usr/bin/env ruby -wKU
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'data_mapper'
require 'dm-migrations'

require 'yaml'
require 'fileutils'
require 'image'

config = YAML.load_file File.join(File.dirname(__FILE__), '..', 'config.yml')

tmp_dir = File.expand_path(config['tmp_dir'])
FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)

image_dir = File.expand_path(config['image_dir'])

db_path = File.expand_path(config['db_path'])
FileUtils.mkdir_p(File.dirname(db_path)) unless File.exist?(File.dirname(db_path))

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{db_path}")
DataMapper.auto_migrate!
# DataMapper.auto_upgrade!

Dir.glob(File.join(image_dir, '**', '*.{jpg,jpeg,JPG}')) do |path|
  Image.create( :path => path )
end

