*** Settings ***
Library          SeleniumLibrary
Library    String

*** Variables ***
@{dropdown_ids}=    select1    select2    select3
${red_button_id} =   id=redButton
${green_button_id} =   id=greenButton
${blue_button_id} =   id=blueButton
${select_option} =  Выбери
${red_option} =  К
${green_option} =  З
${blue_option} =  С
${k_button_id} =      redButton
${z_button_id} =      greenButton
${s_button_id} =      blueButton
${sort_button_id} =    sendDataButton
${clear_button_id} =    clearButton

*** Keywords ***
Check Dropdown Options
    [Arguments]    ${dropdown_id}
    #[Documentation]  Проверяет, что все элементы выпадающего списка корректно отображаются.
    ${options}=    Get List Items    xpath=//select[@id='${dropdown_id}']
    Should Contain    ${options}    ${select_option}
    Should Contain    ${options}    ${red_option}
    Should Contain    ${options}    ${green_option}
    Should Contain    ${options}    ${blue_option}

Select And Check Option
    [Arguments]    ${dropdown_id}    ${option}
    #[Documentation]  Выбирает элемент из выпадающего списка и проверяет, что он был выбран корректно.
    Select From List By Value    ${dropdown_id}    ${option}
    ${selected_value}=    Get Selected List Value    ${dropdown_id}
    Should Be Equal As Strings    ${selected_value}    ${option}

Click Red Button Multiple Times
    [Arguments]  ${times}
    FOR    ${index}    IN RANGE    ${times}
    Click Element    ${red_button_id}
    END

Click Green Button Multiple Times
    [Arguments]  ${times}
    FOR    ${index}    IN RANGE    ${times}
    Click Element    ${green_button_id}
    END

Click Blue Button Multiple Times
    [Arguments]  ${times}
    FOR    ${index}    IN RANGE    ${times}
    Click Element    ${blue_button_id}
    END

Report Known Issue
    [Arguments]    ${issue_number}
    Run Keyword If    '${TEST STATUS}' == 'FAIL'    Fail    Known issue: ${issue_number}

*** Test Cases ***

Check Web page Title - Test 1
    [Documentation]     Проверка названия вкладки страницы "Тестовое задание"
    [Teardown]    Report Known Issue    Bug #5437
    Open Browser    https://dynamic-dolphin-426efe.netlify.app/  Chrome
    ${tab_title}=   Get Title
    Should Be Equal    ${tab_title}    Тестовое задание
    Close Browser

Check Order Title - Test 2
    [Documentation]    Проверка заголовка "Правила порядка": название заголовка соотвествует Правила порядка
    Open Browser    https://dynamic-dolphin-426efe.netlify.app/  Chrome
    ${title_text}=   Get Text    xpath=//div[@class="text-center py-3"]/span
    Should Be Equal    ${title_text}    Правила порядка
    Close Browser

Check Empty Run Sorting - Test 3
    [Documentation]   Проверка "пустого" запуска (при нажатии "Сортировать" и незаполненных данных, приложение не крашится)
    Open Browser    https://dynamic-dolphin-426efe.netlify.app/  Chrome
    Click Button  id=${sort_button_id}
    Sleep    3 seconds
    Close Browser

Check Empty Run Clear - Test 4
    [Documentation]   Проверка "пустого" запуска очистки (при нажатии "Очистить" и незаполненных данных, приложение не крашится)
    Open Browser    https://dynamic-dolphin-426efe.netlify.app/  Chrome
    Click Button  id=${clear_button_id}
    Sleep    3 seconds
    Close Browser

Check Dropdown Options - Test 5
    [Documentation]   Проверка элементов выпадающих списков (все элементы выпадающих списков (select1, select2, select3) корректно отображаются и выбираются)
    Open Browser    https://dynamic-dolphin-426efe.netlify.app/  Chrome
    Sleep    3 seconds
    FOR    ${dropdown_id}    IN    @{dropdown_ids}
        Check Dropdown Options    ${dropdown_id}
        Select And Check Option    ${dropdown_id}    ${red_option}
        Select And Check Option    ${dropdown_id}    ${green_option}
        Select And Check Option    ${dropdown_id}    ${blue_option}
    END
    Close Browser

