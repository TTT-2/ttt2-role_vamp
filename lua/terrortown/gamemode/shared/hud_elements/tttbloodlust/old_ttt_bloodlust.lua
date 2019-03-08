local base = "old_ttt_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then -- CLIENT
	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		hudelements.RegisterChildRelation(self.id, "old_ttt_info", false)
	end

	function HUDELEMENT:Initialize()
		local width, height = self.maxwidth, 45
		local parent = self:GetParent()
		local parentEl = hudelements.GetStored(parent)
		local x, y = 15, ScrH() - height - self.maxheight - self.margin

		if parentEl then
			x = parentEl.pos.x
			y = parentEl.pos.y - self.margin - height - 30
		end

		self:SetBasePos(x, y)
		self:SetSize(width, height)

		BaseClass.Initialize(self)
	end

	function HUDELEMENT:DrawComponent(name, col, val, multiplier)
		multiplier = multiplier or 1

		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local width, height = size.w, size.h

		draw.RoundedBox(8, x, y, width, height, self.bg_colors.background_main)

		local bar_width = width - self.dmargin
		local bar_height = height - self.dmargin

		local tx = x + self.margin
		local ty = y + self.margin

		self:PaintBar(tx, ty, bar_width, bar_height, col, multiplier)
		self:ShadowedText(val, "HealthAmmo", tx + bar_width * 0.5, ty + bar_height * 0.5, COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.SimpleText(name, "TabLarge", x + self.margin * 2, y, COLOR_WHITE, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	local edit_colors = {
		border = COLOR_WHITE,
		background = Color(0, 0, 10, 200),
		fill = Color(100, 100, 100, 255)
	}

	function HUDELEMENT:Draw()
		local ply = LocalPlayer()

		if not IsValid(ply) then return end

		local multiplier

		local color = VAMPIRE.dkcolor
		if not color then return end

		if IsValid(ply) and ply:IsActive() and ply:Alive() and ply:GetSubRole() == ROLE_VAMPIRE then
			if not ply:GetNWBool("InBloodlust", false) then
				local bloodlustTime = ply:GetNWInt("Bloodlust", 0)
				local delay = GetGlobalInt("ttt2_vamp_bloodtime")

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
			self:DrawComponent("Bloodlust", edit_colors, "Bloodlust!")
		elseif multiplier then
			local col_tbl = {
				border = COLOR_WHITE,
				background = self.bg_colors.background_main,
				fill = color
			}

			self:DrawComponent("Bloodlust", col_tbl, ply:GetNWBool("InBloodlust", false) and "Bloodlust!", multiplier)
		end
	end
end
