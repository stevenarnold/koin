Given /^I have a set of users and groups for group testing$/ do
  @primary = make_user('primary')
  @seconday = make_user('secondary')
  @third = make_user('third')
end

Given /^I upload a file for a group "([^"]+)"/ do |group|
  standard_user
  #debugger
  group = User.find_by_username(group)
  @token = upload_file(test_file("1mbfile.txt"), :upload_type => 'select_users', 
    :for_users => [group])
end

Then /^they should see "([^"]+)"?/ do |text|
  #debugger
  step %|I should see "#{text}"|
end

But /^(?:if )?I add "([^"]+)" as a user to "([^"]+)"/ do |child, parent|
  child = User.find_by_username(child)
  parent = User.find_by_username(parent)
  #debugger
  parent.child_groups << (child)
end

Given /^I click "([^"]*)"$/ do |link|
  # debugger
  click_link link
end

