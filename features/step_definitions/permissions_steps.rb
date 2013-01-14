require 'rspec/expectations'
require 'rubygems'

def log_in(user, pass='pass')
  visit("/login/index")
  fill_in("user", :with => user)
  fill_in("pass", :with => pass)
  click_button "Submit"
end

def log_out
  visit '/logout'
end

def file_by_token(token)
  DataFile.where("token_id = ?", token)[0]
end

And /^I am not logged in$/ do
  visit '/'
  @logged_in = false
end

Given /^I am logged in$/ do
  step %{I am not an admin user}
  log_in('test', 'pass')
  @logged_in = true
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
  #@admin = FactoryGirl.create(:user, username: "admin",
  #                       enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
  #                       p_admin: true, quota: 2, salt: "NFTCRHCJ")
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
  case condition
  when " for viewing by anyone"
    upload_small_file("anyone")
  when " for themselves only" 
    upload_small_file("me")
  when nil
    upload_small_file("me")
  end
end

And /^I view "([^']+)'s" files$/ do |user|
  #debugger
  log_in(user)
  click_link "Show my files"
end

Given /^I am (not )?logged in and I choose to download a file that was saved for ([^ ]+)(?: user)?$/ do |log_status, user_type|
  # Create three users, creator, intended, outsider.  Creator creates a file
  # intended for user intended and not intended for user outsider.
  #debugger
  log_status ||= 'am'
  log_status.strip!
  @creator = FactoryGirl.create(:user, username: "creator",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         quota: 2, salt: "NFTCRHCJ")
  @intended = FactoryGirl.create(:user, username: "intended",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         quota: 2, salt: "NFTCRHCJ")
  @outsider = FactoryGirl.create(:user, username: "outsider",
                         enc_passwd: "62361bcc7618023cab2dd8fd4e3887d9",
                         quota: 2, salt: "NFTCRHCJ")
  #debugger
  log_in('creator', 'pass')
  @token = upload_small_file("select_users", :for_users => [@intended])
  #save_and_open_page
  case user_type
  when "another"
    log_out
    if log_status == 'am'
      log_in('outsider', 'pass')
    end
    visit "/token/#{@token}"
    # debugger
  when "myself"
    visit "/token/#{@token}"
  end
end

Given /^I am logged in and I choose to download a file that was saved for me by another user$/ do
  @creator = FactoryGirl.create(:user, :username => "creator",
                         :enc_passwd => "62361bcc7618023cab2dd8fd4e3887d9",
                         :quota => 2, :salt => "NFTCRHCJ")
  @test = FactoryGirl.create(:user, :username => "test",
                         :enc_passwd => "62361bcc7618023cab2dd8fd4e3887d9",
                         :quota => 2, :salt => "NFTCRHCJ")
  log_in('creator', 'pass')
  token = upload_small_file("select_users", :for_users => [@test])
  log_out
  log_in('test', 'pass')
  visit "/token/#{token}"
end

Given /^I upload a file (with a password )?for (?:a|another) user( and then download it)?$/ do |with_pw, download|
  standard_user
  log_in('me', 'pass')
  if with_pw
    @token = upload_small_file("select_users", :password => 'pass', :for_users => [@other])
  else
    @token = upload_small_file("select_users", :for_users => [@other])
  end
  visit "/token/#{@token}" if download
end

Then /^(?:I|they) should receive a file(?: "([^"]*)")?/ do |file|
  # debugger
  #result = page.response_headers['Content-Type'].should == "application/octet-stream"
  if page.response_headers.should have_key('Content-Type')
    result = page.response_headers['Content-Disposition'].should =~ /#{file}/
  else
    fail
  end
end

When /^I enter ([^ ]+) details/ do |detail_type|
  case detail_type
  when "invalid"
    log_in('outsider', 'pass')
  when "correct"
    # debugger
    log_in('intended', 'pass')
  end
end

Then /^I should see the ([^ ]+) page$/ do |the_page|
  case the_page
  when 'login'
    #debugger
    page.has_content?("Please Log In").should == true
  when 'acknowledgement'
  end
end

Given /^I upload a file with a password$/ do
  standard_user
  # @them = make_user('them')
  @token = upload_file(test_file("1mbfile.txt"), :password => 'pass')
end

Given /^I upload a file with a password "([^"]+)" and expiration tomorrow$/ do |pass|
  standard_user
  expr = Time.now + 24*60*60  # One day from now
  #debugger
  @token = upload_file(test_file("multiple_files.zip"), :password => pass, :expiration => expr)
end

Given /^I upload a file with an expiration date$/ do
  standard_user
  @token = upload_file(test_file("tiny.txt"), :expiration => (Time.now.localtime + 5.minutes).to_s)
end

Then /^the file should have the password$/ do
  @df = file_by_token(@token)
  @df.password.should == "pass"
end

And /^(?:another|the) user ("[^"]+" )?attempts to download the file/ do |user|
  #debugger
  if user && !user.empty?
    user.gsub!(/"/, '').gsub!(/ /, '')
    log_in(user)
  else
    log_in("other")
  end
  visit "/token/#{@token}"
end

Then /^they should (not )?see a password prompt$/ do |see|
  # debugger
  if see == "not "
    page.body.should_not =~ /Please enter password/
  else
    page.body.should =~ /Please enter password/
  end
end

When /^they enter invalid details, they should see the password prompt again$/ do
  fill_in("pass", :with => "foobar")
  click_button "Submit"
  page.body.should =~ /Please enter password/
end

When /^they enter correct details$/ do
  fill_in("pass", :with => "pass")
  click_button "Submit"
  step %{I should receive a file "1mbfile.txt"}
end

When /^they enter the password "([^"]+)"$/ do |pass|
  fill_in("pass", :with => pass)
  click_button "Submit"
  step %{I should receive a file "multiple_files.zip"}
end

But /^(?:if )?the file expires$/ do
  @df = file_by_token(@token)
  @df.expiration = (Time.now.localtime - 5.minutes).to_s
  @df.save!
end



