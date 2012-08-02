Given /^(?:that )?I upload a file with a subject and a description$/ do
  @token = upload_small_file('anyone', :subject => "foobar", :description => "foobaz")
end

And /^I log in as "([^"])"$/ do |user|
  log_in(user)
end

