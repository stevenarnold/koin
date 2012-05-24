Given /^I am on the (.+) page$/ do |page_name|
  case page_name
  when 'home'
    visit '/'
  else
    eval("visit #{page_name}_path")
  end
end

Given /^the server allows guest uploads$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

When /^a user goes to the homepage, the they should see a login prompt$/ do
  pending # express the regexp above with the code you wish you had
end

When /^the server does not allow guest uploads$/ do
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
