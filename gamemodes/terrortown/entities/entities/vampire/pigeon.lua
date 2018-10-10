AddCSLuaFile()

-- by grea$emonkey and Alf21

-- TODO: FIX: vehicles
-- TODO: FIX: looking up jumps backwards
-- TODO: FIX: fly handling
-- TODO: FIX: jump to fly

if SERVER then
	resource.AddFile("sound/bird_sounds/pigeon_idle2.wav")
	resource.AddFile("sound/bird_sounds/pigeon_idle4.wav")
end

PIGEON = {}

PIGEON.model = Model("models/pigeon.mdl")
PIGEON.sounds = {}
PIGEON.sounds.idle = Sound("bird_sounds/pigeon_idle2.wav", 100, 100)
PIGEON.sounds.pain = Sound("bird_sounds/pigeon_idle4.wav", 100, 100)

PIGEON.Hooks = {}

-------------------------------------------------------------------------------
-- HELPER FUNCTIONS

function PIGEON.Enable(player)
	if player.pigeon then return end

	if CLIENT then
		player.pigeon = true

		return
	end

	player:DrawViewModel(false)
	player:DrawWorldModel(false)

	GAMEMODE:SetPlayerSpeed(player, 250, 500)

	player:ConCommand("-duck\n")

	player.pigeon = {}
	player.pigeon.idleTimer = 0
	player.pigeon.model = player:GetModel()

	player:SetModel(PIGEON.model)

	player.pigeon.ghost = PIGEON.Ghost(player)

	player:SetNWEntity("pigeon.ghost", player.pigeon.ghost)

	if not player.pigeonHasPrinted then
		player:PrintMessage(HUD_PRINTTALK, "You're a pigeon! AWESOME!\nJump to start flying and then jump again to speed up.\nSprint to hop forward.\nReload to make a cute noise.\n")

		player.pigeonHasPrinted = true
	end
end

function PIGEON.Disable(player)
	player:ConCommand("-duck\n")

	if CLIENT then
		player.pigeon = false

		return
	end

	player:DrawViewModel(true)
	player:DrawWorldModel(true)

	if not player.pigeon then return end

	player.pigeon.ghost:Remove()

	player:SetNWEntity("pigeon.ghost", nil)
	player:SetModel(player.pigeon.model)
	player:SetMoveType(MOVETYPE_WALK)

	player.pigeon = nil
end

function PIGEON.Ghost(player)
	local e = ents.Create("prop_dynamic")
	e:SetAngles(player:GetAngles())
	e:SetCollisionGroup(COLLISION_GROUP_NONE)
	e:SetColor(Color(255, 255, 255, 0))
	e:SetMoveType(MOVETYPE_NONE)
	e:SetModel(PIGEON.model)
	e:SetParent(player)
	e:SetPos(player:GetPos())
	e:SetRenderMode(RENDERMODE_TRANSALPHA)
	e:SetSolid(SOLID_NONE)
	e:Spawn()

	return e
end

function PIGEON.Idle(player)
	if CurTime() >= player.pigeon.idleTimer then
		player.pigeon.idleTimer = CurTime() + 2

		player:EmitSound(PIGEON.sounds.idle, 100, 100)
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

-- CLIENT HOOKS
function PIGEON.Hooks.CalcView(player, pos, ang, fov)
	if not player.pigeon then
		return
	end

	ang = player:GetAimVector():Angle()

	local ghost = player:GetNWEntity("pigeon.ghost")
	if ghost and ghost:IsValid() then
		if GetViewEntity() == player then
			ghost:SetColor(Color(255, 255, 255, 255))
		else
			ghost:SetColor(Color(255, 255, 255, 0))

			return
		end
	end

	local t = {}
	t.start = player:GetPos() + ang:Up() * 20
	t.endpos = t.start + ang:Forward() * -50
	t.filter = player

	local tr = util.TraceLine(t)

	pos = tr.HitPos

	if tr.Fraction < 1 then
		pos = pos + tr.HitNormal * 2
	end

	return GAMEMODE:CalcView(player, pos, ang, fov)
end

-- SERVER HOOKS
function PIGEON.Hooks.Hurt(player, attacker)
	if player.pigeon then
		player:EmitSound(PIGEON.sounds.pain)
	end
end

function PIGEON.Hooks.KeyPress(player, key)
	if not player.pigeon then return end

	if key == IN_JUMP and player:IsOnGround() then
		player:SetMoveType(4)
		player:SetVelocity(player:GetForward() * 300 + Vector(0, 0, 100))
	elseif key == IN_JUMP and player:IsOnGround() then
		player:SetMoveType(2)
	elseif key == IN_JUMP and not player:IsOnGround() then
		player:SetVelocity(player:GetForward() * 300 + player:GetAimVector())
	elseif player:IsOnGround() then
		player:SetMoveType(2)
	elseif not player:IsOnGround() and key == IN_WALK then
		player:SetMaxSpeed(250)
	else
		player:SetMoveType(0)
	end

	if player:OnGround() and key == IN_SPEED then
		player:SetVelocity(player:GetForward() * 1500 + Vector(0, 0, 100))
		player:SetMoveType(2)
	end
end

function PIGEON.Hooks.SetAnimation(player, animation)
	if player.pigeon then
		return false
	end
end

function PIGEON.Hooks.SetModel(player)
	if player.pigeon then
		return false
	end
end

function PIGEON.Hooks.UpdateAnimation(player)
	if not player.pigeon then
		return
	end

	local rate = 2
	local sequence = "idle01"
	local speed = player:GetVelocity():Length()

	if player:IsOnGround() then
		player:SetMoveType(2)

		if speed > 0 then
			sequence = "Walk"

			player:SetMaxSpeed(200)

			if speed > 200 then
				sequence = "Run"
				rate = 1
			end
		end
	elseif not player:IsOnGround() then
		player:SetMoveType(4)

		rate = 1

		player:SetMaxSpeed(100)

		if speed > 0 then
			sequence = "Soar"

			if speed > 400 then
				sequence = "Fly01"
			end
		end
	else
		if player:WaterLevel() > 1 then
			sequence = "Soar"
		else
			sequence = "Idle01"
		end
	end

	local sequenceIndex = player:LookupSequence(sequence)

	if player:GetSequence() ~= sequenceIndex then
		player:ResetSequence(sequenceIndex)
	end

	sequenceIndex = player.pigeon.ghost:LookupSequence(sequence)

	if player.pigeon.ghost:GetSequence() ~= sequenceIndex then
		player.pigeon.ghost:Fire("setanimation", sequence, 0)
	end

	player:SetPlaybackRate(rate)

	player.pigeon.ghost:SetPlaybackRate(rate)
end

function PIGEON.Hooks.PickupWeapon(player, wep)
	if player.pigeon then
		return false
	end
end
