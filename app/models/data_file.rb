require 'digest/md5'
require 'uuid'

class DataFile < ActiveRecord::Base
  belongs_to :user
  attr_accessible :path, :digest, :token_id
  
  def capture_file(upload, available)
    name =  upload['datafile'].original_filename
    directory = "#{Rails.root}/public/data"
    # create the file path
    self.path = File.join(directory, name)
    # write the file
    puts "available = #{available}"
    post = File.open(self.path, "wb")
    post.write(upload['datafile'].read(available))
    post.close
    puts "done writing"
    # Get the MD5 of the file and return the fetch key
    self.size = File.stat(self.path).size
    self.digest = Digest::MD5.hexdigest(file_contents)
    self.token_id = UUID.new.generate
    # Quota handling.  Start by just getting the size.
  end  
end
