if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("pigeon.lua")

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_vamp.vmt")

	util.AddNetworkString("TTT2VampPigeon")
	util.AddNetworkString("TTT2RequestVampTransformation")

	CreateConVar("ttt2_vamp_bloodtime", "60", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
else
	CreateClientConVar("ttt2_vamp_hud_x", "0.8", true, false, "The relative x-coordinate (position) of the HUD. (0-100) Def: 0.8")
	CreateClientConVar("ttt2_vamp_hud_y", "83.3", true, false, "The relative y-coordinate (position) of the HUD. (0-100) Def: 83.3")
end

include("pigeon.lua")

ROLE.color = Color(149, 43, 37, 255) -- ...
ROLE.dkcolor = Color(67, 3, 0, 255) -- ...
ROLE.bgcolor = Color(29, 116, 40, 255) -- ...
ROLE.abbr = "vamp" -- abbreviation
ROLE.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
ROLE.surviveBonus = 0.5 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 5 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -16 -- multiplier for teamkill

ROLE.conVarData = {
	pct = 0.1, -- necessary: percentage of getting this role selected (per player)
	maximum = 1, -- maximum amount of roles in a round
	minPlayers = 10, -- minimum amount of players until this role is able to get selected
	togglable = true, -- option to toggle a role for a client if possible (F1 menu)
	credits = 2
}

-- now link this subrole with its baserole
hook.Add("TTT2BaseRoleInit", "TTT2ConBRTWithVamp", function()
	VAMPIRE:SetBaseRole(ROLE_TRAITOR)
end)

hook.Add("TTT2RolesLoaded", "AddVampTeam", function()
	VAMPIRE.defaultTeam = TEAM_TRAITOR
end)

hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicVampCVars", function(tbl)
	tbl[ROLE_VAMPIRE] = tbl[ROLE_VAMPIRE] or {}

	table.insert(tbl[ROLE_VAMPIRE], {cvar = "ttt2_vamp_bloodtime", slider = true, desc = "vampire bloodlust time"})
end)

