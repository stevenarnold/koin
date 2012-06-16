require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'
require 'factory_girl_rails'

FactoryGirl.define do
  factory :users do
  end
end

def small_file
  File.join(Rails.root, 'features', 'upload_files', '1mbfile.txt')
end

def large_file
  File.join(Rails.root, 'features', 'upload_files', '3mbfile.txt')
end

Given /^I am logged in as a guest with a quota$/ do
  Koin::Application::ALLOW_GUEST = true
  visit '/'
end

Given /^I upload a file less than my quota$/ do
  attach_file("upload[datafile]", small_file)
  click_button "Upload"
end

And /^the database size value for "([^"]*)" should be the same as the file size$/ do |fname|
  fname = case fname
  when '1mbfile.txt'
    small_file
  end
  fsize = File.stat(fname).size
  dbsize = DataFile.maximum("size")
  fsize.should == dbsize
end

Given /^I upload a file( greater than my quota)?$/ do |text|
  # save_and_open_page
  attach_file("upload[datafile]", large_file)
  click_button "Upload"
end

Given /^I am logged in as an admin with a quota$/ do
  # @admin = FactoryGirl.create(:users, :username => "test", :passwd => "secret",
  #     :p_admin => true, :quota => 12)
  # @admin = Users.create!(:username => "test", :passwd => "pass",
  #                       :p_admin => true, :quota => 12)
  @admin = FactoryGirl.create(:users, username: "test",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         p_admin: true, quota: 2, salt: "NFTCRHCJ")
  visit("/login/index")
  fill_in("user", :with => 'test')
  fill_in("pass", :with => 'pass')
  #debugger
  click_button "Submit"
end

Given /^I am logged in as user with no quota$/ do
  @admin = FactoryGirl.create(:users, username: "test",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         p_admin: true, quota: 0, salt: "NFTCRHCJ")
  visit("/login/index")
  fill_in("user", :with => 'test')
  fill_in("pass", :with => 'pass')
  #debugger
  click_button "Submit"
end

