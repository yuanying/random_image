$:.unshift(File.dirname(__FILE__) + '/lib')

require 'data_mapper'
require 'dm-pagination'
require 'dm-pagination/paginatable'
DataMapper::Model.append_extensions DmPagination::Paginatable

require 'yaml'
require 'fileutils'
require 'image'

require 'sinatra'

config = YAML.load_file File.join(File.dirname(__FILE__), 'config.yml')

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

get '/images/:id' do
  image = Image.get(params[:id])
  send_file image.path
end

get '/' do
  per_page = params[:per_page] || '10'
  per_page = per_page.to_i
  num_page = Image.paginate.num_pages
  @images = Image.paginate(:page => (rand(num_page - 1) + 1), :per_page => 20)

  erb :index
end