require 'rspec/expectations'
require 'rubygems'
require 'ruby-debug'

Given /^I am logged in as an? ([^ ]+) user$/ do |user_type|
  # debugger
  case user_type
  when 'admin'
    @admin ||= make_user('admin', true)
    log_in('admin')
  when 'non-admin'
    @non_admin ||= make_user('non_admin', false)
    log_in('non_admin')
  else
    fail
  end
end

Then /^if I visit the admin link manually$/ do
  visit '/koin/admin'
end

Then /^if I log in as the admin user$/ do
  log_in('admin')
  # debugger
end

When /^I press the "([^\"]*)" button$/ do |element|
  case element
  when "Create New User/Group"
    find(:css, "#creategroup").click
  else
    fail
  end
end

And /^fill in details for a non\-admin user "([^"]*)"$/ do |name|
  fill_in "user[username]", :with => "NonAdmin"
  fill_in "password", :with => "pass"
  fill_in "user[quota]", :with => "0"
  find(:css, "#user_p_search_all").set(true)
  find(:css, "#user_p_admin").set(false)
  find(:css, "#create").click
end

Then /^I should see "([^"]*)" exactly ([^ ]+) times?$/ do |string, num|
  page.html.scan(/#{string}/).length.should == num.to_i
end

When /^select the user "([^"]*)" to delete$/ do |user|
  u = User.find_by_username(user)
  find(:css,"#delete_#{u.id}").click
end

And /^(?:I )?select the user "([^"]*)" to edit it$/ do |user|
  u = User.find_by_username(user)
  find(:css,"#edit_#{u.id}").click
end

Then /^I should see that "([^"]*)" is (not )?an admin$/ do |user, state|
  # debugger
  if state == "not "
    find(:css, "#user_p_admin").should_not be_checked
  else
    find(:css, "#user_p_admin").should be_checked
  end
end

Then /^I should see that "([^"]*)" is (not )?in the group "([^"]*)"$/ do |child, presence, parent|
  child_group = User.find_by_username(child)
  if presence == "not "
    find(:css, "#child_group_#{child_group.id}").should_not be_checked
  else
    find(:css, "#child_group_#{child_group.id}").should be_checked
  end
end

But /^if I select "([^"]*)" as a group to (add|remove)$/ do |group, action|
  child_group = User.find_by_username(group)
  if action == "add"
    check("child_group_#{child_group.id}")
  else
    uncheck("child_group_#{child_group.id}")
  end
  click_button "Apply"
end

Given /^that "([^"]*)" is in the group "([^"]*)"$/ do |child, parent|
  child = User.find_by_username(child)
  parent = User.find_by_username(parent)
  parent.child_groups << child
end

And /^(?:if )?I toggle the admin status of "([^"]*)" to "([^"]*)" and save$/ do |user, status|
  user = User.find_by_username(user)
  #debugger
  if status == "on"
    check("user_p_admin")
  else
    uncheck("user_p_admin")
    #find(:css, "#user_p_admin").set(0)
  end
  click_button "Apply"
end

Then /^if I change the quota to "([^"]*)" and save$/ do |quota|
  fill_in("user_quota", :with => quota)
  click_button "Apply"
end

Then /^I should see the quota is set to "([^"]*)"$/ do |quota|
  find(:css, "#user_quota").value.should == quota
end

