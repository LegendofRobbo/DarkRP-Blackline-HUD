

local grad = Material( "gui/gradient" )
local upgrad = Material( "gui/gradient_up" )
local downgrad = Material( "gui/gradient_down" )

surface.CreateFont( "BlacklineF4Small",
{
	font		= "Roboto",
	size		= 12,
	weight		= 400
})

surface.CreateFont( "BlacklineF4Old",
{
	font		= "Roboto",
	size		= 16,
	weight		= 800
})

surface.CreateFont( "BlacklineF4Large",
{
	font		= "Roboto",
	size		= 26,
	weight		= 800
})

local function drawgreyrect( x, y, w, h )

	surface.SetDrawColor( BlacklineCore.Colors[1] )
	surface.DrawRect( x, y, w, h )

	surface.SetDrawColor( BlacklineCore.Colors[3] )
	surface.SetMaterial( downgrad )
	surface.DrawTexturedRect( x, y, w, math.Clamp(h / 3, 10, 50) )
	surface.SetDrawColor( BlacklineCore.Colors[2] )
	surface.DrawTexturedRect( x, y, w, h )

end

local function E_Rect( x, y, w, h, col, mat )
	if !BlacklineCore.drawtrect then return end
	return BlacklineCore.drawtrect( x, y, w, h, col, mat )
end

local overrides = {

    ["weapon_crowbar"] = {
        Damage = 25,
        NumShots = 1,
        ClipSize = 1,
        Delay = 0.404
    },

    ["weapon_stunstick"] = {
        Damage = 40,
        NumShots = 1,
        ClipSize = 1,
        Delay = 0.81
    },

    ["weapon_pistol"] = {
        Damage = 12,
        NumShots = 1,
        ClipSize = 18,
        Ammo = "pistol",
        Delay = 0.12,
    },

    ["weapon_357"] = {
        Damage = 75,
        NumShots = 1,
        ClipSize = 6,
        Ammo = "357",
        Delay = 0.75,
    },

    ["weapon_smg1"] = {
        Damage = 12,
        NumShots = 1,
        ClipSize = 45,
        Ammo = "SMG1",
        Delay = 0.075,
    },

    ["weapon_shotgun"] = {
        Damage = 4,
        NumShots = 7,
        ClipSize = 6,
        Ammo = "buckshot",
        Delay = 0.9,
    },

    ["weapon_ar2"] = {
        Damage = 11,
        NumShots = 1,
        ClipSize = 30,
        Delay = 0.105,
    },

    ["weapon_crossbow"] = {
        Damage = 100,
        NumShots = 1,
        ClipSize = 1,
        Delay = 1.95,
    },

    ["weapon_rpg"] = {
        Damage = 150,
        NumShots = 1,
        ClipSize = 1,
        Delay = 2.2,
    },

    ["weapon_frag"] = {
        Damage = 150,
        NumShots = 1,
        ClipSize = 1,
        Delay = 1.95,
    },

    ["fas2_rem870"] = {
        Delay = .86,
    },

    ["fas2_ks23"] = {
        Delay = 1.11,
    },

    ["fas2_m67"] = {
        Damage = 160,
        Delay = 1.75,
    },

}

local ammostrings = {
    pistol = "Pistol",
    smg1 = "SMG",
    ar2 = "Assault Rifle",
    ["357"] = "Magnum",
    buckshot = "Shotgun",
    rpg_round = "Rockets",
    sniperpenetratedround = "Sniper",
}

