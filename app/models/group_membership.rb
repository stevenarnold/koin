class GroupMembership < ActiveRecord::Base
  belongs_to :parent_group, :class_name => "User"
  belongs_to :child_group, :class_name => "User"
end
