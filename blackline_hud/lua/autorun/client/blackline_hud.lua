local hideHUDElements = {
	-- if you DarkRP_HUD this to true, ALL of DarkRP's HUD will be disabled. That is the health bar and stuff,
	-- but also the agenda, the voice chat icons, lockdown text, player arrested text and the names above players' heads
	["DarkRP_HUD"] = false,

	-- DarkRP_EntityDisplay is the text that is drawn above a player when you look at them.
	-- This also draws the information on doors and vehicles
	["DarkRP_EntityDisplay"] = true,

	-- DarkRP_ZombieInfo draws information about zombies for admins who use /showzombie.
	["DarkRP_ZombieInfo"] = false,

	-- This is the one you're most likely to replace first
	-- DarkRP_LocalPlayerHUD is the default HUD you see on the bottom left of the screen
	-- It shows your health, job, salary and wallet, but NOT hunger (if you have hungermod enabled)
	["DarkRP_LocalPlayerHUD"] = true,

	-- If you have hungermod enabled, you will see a hunger bar in the DarkRP_LocalPlayerHUD
	-- This does not get disabled with DarkRP_LocalPlayerHUD so you will need to disable DarkRP_Hungermod too
	["DarkRP_Hungermod"] = true,

	-- Drawing the DarkRP agenda
	["DarkRP_Agenda"] = true,

	-- Lockdown info on the HUD
	["DarkRP_LockdownHUD"] = true,

	-- Arrested HUD
	["DarkRP_ArrestedHUD"] = false,

	["CHudHealth"] = true,

	["CHudAmmo"] = true,

	["CHudSecondaryAmmo"] = true,

}

-- this is the code that actually disables the drawing.

hook.Add("HUDShouldDraw", "BlacklineOverrides", function(name)
	if !BlacklineCore.EnableHUD then return end
	if hideHUDElements[name] then return false end
end)

local function canseeplayer( p )
	if !BlacklineCore.canseeplayer then return false end
	return BlacklineCore.canseeplayer( p )
end

local function E_Rect( x, y, w, h, col, mat )
	if !BlacklineCore.drawtrect then return end
	return BlacklineCore.drawtrect( x, y, w, h, col, mat )
end


local grad = Material( "gui/gradient" )
local upgrad = Material( "gui/gradient_up" )
local downgrad = Material( "gui/gradient_down" )

local ammorep = {
	["357"] = "Magnum",
	["smg1"] = "SMG",
	["ar2"] = "Rifle",
	["sniperpenetratedround"] = "Heavy Sniper",
	["xbowbolt"] = "Crossbow",
	["rpg_round"] = "RPG Rockets",
}

local function drawgreyrect( x, y, w, h )

	surface.SetDrawColor( BlacklineCore.Colors[1] )
	surface.DrawRect( x, y, w, h )

	surface.SetDrawColor( BlacklineCore.Colors[3] )
	surface.SetMaterial( downgrad )
	surface.DrawTexturedRect( x, y, w, math.Clamp(h / 3, 10, 50) )
	surface.SetDrawColor( BlacklineCore.Colors[2] )
	surface.DrawTexturedRect( x, y, w, h )

end

surface.CreateFont( "Blackline",
{
	font		= "Roboto-Light",
	size		= 16,
	weight		= 800,
})

surface.CreateFont( "BlacklineL",
{
	font		= "Roboto-Light",
	size		= 17,
	weight		= 800,
})

local myid = Material( "blackline/id.png", "smooth" )
local heart = Material( "blackline/heart.png", "smooth" )
local shield = Material( "blackline/shield.png", "smooth" )
local jobicon = Material( "blackline/briefcase.png", "smooth" )
local cmat = Material( "blackline/cash.png", "smooth" )
local cmat2 = Material( "blackline/cash2.png", "smooth" )
local burger = Material( "blackline/burger.png", "smooth" )

local col1 = Color( 0, 0, 0, 155 )

local function LockDownHUD()
    if GetGlobalBool("DarkRP_LockDown") then
        local cin = (math.sin(CurTime() * 2) + 1) / 2
        local ccol = Color(cin * 255, 0, 255 - (cin * 255), 255)
        drawgreyrect( (ScrW() / 2) - 250, 0, 500, 30 )
		surface.SetDrawColor( BlacklineCore.Colors[1] )
		surface.DrawRect( (ScrW() / 2) - 300, 0, 50, 30 )
		surface.SetDrawColor( ccol )
		surface.SetMaterial( downgrad )
		surface.DrawTexturedRect( (ScrW() / 2) - 300, 0, 50, 30 )
		surface.SetDrawColor( BlacklineCore.Colors[1] )
		surface.DrawRect( (ScrW() / 2) + 250, 0, 50, 30 )
		surface.SetDrawColor( ccol )
		surface.SetMaterial( downgrad )
		surface.DrawTexturedRect( (ScrW() / 2) + 250, 0, 50, 30 )

        draw.DrawNonParsedText(DarkRP.getPhrase("lockdown_started"), "BlacklineL", ScrW() / 2, 5, ccol, TEXT_ALIGN_CENTER)
    end
