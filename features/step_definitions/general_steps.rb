require 'rspec/expectations'
require 'rubygems'
# require 'ruby-debug'

Given /^cucumber is properly initialized$/ do
  @admin = User.new(:passwd => 'pass')
  @admin.username = 'admin'
  @admin.p_admin = 't'
  @admin.save!
  g = User.new(:passwd => 'pass')
  g.username = 'guest'
  g.quota = 2
  g.save!
  Koin::Application::ALLOW_GUEST = true
end

Then /^I should see "([^"]*)"$/ do |text|
  # debugger
  page.has_content?(text).should == true
end

