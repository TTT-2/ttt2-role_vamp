local L = LANG.GetLanguageTableReference("zh_hans")

-- GENERAL ROLE LANGUAGE STRINGS
L[VAMPIRE.name] = "吸血鬼"
L["info_popup_" .. VAMPIRE.name] = [[你是个吸血鬼!
是时候流血了!
否则,你会死...]]
L["body_found_" .. VAMPIRE.abbr] = "他们是吸血鬼!"
L["search_role_" .. VAMPIRE.abbr] = "这个人是吸血鬼 ..."
L["target_" .. VAMPIRE.name] = "吸血鬼"
L["ttt2_desc_" .. VAMPIRE.name] = [[吸血鬼是叛徒(与其他叛徒一起工作),目标是杀死除其他叛徒角色之外的所有其他角色.
吸血鬼无法进入([C])商店,但他们可以通过按[LALT](缓慢行走键)变成鸽子.为了保持平衡,吸血鬼需要每分钟杀死另一名玩家.否则,他会陷入嗜血.在嗜血中,吸血鬼每2秒损失1点生命.
在《嗜血狂》中,吸血鬼对其他玩家造成的伤害有50%可以治愈.除此之外,如果他们嗜血,他们可以变成鸽子.他们也可以触发嗜血,但不可能解除它.]]
