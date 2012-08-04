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
                        
  Scenario: Invalid file download -- not logged in
  
    If a file was saved for a particular user, the user must enter a correct
    password to download the file.  Future downloads in the same session
    should not require password re-entry.
    
    Given I am not logged in and I choose to download a file that was saved for another user
    Then I should see "Please Log In"
    # Login and try future downloads
                        
  Scenario: Invalid file download -- logged in
  
    If a user is logged in and tries to download a file for which they don't have
    permission, they get an error
    
    Given I am logged in and I choose to download a file that was saved for another user
    Then I should see "not found or permission not granted"

  Scenario: Valid file download
    
    Given I am logged in and I choose to download a file that was saved for me by another user
    Then I should receive a file "1mbfile.txt"

  Scenario: File download for specific user when user is not logged in
      
    NOTE: When I try to download a file saved for a particular user and I
    am not logged in, I should be taken to the login page, then allowed or
    denied based on whether I am the correct user.

    Given I am not logged in and I choose to download a file that was saved for another user
    Then I should see the login page
    When I enter correct details
    Then I should receive a file "1mbfile.txt"

  Scenario: File download for invalid user when user is not logged in
      
    NOTE: When I try to download a file saved for a particular user and I
    am not logged in, I should be taken to the login page, then allowed or
    denied based on whether I am the correct user.

    Given I am not logged in and I choose to download a file that was saved for another user
    Then I should see the login page
    When I enter invalid details
    Then I should see "File Upload"
    
  Scenario: A user should always be able to download their own posted file

    Given I upload a file for another user and then download it
    Then I should receive a file "1mbfile.txt"
    
  Scenario: When I upload a file with a password, it should have that password
  
    Given I upload a file with a password
    Then the file should have the password
    
  Scenario: Require a password to view a file
  
    Users have the option of entering a password to view a file.  The system should
    ask for the password and check it before providing the file.
    
    Given I upload a file with a password
    And another user attempts to download the file
    Then they should see a password prompt
    When they enter invalid details, they should see the password prompt again
    When they enter correct details
    Then they should receive a file "1mbfile.txt"
    
  Scenario: Require a password to view a file, even for a logged in user
  
    If a password is specified for a file and set for a particular user, the user
    still has to enter the password for the file, even though the file was set
    for them.

    Given I upload a file with a password for a user
    And the user attempts to download the file
    Then they should see a password prompt
    When they enter invalid details, they should see the password prompt again
    When they enter correct details
    Then they should receive a file "1mbfile.txt"
    
  Scenario: Allow a user to enter an expiration date for a file
  
    If a file is given an expiration date, the file should be available (assuming
    all other permissions are valid) prior to that expiration date.  If it is
    requested on or after the expirationd date, the file should be deleted and
    the user informed that "permission denied."
    
    Given I upload a file with an expiration date
    And the user attempts to download the file before the expiration date
    Then they should receive a file "tiny.txt"
    But if the file expires
    And the user attempts to download the file
    Then I should see "not found or permission not granted"

  Scenario: Files with both password and expirations should download
  
    If a user uploads a file with both a password and an expiration date, the file
    should download if the expiration has not passed and the password is correct.
    
    Given I upload a file with a password "bytes3(stEEp" and expiration tomorrow
    And another user attempts to download the file
    Then they should see a password prompt
    When they enter the password "bytes3(stEEp"
    Then they should receive a file "multiple_files.zip"