local function GrabGunStats( wep )
	local gun = weapons.Get( wep )
	local ret = {}
	if !gun then return end
	local m9gay = false
	local fas = false
	local cw2 = false
	if gun.Base == "bobs_gun_base" or gun.Base == "bobs_shotty_base" or gun.Base == "bobs_scoped_base" then m9gay = true end
	if gun.Base == "fas2_base" or gun.Base == "fas2_base_shotgun" then fas = true end
	if gun.Base == "cw_base" then cw2 = true end

	//////////////////////////////// hl2 guns ////////////////////////////////

	if !gun.Primary then gun.Primary = {} end
	if overrides[wep] then
		local tab = overrides[wep]
		for k, v in pairs(tab) do
    		gun.Primary[k] = v
		end
	end

	//////////////////////////////// weapon stat workarounds ////////////////////////////////

	local delay = 0
	if gun.Primary.Delay then
    	delay = gun.Primary.Delay
	elseif m9gay then
    	delay = 60 / gun.Primary.RPM
	elseif fas or cw2 then
    	delay = gun.FireDelay
	end

	local gdmg = 0
	if gun.Primary.Damage then
    	gdmg = gun.Primary.Damage
	elseif fas or cw2 then
    	gdmg = gun.Damage
	end

	local gnumshots = 1
	if gun.Primary.NumShots then
    	gnumshots = gun.Primary.NumShots
	elseif fas or cw2 then
    	gnumshots = gun.Shots or 1
	end

	local gcone = 0
	if m9gay then
    	gcone = gun.Primary.Spread
	elseif fas then
    	gcone = gun.HipCone or 0
	elseif cw2 then
    	gcone = gun.HipSpread or 0
	elseif gun.Primary.Cone then
    	gcone = gun.Primary.Cone
	end

	ret.Damage = (gdmg * gnumshots)
	ret.Rate = delay
	ret.Mag = gun.Primary.ClipSize or 0
	ret.Ammo = gun.Primary.Ammo or "Unknown"
	if ammostrings[string.lower(ret.Ammo)] then ret.Ammo = ammostrings[string.lower(ret.Ammo)] end
	ret.Accuracy = math.Clamp((1 - (gcone * 20)) * 100, 0, 100)

	return ret

end



local jobicon = Material( "blackline/briefcase.png", "smooth" )
local dollarydoos = Material( "blackline/cash.png", "smooth" )
local globe = Material( "blackline/world.png", "smooth" )

local function GenerateEList( eparent, elist, etype )

for k, cat in pairs( elist ) do

	if !cat.canSee or #cat.members < 1 then continue end

	local newcat = vgui.Create( "DPanel", eparent )
	newcat:Dock( TOP ) -- Set the position of the panel
	newcat:SetSize( eparent:GetWide(), 30 ) -- Set the size of the panel
	newcat.Paint = function( self, w, h )
		local cfix = Color( math.Clamp(cat.color.r * 2, 100, 255), math.Clamp(cat.color.g * 2, 100, 255), math.Clamp(cat.color.b * 2, 100, 255) )
		drawgreyrect( 0, 0, w, h )
		draw.SimpleText( cat.name, "BlacklineF4Old", 30, h / 2, Color(255,255,255), 0, 1 )
		E_Rect( 5, 5, 18, 18, cfix, dollarydoos )
	end


	for k, ship in pairs( cat.members ) do
		if ship.allowed and shipallowed != {} and !table.HasValue( ship.allowed, LocalPlayer():Team() ) then continue end
		local bgp = vgui.Create( "DPanel", eparent )
		bgp:SetSize( eparent:GetWide(), 100 )
		bgp:DockMargin( 0, 2, 0 ,0 )
		bgp:Dock( TOP )
		local gtab = GrabGunStats( ship.entity )
		if gtab then
			bgp.gtab = gtab
		end

		bgp.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( Color( 50, 50, 50, 50 ) )
		surface.DrawRect( 0, 0, 100, h )

		local off1, _ = draw.SimpleText( ship.name, "BlacklineF4Old", 110, 5, Color( 200, 200, 200), 0 )
		local off2, _
		if etype == 1 then off2, _ = draw.SimpleText( "(x"..ship.amount..")", "BlacklineF4Old", 115 + off1, 5, Color( 140, 140, 140 ), 0 ) else off2 = 0 end
		local off3, _ = draw.SimpleText( "Cost: $"..ship.price, "BlacklineF4Old", 125 + off1 + off2, 5, Color( 200, 250, 200 ), 0 )
		if etype == 1 then local off4, _ = draw.SimpleText( "($"..ship.price / ship.amount.." per unit)", "BlacklineF4Old", 130 + off1 + off2 + off3, 5, Color( 100, 200, 100 ), 0 ) end

		if self.gtab then
			draw.SimpleText( "Damage: "..self.gtab.Damage, "BlacklineF4Small", 110, 25, Color( 200, 200, 200, 100 ), 0 )
			draw.SimpleText( "DPS: "..math.ceil(1 / self.gtab.Rate * self.gtab.Damage), "BlacklineF4Small", 110, 40, Color( 200, 200, 200, 100 ), 0 )
			draw.SimpleText( "Accuracy: "..self.gtab.Accuracy, "BlacklineF4Small", 110, 55, Color( 200, 200, 200, 100 ), 0 )
			draw.SimpleText( "Mag Size: "..self.gtab.Mag, "BlacklineF4Small", 110, 70, Color( 200, 200, 150, 100 ), 0 )
			draw.SimpleText( "Ammo: "..self.gtab.Ammo, "BlacklineF4Small", 110, 85, Color( 200, 200, 150, 100 ), 0 )
		end

		end

		local icon = vgui.Create( "DModelPanel", bgp )
		icon:SetSize( 100, 100 )
		icon:SetModel( ship.model )
		icon:Dock( LEFT )
		local mn, mx = icon.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
		size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
		size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

		icon:SetFOV( 55 )
		icon.Distance = 1.5
