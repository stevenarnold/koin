Feature: Handle proper file management

  Users should be able to download files within zip files that are uploaded.
  
  Background:
    Given cucumber is properly initialized
  
  Scenario: Fetch a file within an uploaded zip
  
    A user can fetch a file within a zip file if the file ends in .zip, if the
    file properly unzips, and if the user specifies a proper path within the
    zip file.  For example, if the token is 'abc', and the zip contains a file
    mypic.jpg (in addition perhaps to other files), the url token/abc/mypic.jpg
    will return the individual jpg.
    
    Given I upload a zip file that contains multiple files
    And I download one of the files using the path "sample1.txt" after the token
    Then I should receive a file "sample1.txt"

  Scenario: List the files within a zip file
  
    I should be able to list the files for a zip file I have permission to 
    download by using the URL syntax token/list/:token(/:path))
    
    Given I upload a zip file that contains multiple files
    And I download one of the files using the path "foobar/dirtext.txt" after the token
    Then I should receive a file "dirtext.txt"
    
  Scenario: Uploading two different files with the same file name
  
    Uploading two different files of the same name should still result in
    two distinct files when we download them.
    
    Given I upload the file "same_names/1/test.txt"
    And I upload the file "same_names/2/test.txt"
    When I download the files, they should be different
    
  Scenario: When a file expires, the system should delete the file
  
    The file should be deleted both from the database and from the filesystem,
    including its enclosing directory.

    Given I upload a file with an expiration date
    And the file expires
    And the user attempts to download the file
    Then the file should not be in the database
    And the file should not be in the filesystem
    
  Scenario: Expiration date blocks even logged in user with password
  
    Once a file expires, even a logged in user with a password cannot
    access it.

    Given I upload a file with a password for a user
    And the file expires
    And the user attempts to download the file
    Then I should see "not found or permission not granted"
    And the file should not be in the database
    And the file should not be in the filesystem

