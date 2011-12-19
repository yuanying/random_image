#!/usr/bin/env ruby -wKU
$:.unshift(File.dirname(__FILE__) + '/../lib')

require 'data_mapper'
require 'dm-migrations'

require 'yaml'
require 'fileutils'
require 'ri_config'
require 'image_science'
require 'image'


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
    begin
      ImageScience.with_image(image.path) do |img|
        img.cropped_thumbnail(76) do |thumb|
          thumb.save image.thumbnail_path(config)
        end
      end
    rescue
      puts "Cannot create thumbnail: #{image.path}"
    end
  end
end

Image.all(:exists => false).destroy
Image.update(:exists => false)

