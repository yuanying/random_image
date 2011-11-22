
class Image
  include DataMapper::Resource

  property :id,         Serial
  property :path,       FilePath
  property :created_at, DateTime
end

