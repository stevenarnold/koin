require 'digest/md5'

class Users < ActiveRecord::Base
  attr_accessible :username, :p_search_all, :p_admin, :quota
  has_many :data_files
  
  def _gensalt(len=8)
    (0...len).map{65.+(rand(25)).chr}.join
  end

  def save
    if @passwd != nil
      self.salt = _gensalt
      self.enc_passwd = Digest::MD5.hexdigest(@passwd + self.salt)
    end
    super
  end

  def is_admin
    self.p_admin
  end

  def owns_token(token)
    df =  DataFile.where("digest LIKE ?", token)[0]
    self.id == df.creator_id
  end

  def initialize(attributes)
    @passwd = attributes[:passwd]
    attributes.delete(:passwd)
    super(attributes)
  end
  
  def can_download(data_file)
    # Later this will check permissions
    true
  end
end
