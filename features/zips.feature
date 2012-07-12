Feature: Fetch files within zip files

  Users should be able to download files within zip files that are uploaded.
  
  Background:
    Given cucumber is properly initialized
    And I upload a zip file that contains multiple files
  
  Scenario: Fetch a file within an uploaded zip
  
    A user can fetch a file within a zip file if the file ends in .zip, if the
    file properly unzips, and if the user specifies a proper path within the
    zip file.  For example, if the token is 'abc', and the zip contains a file
    mypic.jpg (in addition perhaps to other files), the url token/abc/mypic.jpg
    will return the individual jpg.
    
    And I download one of the files using the path "sample1.txt" after the token
    Then I should receive a file "sample1.txt"

  Scenario: List the files within a zip file
  
    I should be able to list the files for a zip file I have permission to 
    download by using the URL syntax token/list/:token(/:path))
    
    And I download one of the files using the path "foobar/dirtext.txt" after the token
    Then I should receive a file "dirtext.txt"

