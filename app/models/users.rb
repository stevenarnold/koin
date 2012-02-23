require 'digest/md5'

class Users < ActiveRecord::Base
  attr_accessible :username, :p_search_all, :p_admin
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

  def initialize(attributes)
    @passwd = attributes[:passwd]
    attributes.delete(:passwd)
    super(attributes)
  end
end
