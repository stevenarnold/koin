require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

Given /^I upload a zip file that contains multiple files$/ do
  @me = make_user('me')
  log_in('me')
  @token = upload_file(test_file("multiple_files.zip"))
end

Given /^I download one of the files using the path "([^"]+)" after the token$/ do |path|
  visit "/token/#{@token}/#{path}"
end



