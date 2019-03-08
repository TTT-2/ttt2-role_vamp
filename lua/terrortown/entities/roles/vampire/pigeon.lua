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

	ply.pigeon.ghost:Remove()

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

function PIGEON.HooksEnable()
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
end

function PIGEON.HooksDisable()
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

if CLIENT then
	function PIGEON.Hooks.CalcView(ply, pos, ang, fov)
		if not ply.pigeon then return end

		ang = ply:GetAimVector():Angle()

		local ghost = ply:GetNWEntity("pigeon.ghost")
		if ghost and ghost:IsValid() then
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

		if key == IN_JUMP and ply:IsOnGround() then
			--	ply:SetMoveType(4)
			--	ply:SetVelocity(ply:GetForward() * 300 + Vector(0, 0, 100))
			--elseif key == IN_JUMP and ply:IsOnGround() then
			ply:SetMoveType(2)
			ply:SetVelocity(ply:GetForward() * 300 + ply:GetAimVector())
		elseif key == IN_JUMP and not ply:IsOnGround() then
			ply:SetVelocity(ply:GetForward() * 300 + ply:GetAimVector())
		elseif ply:IsOnGround() then
			ply:SetMoveType(2)
		elseif not ply:IsOnGround() and key == IN_WALK then
			ply:SetMaxSpeed(250)
		else
			ply:SetMoveType(0)
		end

		if ply:OnGround() and key == IN_SPEED then
			ply:SetVelocity(ply:GetForward() * 1500 + Vector(0, 0, 100))
			ply:SetMoveType(2)
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

		if ply:IsOnGround() then
			ply:SetMoveType(2)

			if speed > 0 then
				sequence = "Walk"

				ply:SetMaxSpeed(200)

				if speed > 200 then
					sequence = "Run"
					rate = 1
				end
			end
		elseif not ply:IsOnGround() then
			ply:SetMoveType(4)

			rate = 1

			ply:SetMaxSpeed(100)

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

		sequenceIndex = ply.pigeon.ghost:LookupSequence(sequence)

		if ply.pigeon.ghost:GetSequence() ~= sequenceIndex then
			ply.pigeon.ghost:Fire("setanimation", sequence, 0)
		end

		ply:SetPlaybackRate(rate)

		ply.pigeon.ghost:SetPlaybackRate(rate)
	end

	function PIGEON.Hooks.PickupWeapon(ply, wep)
		if ply.pigeon then
			return false
		end
	end
end
