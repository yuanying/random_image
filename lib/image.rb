
class Image
  include DataMapper::Resource

  property :id,         Serial
  property :path,       FilePath,   :unique => true
  property :point,      Integer,    :default => 0, :index => true
  property :created_at, DateTime
end

