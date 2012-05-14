Feature: Homepage

  The appearance of the homepage should depend on the configuration of the 
  server.
  
  Scenario: Server allows guest uploads
    
    Given I am on the home page
    And the server allows guest uploads
    Then I should see "File Upload"
    
  Scenario: Server does not allow guest uploads
  
    When a user goes to the homepage, the they should see a login prompt
    And the server does not allow guest uploads
    Then I should see "Please log in"
    
