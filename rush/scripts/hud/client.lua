hudActive = false
RegisterNetEvent("rush:showHud", function(tog)
    hudActive = tog

    SendNUIMessage({type = "setHudShow", tog = tog})

    DisplayRadar(tog)
end)

RegisterCommand("cursor", function()
    SetNuiFocus(true, true)

    Citizen.Wait(500)
    SendNUIMessage({type = "setForceCursor", tog = true})
end)
  
RegisterKeyMapping("cursor", "Cursor", "keyboard", "GRAVE")

RegisterCommand("hud", function()
    TriggerEvent("rush:showHud", not hudActive)
end)

RegisterNetEvent("rush:uiUpdate", function(updType, val)
    if updType == "updateOnline" then
        SendNUIMessage({type = "setOnlineAmm", amm = val})
    elseif updType == "updateId" then
        SendNUIMessage({type = "setHudUserId", user_id = val})
    elseif updType == "updateCash" then
        SendNUIMessage({type = "setMoney", cash = val})
    elseif updType == "updateBank" then
        SendNUIMessage({type = "setMoney", bank = val})
    elseif updType == "updateThirst" then
        SendNUIMessage({type = "setStats", thirst = val})
    elseif updType == "updateFood" then
        SendNUIMessage({type = "setStats", hunger = val})
    elseif updType == "isAdmin" then
        SendNUIMessage({type = "setAdminTks", isAdmin = val})
    elseif updType == "updateAdminTickets" then
        SendNUIMessage({type = "setAdminTks", tks = val})
    end
end)

RegisterNetEvent("pma-voice:setTalkingState", function(bool, usingRadio)
    SendNUIMessage({type = "setVoice", tog = bool, radiotog = usingRadio})
end)

RegisterNetEvent("pma-voice:setTalkingMode", function(voiceMode)
    SendNUIMessage({type = "setVoice", lvl = voiceMode})
end)

local street, district = false, false
Citizen.CreateThread(function()
    while true do
        local streetHash, crossingHash = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
        
        local streetName = GetStreetNameFromHashKey(streetHash)
        local districtName = GetLabelText(GetNameOfZone(myPos))

        if (streetName ~= street or districtName ~= district) and (streetName:len() >= 2 and districtName:len() >= 2) then
            SendNUIMessage({type = "setLoc", district = districtName, street = streetName})

            street, district = streetName, districtName
        end
    
        Citizen.Wait(1000)
    end
end)

---------------------------------------------------------------------------------
RegisterNetEvent("rush:playerEnterVehicle")

RegisterNetEvent("rush:playerLeaveVehicle")

local sent = false
AddEventHandler("gameEventTriggered", function(name, args)    
    if name == "CEventNetworkPlayerEnteredVehicle" then 
        Wait(1500)
        if not (args[2] == myVehicle) then return end

        local inVeh = myVehicle ~= 0
        local veh = myVehicle
        local isDriver = (GetPedInVehicleSeat(veh, -1) == myPed) or false
        local plate = GetVehicleNumberPlateText(veh)
        local nid = NetworkGetNetworkIdFromEntity(veh)
        if not sent then
            TriggerEvent("rush:playerEnterVehicle", veh, isDriver)
            sent = true
        end
        if isDriver then
            TriggerServerEvent("rush:playerEnterVehicle", nid, plate)
            SetPedCanBeDraggedOut(myPed, false)
        end

        Citizen.CreateThread(function()
            Citizen.CreateThread(function()
                while inVeh do
                    if myVehicle == 0 then break end
                    
                    local fuel = string.format("%.1f", GetVehicleFuelLevel(myVehicle))

                    local doorOpen = false
                    for i=0, GetNumberOfVehicleDoors(myVehicle) do
                        if GetVehicleDoorAngleRatio(myVehicle, i) > 0.0 then
                            doorOpen = true
                            break
                        end
                    end

                    local _, lights, highbeams = GetVehicleLightsState(myVehicle)
                    
                    SendNUIMessage({
                        type = "setSpeedoValue",
                        engine = IsVehicleEngineOn(myVehicle),
                        tank = fuel,
                        doors = doorOpen,
                        -- seatbelt = carBelt,
                        lights = (lights > 0) or (highbeams > 0),
                        class = GetVehicleClass(myVehicle),
                        show = true,
                    })
                
                    Wait(800)
                end
            end)
            while inVeh do
                myVehicle = GetVehiclePedIsIn(myPed)
                if myVehicle == 0 then
                    break
                end
                
                local carSpeed = math.ceil(GetEntitySpeed(myVehicle) * 3.6)

                SendNUIMessage({
                    type = "setSpeedoValue",
                    speed = carSpeed,
                    show = true,
                })
            
                Wait(10)
            end
			TriggerEvent("rush:playerLeaveVehicle", veh)
			if isDriver then
				TriggerServerEvent("rush:playerLeaveVehicle", nid, plate)
			end
            sent = false
            SendNUIMessage({type = "setSpeedoValue", show = false })
        end)
    end
end)
---------------------------------------------------------------------------------