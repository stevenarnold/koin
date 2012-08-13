require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

def standard_user
  @me = make_user('me')
  @other = make_user('other')
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




