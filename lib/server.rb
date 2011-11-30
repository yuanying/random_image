require 'data_mapper'
require 'dm-pagination'
require 'dm-pagination/paginatable'
DataMapper::Model.append_extensions DmPagination::Paginatable

require 'yaml'
require 'fileutils'
require 'image'

require 'sinatra/base'

config = YAML.load_file File.join(File.dirname(__FILE__), '..', 'config.yml')

tmp_dir = File.expand_path(config['tmp_dir'])
FileUtils.mkdir_p(tmp_dir) unless File.exist?(tmp_dir)

db_path = File.expand_path(config['db_path'])

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{db_path}")

class String
  def camel_case
    split('_').map{|e| e.capitalize}.join
  end
end

class RandomImage < Sinatra::Base

  set :views, File.join(File.dirname(__FILE__), '..', 'views')
  set :public_folder, File.join(File.dirname(__FILE__), '..', 'public')

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  get '/images/:id' do
    image = Image.get(params[:id])
    send_file image.path
  end

  get '/' do
    count = Image.count
    id = (rand(Image.count) + 1)
    @image = Image.get(id)

    erb :index
  end

end