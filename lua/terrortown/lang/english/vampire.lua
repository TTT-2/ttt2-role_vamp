local L = LANG.GetLanguageTableReference("english")

-- GENERAL ROLE LANGUAGE STRINGS
L[VAMPIRE.name] = "Vampire"
L["info_popup_" .. VAMPIRE.name] = [[You are a Vampire!
It's time for some blood!
Otherwise, you will die...]]
L["body_found_" .. VAMPIRE.abbr] = "They were a Vampire!"
L["search_role_" .. VAMPIRE.abbr] = "This person was a Vampire ..."
L["target_" .. VAMPIRE.name] = "Vampire"
L["ttt2_desc_" .. VAMPIRE.name] = [[The Vampire is a Traitor (who works together with the other traitors) and the goal is to kill all other roles except the other traitor roles.
The vampire CAN'T access the ([C]) shop, but he can transform into a pigeon by pressing [LALT] (Walk-slowly key). To make it balanced, the Vampire needs to kill another player every minute. Otherwise, he will fall into Bloodlust. In Bloodlust, the Vampire loses 1 hp every 2 seconds.
In Bloodlust, the vampire heals 50% of the damage he did to other players. In addition to that, he can just transform into Pigeon if he is in bloodlust. So you be also able to trigger into bloodlust, but it's not possible to undo it.]]