end

local agendaText
local function DoAgenda()
	local localplayer = LocalPlayer()
    local agenda = localplayer:getAgendaTable()
    if not agenda then return end
    agendaText = agendaText or DarkRP.textWrap((localplayer:getDarkRPVar("agenda") or ""):gsub("//", "\n"):gsub("\\n", "\n"), "Blackline", 350)
	drawgreyrect( 0, 0, 380, 110 )
	drawgreyrect( 0, 0, 380, 25 )
    draw.DrawNonParsedText(agenda.Title, "Blackline", 10, 4, Color(255,255,255), 0)
    draw.DrawNonParsedText(agendaText, "Blackline", 10, 24, Color(205,205,205), 0)
end

hook.Add("DarkRPVarChanged", "agendaHUDBlackline", function(ply, var, _, new)
	if !BlacklineCore.EnableHUD then return end
    if ply ~= LocalPlayer() then return end
    if var == "agenda" and new then
        agendaText = DarkRP.textWrap(new:gsub("//", "\n"):gsub("\\n", "\n"), "Blackline", 350)
    else
        agendaText = nil
    end

end)



local iconcolor = Color(255,255,255, 40)
local dividercolor = Color(255,255,255,5)
local hp = 100
local arm = 0
local function hudPaint()
	if !BlacklineCore.EnableHUD then return end
	local scrw, scrh = ScrW(), ScrH()
	if BlacklineCore.TopOfScreen then scrh = 30 end
	local mycol = team.GetColor( LocalPlayer():Team() )
	local clmp = math.Clamp
	local mycolfixed = Color( clmp(mycol.r * 2, 100, 255), clmp(mycol.g * 2, 100, 255), clmp(mycol.b * 2, 100, 255) )

	local me = LocalPlayer()
	if !me:Alive() then return end
	hp = Lerp( FrameTime()*20, hp, me:Health())
	arm = Lerp( FrameTime()*20, arm, me:Armor())
	local w, h = ScrW(), ScrH()

	drawgreyrect( 0, scrh - 30, scrw, 30 )

	local spacer, newx, newy = 35, 0, 0

	-- its black magic man
	newx, newy = draw.SimpleText( me:getDarkRPVar("rpname") or "unnamed", "Blackline", spacer, scrh - 23, Color(255,255,255, 150), 0 )
	E_Rect( 8, scrh - 23, 20, 20, iconcolor, myid )
	spacer = (spacer + newx) + 36

	surface.SetDrawColor(dividercolor)
	surface.DrawLine( spacer - 30, scrh - 30, spacer - 30, scrh )

	E_Rect( spacer - 24, scrh - 24, 20, 20, iconcolor, heart )
	newx, newy = draw.SimpleText( math.Round(hp).."%", "Blackline", spacer, scrh - 23, Color(255,205,205, 150), 0 )
	E_Rect( (spacer + newx) + 6, scrh - 24, 20, 20, iconcolor, shield )
	spacer = (spacer + newx) + 32

	newx, newy = draw.SimpleText( math.Round(arm).."%", "Blackline", spacer, scrh - 23, Color(205,205,255, 150), 0 )

    local energy = math.ceil(me:getDarkRPVar("Energy") or -1)
    	if energy and energy != -1 then
		E_Rect( (spacer + newx) + 12, scrh - 26, 20, 20, iconcolor, burger )
		spacer = (spacer + newx) + 36
		newx, newy = draw.SimpleText( math.Round(energy).."%", "Blackline", spacer, scrh - 23, Color(255,205,155, 150), 0 )
		surface.SetDrawColor(dividercolor)
		surface.DrawLine( spacer - 30, scrh - 30, spacer - 30, scrh )
    end

	E_Rect( (spacer + newx) + 12, scrh - 26, 20, 20, iconcolor, jobicon )
	spacer = (spacer + newx) + 36

	surface.SetDrawColor(dividercolor)
	surface.DrawLine( spacer - 30, scrh - 30, spacer - 30, scrh )

	local mejob = me:getDarkRPVar("job")
	if !mejob then mejob = "ERROR" end

	newx, newy = draw.SimpleText( mejob, "Blackline", spacer + 2, scrh - 23, mycolfixed, 0 )
	E_Rect( (spacer + newx) + 6, scrh - 24, 20, 20, iconcolor, cmat )
	spacer = (spacer + newx) + 32

	surface.SetDrawColor(dividercolor)
	surface.DrawLine( spacer - 26, scrh - 30, spacer - 26, scrh )

	local dosh = me:getDarkRPVar("money")
	if !dosh then dosh = 0 end

	newx, newy = draw.SimpleText( DarkRP.formatMoney(dosh), "Blackline", spacer, scrh - 23, Color(205,255,205, 100), 0 )
	E_Rect( (spacer + newx) + 10, scrh - 27, 24, 24, iconcolor, cmat2 )
	spacer = (spacer + newx) + 38

	local ndosh = me:getDarkRPVar("salary")
	if !ndosh then ndosh = 0 end

	newx, newy = draw.SimpleText( (DarkRP.formatMoney( (ndosh * 22.5) or 0) ).."/Hour", "Blackline", spacer, scrh - 23, Color(155,255,155, 100), 0 )
	spacer = (spacer + newx) + 38

	surface.SetDrawColor(dividercolor)
	surface.DrawLine( spacer - 30, scrh - 30, spacer - 30, scrh )

	-- turn around and go the other way
	spacer = scrw - 30

	if !me:GetActiveWeapon() or !me:GetActiveWeapon():IsValid() then return end
	local gun = me:GetActiveWeapon()

	local clip1 = gun:Clip1()
	local maxclip1 = gun:GetMaxClip1()
	local ammo = gun:GetPrimaryAmmoType()
	local ammoname = game.GetAmmoName( ammo ) or "NONE"
	local reserve = me:GetAmmoCount(ammo) or "EMPTY"

	if ammorep[string.lower(ammoname)] then ammoname = ammorep[string.lower(ammoname)] end

	if ammoname != "NONE" then
		newx, newy = draw.SimpleText( "Type: "..ammoname, "Blackline", spacer, scrh - 23, Color(255,255,255, 100), 2 )
		spacer = (spacer - newx) - 10
	end

	if clip1 > 0 or reserve > 0 then
		newx, newy = draw.SimpleText( "Ammo: "..clip1.."/ "..reserve, "Blackline", spacer, scrh - 23, Color(255,255,255, 150), 2 )
		spacer = (spacer - newx) - 10
	end

	newx, newy = draw.SimpleText( gun:GetPrintName() or "Unknown", "Blackline", spacer, scrh - 23, Color(255,255,205, 150), 2 )
	spacer = (spacer - newx) - 15

	DoAgenda()
	LockDownHUD()

	local te = LocalPlayer():GetEyeTraceNoCursor().Entity
	if te:IsValid() and te:isKeysOwnable() and te:GetPos():Distance( LocalPlayer():EyePos() ) < 120 then te:drawOwnableInfo() end

