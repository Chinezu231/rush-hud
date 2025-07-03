myPlayerId = PlayerId()
myPed = PlayerPedId()
myPos = GetEntityCoords(myPed)
myVehicle = GetVehiclePedIsIn(myPed)

Citizen.CreateThread(function()
    while true do
        myPlayerId = PlayerId()
        myPed = PlayerPedId()
        myPos = GetEntityCoords(myPed)
        myVehicle = GetVehiclePedIsIn(myPed)
        Citizen.Wait(100)
    end
end)

local resName = GetCurrentResourceName()
local function callback(cbName, cb, ...)
	TriggerServerEvent(resName..":s_callback:"..cbName, ...)
	return RegisterNetEvent(resName..":c_callback:"..cbName, function(...)
		cb(...)
	end)
end

function triggerCallback(cbName, cb, ...)
	local ev = false
	local f = function(...)
		if ev ~= false then
			RemoveEventHandler(ev)
		end
		cb(...)
	end
	ev = callback(cbName, f, ...)
	return ev
end

function DrawText3D(pos, text, font, scale)
    local onScreen,_x,_y=World3dToScreen2d(pos.x, pos.y, pos.z)
    local dst = #(GetGameplayCamCoords() - pos)
    local scale = ((1 / dst) * 2) * ((1 / GetGameplayCamFov()) * 100)

    if onScreen then
        SetTextScale(0.0*scale, 0.35*scale)
        SetTextFont(font or 0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

RegisterNUICallback("triggerEvent", function(data, cb)
    cb("ok")
    if not data then return end

    TriggerEvent(table.unpack(data))
end)

RegisterNUICallback("setFocus", function(data, cb)
    SetNuiFocus(data[1], data[1])
    cb("ok")
end)