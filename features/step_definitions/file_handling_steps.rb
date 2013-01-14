require 'rspec/expectations'
require 'rubygems'

def standard_user
  if !@me
    @me = make_user('me')
    @other = make_user('other')
  end
  log_in('me')
end

Given /^I upload a zip file that contains multiple files$/ do
  standard_user
  @token = upload_file(test_file("multiple_files.zip"))
end

Given /^I download one of the files using the path "([^"]+)" after the token$/ do |path|
  visit "/token/#{@token}/#{path}"
end

Given /^I upload the file "([^"]+)"$/ do |path|
  standard_user
  @tokens ||= []
  @tokens << upload_file(test_file(path))
end

When /^I download the files, they should be different$/ do
  @results ||= []
  @tokens.each do |token|
    visit "/token/#{token}"
    @results << page.document.text
  end
  @results.uniq.length.should == @results.length
end

Then /^the file should not be in the database$/ do
  file_by_token(@token).should == nil
end

And /^the file should not be in the filesystem$/ do
  token_file = File.join(Rails.root, 'public', 'data', @token)
  File.exist?(token_file).should == false
end

Given /^I view the index for that zip file$/ do
  visit "/token/index/#{@token}"
end

When /^I click the link "([^"]*)"$/ do |link_name|
  #debugger
  click_link link_name
end

And /"([^"]*)" should be (\d+) bytes in size/ do |file, size|
  #debugger
  File.stat("tmp/files/data-#{@token}").size.should == size.to_i
end

