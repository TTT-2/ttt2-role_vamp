include("pigeon.lua")

if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_vamp.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_vamp.vmt")

	util.AddNetworkString("TTT2VampPigeon")

	CreateConVar("ttt2_vamp_bloodtime", "60", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
else
	CreateClientConVar("ttt2_vamp_hud_x", "0.8", true, false, "The relative x-coordinate (position) of the HUD. (0-100) Def: 0.8")
	CreateClientConVar("ttt2_vamp_hud_y", "83.3", true, false, "The relative y-coordinate (position) of the HUD. (0-100) Def: 83.3")
end

-- important to add roles with this function,
-- because it does more than just access the array ! e.g. updating other arrays
InitCustomRole("VAMPIRE", { -- first param is access for ROLES array => ROLES["VAMPIRE"] or ROLES["VAMPIRE"]
		color = Color(104, 29, 24, 255), -- ...
		dkcolor = Color(37, 3, 0, 255), -- ...
		bgcolor = Color(18, 80, 29, 255), -- ...
		abbr = "vamp", -- abbreviation
		defaultTeam = TEAM_TRAITOR, -- the team name: roles with same team name are working together
		defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment
		surviveBonus = 0.5, -- bonus multiplier for every survive while another player was killed
		scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
		scoreTeamKillsMultiplier = -16 -- multiplier for teamkill
	}, {
		pct = 0.1, -- necessary: percentage of getting this role selected (per player)
		maximum = 1, -- maximum amount of roles in a round
		minPlayers = 10, -- minimum amount of players until this role is able to get selected
		togglable = true -- option to toggle a role for a client if possible (F1 menu)
})

-- now link this subrole with its baserole
hook.Add("TTT2BaseRoleInit", "TTT2ConBRTWithVamp", function()
	SetBaseRole(VAMPIRE, ROLE_TRAITOR)
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

local savedWeapons = savedWeapons or {}

function TransformToVamp(ply)
	if SERVER then
		if not ply:GetNWBool("transformedVamp", false) then -- transform
			savedWeapons[ply:SteamID64()] = {}

			for _, wep in pairs(ply:GetWeapons()) do
				-- todo save clip too !
				table.insert(savedWeapons[ply:SteamID64()], {cls = wep:GetClass(), clip1 = wep:Clip1(), clip2 = wep:Clip2()})
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

			for _, wep in pairs(savedWeapons[ply:SteamID64()]) do
				local w = ply:Give(wep.cls)
				w:SetClip1(wep.clip1)
				w:SetClip2(wep.clip2)
			end

			savedWeapons[ply:SteamID64()] = {}
		end
	end
end

local hooksInstalled = false

hook.Add("Think", "ThinkVampire", function()
	local rs = GetRoundState()

	if not hooksInstalled and rs == ROUND_ACTIVE then
		hooksInstalled = true

		PIGEON.HooksEnable()
	end

	if hooksInstalled and rs == ROUND_POST then
		hooksInstalled = false

		if SERVER then
			for _, v in ipairs(player.GetAll()) do
				if v:GetSubRole() == ROLE_VAMPIRE and v:GetNWBool("transformedVamp", false) then
					TransformToVamp(v)
				end
			end
		end

		PIGEON.HooksDisable()
	end

	for _, ply in ipairs(player.GetAll()) do
		if ply:IsActive() and ply:GetSubRole() == ROLE_VAMPIRE and ply:GetNWInt("Bloodlust", 0) < CurTime() then
			ply:SetNWBool("InBloodlust", true)

			local health = ply:Health() - 1

			if health > 0 then
				ply:SetHealth(health)
			else
				if SERVER then
					if ply:GetNWBool("transformedVamp", false) then
						TransformToVamp(ply)
					end

					ply:Kill()
				end
			end

			ply:SetNWInt("Bloodlust", CurTime() + 2)
		end
	end
end)

if SERVER then
	hook.Add("KeyRelease", "KeyReleaseVamp", function(ply, key)
		if key == IN_WALK and GetRoundState() == ROUND_ACTIVE and ply:IsActive() and ply:GetSubRole() == ROLE_VAMPIRE then
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

	-- is called if the role has been selected in the normal way of team setup
	hook.Add("TTT2UpdateSubrole", "UpdateVampRoleSelect", function(ply, old, new)
		if new == ROLE_VAMPIRE then
			ply:SetNWBool("InBloodlust", false)
			ply:SetNWInt("Bloodlust", CurTime() + GetConVar("ttt2_vamp_bloodtime"):GetInt())
		end
	end)

	-- if player is transformed and dies
	hook.Add("EntityTakeDamage", "VampKillsAnotherPly", function(target, dmginfo)
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

			local heal = (attacker:Health() + dmginfo:GetDamage() * 0.5)

			attacker:SetHealth(math.ceil(heal))
		end
	end)
else
	net.Receive("TTT2VampPigeon", function()
		local ply = LocalPlayer()

		local b = net.ReadBool()
		if b then
			PIGEON.Enable(ply)
		else
			PIGEON.Disable(ply)
		end
	end)

	surface.CreateFont("BLOODLUST", {font = "Trebuchet24", size = 24, weight = 750})

	local cv = GetConVar("rep_ttt2_vamp_bloodtime")

	hook.Add("HUDPaint", "VampHudBloodlust", function()
		local ply = LocalPlayer()
		local rstate = GetRoundState()

		cv = cv or GetConVar("rep_ttt2_vamp_bloodtime")

		if not cv then return end

		if rstate == ROUND_ACTIVE and IsValid(ply) and ply:IsActive() and ply:GetSubRole() == ROLE_VAMPIRE then
			local xPos = CreateClientConVar("ttt2_vamp_hud_x", "0.8", true, false, "The relative x-coordinate (position) of the HUD. (0-100) Def: 0.8")
			local yPos = CreateClientConVar("ttt2_vamp_hud_y", "83.3", true, false, "The relative y-coordinate (position) of the HUD. (0-100) Def: 83.3")

			local x = math.floor(ScrW() * math.min(math.max(xPos:GetFloat(), 0.01), 100) * 0.01)
			local y = math.floor(ScrH() * math.min(math.max(yPos:GetFloat(), 0.01), 100) * 0.01)

			draw.RoundedBox(8, x - 5, y - 10, 250, 60, Color(0, 0, 0, 200))

			local multiplier = 1
			local color = VAMPIRE.bgcolor

			if not ply:GetNWBool("InBloodlust", false) then
				local bloodlustTime = ply:GetNWInt("Bloodlust", 0)
				local delay = cv:GetInt()

				multiplier = bloodlustTime - CurTime()
				multiplier = multiplier / delay

				local secondColor = INNOCENT.color
				local r = color.r - (color.r - secondColor.r) * multiplier
				local g = color.g - (color.g - secondColor.g) * multiplier
				local b = color.b - (color.b - secondColor.b) * multiplier

				color = Color(r, g, b, 255)
			end

			draw.RoundedBox(8, x + 4, y + 4, 16 + 216 * multiplier, 27, color)

			surface.SetDrawColor(color)
			surface.DrawRect(x + 12, y + 5, 216 * multiplier, 25)

			surface.SetTexture(surface.GetTextureID("gui/corner8"))

			surface.DrawRect(x + 5, y + 13, 8, 9)
			surface.DrawTexturedRectRotated(x + 9, y + 9, 8, 8, 0)
			surface.DrawTexturedRectRotated(x + 9, y + 26, 8, 8, 90)

			surface.DrawRect(x + 10 + 217 * multiplier, y + 13, 8, 9)
			surface.DrawTexturedRectRotated(x + 14 + 217 * multiplier, y + 9, 8, 8, 270)
			surface.DrawTexturedRectRotated(x + 14 + 217 * multiplier, y + 26, 8, 8, 180)

			if ply:GetNWBool("InBloodlust", false) then
				draw.SimpleText("Bloodlust!", "BLOODLUST", x + 15, y + 7, Color(0, 0, 0), TEXT_ALIGN_LEFT)
				draw.SimpleText("Bloodlust!", "BLOODLUST", x + 17, y + 5, Color(255, 255, 255), TEXT_ALIGN_LEFT)
			end

			draw.SimpleText("BLOODLUST", "TabLarge", x + 179, y - 17, Color(255, 255, 255))
		end
	end)

	hook.Add("TTTSettingsTabs", "ttt2VampSettings", function(dtabs)
		local settings_panel = vgui.Create("DPanelList", dtabs)
		settings_panel:StretchToParent(0, 0, dtabs:GetPadding() * 2, 0)
		settings_panel:EnableVerticalScrollbar(true)
		settings_panel:SetPadding(10)
		settings_panel:SetSpacing(10)
		dtabs:AddSheet("Bloodlust", settings_panel, "icon16/user_red.png", false, false, "The bloodlust settings")

		local list = vgui.Create("DIconLayout", settings_panel)
		list:SetSpaceX(5)
		list:SetSpaceY(5)
		list:Dock(FILL)
		list:DockMargin(5, 5, 5, 5)
		list:DockPadding(10, 10, 10, 10)

		local settings_tab = vgui.Create("DForm")
		settings_tab:SetSpacing(10)
		settings_tab:SetName("HUD Position")
		settings_tab:SetWide(settings_panel:GetWide() - 30)
		settings_panel:AddItem(settings_tab)

		settings_tab:NumSlider("x-coordinate (position)", "ttt2_vamp_hud_x", 0, ScrW(), 2)
		settings_tab:NumSlider("y-coordinate (position)", "ttt2_vamp_hud_y", 0, ScrH(), 2)

		settings_tab:SizeToContents()
	end)
end
