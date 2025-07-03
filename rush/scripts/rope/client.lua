local near = false

Citizen.CreateThread(function()
    while true do
        near = exports["vrp"]:getNearestPlayer(2.0)
        Citizen.Wait(1500)
    end
end)


Citizen.CreateThread(function()
    local tied = false

    local nextTiedCheck = 0

    while true do
        Citizen.Wait(500)
        
        while near do
            local myPed = PlayerPedId()

            local weapon = GetSelectedPedWeapon(myPed)
            if weapon ~= GetHashKey("WEAPON_UNARMED") then
                if GetGameTimer() >= nextTiedCheck then
                    tied = Player(near).state.tied or false
                    nextTiedCheck = GetGameTimer() + 2000
                end
            else
                tied = false
            end

            if tied then

			    SetTextFont(0)
				SetTextCentre(1)
				SetTextProportional(0)
				SetTextScale(0.55, 0.55)
				SetTextDropShadow(30, 5, 5, 5, 255)
				SetTextEntry("STRING")
				SetTextColour(255, 255, 255, 255)
                local text = ""
                if tied == "rope" then
                    text = "~b~[E]~w~ Taie sfoara ~HC_1~/~HC_4~/~HC_3~/ "..text
                end
                text = text.."~r~[H] ~w~Jefuieste"
				AddTextComponentString(text)
				DrawText(0.5, 0.85)

                if IsControlJustPressed(0, 38) then
                    ClearPedTasksImmediately(myPed)
                    TriggerServerEvent("rush:cutRope", near)
                    Citizen.Wait(6000)
                end
                
                if IsControlJustPressed(0, 101) then
                    ClearPedTasksImmediately(myPed)
                    TriggerServerEvent("rush:iWannaLootYou", near)
                    Citizen.Wait(6000)
                end
            end
            Citizen.Wait(1)
        end

        tied, nextTiedCheck = false, 0
    end
end)

exports("isTiedWithRope", function()
    return (LocalPlayer.state.tied == "rope") or false
end)