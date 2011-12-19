
class Image
  include DataMapper::Resource

  property :id,         Serial
  property :path,       FilePath,   :unique => true
  property :point,      Integer,    :default => 0, :index => true
  property :created_at, DateTime

  property :exists,     Boolean,    :default => false

  def thumbnail_path config
    tmp_dir     = config.tmp_dir
    regexp_path = Regexp.compile('^' + Regexp.escape(config.image_dir))
    tmp_path    = self.path.to_s.split(regexp_path).last
    thumbnail_path = File.join(tmp_dir, 'thumb', tmp_path)
    FileUtils.mkdir_p(File.dirname(thumbnail_path)) unless File.exist?(File.dirname(thumbnail_path))
    thumbnail_path
  end
end

