require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

def log_in(user, pass)
  visit("/login/index")
  fill_in("user", :with => user)
  fill_in("pass", :with => pass)
  click_button "Submit"
end

And /I am not logged in/ do
  visit '/'
end

Then /^show me the page$/ do
  save_and_open_page
end

Given /^I am on the (.+) page$/ do |page_name|
  case page_name
  when 'home'
    visit '/'
  when 'login'
    visit '/'
  else
    eval("visit #{page_name}_path")
  end
end

Given /^the server allows guest uploads$/ do
  Koin::Application::ALLOW_GUEST = true
end                                             

Given /^the server does not allow guest uploads$/ do
  Koin::Application::ALLOW_GUEST = false
end

Then /^I should not see "([^"]*)"$/ do |text|
  page.has_content?(text).should == false
end

When /^I sign in with invalid details$/ do
  @test = FactoryGirl.create(:user, username: "test",
                         enc_passwd: "",
                         quota: 2, salt: "NFTCRHCJ")
  log_in('test', 'foobar')
end

Given /^I am an admin user$/ do
  @admin = FactoryGirl.create(:user, username: "admin",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         p_admin: true, quota: 2, salt: "NFTCRHCJ")
end

Given /^I am not an admin user$/ do
  @test = FactoryGirl.create(:user, username: "test",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         quota: 2, salt: "NFTCRHCJ")
end

And /^another user has uploaded a file( .+)?$/ do |condition|
  @other_uploader = FactoryGirl.create(:user, username: "other",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         quota: 2, salt: "NFTCRHCJ")
  log_in('other', 'pass')
  # debugger
  if condition == " for viewing by anyone"
    upload_small_file(anyone: true)
  else
    upload_small_file
  end
end

And /^I view "([^']+)'s" files$/ do |user|
  log_in(user, 'pass')
  click_link "Show my files"
end

Given /^I choose to download a file that was saved for a particular user$/ do
  pending
end

When /^I enter ([^ ]+) details/ do |detail_type|
  pending
  case detail_type
  when "invalid"
  when "correct"
  end
end

