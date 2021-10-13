if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("pigeon.lua")

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_vamp.vmt")

	util.AddNetworkString("TTT2VampPigeon")
	util.AddNetworkString("TTT2RequestVampTransformation")
end

include("pigeon.lua")

function ROLE:PreInitialize()
	self.color = Color(149, 43, 37, 255)

	self.abbr = "vamp"
	self.score.surviveBonusMultiplier = 0.5
	self.score.timelimitMultiplier = -0.5
	self.score.killsMultiplier = 2
	self.score.teamKillsMultiplier = -16
	self.score.bodyFoundMuliplier = 0

	self.defaultTeam = TEAM_TRAITOR
	self.defaultEquipment = SPECIAL_EQUIPMENT

	self.conVarData = {
		pct = 0.1,
		maximum = 1,
		minPlayers = 10,
		togglable = true,
		traitorButton = 1,
		credits = 2,
		creditsAwardDeadEnable = 1,
		creditsAwardKillEnable = 1
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_TRAITOR)
end

if SERVER then
	local savedWeapons = savedWeapons or {}

	function TransformToVamp(ply)
		if not ply:GetNWBool("transformedVamp", false) then -- transform
			savedWeapons[ply:SteamID64()] = {}

			for _, wep in pairs(ply:GetWeapons()) do
				savedWeapons[ply:SteamID64()][#savedWeapons[ply:SteamID64()] + 1] = {
					cls = wep:GetClass(),
					clip1 = wep:Clip1(),
					clip2 = wep:Clip2()
				}
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

			local oldHealth = attacker:Health()

			if oldHealth < GetConVar("ttt2_vamp_maxhealth"):GetInt() then
				local heal = math.min(oldHealth + (ply:Health() or 100), math.ceil(oldHealth + dmginfo:GetDamage() * 0.5))

				attacker:SetMaxHealth(math.max(heal, attacker:GetMaxHealth()))

				if heal > GetConVar("ttt2_vamp_maxhealth"):GetInt() then
					heal = GetConVar("ttt2_vamp_maxhealth"):GetInt()
				end

				attacker:SetHealth(heal)
			end
		end
	end)
end

if CLIENT then
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
