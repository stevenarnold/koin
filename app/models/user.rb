require 'digest/md5'

class User < ActiveRecord::Base
  has_many :permitted_uses
  has_many :viewable_files, :class_name => 'DataFile', :foreign_key => "data_file_id",
           :through => :permitted_uses, :source => :data_file
  has_many :data_files
  
  attr_accessible :username, :passwd, :p_search_all, :p_admin, :quota
  before_save :set_up_passwd
  
  def _gensalt(len=8)
    (0...len).map{65.+(rand(25)).chr}.join
  end
  
  def passwd=(password)
    @passwd = password
  end

  def set_up_passwd
    # debugger
    if @passwd != nil
      self.salt = _gensalt
      self.enc_passwd = Digest::MD5.hexdigest(@passwd + self.salt)
    end
  end

  def is_admin
    self.p_admin
  end

  def owns_token(token)
    df =  DataFile.where("digest LIKE ?", token)[0]
    self.id == df.creator_id
  end

  def initialize(*args)
    #debugger
    attributes = args[0]
    if attributes
      @passwd = attributes[:passwd]
      attributes.delete(:passwd)
    end
    super(*args)
  end
  
  def can_download(data_file, password)
    #debugger
    if (!data_file.password) || (data_file.password == password)
      if data_file.p_any_logged_user || data_file.p_upon_token_presentation
        true
      elsif viewable_files.include?(data_file)
        true
      else
        false
      end
    else
      false
    end
  end
  
  def get_quota
    User.where("id = ?", self.id)[0].quota * 1024 * 1024
  end
  
  def used_quota
    # This is the sum of the size of the files created by this user.
    DataFile.where("id = ?", self.id).sum('size')
  end
  
  def available
    # Return the space available for this user, in bytes
    if quota != 0
      get_quota - used_quota
    else
      Float::INFINITY
    end
  end
end
