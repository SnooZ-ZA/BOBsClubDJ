ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_dj:PayMoney')
AddEventHandler('esx_dj:PayMoney', function()
    xPlayer = ESX.GetPlayerFromId(source)
    PlayerJob = xPlayer.getJob()

    if PlayerJob.name == "dj" then
        if Config.MoneyType == true then
            xPlayer.addMoney(Config.MoneyAmount)
        else
            xPlayer.addAccountMoney('bank', Config.MoneyAmount)
        end
    end
end)


------
-- Interaction Sounds by Scott
-- Version: v0.0.1
-- Path: server/main.lua
--
-- Allows sounds to be played on single clients, all clients, or all clients within
-- a specific range from the entity to which the sound has been created. Triggers
-- client events only. Used to trigger sounds on other clients from the client or
-- server without having to pass directly to another client.
------

RegisterServerEvent('BobInteractSound_SV:PlayOnOne')
AddEventHandler('BobInteractSound_SV:PlayOnOne', function(clientNetId, soundFile, soundVolume)
    TriggerClientEvent('BobInteractSound_CL:PlayOnOne', clientNetId, soundFile, soundVolume)
end)

RegisterServerEvent('BobInteractSound_SV:PlayOnSource')
AddEventHandler('BobInteractSound_SV:PlayOnSource', function(soundFile, soundVolume)
    TriggerClientEvent('BobInteractSound_CL:PlayOnOne', source, soundFile, soundVolume)
end)

RegisterServerEvent('BobInteractSound_SV:PlayOnAll')
AddEventHandler('BobInteractSound_SV:PlayOnAll', function(soundFile, soundVolume)
    TriggerClientEvent('BobInteractSound_CL:PlayOnAll', -1, soundFile, soundVolume)
end)

RegisterServerEvent('BobInteractSound_SV:PlayWithinDistance')
AddEventHandler('BobInteractSound_SV:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    TriggerClientEvent('BobInteractSound_CL:PlayWithinDistance', -1, source, maxDistance, soundFile, soundVolume)
end)
