local PlayerData = {}

Events.Subscribe("playerJoin", function()

    if PlayerData ~= nil then 
        Events.BroadcastRemote("Updates_PlayerDataNeons_cl", {PlayerData})
    end
end, true)

Events.Subscribe("playerDisconnect", function(id, name, reason)
    local PlayerDisconnected = id

    if PlayerData[PlayerDisconnected] ~= nil then 
        PlayerData[PlayerDisconnected] = nil
    end

    Events.BroadcastRemote("Updates_PlayerDataNeons_cl", {PlayerData})
end)

Events.Subscribe("Send_NeonColor_sv", function(r, g, b)
    local source = Events.GetSource()

    if PlayerData == nil then 
        PlayerData = {}
    end

    if PlayerData[source] == nil then 
        PlayerData[source] = {
            vid = 0,
            r = r,
            g = g,
            b = b,
            enabled = true
        }
    else
        PlayerData[source].r = r
        PlayerData[source].g = g
        PlayerData[source].b = b
        PlayerData[source].enabled = true
    end

    Events.BroadcastRemote("Updates_PlayerDataNeons_cl", {PlayerData})
end, true)

Events.Subscribe("Send_NeonActive_sv", function(enabled)
    local source = Events.GetSource()

    if PlayerData == nil then 
        PlayerData = {}
    end

    if PlayerData[source] ~= nil then 
        PlayerData[source].enabled = enabled
    end

    Events.BroadcastRemote("Updates_PlayerDataNeons_cl", {PlayerData})
end, true)

Events.Subscribe("Send_SetNeonVehId_sv", function(netid)
    local source = Events.GetSource()

    if PlayerData == nil then 
        PlayerData = {}
    end

    if PlayerData[source] ~= nil then 
        PlayerData[source].vid = netid
    end

    Events.BroadcastRemote("Updates_PlayerDataNeons_cl", {PlayerData})
end, true)

Events.Subscribe("Send_RemoveNeonVehId_sv", function()
    local source = Events.GetSource()

    if PlayerData == nil then 
        PlayerData = {}
    end

    if PlayerData[source] ~= nil then 
        PlayerData[source].vid = 0
    end

    Events.BroadcastRemote("Updates_PlayerDataNeons_cl", {PlayerData})
end, true)