Check Color Buttons Options - Test 6
    [Documentation]   Проверка кнопок "К","С","З" (имена кнопок корректны и при их нажатии прописывается корректный элемент)
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    #проверка наименований кнопок
    ${k_button_text}=   Get Text    id=${k_button_id}
    Should Be Equal As Strings    ${k_button_text}    К
    ${z_button_text}=   Get Text    id=${z_button_id}
    Should Be Equal As Strings    ${z_button_text}    З
    ${s_button_text}=   Get Text    id=${s_button_id}
    Should Be Equal As Strings    ${s_button_text}    С

    #проверка правильного текста при нажатии соотвествующей кнопки
    Click Green Button Multiple Times   1
    Click Blue Button Multiple Times    1
    Click Red Button Multiple Times    1
    # Cчитывание введеной последовательности и приведение ее к виду "без спецсимвола": замена \n на пробел
    ${subsequence}=    Get Text  id:output
    ${cleaned_subsequence}=    Replace String    ${subsequence}    \n    ${SPACE}
    # Cравнение результата нажатия кнопок и ожидаемой последовательности
    Should Be Equal As Strings  ${cleaned_subsequence}  З С К
    Close Browser

Check Sequence Options - Test 7
    [Documentation]   Проверка поля ввода последовательности (поле ввода пустое и недоступно для редактирования с клавиатуры)
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    # Проверка, что в строке-входной последовательности пусто
    ${subsequence}=    Get Text  id:output
    Should Be Empty  ${subsequence}

    #проверка, что элемент не доступен для редактирования (если contenteditable None, то по умолчанию нельзя редактировать)
    ${attr}=    Get Element Attribute    id=output    contenteditable
    Should Be Equal    ${attr}    ${None}
    Close Browser

Check Color of Sequence - Test 8
    [Documentation]  Проверка поля ввода последовательности (Цвет символа соотвествует названию буквы К-красный, З-зеленый, С-синий)
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    Select From List By Value  id:select1  К
    Select From List By Value  id:select2  С
    Select From List By Value  id:select3  З

    Click Green Button Multiple Times   1
    Click Blue Button Multiple Times    1
    Click Red Button Multiple Times    1

    ${class}=    Get Element Attribute    xpath=//div[@id='output']/span[.='К'][1]    class
    Should Contain    ${class}    text-red-500
    ${class}=    Get Element Attribute    xpath=//div[@id='output']/span[.='С'][1]    class
    Should Contain    ${class}    text-blue-500
    ${class}=    Get Element Attribute    xpath=//div[@id='output']/span[.='З'][1]    class
    Should Contain    ${class}    text-green-500

    Close Browser

Check Sort Button Options - Test 9
    [Documentation]    Проверка кнопки "Сортировать" : имя кнопки корректно и при ее нажатии прописывается результат
    [Teardown]    Report Known Issue    Bug #5430
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    #проверка наименования кнопки
    ${sort_button_text}=   Get Text    id=${sort_button_id}
    Should Be Equal As Strings    ${sort_button_text}    Сортировать

    #проверка наличия результата при нажатии кнопки "Сортировать"
    #выбирается правило только для двух цветов
    Select From List By Value  id:select1  С
    Select From List By Value  id:select2  К

    Click Green Button Multiple Times   1
    Click Blue Button Multiple Times    1
    Click Red Button Multiple Times    1

    Click Button  id=${sort_button_id}

    # Cчитывание введеной последовательности и приведение ее к виду "без спецсимвола": замена \n на пробел
    ${text_result}=    Get Text  id:result
    ${cleaned_result}=    Replace String    ${text_result}    \n    ${SPACE}
    Log    ${cleaned_result}
    # Cравнение строки-результата и ожидаемой строки
    Should Be Equal As Strings  ${cleaned_result}  С К
    Fail    Known issue: result may be incorrect due to Bug #5430
    Close Browser

Check Result Options - Test 10
    [Documentation]  Проверка поля вывода результата (поле вывода пустое и недоступно для редактирования)
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    # Проверка, что в строке-результате пусто
    ${result}=    Get Text  id:output
    Should Be Empty  ${result}

    #проверка, что элемент не доступен для редактирования (если contenteditable None, то по умолчанию нельзя редактировать)
    ${attr}=    Get Element Attribute    id=output    contenteditable
    Should Be Equal    ${attr}    ${None}
    Close Browser

