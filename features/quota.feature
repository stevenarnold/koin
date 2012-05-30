Feature: Quota

  In this feature, we ensure that users cannot upload more than their allotted
  quota.  If the quota is set to zero, that means there is no quota, so any 
  upload will suffice to ensure that this works.
  
  Scenario: Upload a file less than quota
    Given I am logged in as a guest with a quota
    And I upload a file less than my quota
    Then I should see "File saved under token"
  
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
    
