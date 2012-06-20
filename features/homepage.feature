Feature: Homepage

  The appearance of the homepage should depend on the configuration of the 
  server.
  
  Background:
    Given cucumber is properly initialized
  
  Scenario: Server allows guest uploads
    
    Given the server allows guest uploads
    And I am not logged in
    Then I should see "File Upload"
    
  Scenario: Server does not allow guest uploads
  
    Given the server does not allow guest uploads
    And I am not logged in
    Then I should see "Please Log In"
    And I should not see "File Upload"
    And I should not see "Welcome, guest"
    
