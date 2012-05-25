require 'digest/md5'
require 'uuid'

class DataFile < ActiveRecord::Base
  belongs_to :user
  attr_accessible :path, :digest, :token_id
  
  def capture_file(upload, available)
    breakpoint
    name =  upload['datafile'].original_filename
    directory = "#{Rails.root}/public/data"
    # create the file path
    self.path = File.join(directory, name)
    # write the file
    post = File.open(self.path, "wb") { |f| f.write(upload['datafile'].read(available)) }
    # Get the MD5 of the file and return the fetch key
    file_contents = IO.read(self.path)
    self.size = file_contents.length
    self.digest = Digest::MD5.hexdigest(file_contents)
    self.token_id = UUID.new.generate
    # Quota handling.  Start by just getting the size.
  end  
end
