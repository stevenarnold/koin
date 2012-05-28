Feature: Homepage

  The appearance of the homepage should depend on the configuration of the 
  server.
  
  Scenario: Server allows guest uploads
    
    Given the server allows guest uploads
    And I am not logged in
    Then I should see "File Upload"
    
  Scenario: Server does not allow guest uploads
  
    Given the server does not allow guest uploads
    And I am not logged in
    Then I should see "Please log in"
    
