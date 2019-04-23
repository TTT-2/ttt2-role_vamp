AddCSLuaFile()

-- by grea$emonkey and Alf21

-- TODO: FIX: vehicles
-- TODO: FIX: looking up jumps backwards
-- TODO: FIX: fly handling

if SERVER then
	resource.AddFile("sound/bird_sounds/pigeon_idle2.wav")
	resource.AddFile("sound/bird_sounds/pigeon_idle4.wav")
end

PIGEON = {}

PIGEON.model = util.IsValidModel("models/tsbb/animals/bat.mdl") and Model("models/tsbb/animals/bat.mdl") or Model("models/pigeon.mdl")
PIGEON.sounds = {}
PIGEON.sounds.idle = Sound("bird_sounds/pigeon_idle2.wav", 100, 100)
PIGEON.sounds.pain = Sound("bird_sounds/pigeon_idle4.wav", 100, 100)

PIGEON.Hooks = {}

-------------------------------------------------------------------------------
-- HELPER FUNCTIONS

function PIGEON.Enable(ply)
	if ply.pigeon then return end

	if CLIENT then
		ply.pigeon = true

		return
	end

	ply:DrawViewModel(false)
	ply:DrawWorldModel(false)

	GAMEMODE:SetPlayerSpeed(ply, 250, 500)

	ply:ConCommand("-duck\n")

	ply.pigeon = {}
	ply.pigeon.idleTimer = 0
	ply.pigeon.model = ply:GetModel()

	ply:SetModel(PIGEON.model)

	ply.pigeon.ghost = PIGEON.Ghost(ply)

	ply:SetNWEntity("pigeon.ghost", ply.pigeon.ghost)

	if not ply.pigeonHasPrinted then
		ply:PrintMessage(HUD_PRINTTALK, "You're a pigeon! AWESOME!\nJump to start flying and then jump again to speed up.\nSprint to hop forward.\nReload to make a cute noise.\n")

		ply.pigeonHasPrinted = true
	end
end

function PIGEON.Disable(ply)
	ply:ConCommand("-duck\n")

	if CLIENT then
		ply.pigeon = false

		return
	end

	ply:SetRunSpeed(220)
	ply:SetWalkSpeed(220)
	ply:SetMaxSpeed(220)

	ply:DrawViewModel(true)
	ply:DrawWorldModel(true)

	if not ply.pigeon then return end

	if IsValid(ply.pigeon.ghost) then
		ply.pigeon.ghost:Remove()
	end

	ply:SetNWEntity("pigeon.ghost", nil)
	ply:SetModel(ply.pigeon.model)
	ply:SetMoveType(MOVETYPE_WALK)

	ply.pigeon = nil
end

function PIGEON.Ghost(ply)
	local e = ents.Create("prop_dynamic")
	e:SetAngles(ply:GetAngles())
	e:SetCollisionGroup(COLLISION_GROUP_NONE)
	e:SetColor(Color(255, 255, 255, 0))
	e:SetMoveType(MOVETYPE_NONE)
	e:SetModel(PIGEON.model)
	e:SetParent(ply)
	e:SetPos(ply:GetPos())
	e:SetRenderMode(RENDERMODE_TRANSALPHA)
	e:SetSolid(SOLID_NONE)
	e:Spawn()

	return e
end

function PIGEON.Idle(ply)
	if CurTime() >= ply.pigeon.idleTimer then
		ply.pigeon.idleTimer = CurTime() + 2

		ply:EmitSound(PIGEON.sounds.idle, 100, 100)
	end
end

-- =============================================================================
-- HOOKS

