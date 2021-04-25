local L = LANG.GetLanguageTableReference("de")

-- GENERAL ROLE LANGUAGE STRINGS
L[VAMPIRE.name] = "Vampir"
L["info_popup_" .. VAMPIRE.name] = [[Du bist ein Vampir!
Es ist Zeit für etwas Blut! Ansonsten wirst du sterben...]]
L["body_found_" .. VAMPIRE.abbr] = "Er war ein Vampir..."
L["search_role_" .. VAMPIRE.abbr] = "Diese Person war ein Vampir!"
L["target_" .. VAMPIRE.name] = "Vampir"
L["ttt2_desc_" .. VAMPIRE.name] = [[Der Vampir ist ein Verräter (der mit den anderen Verräter-Rollen zusammenarbeitet) und dessen Ziel es ist, alle anderen Rollen (außer Verräter-Rollen) zu töten.
Er kann NICHT den ([C]) Shop betreten, doch dafür kann er sich, wenn er die Taste [LALT] (Walk-slowly Taste) drückt, in eine Taube verwandeln. Damit der Vampir nicht zu stark ist, muss er jede Minute einen anderen Spieler killen. Ansonsten fällt er in den Blutdurst. Im Blutdurst verliert der Vampir jede Sekunde 1hp.
Allerdings heilt er sich im Blutdurst auch um 50% des Schadens, den er anderen Spielern zufügt. Er kann sich auch nur im Blutdurst transformieren. Du kannst also mit [LALT] den Blutdurst triggern, doch es nicht rückgängig machen.]]
