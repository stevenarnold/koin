Feature: User/group administration

  Administrative users (only) should be able to perform administrative tasks,
  including creating, deleting and modifying users as well as their files.
  
  Background:
    Given cucumber is properly initialized
    And I have a set of users and groups for group testing
    And I am logged in as an admin user
    And I click "Administer users"

  Scenario: Create new group
  
    I should be able to create a new group and edit the attributes, like
    admin and quota, for that group
  
    When I press the "Create New User/Group" button
    And fill in details for a non-admin user "NonAdmin"
    Then I should see "User created!"
    And I should see "NonAdmin" exactly 1 time
  
  Scenario: Edit a group
  
    I should be able to edit a group and change its values
    
    And select the user "secondary" to edit it
    Then I should see that "secondary" is not an admin
    
  Scenario: Delete a group
  
    I should be able to pick a group and delete it
    
    And select the user "secondary" to delete
    Then I should not see "secondary"
    
  Scenario: Add a user to a group
  
    I should be able to add a user/group to another user/group
    
    Given I select the user "secondary" to edit it
    Then I should see that "third" is not in the group "secondary"
    But if I select "third" as a group to add
    Then I should see that "third" is in the group "secondary"
  
  Scenario: Remove a user from a group
  
    I should be able to remove a user/group from another user/group
    
    Given that "third" is in the group "secondary"
    Given I select the user "secondary" to edit it
    Then I should see that "third" is in the group "secondary"
    But if I select "third" as a group to remove
    Then I should see that "secondary" is not in the group "third"
    
  Scenario: Toggle settings
  
    I should be able to toggle and save settings such as the quota and
    admin privileges of a user.
    
    Given I select the user "secondary" to edit it
    And I toggle the admin status of "secondary" to "on" and save
    Then I should see that "secondary" is an admin
    But if I toggle the admin status of "secondary" to "off" and save
    Then I should see that "secondary" is not an admin
    And if I change the quota to "10" and save
    Then I should see the quota is set to "10"
    And if I change the quota to "20" and save
    Then I should see the quota is set to "20"
    
  Scenario: Non-admins should not be able to list users
  
    Given I am logged in as a non-admin user
    Then I should not see "Administer Users"
    And if I visit the admin link manually
    Then I should see the login page
    And if I log in as the admin user
    Then I should see "Administer Users"
    And I should see "primary"
    And I should see "secondary"
    And I should see "third"
    
  Scenario: An admin should be able to disable a user from the admin page
  
    If an admin disables a user, the user cannot log in, and no one except an
    admin can download the disabled user's files.
  
    Given the user "secondary" uploads a file
    And I log in as the admin user
    And I visit the admin link
    And I disable the user "secondary"
    And the user "secondary" attempts to log in
    Then they should see "Incorrect username or password"
    And the user "third" logs in
    And they attempt to download the file
    Then they should see "not found or permission not granted"
    But if I log in as the admin user
    And I attempt to download the file
    Then I should receive a file "1mbfile.txt"

  Scenario: An admin should be able to disable a user from the user page
  
    Given the user "secondary" uploads a file
    And I log in as the admin user
    And I visit the admin link
    And I edit the user "secondary"
    And I disable the user "secondary"
    And the user "secondary" attempts to log in
    Then they should see "Incorrect username or password"
    And the user "third" logs in
    And they attempt to download the file
    Then they should see "not found or permission not granted"
    But if I log in as the admin user
    And I attempt to download the file
    Then I should receive a file "1mbfile.txt"
    
  Scenario: A non-admin should not be able to disable or delete a user

    Given I log in as a non-admin user
    # More...