end
hook.Add("HUDPaint", "Blackline_HUDPaint", hudPaint)


hook.Add("PostDrawOpaqueRenderables", "Blackline_Doplayernames", function()
	if !LocalPlayer():IsValid() or !LocalPlayer():Alive() or !BlacklineCore.EnableHUD then return end
	for _, ply in pairs (player.GetAll()) do
		if ply:GetPos():Distance(LocalPlayer():GetPos()) > 400 then continue end
		if !canseeplayer( ply ) then continue end
		
		local mycol = team.GetColor( ply:Team() )
		local clmp = math.Clamp
		local cteam = Color( clmp(mycol.r * 2, 100, 255), clmp(mycol.g * 2, 100, 255), clmp(mycol.b * 2, 100, 255) )
		local direction = ply:GetPos() - LocalPlayer():GetPos()
		local x_d = direction.x
		local y_d = direction.y
		local Ang = Angle(0, math.deg(math.atan(y_d/x_d))+90/(x_d/-math.abs(x_d)), 90)
		surface.SetFont( "Blackline")
		local tw1, th1 = surface.GetTextSize( ply:Nick() )
		local tw2, th2 = surface.GetTextSize( ply:getDarkRPVar("job") or "ERROR" )

		cam.Start3D2D(ply:GetPos() + ply:GetUp() * 85, Ang, 0.2)
		drawgreyrect( -(math.max( tw1, tw2 ) / 2) - 10, 0, math.max( tw1, tw2 ) + 20, 40 )
		draw.SimpleTextOutlined( ply:Nick(), "Blackline", 0, 2, Color(205,205,205), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
		draw.SimpleTextOutlined( ply:getDarkRPVar("job") or "ERROR", "Blackline", 0, 18, cteam, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
		if ply:getDarkRPVar("wanted") and ply:getDarkRPVar("wantedReason") then
        		local cin = (math.sin(CurTime() * 8) + 1) / 2
				draw.SimpleTextOutlined( "WANTED: "..tostring(ply:getDarkRPVar("wantedReason")), "Blackline", 0, -18, Color(cin * 255, 0, 255 - (cin * 255), 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, 255))
		end
		cam.End3D2D()
	end
end)
