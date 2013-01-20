require 'digest/md5'
require 'uuid'

class DataFile < ActiveRecord::Base
  belongs_to :user
  has_many :permitted_uses
  has_many :viewers, :foreign_key => "user_id",
           :through => :permitted_uses, :source => :user
  
  attr_accessible :path, :digest, :token_id, :description, :subject,
                  :creator_id
  attr_accessor :p_permissions
  # attr_accessor :path, :digest, :token_id

  class OverQuotaError < StandardError
    attr_accessor :available
  end

  class NoFileSpecifiedError < StandardError; end
  
  def capture_file(upload, available)
    # Get the MD5 of the file and return the fetch key
    self.token_id = UUID.new.generate
    begin
      name =  upload['upload'].original_filename
    rescue NoMethodError
      raise DataFile::NoFileSpecifiedError
    end
    directory = "#{Rails.root}/public/data/#{self.token_id}"
    # create the directory
    Dir::mkdir(directory)
    # create the file path
    self.path = File.join(directory, name)
    # write the file
    post = File.open(self.path, "wb")
    amt_to_read = 1000000
    file_content = ""
    while new_content = upload['upload'].read(amt_to_read)
      file_content += new_content
      if file_content.length > available
        raise DataFile::OverQuotaError, available
      end
    end
    post.write(file_content)
    post.close
    self.size = File.stat(self.path).size
    self.digest = Digest::MD5.hexdigest(file_content)
    # Quota handling.  Start by just getting the size.
  end
  
  def multiple_viewers?
    viewers.length > 0 ? true : false
  end
end

class PermittedUse < ActiveRecord::Base
  belongs_to :user
  belongs_to :data_file
end
