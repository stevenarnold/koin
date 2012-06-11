require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

Given /^cucumber is properly initialized$/ do
  u = Users.new(:passwd => 'admin')
  u.username = 'admin'
  u.p_admin = 't'
  u.save!
  g = Users.new(:passwd => 'guest')
  g.username = 'guest'
  g.quota = 2
  g.save!
end

Then /^I should see "([^"]*)"$/ do |text|
  # debugger
  page.has_content?(text).should == true
end
