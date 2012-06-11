Feature: Quota

  In this feature, we ensure that users cannot upload more than their allotted
  quota.  If the quota is set to zero, that means there is no quota, so any 
  upload will suffice to ensure that this works.
  
  Background:
    Given cucumber is properly initialized
  
  Scenario: Upload a file less than quota
    Given I am logged in as a guest with a quota      
    And I upload a file less than my quota
    Then I should see "File saved under token"
    And the database size value for "1mbfile.txt" should be the same as the file size
  
  Scenario: Upload a file that exceeds quota
    Given I am logged in as a guest with a quota
    And I upload a file greater than my quota
    Then I should see "Can't upload file: Quota exceeded"
    
  Scenario: Upload a file that exceeds quota as admin
    Given I am logged in as an admin with a quota
    And I upload a file greater than my quota
    Then I should see "Can't upload file: Quota exceeded"
  
  Scenario: Upload a file for a user with no quota
    Given I am logged in as user with no quota
    And I upload a file
    Then I should see "File saved under token"
    
