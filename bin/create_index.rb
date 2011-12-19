#!/usr/bin/env ruby -wKU
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'data_mapper'
require 'dm-migrations'

require 'yaml'
require 'fileutils'
require 'image_science'
require 'image'

class RIConfig
  attr_reader :opts
  def initialize path
    @opts = YAML.load_file path
  end

  def image_dir
    File.expand_path(opts['image_dir'])
  end

  def tmp_dir
    File.expand_path(opts['tmp_dir'])
  end

  def db_path
    File.expand_path(opts['db_path']).tap do |db_path|
      FileUtils.mkdir_p(File.dirname(db_path)) unless File.exist?(File.dirname(db_path))
    end
  end
end

config = RIConfig.new(File.join(File.dirname(__FILE__), '..', 'config.yml'))


DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{config.db_path}")
# DataMapper.auto_migrate!
DataMapper.auto_upgrade!

Dir.glob(File.join(config.image_dir, '**', '*.{jpg,jpeg,JPG}')) do |path|
  if image = Image.first( :path => path )
    image.update(:exists => true)
  else
    image = Image.create( :path => path, :exists => true )
  end
  unless File.exist?(image.thumbnail_path(config))
    ImageScience.with_image(image.path) do |img|
      img.cropped_thumbnail(57) do |thumb|
        thumb.save image.thumbnail_path(config)
      end
    end
  end
end

Image.all(:exists => false).destroy
Image.all(:exists => true).update(:exists => false)

