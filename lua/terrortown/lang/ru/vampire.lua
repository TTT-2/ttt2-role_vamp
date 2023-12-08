local L = LANG.GetLanguageTableReference("ru")

-- GENERAL ROLE LANGUAGE STRINGS
L[VAMPIRE.name] = "Вампир"
L["info_popup_" .. VAMPIRE.name] = [[Вы вампир!
Пришло время для крови!
Иначе вы умрёте...]]

L["body_found_" .. VAMPIRE.abbr] = "Он был вампиром!"
L["search_role_" .. VAMPIRE.abbr] = "Этот человек был вампиром ..."
L["target_" .. VAMPIRE.name] = "Вампир"
L["ttt2_desc_" .. VAMPIRE.name] = [[Вампир - предатель (который работает вместе с другими предателями), и его цель - убить всех остальных ролей, кроме других ролей предателя.
Вампир НЕ МОЖЕТ получить доступ к магазину ([C]), но он может превратиться в голубя, нажав [LALT] (медленный шаг). Чтобы сделать его сбалансированным, вампиру нужно каждую минуту убивать другого игрока. В противном случае он впадёт в кровожадность. В кровожадности вампир теряет 1 ед. здоровья каждые 2 секунды.
В кровожадности вампир восстанавливает 50% урона, нанесённого другим игрокам. Кроме того, он может просто превратиться в голубя, если он жаждет крови. Таким образом, вы также можете вызвать кровожадность, но отменить её невозможно.]]

-- OTHER ROLE LANGUAGE STRINGS
--L["label_vamp_bloodtime"] = "Vampire bloodlust time"
--L["label_vamp_maxhealth"] = "Vampire max health"

--L["label_bind_vampire_toggle"] = "toggle transformation"
--L["label_keyhelper_vampire"] = "toggle vampire transformation"
