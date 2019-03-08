local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	local iconSize_default = 64
	local pad_default = 14
	local w_default, h_default = 365, 32

	local w, h = w_default, h_default
	local min_w, min_h = 225, 32
	local pad = pad_default -- padding
	local iconSize = iconSize_default

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		huds.GetStored("pure_skin"):ForceElement(self.id)
	end

	function HUDELEMENT:Initialize()
		w, h = w_default, h_default
		pad = pad_default
		self.scale = 1.0

		self:RecalculateBasePos()

		self:SetMinSize(min_w, min_h)
		self:SetSize(w, h)

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:RecalculateBasePos()
	    self:SetBasePos(10 * self.scale, ScrH() - h - 146 * self.scale - pad - 10 * self.scale)
	end

	function HUDELEMENT:PerformLayout()
		local size = self:GetSize()

		iconSize = iconSize_default * self.scale
		pad = pad_default * self.scale

		w, h = size.w, size.h
	end

	function HUDELEMENT:DrawComponent(multiplier, col, text)
		multiplier = multiplier or 1

		local pos = self:GetPos()
		local x, y = pos.x, pos.y

		self:DrawBg(x, y, w, h, self.basecolor)

		-- draw bar
		self:DrawBar(x + pad, y + pad, w - pad * 2, h - pad * 2, col, multiplier, scale, text)

		self:DrawLines(x, y, w, h, self.basecolor.a)

		--local nSize = iconSize - 8

		--util.DrawFilteredTexturedRect(x, y + 2 - (nSize - h), nSize, nSize, self.icon)
	end

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local duration = GetGlobalInt("ttt2_vamp_bloodtime")
		local multiplier

		local color = VAMPIRE.dkcolor
		if not color then return end

		if IsValid(ply) and ply:IsActive() and ply:Alive() and ply:GetSubRole() == ROLE_VAMPIRE then
			if not ply:GetNWBool("InBloodlust", false) then
				local bloodlustTime = ply:GetNWInt("Bloodlust", 0)
				local delay = cv:GetInt()

				multiplier = bloodlustTime - CurTime()
				multiplier = multiplier / delay

				local secondColor = VAMPIRE.bgcolor
				local r = color.r - (color.r - secondColor.r) * multiplier
				local g = color.g - (color.g - secondColor.g) * multiplier
				local b = color.b - (color.b - secondColor.b) * multiplier

				color = Color(r, g, b, 255)
			end
		end

		if HUDEditor.IsEditing then
			self:DrawComponent(1, color)
		elseif multiplier then
			self:DrawComponent(multiplier, color, ply:GetNWBool("InBloodlust", false) and "Bloodlust!")
		end
	end
end
