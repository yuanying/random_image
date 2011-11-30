require 'data_mapper'
require 'dm-pagination'
require 'dm-pagination/paginatable'
DataMapper::Model.append_extensions DmPagination::Paginatable

require 'yaml'
require 'fileutils'
require 'image'

require 'sinatra/base'
require 'json'

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

  post '/images/:id' do
    image = Image.get(params[:id])
    image.point = image.point + 1
    image.save
    content_type :json
    true.to_json
  end

  get '/favorite' do
    @count    = Image.count
    @page     = params[:page] || 0
    @page     = @page.to_i
    @next     = @page + 1;
    @next     = @count - 1 if @next >= @count
    @previous = @page - 1;
    @previous = 0 if @previous < 0

    @image    = Image.all(:order => [:point.desc], :offset => @page, :limit => 1).first

    erb :favorite
  end

  get '/' do
    @count        = Image.count
    @id           = params[:id] || (rand(Image.count) + 1)
    @id           = @id.to_i
    @next_id      = @id + 1
    @next_id      = 0 if @next_id > @count
    @previous_id  = @id - 1
    @previous_id  = @count if @previous_id == 0

    @image        = Image.get(@id)

    erb :index
  end

end