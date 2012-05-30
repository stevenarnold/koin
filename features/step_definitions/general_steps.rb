require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

Given /^cucumber is properly initialized$/ do
  u = Users.new(:passwd => 'admin')
  u.username = 'admin'
  u.p_admin = 't'
  u.save!
end
