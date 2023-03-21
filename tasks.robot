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
${counter}     ${1}
${play_button}    //a[contains(text(),'Play')]
${vault_name}    OpenAI
${gpt-model}    gpt-3.5-turbo   # Use model gpt-3.5-turbo or gpt-4 

*** Tasks ***
OpenAI Trivia Robot
    Authorize
    Open Browser    ${url} 
    Start the Trivia
    WHILE    ${counter} <= 10
        Answer the Question
    END
    Take a screenshot of the result

*** Keywords ***
Authorize 
    ${secrets}   Get Secret   secret_name=${vault_name} 
    Authorize To OpenAI   api_key=${secrets}[key]   

Start the Trivia  
    Click    ${play_button}

Answer the Question
    Wait For Elements State    //div[@id='ques'] >> text=${counter}/10
    ${first_part_of_question}    Get Text    //h1/span
    ${second_part_of_question}   Get Text    //div[@id='qscreenimg']/span
    ${question}   Set Variable   ${first_part_of_question} ${second_part_of_question}
    ${answer_A}   Get Text    ${answer_locators}[A]
    ${answer_B}   Get Text    ${answer_locators}[B]
    ${answer_C}   Get Text    ${answer_locators}[C]
    ${answer_D}   Get Text    ${answer_locators}[D]
    Log to console    ${question} \n ${answer_A}, ${answer_B}, ${answer_C}, ${answer_D}

    ${answer}     @{conversation}    Chat Completion Create
    ...    user_content=${question} A=${answer_A}, B=${answer_B}, C=${answer_C}, D=${answer_D}. Write just the correct answers letter A, B, C or D. Don't use period or anything else, just a single letter.
    ...    model=${gpt-model}
    ...    temperature=0.4
    ${answer}     Strip String    ${answer}
    # Sometimes GPT gives longer answers so let's use the first character as an answer.
    Click   ${answer_locators}[${answer[0]}]
    ${counter}   Evaluate    ${counter}+1
    Set Global Variable    ${counter}

Take a screenshot of the result
    Sleep   5
    Take Screenshot   filename=${CURDIR}${/}Result