Feature: Permissions

  Users should not be able take actions that they don't have permission
  to do.
  
  Scenario: Failed log in
  
    A user entering an incorrect username and password should see the standard
    upload prompt if guest access is turned on.
    
    Given I have chosen to log in
    When I sign up with invalid details
    Then I should see an error message and the upload prompt
    
  Scenario: Failed log in guest access off
  
    A user should see a login prompt if they enter a wrong password and guest
    access is turned off.
    
    Given I have chosen to log in
    When I sign up with invalid details
    Then I should see an error message and the login screen
    
  Scenario: File viewing
  
    A non-admin user should be able to manage only their own files, while an 
    admin can manage all files.
    
    Given I am not an admin user
    And I view my files
    Then I should not see a file that is not mine
    
    Given I am an admin user
    And I view my files
    Then I should see a file that is not mine
    
  Scenario: File download
  
    If a file was saved for a particular user, the user must enter a correct
    password to download the file.  Future downloads in the same session
    should not require password re-entry.
    
    Given I choose to download a file that was saved for a particular user
    When I enter invalid details
    Then I should see the login page
    
    Given I choose to download a file that was saved for a particular user
    When I enter correct details
    Then I should see the acknowledgement page

