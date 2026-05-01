
-- Neon Front Y offset.
local neonFYoff = 1.3;
-- Neon Back Y offset.
local neonBYoff = -1.3;
-- Neon Middle Y offset.
local neonMYoff = 0.0;
-- Neon Height offset.
local neonHeight = 0.0;
-- Neon Front & Back range.
local neonFBrange = 2.7;
-- Neon Front & Back intensity.
local neonIntensity = 85;
-- Neon Middle range.
local neonMRange = 2.5;

-- Données néon de tous les joueurs
local AllPlayersNeon = {}
local Webui_RGB = nil
local VisibleDistanceColor = 70

local Colors_rgb = {
    ["white"] = {r = 255, g = 255, b = 255},
    ["blue"] = {r = 0, g = 0, b = 255},
    ["electric_blue"] = {r = 0, g = 255, b = 255},
    ["mint_green"] = {r = 50, g = 255, b = 155},
    ["lime_green"] = {r = 0, g = 255, b = 0},
    ["yellow"] = {r = 255, g = 255, b = 0},
    ["gold"] = {r = 255, g = 215, b = 0},
    ["orange"] = {r = 255, g = 165, b = 0},
    ["red"] = {r = 255, g = 0, b = 0},
    ["pink"] = {r = 255, g = 20, b = 147},
    ["purple"] = {r = 128, g = 0, b = 128}
}

local function SetColorToNeon(color)
    
    if Colors_rgb[color] ~= nil then 
        
        local r = Colors_rgb[color].r
        local g = Colors_rgb[color].g
        local b = Colors_rgb[color].b

        Events.CallRemote("Send_NeonColor_sv", {r, g, b})
    end
end

Events.Subscribe("ChangeColorNeon_cl", function(r, g, b)
	Events.CallRemote("Send_NeonColor_sv", {r, g, b})
end, true)

Events.Subscribe("Updates_PlayerDataNeons_cl", function(data)

   for i = 1, #data do
        AllPlayersNeon[i] = {
            vid = data[i].vid,
            r = data[i].r,
            g = data[i].g,
            b = data[i].b,
            enabled = data[i].enabled
        }
   end
   
end, true)

local function Customs_Neon(netcar, ped, r, g, b)
    if(Game.IsCharInAnyCar(ped) and not Game.IsCharInAnyBoat(ped) and not Game.IsCharInAnyHeli(ped)) then 
        local targetCar = Game.GetCarCharIsUsing(ped)
        local driver = Game.GetDriverOfCar(targetCar)
        local vehicle_Byid = Game.GetVehicleFromNetworkId(netcar)
        local neonToggle = false

        if driver == ped then 
            if (Game.IsVehDriveable(targetCar) and not Game.IsBigVehicle(targetCar)) then 
                if vehicle_Byid > 0 then 
                    if targetCar == vehicle_Byid then 
                        neonToggle = true
                    else
                        neonToggle = false
                    end
                else
                    neonToggle = true
                end
            else
                neonToggle = false
            end
        else
            neonToggle = false
        end

        if neonToggle then 
            local v_attach_h = Game.GetCarHeading(targetCar);
            local v_attach_x, v_attach_y, v_attach_z = Game.GetCarCoordinates(targetCar);

            local v_moff_x, v_moff_y, v_moff_z = Game.GetOffsetFromCarInWorldCoords(targetCar, -20.0, neonMYoff, neonHeight);

            local mdist = Game.GetDistanceBetweenCoords2d(v_attach_x + -20.0, v_attach_y + neonMYoff, v_attach_x, v_attach_y);
            local mx = Game.Cos(v_attach_h) * mdist + v_moff_x;
            local my = Game.Sin(v_attach_h) * mdist + v_moff_y;

            Game.DrawLightWithRange(mx, my, v_attach_z + neonHeight, r, g, b, neonMRange, neonIntensity);

            if (not Game.IsCharOnAnyBike(ped)) then 

                local v_foff_x, v_foff_y, v_foff_z = Game.GetOffsetFromCarInWorldCoords(targetCar, -20.0, neonFYoff, neonHeight);
                local v_boff_x, v_boff_y, v_boff_z = Game.GetOffsetFromCarInWorldCoords(targetCar, -20.0, neonBYoff, neonHeight);
                local fdist = Game.GetDistanceBetweenCoords2d(v_attach_x + -20.0, v_attach_y + neonFYoff, v_attach_x, v_attach_y);
                local bdist = Game.GetDistanceBetweenCoords2d(v_attach_x - -20.0, v_attach_y - neonBYoff, v_attach_x, v_attach_y);
                local fx = Game.Cos(v_attach_h) * fdist + v_foff_x;
                local fy = Game.Sin(v_attach_h) * fdist + v_foff_y;
                local bx = Game.Cos(v_attach_h) * bdist + v_boff_x;
                local by = Game.Sin(v_attach_h) * bdist + v_boff_y;
                
                Game.DrawLightWithRange(fx, fy, v_attach_z + neonHeight, r, g, b, neonFBrange, neonIntensity);
                Game.DrawLightWithRange(bx, by, v_attach_z + neonHeight, r, g, b, neonFBrange, neonIntensity);
            end
        end
        
    end
