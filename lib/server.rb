require 'data_mapper'
require 'dm-pagination'
require 'dm-pagination/paginatable'
DataMapper::Model.append_extensions DmPagination::Paginatable

require 'yaml'
require 'fileutils'
require 'ri_config'
require 'image'

require 'sinatra/base'
require 'json'

$config = RIConfig.new(File.join(File.dirname(__FILE__), '..', 'config.yml'))

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite://#{$config.db_path}")

DataMapper.auto_upgrade!

class String
  def camel_case
    split('_').map{|e| e.capitalize}.join
  end
end

class RandomImage < Sinatra::Base

  set :views, File.join(File.dirname(__FILE__), '..', 'views')
  set :public_folder, File.join(File.dirname(__FILE__), '..', 'public')

  configure :production do
    require 'sinatra-xsendfile'
    helpers Sinatra::Xsendfile
    Sinatra::Xsendfile.replace_send_file!
  end

  configure :development do
    require 'sinatra/reloader'
    register Sinatra::Reloader
  end

  get '/' do
    @per_page = 40
    @page     = (params[:page] || (rand(Image.count) / @per_page + 1)).to_i
    @images   = Image.paginate(:order => [:point.desc], :page => @page, :per_page => @per_page)
    @next     = @page + 1;
    @next     = 1 if @next >= @images.num_pages
    @previous = @page - 1;
    @previous = @images.num_pages if @previous < 1

    erb :index
  end

  get '/images/:id' do
    @id           = params[:id] || (rand(Image.count) + 1)
    @id           = @id.to_i

    @image        = Image.get(@id)
    @next         = Image.first(:id.gt => @id, :order => [:id.asc])
    @next         = Image.first unless @next
    @next_id      = @next.id
    @previous     = Image.first(:id.lt => @id, :order => [:id.desc])
    @previous     = Image.last unless @previous
    @previous_id  = @previous.id

    erb :images
  end

  get '/files/:id' do
    image = Image.get(params[:id])
    send_file image.path.to_s
  end

  post '/files/:id' do
    image = Image.get(params[:id])
    image.point = image.point + 1
    image.save
    content_type :json
    true.to_json
  end

  get '/thumbs/:id' do
    image = Image.get(params[:id])
    send_file image.thumbnail_path($config)
  end

  get '/favorites' do
    @per_page = 40
    @page     = params[:page] || 1
    @page     = @page.to_i
    @images   = Image.paginate(:order => [:point.desc], :page => @page, :per_page => @per_page)
    @next     = @page + 1;
    @next     = 1 if @next >= @images.num_pages
    @previous = @page - 1;
    @previous = @images.num_pages if @previous < 1

    erb :favorites
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

end