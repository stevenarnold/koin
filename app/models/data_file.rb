require 'digest/md5'

class DataFile < ActiveRecord::Base
  attr_accessor :path, :digest
  
  def capture_file(upload)
    name =  upload['datafile'].original_filename
    directory = "public/data"
    # create the file path
    @path = File.join(directory, name)
    # write the file
    post = File.open(@path, "wb") { |f| f.write(upload['datafile'].read) }
    # Get the MD5 of the file and return the fetch key
    @digest = Digest::MD5.hexdigest(File.read(@path))
  end  
end
