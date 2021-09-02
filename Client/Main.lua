--[[
  _____   _                                 _   _   _
 |_   _| (_)  _ __    _   _   ___          | \ | | | |
   | |   | | | '_ \  | | | | / __|         |  \| | | |    
   | |   | | | | | | | |_| | \__ \         | |\  | | |___ 
   |_|   |_| |_| |_|  \__,_| |___/  _____  |_| \_| |_____|
                                   |_____|
]]--

ESX             = nil
local PlayerData = {}
local coords = 0
MenuOpened = false
OnDuty = false
CurrentJob = nil
LastVehicle = 0

MainBlip = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	while true do
		if ESX == nil then
			Citizen.Wait(1)
		else
			ESX.PlayerData = xPlayer
			break
		end
	end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterCommand("coords", function()
	print(GetEntityCoords(PlayerPedId()))
end)

function OpenLocker()
	MenuOpened = true

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "locker_menu", {
		title = Config.TranslationList[Config.Translation]["LOCKER_MENU"],
		align = "bottom-right",
		elements = {
			{label = Config.TranslationList[Config.Translation]["WORK_CLOTHES"], value = "work_clothes"},
			{label = Config.TranslationList[Config.Translation]["NORMAL_CLOTHES"], value = "normal_clothes"}
		}
	}, 
	function(Data, LockerMenu) -- Selection
		if Data.current.value == "normal_clothes" then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(CurrentSkin, jobSkin)
				local isMale = CurrentSkin.sex == 0

				TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(CurrentSkin)
						TriggerEvent('skinchanger:loadSkin', CurrentSkin)
						OnDuty = false
					end)
				end)
			end)
		elseif Data.current.value == "work_clothes" then
			WorkClothesData = {}

			TriggerEvent('skinchanger:getSkin', function(CurrentSkin)
				if CurrentSkin.sex == 0 then
					WorkClothesData = Config.Uniforms.Male
				else
					WorkClothesData = Config.Uniforms.FeMale
				end

				if WorkClothesData ~= {} then
					TriggerEvent('skinchanger:loadClothes', CurrentSkin, WorkClothesData)
				end

				OnDuty = true
			end)
		end

		LockerMenu.close()
		MenuOpened = false
	end, 
	function(Data, LockerMenu) -- Close
		LockerMenu.close()
		MenuOpened = false
	end)
end

function OpenGarage()
	MenuOpened = true

	MenuList = {}

	for Index, CurrentVehicle in pairs(Config.Vehicles) do
		table.insert(MenuList, {label = CurrentVehicle.Name, value = CurrentVehicle.SpawnName})
	end

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_menu", {
		title = Config.TranslationList[Config.Translation]["GARAGE_MENU"],
		align = "bottom-right",
		elements = MenuList
	}, 
	function(Data, GarageMenu) -- Selection
		for Index, CurrentVehicle in pairs(Config.Vehicles) do
			if Data.current.value == CurrentVehicle.SpawnName then
				VehicleHash = GetHashKey(CurrentVehicle.SpawnName)

				RequestModel(VehicleHash)

				Citizen.CreateThread(function()
					TimeWaited = 0

					while not HasModelLoaded(VehicleHash) do
						Citizen.Wait(100)
						TimeWaited = TimeWaited + 100

						if TimeWaited >= 5000 then
							ESX.ShowNotification(Config.TranslationList[Config.Translation]["GARAGE_PROBLEM"], false, true, 90)
							break
						end
					end

					NewVehicle = CreateVehicle(
						VehicleHash, 
						Config.VehicleSpawn.X, Config.VehicleSpawn.Y, Config.VehicleSpawn.Z,
						Config.VehicleSpawn.Heading,
						true, false
					)

					if (Config.LicensePlate ~= "") then
						SetVehicleNumberPlateText(NewVehicle, Config.LicensePlate)
					end

					SetVehicleOnGroundProperly(NewVehicle)
					SetModelAsNoLongerNeeded(VehicleHash)

					TaskWarpPedIntoVehicle(PlayerPedId(), NewVehicle, -1)
				end)
			end
		end

		GarageMenu.close()
		MenuOpened = false
	end, 
	function(Data, GarageMenu) -- Close
		GarageMenu.close()
		MenuOpened = false
	end)
