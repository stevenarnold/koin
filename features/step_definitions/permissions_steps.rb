require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

And /I am not logged in/ do
  visit '/'
end

Given /^I am on the (.+) page$/ do |page_name|
  case page_name
  when 'home'
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

Then /^I should see "([^"]*)"$/ do |text|
  #debugger
  page.has_content?(text).should == true
end

Then /^I should not see "([^"]*)"$/ do |text|
  !page.has_content?(text)
end

When /^a user goes to the homepage, the they should see a login prompt$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have chosen to log in$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I sign up with invalid details$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see an error message and the upload prompt$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see an error message and the login screen$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am not an admin user$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I view my files$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should not see a file that is not mine$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am an admin user$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see a file that is not mine$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I choose to download a file that was saved for a particular user$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I enter invalid details$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the login page$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I enter correct details$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see the acknowledgement page$/ do
  pending # express the regexp above with the code you wish you had
end

