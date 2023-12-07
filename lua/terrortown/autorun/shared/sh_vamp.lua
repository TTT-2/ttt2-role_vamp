CreateConVar("ttt2_vamp_bloodtime", "60", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("ttt2_vamp_maxhealth", "250", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

if SERVER then
	resource.AddFile("sound/bird_sounds/pigeon_idle2.wav")
	resource.AddFile("sound/bird_sounds/pigeon_idle4.wav")

	resource.AddFile("materials/vgui/ttt/hudhelp/vampire.vmt")
end

if CLIENT then
	local materialVampire = Material("vgui/ttt/hudhelp/vampire")

	hook.Add("TTT2FinishedLoading", "TTTRoleVampireInit", function()
		bind.Register("vamptranstoggle", function()
			net.Start("TTT2RequestVampTransformation")
			net.SendToServer()
		end, nil, roles.VAMPIRE.name, "label_bind_vampire_toggle", KEY_V)

		keyhelp.RegisterKeyHelper("vamptranstoggle", materialVampire, KEYHELP_CORE, "label_keyhelper_vampire", function(client)
			if client:IsSpec() or client:GetSubRole() ~= ROLE_VAMPIRE then return end

			return true
		end)
	end)
end