hook.Add("TTT2ToggleRole", "TogglePigeonHooks", function(roleData, toggled)
	if roleData == VAMPIRE then
		if toggled then
			if CLIENT then
				hook.Add("CalcView", "PIGEON.CalcView", PIGEON.Hooks.CalcView)
			else
				hook.Add("KeyPress", "PIGEON.KeyPress", PIGEON.Hooks.KeyPress)
				hook.Add("PlayerHurt", "PIGEON.PlayerHurt", PIGEON.Hooks.Hurt)
				hook.Add("PlayerSetModel", "PIGEON.PlayerSetModel", PIGEON.Hooks.SetModel)
				hook.Add("SetPlayerAnimation", "PIGEON.SetPlayerAnimation", PIGEON.Hooks.SetAnimation)
				hook.Add("UpdateAnimation", "PIGEON.UpdateAnimation", PIGEON.Hooks.UpdateAnimation)
				hook.Add("PlayerCanPickupWeapon", "PIGEON.PickupWeapon", PIGEON.Hooks.PickupWeapon)
			end
		else
			if CLIENT then
				hook.Remove("CalcView", "PIGEON.CalcView")
			else
				hook.Remove("KeyPress", "PIGEON.KeyPress")
				hook.Remove("PlayerHurt", "PIGEON.PlayerHurt")
				hook.Remove("PlayerSetModel", "PIGEON.PlayerSetModel")
				hook.Remove("SetPlayerAnimation", "PIGEON.SetPlayerAnimation")
				hook.Remove("UpdateAnimation", "PIGEON.UpdateAnimation")
				hook.Remove("PlayerCanPickupWeapon", "PIGEON.PickupWeapon")
			end
		end
	end
end)

if CLIENT then
	function PIGEON.Hooks.CalcView(ply, pos, ang, fov)
		if not ply.pigeon then return end

		ang = ply:GetAimVector():Angle()

		local ghost = ply:GetNWEntity("pigeon.ghost")
		if IsValid(ghost) then
			if GetViewEntity() == ply then
				ghost:SetColor(Color(255, 255, 255, 255))
			else
				ghost:SetColor(Color(255, 255, 255, 0))

				return
			end
		end

		local t = {}
		t.start = ply:GetPos() + ang:Up() * 20
		t.endpos = t.start + ang:Forward() * -50
		t.filter = ply

		local tr = util.TraceLine(t)

		pos = tr.HitPos

		if tr.Fraction < 1 then
			pos = pos + tr.HitNormal * 2
		end

		return GAMEMODE:CalcView(ply, pos, ang, fov)
	end
else -- SERVER
	function PIGEON.Hooks.Hurt(ply, attacker)
		if ply.pigeon then
			ply:EmitSound(PIGEON.sounds.pain)
		end
	end

	function PIGEON.Hooks.KeyPress(ply, key)
		if not ply.pigeon then return end

		if key == IN_JUMP and ply:OnGround() then
			ply:SetMoveType(MOVETYPE_NOCLIP)
			ply:SetVelocity(ply:GetAimVector() * 100)
		elseif key == IN_JUMP and not ply:OnGround() then
			ply:SetVelocity(ply:GetAimVector() + Vector(0, 0, 50))
		elseif not ply:OnGround() and key == IN_WALK then
			ply:SetMaxSpeed(250)
		end
	end

	function PIGEON.Hooks.SetAnimation(ply, animation)
		if ply.pigeon then
			return false
		end
	end

	function PIGEON.Hooks.SetModel(ply)
		if ply.pigeon then
			return false
		end
	end

	function PIGEON.Hooks.UpdateAnimation(ply)
		if not ply.pigeon then return end

		local rate = 2
		local sequence = "idle01"
		local speed = ply:GetVelocity():Length()

		if ply:OnGround() then
			ply:SetMoveType(MOVETYPE_WALK)

			if speed > 0 then
				sequence = "Walk"

				if speed > 200 then
					sequence = "Run"
					rate = 1
				end
			end
		elseif not ply:OnGround() then
			ply:SetMoveType(MOVETYPE_FLY)

			rate = 1

			if speed > 0 then
				sequence = "Soar"

				if speed > 400 then
					sequence = "Fly01"
				end
			end
		else
			if ply:WaterLevel() > 1 then
				sequence = "Soar"
			else
				sequence = "Idle01"
			end
		end

		if PIGEON.model ~= "models/pigeon.mdl" then return end

		local sequenceIndex = ply:LookupSequence(sequence)

		if ply:GetSequence() ~= sequenceIndex then
			ply:ResetSequence(sequenceIndex)
		end

		local ghost = ply.pigeon.ghost

		if IsValid(ghost) then
			sequenceIndex = ghost:LookupSequence(sequence)

			if ply.pigeon.ghost:GetSequence() ~= sequenceIndex then
				ply.pigeon.ghost:Fire("setanimation", sequence, 0)
			end

			ply.pigeon.ghost:SetPlaybackRate(rate)
		end

		ply:SetPlaybackRate(rate)
	end

	function PIGEON.Hooks.PickupWeapon(ply, wep)
		if ply.pigeon then
			return false
		end
	end
end
