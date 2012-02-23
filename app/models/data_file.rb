require 'digest/md5'
require 'uuid'

class DataFile < ActiveRecord::Base
  belongs_to :user
  attr_accessible :path, :digest, :token_id
  
  def capture_file(upload)
    name =  upload['datafile'].original_filename
    directory = "public/data"
    # create the file path
    self.path = File.join(directory, name)
    # write the file
    #FIXME -- In the future, we need to make sure we don't read more than
    # quota bytes
    post = File.open(self.path, "wb") { |f| f.write(upload['datafile'].read) }
    # Get the MD5 of the file and return the fetch key
    self.digest = Digest::MD5.hexdigest(File.read(self.path))
    self.token_id = UUID.new.generate
  end  
end
