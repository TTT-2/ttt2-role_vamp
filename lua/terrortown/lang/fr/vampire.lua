local L = LANG.GetLanguageTableReference("fr")

-- GENERAL ROLE LANGUAGE STRINGS
L[VAMPIRE.name] = "Vampire"
L["info_popup_" .. VAMPIRE.name] = [[Vous êtes un Vampire!
Il est temps d'avoir du sang!
Sinon, vous allez mourir...]]
L["body_found_" .. VAMPIRE.abbr] = "C'était un Vampire!"
L["search_role_" .. VAMPIRE.abbr] = "Cette personne était un Vampire ..."
L["target_" .. VAMPIRE.name] = "Vampire"
L["ttt2_desc_" .. VAMPIRE.name] = [[Le Vampire est un traître (qui travaille avec les autres traîtres) et son but est de tuer tous les autres rôles, sauf les autres traître.
Le Vampire ne peut pas accéder au ([C]) shop, mais il peut se transformer en pigeon en appuyant sur [LALT] (Touche pour Marcher lentement). Pour qu'il soit équilibré, le Vampire doit tuer un autre joueur chaque minute. Sinon il tombera dans une soif de sang. En soif de sang le Vampire perd 1 hp toutes les 2 secondes.
En soif de sang,le Vampire se soigne de 50% des dommages qu'il a causés aux autres joueurs. En plus de cela, il peut se transformer en pigeon s'il est en soif de sang. Vous pouvez donc aussi déclencher la soif de sang, mais il n'est pas possible de la stopper.]]
