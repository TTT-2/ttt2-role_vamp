local L = LANG.GetLanguageTableReference("es")

-- GENERAL ROLE LANGUAGE STRINGS
L[VAMPIRE.name] = "Vampiro"
L["info_popup_" .. VAMPIRE.name] = [[¡Eres un Vampiro!
¡Es tiempo de un poco de sangre!
Sino, morirás...]]
L["body_found_" .. VAMPIRE.abbr] = "¡Era un Vampiro!"
L["search_role_" .. VAMPIRE.abbr] = "Esta persona era un Vampiro."
L["target_" .. VAMPIRE.name] = "Vampiro"
L["ttt2_desc_" .. VAMPIRE.name] = [[El Vampiro es un traidor que no puede acceder a la tienda ([C]), pero puede transformarse en murciélago/ave con [LALT] (la tecla de caminar). Para balancearlo, el Vampiro necesita matar a una persona por minuto. De lo contrario, caerá en el estado de Lujuria de Sangre. En este estado, el Vampiro pierde vida por segundo.
Además, en ese estado se cura un 50% del daño que le haga a otras personas. Si así lo desea, al estar en Lujuria de Sangre, puede transformarse en un murciélago/ave. Puedes activar este estado transformándote voluntariamente, aunque no podrás deshacerlo.]]