end

function OpenMenu()
	MenuOpened = true

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "menu_menu", {
		title = Config.TranslationList[Config.Translation]["MENU_MENU"],
		align = "bottom-right",
		elements = {
			{label = Config.TranslationList[Config.Translation]["MENU_NEW"], value = "new_job"},
			{label = Config.TranslationList[Config.Translation]["MENU_CANCEL"], value = "cancel_job"}
		}
	}, 
	function(Data, MenuMenu) -- Selection
		if Data.current.value == "new_job" then
			if CurrentJob == nil then
				RandomJob = Config.Jobs[math.random(1, #Config.Jobs)]
				
				CurrentJob = {}

				CurrentJob["X"] = RandomJob.X
				CurrentJob["Y"] = RandomJob.Y
				CurrentJob["Z"] = RandomJob.Z

				CurrentJob["Blip"] = AddBlipForCoord(CurrentJob.X, CurrentJob.Y, CurrentJob.Z)
				SetBlipSprite(CurrentJob.Blip, 66)
				SetBlipDisplay(CurrentJob.Blip, 4)
				SetBlipScale(CurrentJob.Blip, 1.0)
				SetBlipColour(CurrentJob.Blip, 64)
				SetBlipAsShortRange(CurrentJob.Blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(Config.JobBlipName)
				EndTextCommandSetBlipName(CurrentJob.Blip)

				SetNewWaypoint(CurrentJob.X, CurrentJob.Y)

				CurrentJob["Enabled"] = false

				ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_CREATED"], false, true, 210)
			else
				ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_ALREADY"], false, true, 90)
			end
		elseif Data.current.value == "cancel_job" then
			if CurrentJob ~= {} then
				RemoveBlip(CurrentJob.Blip)
				DeleteWaypoint()
				CurrentJob = nil

				ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_CANCELED"], false, true, 210)
			else
				ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
			end
		end

		MenuMenu.close()
		MenuOpened = false
	end, 
	function(Data, MenuMenu) -- Close
		MenuMenu.close()
		MenuOpened = false
	end)
end

RegisterNUICallback("main", function(RequestData)
	if RequestData.ReturnType == "EXIT" then
		if CurrentJob ~= {} then
			CurrentJob.Enabled = false

			SetNuiFocus(false, false)
			SendNUIMessage({RequestType = "Visibility", RequestData = false})
		else
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
		end
	elseif RequestData.ReturnType == "DONE" then
		if CurrentJob ~= {} then
			SetNuiFocus(false, false)
			SendNUIMessage({RequestType = "Visibility", RequestData = false})

			RemoveBlip(CurrentJob.Blip)
			DeleteWaypoint()
			CurrentJob = nil

			TriggerServerEvent('esx_dj:PayMoney', CurrentJob)
			
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["JOB_DONE"], false, true, 210)
		else
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
		end
	end
end)

LockerCoords = vector3(Config.Locker.X, Config.Locker.Y, Config.Locker.Z)
GarageCoords = vector3(Config.Garage.X, Config.Garage.Y, Config.Garage.Z)
DeleteCoords = vector3(Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z)

Citizen.CreateThread(function() -- Locker
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			PlayerJobInfo = ESX.PlayerData.job

			if PlayerJobInfo ~= nil then
				if PlayerJobInfo.name == "dj" then
					PlayerCoords = GetEntityCoords(PlayerPedId())
					PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

					if Vdist2(PlayerCoords, LockerCoords) <= 1.5 and PlayerVehicle == 0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["LOCKER_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							if MenuOpened == false then
								OpenLocker()
							end
						end
					end

					-- Blip
					if MainBlip == nil then
						MainBlip = AddBlipForCoord(Config.Locker.X, Config.Locker.Y, Config.Locker.Z)
						SetBlipSprite(MainBlip, 463)
						SetBlipDisplay(MainBlip, 4)
						SetBlipScale(MainBlip, 0.8)
						SetBlipColour(MainBlip, 57)
						SetBlipAsShortRange(MainBlip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(Config.BlipName)
						EndTextCommandSetBlipName(MainBlip)
					end

					-- Circle
					DrawMarker(
						25, -- Type
						Config.Locker.X, Config.Locker.Y, Config.Locker.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						1.5, 1.5, 1.5, -- Scale
						255, 120, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Stripes
					DrawMarker(
						30, -- Type
						Config.Locker.X, Config.Locker.Y, Config.Locker.Z, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						0.75, 0.75, 0.75, -- Scale
						255, 120, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

				else
					if MainBlip ~= nil then
						RemoveBlip(MainBlip)
						MainBlip = nil
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Garage
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true then
				PlayerCoords = GetEntityCoords(PlayerPedId())
				PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

				-- Circle
				DrawMarker(
					25, -- Type
					Config.Garage.X, Config.Garage.Y, Config.Garage.Z - 0.98, -- Position
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
					1.5, 1.5, 1.5, -- Scale
					255, 120, 0, 155, -- Color
					false, true, 2, nil, nil, false -- Extra
				)

				-- Car
				DrawMarker(
					36, -- Type
					Config.Garage.X, Config.Garage.Y, Config.Garage.Z, -- Position
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
					0.75, 0.75, 0.75, -- Scale
					255, 120, 0, 155, -- Color
					false, true, 2, nil, nil, false -- Extra
				)

				if Vdist2(PlayerCoords, GarageCoords) <= 1.5 and PlayerVehicle == 0 then
					ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["GARAGE_HELP"], true, false, 1)
				
					if IsControlJustPressed(1, 51) then
						if MenuOpened == false then
							OpenGarage()
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Deleter
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true then
				PlayerCoords = GetEntityCoords(PlayerPedId())
				PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

				IsVehicle = false

				for Index, CurrentVehicle in pairs(Config.Vehicles) do
					if IsVehicleModel(PlayerVehicle, GetHashKey(CurrentVehicle.SpawnName)) then
						IsVehicle = true
					end
				end

				if IsVehicle == true then
					-- Circle
					DrawMarker(
						25, -- Type
						Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						3.5, 3.5, 3.5, -- Scale
						255, 0, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Car
					DrawMarker(
						36, -- Type
						Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z + 0.5, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						3.0, 3.0, 3.0, -- Scale
						255, 0, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					if Vdist2(PlayerCoords, DeleteCoords) <= 3.0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["DELETE_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							SetEntityAsMissionEntity(PlayerVehicle, true, true)
							DeleteVehicle(PlayerVehicle)
						end
					else
						if LastVehicle ~= PlayerVehicle then
							LastVehicle = PlayerVehicle
							ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["MENU_HELP"], false, false, 5000)
						end
					end

					if IsControlJustPressed(1, 10) then
						if MenuOpened == false then
							OpenMenu()
						end
					end
				else
					LastVehicle = 0
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Jobs
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true and CurrentJob ~= nil then
				if CurrentJob.Enabled == false then
					PlayerCoords = GetEntityCoords(PlayerPedId())
					PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())
					JobCoords = vector3(CurrentJob.X, CurrentJob.Y, CurrentJob.Z)
					
					
					-- Circle
					DrawMarker(
						25, -- Type
						CurrentJob.X, CurrentJob.Y, CurrentJob.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						1.5, 1.5, 1.5, -- Scale
						0, 255, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Question Mark
					DrawMarker(
						32, -- Type
						CurrentJob.X, CurrentJob.Y, CurrentJob.Z, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						0.75, 0.75, 0.75, -- Scale
						0, 255, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					if Vdist2(PlayerCoords, JobCoords) <= 1.5 and PlayerVehicle == 0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["JOB_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							CurrentJob.Enabled = true

							--SetNuiFocus(true, true)
							--SendNUIMessage({RequestType = "Visibility", RequestData = true})
							if not DoesEntityExist(dancer) then
							RequestModel("u_f_y_dancerave_01")
								while not HasModelLoaded("u_f_y_dancerave_01") do
								Wait(10)
								end
							dancer = CreatePed(4, "u_f_y_dancerave_01", CurrentJob.X+0.2, CurrentJob.Y-0.8, CurrentJob.Z, 268.0, true, false)
							dancer2 = CreatePed(4, "u_f_y_dancerave_01", CurrentJob.X+0.2, CurrentJob.Y+0.8, CurrentJob.Z, 260.0, true, false)
							RequestAnimDict("anim@amb@nightclub@dancers@podium_dancers@")
								while not HasAnimDictLoaded("anim@amb@nightclub@dancers@podium_dancers@") do
								Wait(1)
								end
								local dj = (PlayerPedId())
							TaskTurnPedToFaceEntity(dancer, dj, 2000)
							TaskTurnPedToFaceEntity(dancer2, dj, 2000)
							Wait(1000)
							TaskPlayAnim(dancer,"anim@amb@nightclub@dancers@podium_dancers@","hi_dance_facedj_17_v2_female^2", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
							TaskPlayAnim(dancer2,"anim@amb@nightclub@dancers@podium_dancers@","hi_dance_facedj_17_v2_male^5", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
							end
							
							
							exports.rprogress:Custom({
								Async = true,
								x = 0.5,
								y = 0.5,
								From = 0,
								To = 100,
								Duration = 60000,
								Radius = 60,
								Stroke = 10,
								MaxAngle = 360,
								Rotation = 0,
								Easing = "easeLinear",
								Label = "Hitting Decks",
								LabelPosition = "right",
								Color = "rgba(255, 255, 255, 1.0)",
								BGColor = "rgba(107, 109, 110, 0.95)",
								Animation = {
								--scenario = "CODE_HUMAN_MEDIC_TEND_TO_DEAD", -- https://pastebin.com/6mrYTdQv
								animationDictionary = "anim@amb@nightclub@djs@dixon@", -- https://alexguirre.github.io/animations-list/
								animationName = "dixn_dance_cntr_open_dix",
								},
								DisableControls = {
								Mouse = false,
								Player = true,
								Vehicle = true
								},
								})
								local sound = math.random(1, 4) --12 1 min mixes 1 - 12
								if sound == 1 then
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '1_1', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '1_2', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '1_3', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '1_4', 0.6)
								Citizen.Wait (15000)
								elseif sound == 2 then
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '2_1', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '2_2', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '2_3', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '2_4', 0.6)
								Citizen.Wait (15000)
								elseif sound == 3 then
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '3_1', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '3_2', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '3_3', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '3_4', 0.6)
								Citizen.Wait (15000)
								elseif sound == 4 then
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '4_1', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '4_2', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '4_3', 0.6)
								Citizen.Wait (15000)
								TriggerServerEvent('BobInteractSound_SV:PlayWithinDistance', 10.0, '4_4', 0.6)
								Citizen.Wait (15000)
								end
								if DoesEntityExist(dancer) then
								DeleteEntity(dancer)
								DeleteEntity(dancer2)
								end
								RemoveBlip(CurrentJob.Blip)
								DeleteWaypoint()
								CurrentJob = nil

								TriggerServerEvent('esx_dj:PayMoney', CurrentJob)
			
								ESX.ShowNotification(Config.TranslationList[Config.Translation]["JOB_DONE"], false, true, 210)
						end
					end
				end
			end
		end
	end
end)


------
-- InteractionSound by Scott
-- Version: v0.0.1
-- Path: client/main.lua
--
-- Allows sounds to be played on single clients, all clients, or all clients within
-- a specific range from the entity to which the sound has been created.
------

local standardVolumeOutput = 1.0;

RegisterNetEvent('BobInteractSound_CL:PlayOnOne')
AddEventHandler('BobInteractSound_CL:PlayOnOne', function(soundFile, soundVolume)
    SendNUIMessage({
        transactionType     = 'playSound',
        transactionFile     = soundFile,
        transactionVolume   = soundVolume
    })
end)

RegisterNetEvent('BobInteractSound_CL:PlayOnAll')
AddEventHandler('BobInteractSound_CL:PlayOnAll', function(soundFile, soundVolume)
    SendNUIMessage({
        transactionType     = 'playSound',
        transactionFile     = soundFile,
        transactionVolume   = soundVolume
    })
end)

RegisterNetEvent('BobInteractSound_CL:PlayWithinDistance')
AddEventHandler('BobInteractSound_CL:PlayWithinDistance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs  = Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if(distIs <= maxDistance) then
        SendNUIMessage({
            transactionType     = 'playSound',
            transactionFile     = soundFile,
            transactionVolume   = soundVolume
        })
    end
end)

