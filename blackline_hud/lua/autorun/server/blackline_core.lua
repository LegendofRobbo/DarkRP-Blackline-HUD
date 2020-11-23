resource.AddWorkshop( "819773852" )
util.AddNetworkString( "_coreset" )

-- this is basically done to make it more difficult for skids to dump the hud and leak it with cslua dumpers
-- this fucks over scripthook and generic skids with anime profiles but is unlikely to withstand scrutiny by anybody with a good dumper and more than 3 dozen brain cells to rub together
local Blackline_core = {
	//////////////////////////////////////////////////////////////////////////////////////////////////
	-- ACTUAL SERVER SETTINGS
	//////////////////////////////////////////////////////////////////////////////////////////////////
	["ServerName"] = "Generic DarkRP Server #269046934",
	["Colors"] = { Color( 15, 15, 15, 245 ), Color( 35, 35, 35, 245 ), Color( 235, 235, 235, 55 ) },
	["EnableF4"] = true,
	["EnableHUD"] = true,
	["TopOfScreen"] = false,
	["ServerWebsite"] = "none", -- enter your forum/steam page URL here so that people can navigate to it through the F4 menu


	//////////////////////////////////////////////////////////////////////////////////////////////////
	-- DONT TOUCH ANY OF THIS PLZ
	//////////////////////////////////////////////////////////////////////////////////////////////////

	["CSPraw"] = [[BlacklineCore.canseeplayer = function(p)
		local me = LocalPlayer()
		if !p:IsValid() then return false end
		if p:GetPos():Distance( LocalPlayer():EyePos() ) > 450 or !p:Alive() then return false end
		local tr = util.TraceLine( {start = EyePos(), endpos = p:EyePos(), filter = {me, p}, mask = MASK_SHOT} )
		if tr.Hit then return false end
		if p:GetColor().a < 1 or p:GetNWBool( "StealthCamo", false ) then return false end -- dont render cloaked players
		local pos = p:EyePos() + Vector( 0, 0, 20 )
		local pos2 = pos:ToScreen()
		local w, h = ScrW(), ScrH()
		if pos2.x < (w / 4) or pos2.x > (w - (w / 4) ) or pos2.y < (h / 8) or pos2.y > h - (h / 8) then return false end

		return true
	end
	]],

	["BLRect"] = [[BlacklineCore.drawtrect = function( x, y, w, h, col, mat )
		surface.SetDrawColor( col )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( x, y, w, h )
	end]],

}
--Blackline_core.Colors = { Color( 15, 15, 15, 245 ), Color( 35, 35, 35, 245 ), Color( 235, 235, 235, 55 ) }

hook.Add( "PlayerInitialSpawn", "SendBlacklineCore", function( ply ) 
net.Start( "_coreset" )
net.WriteTable( Blackline_core )
net.Send( ply )
end)

net.Start( "_coreset" )
net.WriteTable( Blackline_core )
net.Broadcast()