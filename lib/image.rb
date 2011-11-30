
class Image
  include DataMapper::Resource

  property :id,         Serial
  property :path,       FilePath
  property :point,      Integer,    :default => 0
  property :created_at, DateTime
end