-- if sync of roles has finished
hook.Add("TTT2FinishedLoading", "VampInitT", function()
	if CLIENT then
		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", VAMPIRE.name, "Vampire")
		LANG.AddToLanguage("English", "info_popup_" .. VAMPIRE.name, [[You are a Vampire!
It's time for some blood!
Otherwise, you will die...]])
		LANG.AddToLanguage("English", "body_found_" .. VAMPIRE.abbr, "This was a Vampire...")
		LANG.AddToLanguage("English", "search_role_" .. VAMPIRE.abbr, "This person was a Vampire!")
		LANG.AddToLanguage("English", "target_" .. VAMPIRE.name, "Vampire")
		LANG.AddToLanguage("English", "ttt2_desc_" .. VAMPIRE.name, [[The Vampire is a Traitor (who works together with the other traitors) and the goal is to kill all other roles except the other traitor roles ^^
The vampire CAN'T access the ([C]) shop, but he can transform into a pigeon by pressing [LALT] (Walk-slowly key). To make it balanced, the Vampire needs to kill another player every minute. Otherwise, he will fall into Bloodlust. In Bloodlust, the Vampire loses 1 hp every 2 seconds.
In Bloodlust, the vampire heals 50% of the damage he did to other players. In addition to that, he can just transform into Pigeon if he is in bloodlust. So you be also able to trigger into bloodlust, but it's not possible to undo it.]])

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", VAMPIRE.name, "Vampir")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. VAMPIRE.name, [[Du bist ein Vampir!
Es ist Zeit für etwas Blut!
Ansonsten wirst du sterben...]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. VAMPIRE.abbr, "Er war ein Vampir...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. VAMPIRE.abbr, "Diese Person war ein Vampir!")
		LANG.AddToLanguage("Deutsch", "target_" .. VAMPIRE.name, "Vampir")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. VAMPIRE.name, [[Der Vampir ist ein Verräter (der mit den anderen Verräter-Rollen zusammenarbeitet) und dessen Ziel es ist, alle anderen Rollen (außer Verräter-Rollen) zu töten ^^
Er kann NICHT den ([C]) Shop betreten, doch dafür kann er sich, wenn er die Taste [LALT] (Walk-slowly Taste) drückt, in eine Taube verwandeln. Damit der Vampir nicht zu stark ist, muss er jede Minute einen anderen Spieler killen. Ansonsten fällt er in den Blutdurst. Im Blutdurst verliert der Vampir jede Sekunde 1hp.
Allerdings heilt er sich im Blutdurst auch um 50% des Schadens, den er anderen Spielern zufügt. Er kann sich auch nur im Blutdurst transformieren. Du kannst also mit [LALT] den Blutdurst triggern, doch es nicht rückgängig machen.]])
	end
end)

if SERVER then
	local savedWeapons = savedWeapons or {}

	function TransformToVamp(ply)
		if not ply:GetNWBool("transformedVamp", false) then -- transform
			savedWeapons[ply:SteamID64()] = {}

			for _, wep in pairs(ply:GetWeapons()) do
				savedWeapons[ply:SteamID64()][#savedWeapons[ply:SteamID64()] + 1] = {cls = wep:GetClass(), clip1 = wep:Clip1(), clip2 = wep:Clip2()}
			end

			ply:StripWeapons()

			ply:ChatPrint("Transformed to PIGEON!")

			net.Start("TTT2VampPigeon")
			net.WriteBool(true)
			net.Send(ply)

			PIGEON.Enable(ply)

			ply:SetNWBool("transformedVamp", true)
		else -- undo
			ply:ChatPrint("Transformed to normal player!")

			net.Start("TTT2VampPigeon")
			net.WriteBool(false)
			net.Send(ply)

			PIGEON.Disable(ply)

			ply:SetNWBool("transformedVamp", false)

			if savedWeapons[ply:SteamID64()] then
				for _, wep in pairs(savedWeapons[ply:SteamID64()]) do
					local w = ply:Give(wep.cls)
					w:SetClip1(wep.clip1)
					w:SetClip2(wep.clip2)
				end
			end

			savedWeapons[ply:SteamID64()] = {}
		end
	end

	hook.Add("Think", "ThinkVampire", function()
		for _, ply in ipairs(player.GetAll()) do
			if ply:IsActive() and ply:GetSubRole() == ROLE_VAMPIRE and ply:GetNWInt("Bloodlust", 0) < CurTime() then
				ply:SetNWBool("InBloodlust", true)
				ply:TakeDamage(1, game.GetWorld())
				ply:SetNWInt("Bloodlust", CurTime() + 2)
			end
		end
	end)

	net.Receive("TTT2RequestVampTransformation", function(len, ply)
		if IsValid(ply) and ply:IsActive() and ply:Alive() and ply:GetSubRole() == ROLE_VAMPIRE then
			if not ply:GetNWBool("InBloodlust", false) and ply:GetNWInt("Bloodlust", 0) >= CurTime() then
				ply:SetNWInt("Bloodlust", 0)
				ply:SetNWBool("InBloodlust", true)
				ply:ChatPrint("You turned into bloodlust!")
			end

			if ply:GetNWBool("InBloodlust", false) then
				TransformToVamp(ply)
			end
		end
	end)

	hook.Add("TTTPrepareRound", "ResetVampirePigeon", function()
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetNWBool("transformedVamp", false) then
				TransformToVamp(ply)
			end
		end
	end)

	hook.Add("TTT2SyncGlobals", "AddVampireGlobals", function()
		SetGlobalInt("ttt2_vamp_bloodtime", GetConVar("ttt2_vamp_bloodtime"):GetInt())
	end)

	cvars.AddChangeCallback("ttt2_vamp_bloodtime", function(name, old, new)
		SetGlobalInt(name, tonumber(new))
	end, "TTT2VampBloodlust")

	-- is called if the role has been selected in the normal way of team setup
	hook.Add("TTT2UpdateSubrole", "UpdateVampRoleSelect", function(ply, old, new)
		if new == ROLE_VAMPIRE then
			ply:SetNWBool("InBloodlust", false)
			ply:SetNWInt("Bloodlust", CurTime() + GetConVar("ttt2_vamp_bloodtime"):GetInt())
		elseif old == ROLE_VAMPIRE then
			if ply:GetNWBool("transformedVamp", false) then
				TransformToVamp(ply)
			end

			ply:SetNWBool("InBloodlust", nil)
			ply:SetNWInt("Bloodlust", nil)
		end
	end)

	-- if player is transformed and dies
	hook.Add("EntityTakeDamage", "VampDeathDmg", function(target, dmginfo)
		if IsValid(target) and target:IsPlayer() and target:IsActive() and target:Health() - dmginfo:GetDamage() <= 0
		and target:GetSubRole() == ROLE_VAMPIRE and target:GetNWBool("transformedVamp", false)
		then
			TransformToVamp(target)
		end
	end)

	hook.Add("PlayerDeath", "VampKillsAnotherPly", function(victim, inflictor, attacker)
		if IsValid(attacker) and attacker:IsPlayer() and attacker:GetSubRole() == ROLE_VAMPIRE then
			attacker:SetNWBool("InBloodlust", false)
			attacker:SetNWInt("Bloodlust", CurTime() + GetConVar("ttt2_vamp_bloodtime"):GetInt())
		end

		if victim:GetSubRole() == ROLE_VAMPIRE and victim:GetNWBool("transformedVamp", false) then
			TransformToVamp(victim)
		end
	end)

	hook.Add("ScalePlayerDamage", "VampScaleDmg", function(ply, hitgroup, dmginfo)
		local attacker = dmginfo:GetAttacker()

		if ply:IsPlayer() and IsValid(attacker) and attacker:IsPlayer()
		and attacker:GetSubRole() == ROLE_VAMPIRE
		and attacker:GetNWBool("InBloodlust", false)
		then
			dmginfo:ScaleDamage(1.125)

			local heal = math.ceil(attacker:Health() + dmginfo:GetDamage() * 0.5)

			attacker:SetMaxHealth(math.max(heal, attacker:GetMaxHealth()))
			attacker:SetHealth(heal)
		end
	end)
else -- CLIENT
	net.Receive("TTT2VampPigeon", function()
		local ply = LocalPlayer()

		if net.ReadBool() then
			PIGEON.Enable(ply)
		else
			PIGEON.Disable(ply)
		end
	end)

	local function ToggleTransformation()
		net.Start("TTT2RequestVampTransformation")
		net.SendToServer()
	end
	bind.Register("vamptranstoggle", ToggleTransformation, nil, "Vampire", "Toggle Transformation")
end
