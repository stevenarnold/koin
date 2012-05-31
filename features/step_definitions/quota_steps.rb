require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

Given /^I am logged in as a guest with a quota$/ do
  Koin::Application::ALLOW_GUEST = true
  visit '/'
end

Given /^I upload a file less than my quota$/ do
  attach_file("upload[datafile]", File.join(Rails.root, 'features',
    'upload_files', '6mbfile.txt'))
  click_button "Upload"
end

Given /^I upload a file greater than my quota$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am logged in as an admin with a quota$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am logged in as user with no quota$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I upload a file$/ do
  pending # express the regexp above with the code you wish you had
end

