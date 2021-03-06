require 'rspec/expectations'
require 'rubygems'
require 'factory_girl_rails'

FactoryGirl.define do
  factory :user do
  end
end

def make_user(name, admin=false, quota=2)
  FactoryGirl.create(:user, username: name,
                     enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                     p_admin: admin, quota: quota, salt: "NFTCRHCJ")
end

def test_file(name)
  File.join(Rails.root, 'features', 'upload_files', name)
end

def small_file
  File.join(Rails.root, 'features', 'upload_files', '1mbfile.txt')
end

def large_file
  File.join(Rails.root, 'features', 'upload_files', '3mbfile.txt')
end

def upload_file(file, params={})
  #debugger
  upload_type = params.fetch(:upload_type, 'anyone')
  for_users = params.fetch(:for_users, [])
  password = params.fetch(:password, nil)
  expiration = params.fetch(:expiration, nil)
  subject = params.fetch(:subject, nil)
  description = params.fetch(:description, nil)
  case upload_type
  when "anyone"
    choose("data_file_p_permissions_anyone")
  when "me"
    choose("data_file_p_permissions_me")
  when "select_users"
    choose("data_file_p_permissions_specific_users")
    select_list = find('#users_selected')
    for_users.each do |user|
      select_list.select(user.username)
    end
  end
  if password
    fill_in("data_file_pass", :with => password)
  end
  if expiration
    fill_in('data_file_expiration', :with => expiration)
  end
  if subject
    fill_in('data_file_subject', :with => subject)
  end
  if description
    fill_in('data_file_description', :with => description)
  end
  attach_file("data_file[upload]", file)
  # page.find(:css, "#sections input[type=submit]").click
  click_button "Upload"
  #debugger
  link_text = find("a[href*='token']").native.attributes["href"].value
  link_text.match(/token\/(.*)/)[1]
end

def upload_large_file
  # args = {}
  # args[:upload_type] = 'anyone'
  # upload_file(large_file, args)
  attach_file("data_file[upload]", large_file)
  click_button "Upload"
end

def upload_small_file(upload_type, args={})
  #debugger
  args[:for_users] ||= []
  if args[:for_users].length > 0
    args[:upload_type] = "select_users"
  else
    args[:upload_type] = upload_type || "anyone"
  end
  upload_file(small_file, args)
end

Given /^I am logged in as a guest with a quota$/ do
  Koin::Application::ALLOW_GUEST = true
  visit '/'
end

Given /^I upload a file less than my quota$/ do
  attach_file("data_file_upload", small_file)
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

Given /^I log in as "([^"]*)"$/ do |user|
  log_in(user)
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

