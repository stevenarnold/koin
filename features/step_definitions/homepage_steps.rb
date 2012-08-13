Given /^(?:that )?I upload a file with a subject and a description$/ do
  #debugger
  @token = upload_small_file('anyone', :subject => "foobar", :description => "foobaz")
end

And /^I log in as "([^"])"$/ do |user|
  log_in(user)
end

Given /^I change the subject and description$/ do
  #debugger
  visit "/edit/#{@token}"
  fill_in("data_file_subject", :with => "test1")
  fill_in("data_file_description", :with => "test2")
  # save_and_open_page
  click_button "Apply"
end

Then /^I should see the subject and description that I saved$/ do
  page.html.should =~ /test1/
end

