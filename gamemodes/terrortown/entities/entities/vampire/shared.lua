include("pigeon.lua")

if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/icon_vamp.vmt")
	resource.AddFile("materials/vgui/ttt/sprite_vamp.vmt")

	util.AddNetworkString("TTT2VampPigeon")
end
   
CreateConVar("ttt2_vamp_bloodtime", "60", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- important to add roles with this function,
-- because it does more than just access the array ! e.g. updating other arrays
AddCustomRole("VAMPIRE", { -- first param is access for ROLES array => ROLES["VAMPIRE"] or ROLES["VAMPIRE"]
	color = Color(104, 29, 24, 255), -- ...
	dkcolor = Color(93, 26, 22, 255), -- ...
	bgcolor = Color(83, 23, 19, 200), -- ...
	name = "vampire", -- just a unique name for the script to determine
	printName = "Vampire", -- The text that is printed to the player, e.g. in role alert
	abbr = "vamp", -- abbreviation
	team = TEAM_TRAITOR, -- the team name: roles with same team name are working together
	visibleForTraitors = true, -- other traitors can see this role / sync them with traitors
	defaultEquipment = SPECIAL_EQUIPMENT, -- here you can set up your own default equipment
    surviveBonus = 0.5, -- bonus multiplier for every survive while another player was killed
    scoreKillsMultiplier = 5, -- multiplier for kill of player of another team
    scoreTeamKillsMultiplier = -16, -- multiplier for teamkill
    --showOnConfirm = true -- shows the player on death to each client (e.g. on scoreboard)
}, {
    pct = 0.1, -- necessary: percentage of getting this role selected (per player)
    maximum = 1, -- maximum amount of roles in a round
    minPlayers = 10, -- minimum amount of players until this role is able to get selected
    togglable = true -- option to toggle a role for a client if possible (F1 menu)
})

-- if sync of roles has finished
hook.Add("TTT2_FinishedSync", "VampInitT", function(ply, first)
    if first then -- just on first init !
        hook.Add("TTTUlxDynamicRCVars", "TTTUlxDynamicVampCVars", function(tbl)
            tbl[ROLES.VAMPIRE.index] = tbl[ROLES.VAMPIRE.index] or {}
        
            table.insert(tbl[ROLES.VAMPIRE.index], {cvar = "ttt2_vamp_bloodtime", slider = true, desc = "vampire bloodlust time"})
        end)
        
        if CLIENT then
            -- setup here is not necessary but if you want to access the role data, you need to start here
            -- setup basic translation !
            LANG.AddToLanguage("English", ROLES.VAMPIRE.name, "Vampire")
            LANG.AddToLanguage("English", "info_popup_" .. ROLES.VAMPIRE.name, [[You are a Vampire! 
It's time for some blood!
Otherwise, you will die...]])
            LANG.AddToLanguage("English", "body_found_" .. ROLES.VAMPIRE.abbr, "This was a Vampire...")
            LANG.AddToLanguage("English", "search_role_" .. ROLES.VAMPIRE.abbr, "This person was a Vampire!")
            LANG.AddToLanguage("English", "target_" .. ROLES.VAMPIRE.name, "Vampire")
            LANG.AddToLanguage("English", "ttt2_desc_" .. ROLES.VAMPIRE.name, [[The Vampire is a Traitor (who works together with the other traitors) and the goal is to kill all other roles except the other traitor roles ^^ 
The vampire CAN'T access the ([C]) shop, but he can transform into a pigeon by pressing [LALT] (Walk-slowly key). To make it balanced, the Vampire needs to kill another player every minute. Otherwise, he will fall into Bloodlust. In Bloodlust, the Vampire loses 1 hp every 2 seconds.
In Bloodlust, the vampire heals 50% of the damage he did to other players. In addition to that, he can just transform into Pigeon if he is in bloodlust. So you be also able to trigger into bloodlust, but it's not possible to undo it.]])
            
            -- optional for toggling whether player can avoid the role
            LANG.AddToLanguage("English", "set_avoid_" .. ROLES.VAMPIRE.abbr, "Avoid being selected as Vampire!")
            LANG.AddToLanguage("English", "set_avoid_" .. ROLES.VAMPIRE.abbr .. "_tip", "Enable this to ask the server not to select you as Vampire if possible. Does not mean you are Traitor more often.")
            
            ---------------------------------

            -- maybe this language as well...
            LANG.AddToLanguage("Deutsch", ROLES.VAMPIRE.name, "Vampir")
            LANG.AddToLanguage("Deutsch", "info_popup_" .. ROLES.VAMPIRE.name, [[Du bist ein Vampir! 
Es ist Zeit für etwas Blut!
Ansonsten wirst du sterben...]])
            LANG.AddToLanguage("Deutsch", "body_found_" .. ROLES.VAMPIRE.abbr, "Er war ein Vampir...")
            LANG.AddToLanguage("Deutsch", "search_role_" .. ROLES.VAMPIRE.abbr, "Diese Person war ein Vampir!")
            LANG.AddToLanguage("Deutsch", "target_" .. ROLES.VAMPIRE.name, "Vampir")
            LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. ROLES.VAMPIRE.name, [[Der Vampir ist ein Verräter (der mit den anderen Verräter-Rollen zusammenarbeitet) und dessen Ziel es ist, alle anderen Rollen (außer Verräter-Rollen) zu töten ^^ 
Er kann NICHT den ([C]) Shop betreten, doch dafür kann er sich, wenn er die Taste [LALT] (Walk-slowly Taste) drückt, in eine Taube verwandeln. Damit der Vampir nicht zu stark ist, muss er jede Minute einen anderen Spieler killen. Ansonsten fällt er in den Blutdurst. Im Blutdurst verliert der Vampir jede Sekunde 1hp.
Allerdings heilt er sich im Blutdurst auch um 50% des Schadens, den er anderen Spielern zufügt. Er kann sich auch nur im Blutdurst transformieren. Du kannst also mit [LALT] den Blutdurst triggern, doch es nicht rückgängig machen.]])
            
            LANG.AddToLanguage("Deutsch", "set_avoid_" .. ROLES.VAMPIRE.abbr, "Vermeide als Vampir ausgewählt zu werden!")
            LANG.AddToLanguage("Deutsch", "set_avoid_" .. ROLES.VAMPIRE.abbr .. "_tip", "Aktivieren, um beim Server anzufragen, nicht als Vampir ausgewählt zu werden. Das bedeuted nicht, dass du öfter Traitor wirst!")
        end
    end
end)

local savedWeapons = savedWeapons or {}
    
function TransformToVamp(ply)
    if SERVER then
        if not ply:GetNWBool("transformedVamp", false) then -- transform
            savedWeapons[ply:SteamID()] = {}
            
            for _, wep in pairs(ply:GetWeapons()) do
                -- todo save clip too !
                table.insert(savedWeapons[ply:SteamID()], {cls = wep:GetClass(), clip1 = wep:Clip1(), clip2 = wep:Clip2()})
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
            
            for _, wep in pairs(savedWeapons[ply:SteamID()]) do
                local w = ply:Give(wep.cls)
                w:SetClip1(wep.clip1)
                w:SetClip2(wep.clip2)
            end
            
            savedWeapons[ply:SteamID()] = {}
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
                if v:GetRole() == ROLES.VAMPIRE.index and v:GetNWBool("transformedVamp", false) then
                    TransformToVamp(v)
                end
            end
        end
        
        PIGEON.HooksDisable()
    end

    for _, ply in ipairs(player.GetAll()) do
        if ply:IsActive() and ply:GetRole() == ROLES.VAMPIRE.index then
            if ply:GetNWInt("Bloodlust", 0) < CurTime() then
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
    end
end)
    
if SERVER then
    hook.Add("KeyRelease", "KeyReleaseVamp", function(ply, key)
        if key == IN_WALK and GetRoundState() == ROUND_ACTIVE then
            if ply:IsActive() and ply:GetRole() == ROLES.VAMPIRE.index then
                if not ply:GetNWBool("InBloodlust", false) and ply:GetNWInt("Bloodlust", 0) >= CurTime() then
                    ply:SetNWInt("Bloodlust", 0)
                    ply:SetNWBool("InBloodlust", true)
                    ply:ChatPrint("You turned into bloodlust!")
                end
                
                if ply:GetNWBool("InBloodlust", false) then
                    TransformToVamp(ply)
                end
            end
        end
    end)
    
	-- is called if the role has been selected in the normal way of team setup
	hook.Add("TTT2_RoleTypeSet", "UpdateVampRoleSelect", function(ply)
		if ply:GetRole() == ROLES.VAMPIRE.index then
            ply:SetNWBool("InBloodlust", false)
            ply:SetNWInt("Bloodlust", CurTime() + GetConVar("ttt2_vamp_bloodtime"):GetInt())
		end
	end)
    
    hook.Add("PlayerDeath", "VampKillsAnotherPly", function(victim, inflictor, attacker)
        if IsValid(attacker) and attacker:IsPlayer() and attacker:GetRole() == ROLES.VAMPIRE.index then
            attacker:SetNWBool("InBloodlust", false)
            attacker:SetNWInt("Bloodlust", CurTime() + GetConVar("ttt2_vamp_bloodtime"):GetInt())
        end
		
		if victim:GetRole() == ROLES.VAMPIRE.index and victim:GetNWBool("transformedVamp", false) then
			TransformToVamp(victim)
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

	hook.Add("ScalePlayerDamage", "VampScaleDmg", function(ply, hitgroup, dmginfo)
		if ply:IsPlayer() and dmginfo:GetAttacker():IsPlayer() then
			if dmginfo:IsBulletDamage() then
				if dmginfo:GetAttacker():GetRole() == ROLES.VAMPIRE.index and dmginfo:GetAttacker():GetNWBool("InBloodlust", false) then
			        dmginfo:ScaleDamage(1.125)
                    
                    local heal = (dmginfo:GetAttacker():Health() + dmginfo:GetDamage() / 2)
                    
                    dmginfo:GetAttacker():SetHealth(math.ceil(heal))
			    end
			end
		end
	end)
    
    surface.CreateFont("BLOODLUST", {font = "Trebuchet24", size = 24, weight = 750})

    hook.Add("HUDPaint", "VampHudBloodlust", function()
        local ply = LocalPlayer()
        local rstate = GetRoundState()
        
        if rstate == ROUND_ACTIVE and IsValid(ply) and ply:IsActive() and ply:GetRole() == ROLES.VAMPIRE.index then
            local xPos = CreateClientConVar("ttt2_vamp_hud_x", "0.8", true, false, "The relative x-coordinate (position) of the HUD. (0-100) Def: 0.8")
            local yPos = CreateClientConVar("ttt2_vamp_hud_y", "83.3", true, false, "The relative y-coordinate (position) of the HUD. (0-100) Def: 83.3")
            
            local x = math.floor(ScrW() * math.min(math.max(xPos:GetFloat(), 0.01), 100) / 100)
            local y = math.floor(ScrH() * math.min(math.max(yPos:GetFloat(), 0.01), 100) / 100)
            
            draw.RoundedBox(8, x - 5, y - 10, 250, 60, Color(0, 0, 0, 200))
            
            local multiplier = 1
            local color = ROLES.VAMPIRE.bgcolor
            
            if not ply:GetNWBool("InBloodlust", false) then
                local bloodlustTime = ply:GetNWInt("Bloodlust", 0)
                local delay = GetConVar("ttt2_vamp_bloodtime"):GetInt()
                
                multiplier = bloodlustTime - CurTime()
                multiplier = multiplier / delay
                
                local secondColor = ROLES.INNOCENT.color
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
	
	-- modify roles table of rolesetup addon
	hook.Add("TTTAModifyRolesTable", "ModifyRoleVampToTraitor", function(rolesTable)
		for role in pairs(rolesTable) do
			if role == ROLES.VAMPIRE.index then
				roles[ROLE_INNOCENT] = roles[ROLE_INNOCENT] + roles[ROLES.VAMPIRE.index]
			end
		end
	end)
end