Check Color of Result - Test 11
    [Documentation]  Проверка поля вывода результата (цвет символа соотвествует названию буквы К-красный, З-зеленый, С-синий)
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    Select From List By Value  id:select1  З
    Select From List By Value  id:select2  К
    Select From List By Value  id:select3  С

    Click Red Button Multiple Times    1
    Click Green Button Multiple Times   1
    Click Blue Button Multiple Times    1

    Click Button  id=${sort_button_id}

    ${elements}=    Get WebElements    xpath=//div[@id='result']/span

    FOR    ${el}    IN    @{elements}
       ${text}=    Get Text    ${el}
       ${class}=   Get Element Attribute    ${el}    class

         IF    '${text}' == 'З'
                Should Contain    ${class}    text-green-500
         END

          IF    '${text}' == 'К'
             Should Contain    ${class}    text-red-500
          END

          IF    '${text}' == 'С'
            Should Contain    ${class}    text-blue-500
          END
    END


    Close Browser

Check Clear Button Options - Test 12
    [Documentation]  Проверка кнопки "Очистить" (имя кнопки корректно и при ее нажатии выпадающие списки принимаю дефолтное значение, а поля становятся пустыми)
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome

    #проверка наименования кнопки
    ${clear_button_text}=   Get Text    id=${clear_button_id}
    Should Be Equal As Strings    ${clear_button_text}    Очистить

    #проверка что после нажатия кнопки "Очистить" списки в дефолтном стостоянии, поля чистые
    #выбираются все выпадающие списки, заполняются все строки
    Select From List By Value  id:select1  К
    Select From List By Value  id:select2  С
    Select From List By Value  id:select3  З
    Click Green Button Multiple Times   2
    Click Blue Button Multiple Times    1
    Click Red Button Multiple Times    3

    Click Button  id=${sort_button_id}
    Click Button  id=${clear_button_id}

    # Проверка, что в выпадающих списках значение "Выбери"
    ${selected}=    Get Selected List Label    id:select1
    Should Be Equal As Strings    ${selected}    Выбери
    ${selected}=    Get Selected List Label    id:select2
    Should Be Equal As Strings    ${selected}    Выбери
    ${selected}=    Get Selected List Label    id:select3
    Should Be Equal As Strings    ${selected}    Выбери

    # Проверка, что в строке-входной последовательности пусто
    ${subsequence}=    Get Text  id:output
    Should Be Empty  ${subsequence}

    # Проверка, что в строке-результате пусто
    ${text_result}=    Get Text  id:result
    Should Be Empty  ${text_result}
    Close Browser

Check Sorting Rule - Test 13
    [Documentation]  Проверка правильности сортировки
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome
    # Выбор значений значений в выпадающих списках
    Select From List By Value  id:select1  К
    Select From List By Value  id:select2  З
    Select From List By Value  id:select3  С
    # Формирование произвольной строки и нажатие кнопки сортировки
    Click Blue Button Multiple Times    2
    Click Red Button Multiple Times    4
    Click Green Button Multiple Times   5
    Click Red Button Multiple Times    1
    Click Button  id=sendDataButton
    Sleep    3 seconds
    # Cчитывание строки-результата и приведение ее к виду "без спецсимвола": замена \n на пробел
    ${text_result}=    Get Text  id:result
    ${cleaned_result}=    Replace String    ${text_result}    \n    ${SPACE}
    Log    ${cleaned_result}
    # Cравнение строки-результата и ожидаемой строки
    Should Be Equal As Strings  ${cleaned_result}  К К К К К З З З З З С С
    Close Browser

Check Hight Loaded Sorting - Test 14
    [Documentation]  Проверка правильности сортировки при большой нагрузке
    Open Browser    https://enchanting-dango-f1fff3.netlify.app  Chrome
    # Выбор значений значений в выпадающих списках
    Select From List By Value  id:select1  З
    Select From List By Value  id:select2  К
    Select From List By Value  id:select3  С
    # Формирование произвольной строки и нажатие кнопки сортировки
    Click Blue Button Multiple Times    15
    Click Red Button Multiple Times    12
    Click Green Button Multiple Times   23
    Click Red Button Multiple Times    10
    Click Blue Button Multiple Times    34
    Click Red Button Multiple Times    7
    Click Button  id=sendDataButton
    Sleep    3 seconds

    # Cчитывание строки-результата и приведение ее к виду "без спецсимвола": замена \n на пробел
    ${text_result}=    Get Text  id:result
    ${cleaned_result}=    Replace String    ${text_result}    \n    ${SPACE}
    Log    ${cleaned_result}
    # Cравнение строки-результата и ожидаемой строки
    Should Be Equal As Strings  ${cleaned_result}  З З З З З З З З З З З З З З З З З З З З З З З К К К К К К К К К К К К К К К К К К К К К К К К К К К К К С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С С
    Close Browser
