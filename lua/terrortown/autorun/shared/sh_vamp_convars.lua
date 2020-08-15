CreateConVar("ttt2_vamp_bloodtime", "60", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_vamp_maxhealth", "250", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicVampCVars", function(tbl)
	tbl[ROLE_VAMPIRE] = tbl[ROLE_VAMPIRE] or {}

	table.insert(tbl[ROLE_VAMPIRE], {
		cvar = "ttt2_vamp_bloodtime",
		slider = true,
		desc = "vampire bloodlust time (def: 60)"
	})

	table.insert(tbl[ROLE_VAMPIRE], {
		cvar = "ttt2_vamp_maxhealth",
		slider = true,
		min = 100,
		max = 600,
		desc = "vampire max health (def: 250)"
	})
end)
