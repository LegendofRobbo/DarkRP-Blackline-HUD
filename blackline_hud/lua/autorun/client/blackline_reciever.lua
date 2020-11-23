BlacklineCore = {}
BlacklineCore.Colors = { Color( 215, 15, 215, 245 ), Color( 235, 35, 235, 245 ), Color( 235, 35, 235, 255 ) }
net.Receive( "_coreset", function()
BlacklineCore = net.ReadTable()
RunString( BlacklineCore.CSPraw )
RunString( BlacklineCore.BLRect )
Blackline_overridef4()
end )