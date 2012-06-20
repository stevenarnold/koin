Feature: Permissions

  Users should not be able take actions that they don't have permission
  to do.
  
  Background:
    Given cucumber is properly initialized
  
  Scenario: Failed log in
  
    A user should see a login prompt if they enter a wrong password
    
    Given I am on the login page
    When I sign in with invalid details
    Then I should see "Incorrect username or password"
    And I should see "Please Log In"
    
  Scenario: File viewing for non-admins
  
    A non-admin user should be able to manage only their own files, while an 
    admin can manage all files.
    
    Given I am not an admin user
    And another user has uploaded a file for themselves only
    And I view "test's" files
    Then I should not see "1mbfile.txt"
    
  Scenario: File viewing for admins
  
    An admin can see all files, whether owned by him/her or not
    
    Given I am an admin user
    And another user has uploaded a file
    And I view "admin's" files
    Then I should see "1mbfile.txt"
    
  Scenario: Files for anybody should be visible to non-admin users
    Given I am not an admin user
    And another user has uploaded a file for viewing by anyone
    And I view "test's" files
    Then I should see "1mbfile.txt"

  Scenario: Invalid file download
  
    If a file was saved for a particular user, the user must enter a correct
    password to download the file.  Future downloads in the same session
    should not require password re-entry.
    
    Given I choose to download a file that was saved for a particular user
    When I enter invalid details
    Then I should see the login page

  Scenario: Valid file download
    
    Given I choose to download a file that was saved for a particular user
    When I enter correct details
    Then I should see the acknowledgement page

