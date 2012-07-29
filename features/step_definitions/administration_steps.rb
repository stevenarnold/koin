Given /^I am logged in as an admin user$/ do
  @admin = make_user('admin', :admin => true)
  log_in('admin')
end

