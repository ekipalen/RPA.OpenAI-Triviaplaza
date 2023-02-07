# OpenAI Triviaplaza robot

This robot solves a [Triviaplaza quiz](https://www.triviaplaza.com/king-arthur-quiz/) using OpenAI.

> The robot takes a trivia quiz about King Arthur from Triviaplaza.com. The robot reads the question and the answer options and uses the API interface to ask the OpenAI artificial intelligence which of the options it thinks is the right answer, which the robot chooses.

## The robot code

> Note: By changing the address in ${url} variable in the *** Variables *** section, you can configure the robot to perform another quiz..

The robot uses the [RPA.Browser.Playwright](https://robocorp.com/docs/libraries/rpa-framework/rpa-browser-playwright) library for browser automation and custom keyword library for interacting with OpenAI API.

```robot
*** Settings ***
Documentation       Robot using OpenAI to complete a Trivia. 
Library             RPA.Robocorp.Vault 
Library             RPA.Browser.Playwright
Library             RPA.OpenAI
Library             String

*** Variables ***
# Change the following URL to complete some other Trivia from Triviaplaza.com site.
${url}        https://www.triviaplaza.com/king-arthur-quiz/
&{answer_locators}    A=//div[@id='b1']  B=//div[@id='b2']  C=//div[@id='b3']  D=//div[@id='b4']
${counter}    1

*** Tasks ***
OpenAI Trivia Robot
    Authorize
    Open Browser    ${url} 
    Start the Trivia
    Answer the Questions
    Take a screenshot of the result

*** Keywords ***
Authorize 
    ${secrets}   Get Secret   secret_name=OpenAI 
    Authorize To OpenAI   api_key=${secrets}[key]   

Start the Trivia  
    Click    //a[contains(text(),'Play')]

Answer the Questions
    WHILE    ${counter} < 11
        Wait For Elements State    //div[@id='ques'] >> text=${counter}
        ${first_part_of_question}    Get Text    //h1/span
        ${second_part_of_question}   Get Text    //div[@id='qscreenimg']/span
        ${question}   Set Variable   ${first_part_of_question} ${second_part_of_question}
        ${answer_A}   Get Text    //div[@id='b1']
        ${answer_B}   Get Text    //div[@id='b2']
        ${answer_C}   Get Text    //div[@id='b3']
        ${answer_D}   Get Text    //div[@id='b4']
        ${answer}  Completion Create    
        ...     ${question} A=${answer_A}, B=${answer_B}, C=${answer_C}, D=${answer_D}. Write just the correct answers letter A, B, C or D without any other characters.
        # Sometimes OpenAI answers with multiple options e.g. "A, B". If answer is longer than one character, lets use the first one.
        ${length}   Get Length    ${answer}
        IF    ${length} > 1
            ${answer}   Get Substring   ${answer}  0   1
        END
        Click   ${answer_locators}[${answer}]
        ${counter}   Evaluate    ${counter}+1
    END

Take a screenshot of the result
    Sleep   5
    Take Screenshot   filename=${CURDIR}${/}Result
```

<img src="images/result.png" style="margin-bottom:20px">