end
	
Events.Subscribe("scriptInit", function()
   
    Thread.Create(function()
        while true do   
            Thread.Pause(0) 
            local playerId = Game.GetPlayerId()
			local playerChar = Game.GetPlayerChar(playerId)
            local px, py, pz = Game.GetCharCoordinates(playerChar)
   

            for i = 0, 31, 1 do
                if Game.IsNetworkPlayerActive(i) then
                    local playerId = Player.GetServerID(i)
                    local targetChar = Game.GetPlayerChar(i)
                    local netx, nety, netz = Game.GetCharCoordinates(targetChar)
                    local dist = Game.GetDistanceBetweenCoords3d(px, py, pz, netx, nety, netz)
                   

                    if AllPlayersNeon[playerId] ~= nil then 
                        if AllPlayersNeon[playerId].enabled then 
                            if AllPlayersNeon[playerId].r ~= nil and AllPlayersNeon[playerId].g ~= nil and AllPlayersNeon[playerId].b ~= nil then
                                if dist < VisibleDistanceColor then 
                                    Customs_Neon(AllPlayersNeon[playerId].vid, targetChar, AllPlayersNeon[playerId].r, AllPlayersNeon[playerId].g, AllPlayersNeon[playerId].b)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end)

local function GetNetIdVehicle()
    local playerId = Game.GetPlayerId()
	local playerChar = Game.GetPlayerChar(playerId)

    if (Game.IsCharInAnyCar(playerChar) and not Game.IsCharInAnyBoat(playerChar) and not Game.IsCharInAnyHeli(playerChar)) then 
        local targetCar = Game.GetCarCharIsUsing(playerChar)
        if (Game.IsVehDriveable(targetCar) and not Game.IsBigVehicle(targetCar)) then 
            return Game.GetNetworkIdFromVehicle(targetCar)
        else
            return 0
        end
    else 
        return 0
    end
end

Events.Subscribe("chatCommand", function(fullcommand)
	local command = stringsplit(fullcommand, ' ')

    if command[1] == "/neon_on" then
        Events.CallRemote("Send_NeonActive_sv", { true })

    elseif command[1] == "/neon_off" then
        Events.CallRemote("Send_NeonActive_sv", { false })

    elseif command[1] == "/neon_color" then
        if command[2] == nil then 
            Chat.AddMessage("Usage: /neon_color [color]")
        else
            SetColorToNeon(tostring(command[2]))
			Chat.AddMessage("color selected : "..tostring(command[2]))
        end

    elseif command[1] == "/color_help" then
        Chat.AddMessage("color: white, blue, electric_blue, mint_green, lime_green, yellow, gold, orange, red, pink, purple")

    elseif command[1] == "/neon_veh_id" then
        Events.CallRemote("Send_SetNeonVehId_sv", { GetNetIdVehicle() })
		Chat.AddMessage("vehicle id saved")

    elseif command[1] == "/neon_veh_off" then
        Events.CallRemote("Send_RemoveNeonVehId_sv", {})
		Chat.AddMessage("remove vehicle id")
    else
        Chat.AddMessage("error: command not found")
    end
end)

