require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'
require 'factory_girl_rails'

FactoryGirl.define do
  factory :user do
  end
end

def small_file
  File.join(Rails.root, 'features', 'upload_files', '1mbfile.txt')
end

def large_file
  File.join(Rails.root, 'features', 'upload_files', '3mbfile.txt')
end

def upload_large_file
  attach_file("upload[datafile]", large_file)
  click_button "Upload"
end

def upload_small_file(upload_type="anyone", for_users=[])
  # debugger
  case upload_type
  when "anyone"
    choose("download_perms_anyone")
  when "me"
    choose("download_perms_me")
  when "select_users"
    choose("download_perms_specific_users")
    select_list = find('#users_selected')
    for_users.each do |user|
      select_list.select(user.username)
    end
  end
  attach_file("upload[datafile]", small_file)
  click_button "Upload"
  link_text = find("a[href*='token']").native.attributes["href"].value
  link_text.match(/token\/(.*)/)[1]
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
  upload_large_file
end

Given /^I upload a large file$/ do
  upload_large_file
end

Given /^I am logged in as an admin with a quota$/ do
  @admin = FactoryGirl.create(:user, username: "test",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         p_admin: true, quota: 2, salt: "NFTCRHCJ")
  visit("/login/index")
  fill_in("user", :with => 'test')
  fill_in("pass", :with => 'pass')
  #debugger
  click_button "Submit"
end

Given /^I am logged in as user with no quota$/ do
  @admin = FactoryGirl.create(:user, username: "test",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         p_admin: false, quota: 0, salt: "NFTCRHCJ")
  visit("/login/index")
  fill_in("user", :with => 'test')
  fill_in("pass", :with => 'pass')
  #debugger
  click_button "Submit"
end

