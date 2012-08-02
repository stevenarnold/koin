require 'digest/md5'

# A 'user' may be a person or a group of people.  In Koin, we do not distinguish
# between the two.  Even to the extent of logging in, while you almost never 
# log in as a group, and you almost always do as a user, there is no fundamental
# code-level checking we do to make sure that is enforced.  (Sometimes you don't
# want users to log in, and sometimes maybe you want to be able to log in as a 
# group without first creating a user and putting the user in that group; although
# admittedly the latter arrangement is more a testing convenience).
class User < ActiveRecord::Base
  has_many :permitted_uses
  has_many :viewable_files, :class_name => 'DataFile', :foreign_key => "data_file_id",
           :through => :permitted_uses, :source => :data_file
  has_many :data_files
  
  # Group-to-group membership  
  
  has_many :group_memberships_children, :class_name => "GroupMembership",
           :foreign_key => :parent_group_id
  has_many :child_groups, :through => :group_memberships_children, :source => :child_group
  
  has_many :group_memberships_parents, :class_name => "GroupMembership", 
           :foreign_key => :child_group_id
  has_many :parent_groups, :through => :group_memberships_parents, :source => :parent_group

  # has_many :parent_group_links, :class_name => 'GroupMembership',
  #          :foreign_key => 'parent_user_id'
  # has_many :parent_groups, :through => :parent_group_links,
  #          :foreign_key => "parent_user_id"
  # 
  # has_many :child_group_links, :class_name => 'GroupMembership',
  #          :foreign_key => 'child_user_id'
  # has_many :child_groups, :through => :child_group_links,
  #          :foreign_key => "child_user_id"
  
  attr_accessible :username, :passwd, :p_search_all, :p_admin, :quota
  before_save :set_up_passwd
  
  scope :all_groups, lambda {
    find(:all)
  }
  
  def self.user_files
    User.find_by_sql("SELECT    u.id, u.username, count(df.digest) AS num,
                            sum(df.size) AS size, u.quota
                  FROM      users u
                  LEFT JOIN data_files df
                  ON        u.id = df.creator_id
                  WHERE     u.id IN (SELECT    count(df.creator_id)
                                     FROM      data_files df)
                  UNION ALL
                  SELECT    u.id, u.username, 0 AS num, 0 AS size, u.quota
                  FROM      users u
                  WHERE     u.id NOT IN (SELECT    count(df.creator_id)
                                         FROM      data_files df)
                  ORDER BY  u.username")
  end
  
  # Return all ancestors of the current entity
  def all_ancestors(ancestors=[])
    # Assumes only one parent
    result = []
    c = self
    while c && c.parent_groups
      result += c.parent_groups
      c = c.parent_groups[0]
    end
    result
  end
  
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
    # debugger
    if (!data_file.expiration) || (data_file.expiration > Time.now.localtime)
      if (!data_file.password) || (data_file.password == password)
        if data_file.p_any_logged_user || data_file.p_upon_token_presentation
          :permission_granted
        elsif viewable_files.include?(data_file)
          :permission_granted
        else
          #debugger
          all_ancestors.each do |ancestor|
            if ancestor.viewable_files.include?(data_file)
              return :permission_granted
            end
          end
          # User doesn't have permission to view this file
          :permission_denied
        end
      else
        # Password required & incorrect
        :wrong_password
      end
    else
      # File has expired
      :file_expired
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

# There is no difference between an Entity, a User and a Group
Entity = User
Group = User