--		icon:SetCamPos( Vector( size, size, size / 2 ) )
		icon.OriginPos = (mn - mx) * 0.5
		if icon.Entity:GetPos():Distance( (mn - mx) * 0.5 ) > 8 then icon.OriginPos = icon.Entity:GetPos() end
		icon:SetCamPos( Vector( 0, 0, 0 ) )
		icon:SetLookAt( icon.OriginPos )


		function icon:LayoutEntity( ent )
--			ent:SetAngles( Angle( 0, RealTime() * 40 % 360, 0 ) )
			icon:SetCamPos( self.OriginPos + Vector( math.sin(RealTime()) * (size * icon.Distance), math.cos(RealTime()) * (size * icon.Distance), (size * 0.75) * icon.Distance ) )
		end

		local icopref = vgui.Create( "DButton", bgp )
		icopref:SetText( "" )
		icopref:SetPos( 80, 85 )
		icopref:SetSize( 20, 15 )
		icopref.DoClick = function()
			icon.Distance = math.Clamp(icon.Distance - 0.2, 0.3, 3 )
		end
		icopref.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 50, 50, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.SimpleText( ">", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
		end

		local icopref2 = vgui.Create( "DButton", bgp )
		icopref2:SetText( "" )
		icopref2:SetPos( 60, 85 )
		icopref2:SetSize( 20, 15 )
		icopref2.DoClick = function()
			icon.Distance = math.Clamp(icon.Distance + 0.2, 0.3, 3 )
		end
		icopref2.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 50, 50, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.SimpleText( "<", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
		end

		local selectjob = vgui.Create( "DButton", bgp )
		selectjob:SetText( "" )
		selectjob:SetSize( 120, 100 )
		selectjob:DockMargin( 0, 0, 5 ,0 )
		selectjob:Dock( RIGHT )
		-- yeah i know, this is pretty disgusting
		if etype == 0 then
			selectjob.DoClick = function()
				RunConsoleCommand( "DarkRP", "buyvehicle", ship.name )
			end
		elseif etype == 1 then
			selectjob.DoClick = function()
				RunConsoleCommand( "DarkRP", "buyshipment", ship.name )
			end
		elseif etype == 2 then
			selectjob.DoClick = function()
				RunConsoleCommand( "DarkRP", "buyammo", ship.id )
			end
		elseif etype == 3 then
			selectjob.DoClick = function()
				RunConsoleCommand( "DarkRP", "buy", ship.name )
			end
		else
			selectjob.DoClick = function()
				RunConsoleCommand( "DarkRP", ship.cmd )
			end
		end

		selectjob.Paint = function( self, w, h )
		drawgreyrect( 0, 0, w, h )
		surface.SetMaterial( downgrad )
		surface.SetDrawColor( BlacklineCore.Colors[2] )
		surface.DrawTexturedRect( 0, 0, 5, h )
		surface.DrawTexturedRect( w - 5, 0, 5, h )
			if LocalPlayer():getDarkRPVar("money") >= ship.price then
				draw.SimpleText( "Buy", "BlacklineF4Old", w / 2, h / 2, Color(255,255,255), 1, 1 )
			else
				draw.SimpleText( "Cannot Afford", "BlacklineF4Old", w / 2, h / 2, Color(255,255,255), 1, 1 )
			end
		end


	end


end

end


-- why the fuck does darkrp have a seperate buy system for food?
local function GenerateFoodList( eparent )
	if !FoodItems then return end

	local newcat = vgui.Create( "DPanel", eparent )
	newcat:Dock( TOP ) -- Set the position of the panel
	newcat:SetSize( eparent:GetWide(), 30 ) -- Set the size of the panel
	newcat.Paint = function( self, w, h )
		local cfix = Color( 255, 150, 0 )
		drawgreyrect( 0, 0, w, h )
		draw.SimpleText( "Food", "BlacklineF4Old", 30, h / 2, Color(255,255,255), 0, 1 )
		E_Rect( 5, 5, 18, 18, cfix, dollarydoos )
	end

	for k, ship in pairs( FoodItems ) do
		local bgp = vgui.Create( "DPanel", eparent )
		bgp:SetSize( eparent:GetWide(), 100 )
		bgp:DockMargin( 0, 2, 0 ,0 )
		bgp:Dock( TOP )

		bgp.Paint = function( self, w, h )
			surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( Color( 50, 50, 50, 50 ) )
			surface.DrawRect( 0, 0, 100, h )

			local off1, _ = draw.SimpleText( ship.name, "BlacklineF4Old", 110, 5, Color( 200, 200, 200), 0 )
			local off2, _ = 0, 0
			local off3, _ = draw.SimpleText( "Cost: $"..ship.price, "BlacklineF4Old", 125 + off1 + off2, 5, Color( 200, 250, 200 ), 0 )
			draw.SimpleText( "Hunger restored: "..ship.energy.."%", "BlacklineF4Old", 110, 22, Color( 200, 250, 200 ), 0 )
		end

		local icon = vgui.Create( "DModelPanel", bgp )
		icon:SetSize( 100, 100 )
		icon:SetModel( ship.model )
		icon:Dock( LEFT )
		local mn, mx = icon.Entity:GetRenderBounds()
		local size = 0
		size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
		size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
		size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

		icon:SetFOV( 55 )
		icon.Distance = 1.5
		icon.OriginPos = (mn - mx) * 0.5
		if icon.Entity:GetPos():Distance( (mn - mx) * 0.5 ) > 8 then icon.OriginPos = icon.Entity:GetPos() end
		icon:SetCamPos( Vector( 0, 0, 0 ) )
		icon:SetLookAt( icon.OriginPos )


		function icon:LayoutEntity( ent )
			icon:SetCamPos( self.OriginPos + Vector( math.sin(RealTime()) * (size * icon.Distance), math.cos(RealTime()) * (size * icon.Distance), (size * 0.75) * icon.Distance ) )
		end

		local icopref = vgui.Create( "DButton", bgp )
		icopref:SetText( "" )
		icopref:SetPos( 80, 85 )
		icopref:SetSize( 20, 15 )
		icopref.DoClick = function()
			icon.Distance = math.Clamp(icon.Distance - 0.2, 0.3, 3 )
		end
		icopref.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 50, 50, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.SimpleText( ">", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
		end

		local icopref2 = vgui.Create( "DButton", bgp )
		icopref2:SetText( "" )
		icopref2:SetPos( 60, 85 )
		icopref2:SetSize( 20, 15 )
		icopref2.DoClick = function()
			icon.Distance = math.Clamp(icon.Distance + 0.2, 0.3, 3 )
		end
		icopref2.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 50, 50, 50 ) )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.SimpleText( "<", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
		end

		local selectjob = vgui.Create( "DButton", bgp )
		selectjob:SetText( "" )
		selectjob:SetSize( 120, 100 )
		selectjob:DockMargin( 0, 0, 5 ,0 )
		selectjob:Dock( RIGHT )
		-- yeah i know, this is pretty disgusting
		selectjob.DoClick = function()
			RunConsoleCommand( "DarkRP", "buyfood", ship.name )
		end

		selectjob.Paint = function( self, w, h )
		drawgreyrect( 0, 0, w, h )
		surface.SetMaterial( downgrad )
		surface.SetDrawColor( BlacklineCore.Colors[2] )
		surface.DrawTexturedRect( 0, 0, 5, h )
		surface.DrawTexturedRect( w - 5, 0, 5, h )
			if LocalPlayer():getDarkRPVar("money") >= ship.price then
				draw.SimpleText( "Buy", "BlacklineF4Old", w / 2, h / 2, Color(255,255,255), 1, 1 )
			else
				draw.SimpleText( "Cannot Afford", "BlacklineF4Old", w / 2, h / 2, Color(255,255,255), 1, 1 )
			end
		end


	end

end






local function CreateF4Menu()
local sw, sh = ScrW(), ScrH()
if f4Frame and f4Frame:IsVisible() then return false end
f4Frame = vgui.Create( "DFrame" )
f4Frame:SetTitle( "" )
f4Frame:SetSize( 900, 750 )
f4Frame:Center()
f4Frame:SetDraggable( false )
f4Frame:ShowCloseButton( false )
f4Frame:SetSizable( false )

f4Frame.Paint = function( self, w, h )
	drawgreyrect( 0, 0, w, h )
	drawgreyrect( 0, 0, w, 50 )
	draw.SimpleText( BlacklineCore.ServerName or "Im a huge fucking faggot that uses leaks", "BlacklineF4Large", 10, 25, Color(255,255,255, 50), 0, 1 )
	draw.SimpleText( "Blackline VGUI Skin - Created by LegendofRobbo", "BlacklineF4Small", f4Frame:GetWide() - 10, 40, Color(255,255,255, 5), 2, 1 )
end

local xit = vgui.Create( "DButton", f4Frame )
xit:SetText( "" )
xit:SetPos( f4Frame:GetWide() - 25, 5 )
xit:SetSize( 20, 15 )
xit.DoClick = function()
	gui.EnableScreenClicker( false )
	f4Frame:Remove()
end
xit.Paint = function( self, w, h )
surface.SetDrawColor( Color( 50, 50, 50 ) )
surface.DrawOutlinedRect( 0, 0, w, h )
draw.SimpleText( "X", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
end

local sheet = vgui.Create( "DPropertySheet", f4Frame )
sheet:SetSize( f4Frame:GetWide(), f4Frame:GetTall() - 60 )
sheet:SetPos( 0, 50 )
sheet.Paint = function( self, w, h )
--	drawgreyrect( 0, 0, w, h )

	for k, v in pairs(sheet.Items) do
		if (!v.Tab) then continue end
		v.Tab.Paint = function(self,w,h)
			drawgreyrect( 0, 0, w - 5, h )
			surface.SetDrawColor(Color(255,255,255, 10))
			surface.DrawLine( 1, 0, 1, h )
		end
		if BlacklineCore.ServerWebsite and BlacklineCore.ServerWebsite != "none" and v.Tab:GetText() == "Server Website" then
			v.Tab.DoClick = function( self ) gui.OpenURL( BlacklineCore.ServerWebsite ) end
		end
	end
end

-- jobs panel
local pjobs = vgui.Create( "DScrollPanel", sheet )
pjobs:Dock( FILL )
sheet:AddSheet( "Choose a Job", pjobs )

-- shipments panel
local pshipments = vgui.Create( "DScrollPanel", sheet )
pshipments:Dock( FILL )
sheet:AddSheet( "Buy a Shipment", pshipments )

-- items panel
local pitems = vgui.Create( "DScrollPanel", sheet )
pitems:Dock( FILL )
sheet:AddSheet( "Buy an Item", pitems )

if BlacklineCore.ServerWebsite and BlacklineCore.ServerWebsite != "none" then
	local pactions = vgui.Create( "DScrollPanel", sheet )
	pactions:Dock( FILL )
	sheet:AddSheet( "Server Website", pactions )
end

local mastertable = DarkRP.getCategories()
-- populate jobs tab

for k, cat in pairs( mastertable.jobs ) do

	if !cat.canSee or #cat.members < 1 then continue end
	local newcat = vgui.Create( "DPanel", pjobs )
	newcat:Dock( TOP )
	newcat:SetSize( pjobs:GetWide(), 30 )
	newcat.Paint = function( self, w, h )
		local cfix = Color( math.Clamp(cat.color.r * 2, 100, 255), math.Clamp(cat.color.g * 2, 100, 255), math.Clamp(cat.color.b * 2, 100, 255) )
		drawgreyrect( 0, 0, w, h )
		draw.SimpleText( cat.name, "BlacklineF4Old", 30, h / 2, Color(255,255,255), 0, 1 )
		E_Rect( 5, 5, 18, 18, cfix, jobicon )
	end


	for k, job in pairs( cat.members ) do
		local bgp = vgui.Create( "DPanel", pjobs )
		bgp:SetSize( pjobs:GetWide(), 80 )
		bgp:DockMargin( 0, 2, 0 ,0 )
		bgp:Dock( TOP )
		bgp.Paint = function( self, w, h )
		local cfix = Color( math.Clamp(job.color.r * 2, 100, 255), math.Clamp(job.color.g * 2, 100, 255), math.Clamp(job.color.b * 2, 100, 255) )
		surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( Color( 50, 50, 50, 50 ) )
		surface.DrawRect( 0, 0, 80, h )
		draw.SimpleText( job.name, "BlacklineF4Old", 105, 5, cfix, 0 )
		draw.DrawText( job.description, "BlacklineF4Small", 105, 20, Color( 150, 150, 150 ), 0 )
		draw.SimpleText( "Salary: $"..(job.salary * 22.5).."/Hr", "BlacklineF4Small", 770, 5, Color(205, 255, 205, 50), 2 )
		local fags = #team.GetPlayers( job.team )
		local jmax = job.max
		if jmax == 0 then jmax = "Unlimited" end
		draw.SimpleText( "Slots: "..fags.."/"..jmax, "BlacklineF4Small", 770, 20, Color(255, 255, 255, 50), 2 )
		end

		local icon = vgui.Create( "DModelPanel", bgp )
		icon:SetSize( 80, 80 )
		if isstring(job.model) then icon:SetModel( job.model ) else 
			local mdl = DarkRP.getPreferredJobModel(job.team)
			if !mdl or mdl == nil then mdl = job.model[1] end
			icon:SetModel( mdl ) 
		end
		icon:SetCamPos( Vector( 20, 0, 65 ) )
		icon:SetLookAt( Vector( 0, 0, 60 ) )
		icon.LayoutEntity = function( ent ) return end

		if istable(job.model) and #job.model > 1 then
			local icopref = vgui.Create( "DButton", bgp )
			icopref:SetText( "" )
			icopref:SetPos( 60, 65 )
			icopref:SetSize( 20, 15 )
			icopref.DoClick = function()
				local n = table.KeyFromValue( job.model, DarkRP.getPreferredJobModel(job.team) ) or 1
				n = n + 1
				if n >= #job.model then n = 1 end
				DarkRP.setPreferredJobModel( job.team, job.model[n] )
				icon:SetModel( job.model[n] )
			end
			icopref.Paint = function( self, w, h )
			surface.SetDrawColor( Color( 50, 50, 50 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			draw.SimpleText( ">", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
			end

			local icopref2 = vgui.Create( "DButton", bgp )
			icopref2:SetText( "" )
			icopref2:SetPos( 40, 65 )
			icopref2:SetSize( 20, 15 )
			icopref2.DoClick = function()
				local n = table.KeyFromValue( job.model, DarkRP.getPreferredJobModel(job.team) ) or 1
				n = n - 1
				if n <= 0 then n = #job.model end
				DarkRP.setPreferredJobModel( job.team, job.model[n] )
				icon:SetModel( job.model[n] )
			end
			icopref2.Paint = function( self, w, h )
			surface.SetDrawColor( Color( 50, 50, 50 ) )
			surface.DrawOutlinedRect( 0, 0, w, h )
			draw.SimpleText( "<", "BlacklineF4Old", w / 2, 6, Color(255,255,255), 1, 1 )
			end

		end



		local selectjob = vgui.Create( "DButton", bgp )
		selectjob:SetText( "" )
		selectjob:SetSize( 100, 80 )
		selectjob:DockMargin( 0, 0, 5 ,0 )
		selectjob:Dock( RIGHT )
		selectjob.DoClick = function()
			if job.vote then RunConsoleCommand( "darkrp", "vote"..job.command ) else RunConsoleCommand( "darkrp", job.command ) end
		end
		selectjob.Paint = function( self, w, h )
		drawgreyrect( 0, 0, w, h )
		surface.SetMaterial( downgrad )
		surface.SetDrawColor( BlacklineCore.Colors[2] )
		surface.DrawTexturedRect( 0, 0, 5, h )
		surface.DrawTexturedRect( w - 5, 0, 5, h )
		local jtx = "Become Job"
		local jtxc = Color(255,255,255)
		if job.vote then jtx = "Vote For Job" end
		if job.customCheck and !job.customCheck(LocalPlayer()) then jtx = "Unavailable" jtxc = Color(255,155,155, 50) end
		if job.max >= 1 and #team.GetPlayers( job.team ) == job.max then jtx = "Job is full!" jtxc = Color(255,155,155, 50) end
		draw.SimpleText( jtx, "BlacklineF4Old", w / 2, h / 2, jtxc, 1, 1 )
		end


	end


end

-- populate shipments

GenerateEList( pshipments, mastertable.shipments, 1 )
GenerateEList( pitems, mastertable.entities, 69 )
GenerateEList( pitems, mastertable.vehicles, 0 )
GenerateEList( pitems, mastertable.weapons, 3 )
GenerateEList( pitems, mastertable.ammo, 2 )
GenerateFoodList( pitems )


end


function Blackline_overridef4()
if !BlacklineCore.EnableF4 then return end
function DarkRP.openF4Menu()
	gui.EnableScreenClicker( true )
	CreateF4Menu()
end

function DarkRP.closeF4Menu()
	if f4Frame and f4Frame:IsVisible() then f4Frame:SetVisible( false ) gui.EnableScreenClicker( false ) end
end

function DarkRP.toggleF4Menu()
    if not IsValid(f4Frame) or not f4Frame:IsVisible() then
        DarkRP.openF4Menu()
    else
        DarkRP.closeF4Menu()
    end
end

function DarkRP.getF4MenuPanel()
    return f4Frame
end

GAMEMODE.ShowSpare2 = DarkRP.toggleF4Menu

end
--hook.Add( "PostGamemodeLoaded", "override_gayrp_menu", function() timer.Simple( 2, function() overridef4() end) end, 1 )
hook.Add( "OnReloaded", "override_gayrp_menu", function() timer.Simple( 2, function() Blackline_overridef4() end) end, -1 )