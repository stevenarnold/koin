Feature: Users and groups

  Users should be able to contain other users, and if you as a User are
  contained within another user, you get most of the the powers and
  privileges that go with your parent User, including seeing all their
  files, for example.
         
  Background:
    Given cucumber is properly initialized
    And I have a set of users and groups for group testing
    
  Scenario: User membership in a group
  
    If I create a group and upload a file just for that user, initially
    only the group itself can see it.  But if I add another user to that group's
    membership, then the other user can see the file.
  
    Given I upload a file for a group "primary"
    And the user "secondary" attempts to download the file
    Then they should see "not found or permission not granted"
    But if I add "secondary" as a user to "primary"
    And the user "secondary" attempts to download the file
    Then they should receive a file "1mbfile.txt"
    # Now we test a third level of group inheritance
    When the user "third" attempts to download the file
    Then they should see "not found or permission not granted"
    But if I add "third" as a user to "secondary"
    And the user "third" attempts to download the file
    Then they should receive a file "1mbfile.txt"

  Scenario: No group access to user's files
  
    Just because a user joins a group does not mean the group has access to the
    user's files.
    
    Given I upload a file for a group "secondary"
    And I add "secondary" as a user to "primary"
    And the user "primary" attempts to download the file
    Then they should see "not found or permission not granted"


