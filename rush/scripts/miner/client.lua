local mineCoords <const> = vector3(2907.5361328125, 2717.6008300781, 44.577068328857)

local furnacePos <const> = vector3(2920.904296875, 2653.474609375, 43.183284759521)

local miningPos <const> = { -- sync w server
    {pos = vec3(2896.0854492188,2725.8796386719,44.112449645996)},
    {pos = vec3(2897.2436523438,2717.0424804688,43.547924041748)},
    {pos = vec3(2906.3332519531,2725.2333984375,44.816787719727)},
    {pos = vec3(2912.1418457031,2720.1760253906,47.482376098633)},
    {pos = vec3(2913.1608886719,2713.7294921875,43.864398956299)},
    {pos = vec3(2910.833984375,2707.3544921875,43.751274108887)},
    {pos = vec3(2926.7116699219,2702.564453125,44.710227966309)},
    {pos = vec3(2930.0861816406,2695.9865722656,44.349620819092)},
    {pos = vec3(2915.64453125,2688.4240722656,45.852882385254)},
    {pos = vec3(2930.6906738281,2684.8718261719,45.416023254395)},
    {pos = vec3(2900.9013671875,2682.4028320312,45.302570343018)},
    {pos = vec3(2885.1948242188,2684.8198242188,46.296142578125)},
    {pos = vec3(2873.5063476562,2701.5754394531,46.587951660156)},
    {pos = vec3(2870.0920410156,2687.1967773438,45.590866088867)},
    {pos = vec3(2859.3979492188,2675.9548339844,42.850257873535)},
    {pos = vec3(2845.7702636719,2673.1923828125,40.809673309326)},
    {pos = vec3(2843.5400390625,2661.2426757812,40.497627258301)},
    {pos = vec3(2858.0498046875,2661.0510253906,44.372550964355)},
    {pos = vec3(2853.9157714844,2659.0859375,39.311550140381)},
    {pos = vec3(2845.5671386719,2656.6789550781,39.260238647461)},
}

local stones = {
    {name = "stone", label = "Piatra", chance = 90},
    {name = "silver", label = "Argint", chance = 10},
    {name = "lead", label = "~HC_4~Plumb", chance = 10},
    {name = "iron", label = "~HC_3~Fier", chance = 10},
    {name = "gold", label = "~y~Aur", chance = 10},
    {name = "copper", label = "~HC_17~Cupru", chance = 10},
    {name = "coal", label = "~l~Carbune", chance = 10},
    {name = "sulfur", label = "~HC_13~Sulf", chance = 10},
}

local function getRandStone()
    ::retryPick::
    Citizen.Wait(1)
    math.randomseed(PlayerId() * GetGameTimer())
    local rnd = math.random(1, 100)
    local i = math.random(1, #stones)

    local itmdata = stones[i]

    if rnd <= itmdata.chance then        
        local itemId = itmdata.name:lower()

        return itemId, itmdata.label
    end
    goto retryPick
end

local nearMine = false
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(mineCoords)
    SetBlipSprite(blip, 124)
    SetBlipColour(blip, 5)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mina")
    EndTextCommandSetBlipName(blip)

    Citizen.CreateThread(function()
        while true do
            if nearMine then

                for i = 1, #miningPos do
                    if (not miningPos[i].obj or not DoesEntityExist(miningPos[i].obj)) and not miningPos[i].crystalObj then
                        local randomPick, label = getRandStone()

                        local randomPickOre = randomPick

                        if randomPickOre == "stone" then
                            randomPickOre = "empty"
                        elseif randomPickOre == "silver" then
                            randomPickOre = "tin"
                        end

                        if randomPickOre ~= "coal" and randomPickOre ~= "sulfur" then
                            randomPickOre = randomPickOre.."ore"
                        
                            if randomPickOre ~= "emptyore" then
                                randomPickOre = randomPickOre.."2"
                            end
                        end

                        local model = GetHashKey("k4mb1_"..randomPickOre)

                        RequestModel(model)
                        while not HasModelLoaded(model) do
                            Citizen.Wait(100)
                        end

                        miningPos[i].obj = CreateObjectNoOffset(model, miningPos[i].pos, true, true, false)
                        FreezeEntityPosition(miningPos[i].obj, true)
                        miningPos[i].pick = randomPick
                        miningPos[i].label = label
                    end
                end

                Citizen.Wait(20000)

            else
                Citizen.Wait(5000)
            end
            Citizen.Wait(1)
        end
    end)

    Citizen.CreateThread(function()
        local selectedStone = 2

        local blip = AddBlipForCoord(furnacePos)
        SetBlipSprite(blip, 436)
        SetBlipColour(blip, 21)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Furnal")
        EndTextCommandSetBlipName(blip)

        while true do
            if not nearMine then
                Citizen.Wait(3000)
            else
                local nearFurnace = false

                local dst = #(myPos - furnacePos)

                if dst <= 10.0 then
                    nearFurnace = true

                    local nearToUse = dst <= 1.5

                    local text = ""

                    for stoneId, stone in pairs(stones) do
                        if stone.name ~= "coal" and stone.name ~= "stone" then
                            text = text .. "~n~" .. ((selectedStone == stoneId and nearToUse) and "~w~[E] " or "") ..stone.label
                        end
                    end

                    if nearToUse then
                        if IsControlJustReleased(0, 172) then
                            selectedStone = math.max(2, selectedStone - 1)
                            
                            if selectedStone == 7 then
                                selectedStone = selectedStone - 1
                            end
                        end
                        
                        if IsControlJustReleased(0, 173) then
                            selectedStone = math.min(#stones, selectedStone + 1)

                            if selectedStone == 7 then
                                selectedStone = selectedStone + 1
                            end
                        end

                        if IsControlJustReleased(0, 38) then
                            local p = promise:new()

                            triggerCallback("tryMeltItem", function(res)
                                if not res then
                                    p:resolve(false)
                                else

                                    ExecuteCommand("e jreacteasy")

                                    local untilTime = GetGameTimer() + 20000
                                    
                                    while GetGameTimer() <= untilTime do
                                        DrawText3D(furnacePos, "Topesti "..stones[selectedStone].label.."...")
                                        Citizen.Wait(1)
                                    end

                                    TriggerServerEvent("rush-mine:meltReady")

                                    p:resolve(true)

                                end
                            end, stones[selectedStone].name)

                            Citizen.Await(p)
                        end

                        DrawText3D(furnacePos - vector3(0.0, 0.0, 0.2), "~HC_4~Foloseste sagetile ~bold~sus/jos~h~ sa selectezi~n~minereul pe care vrei sa il topesti")
                    end

                    DrawText3D(furnacePos + vector3(0.0, 0.0, 0.6), text)
                end

                if not nearFurnace then
                    Citizen.Wait(1000)
                end

                Citizen.Wait(1)
            end
        end
    end)

    local wasInMine = false

    while true do
        nearMine = #(mineCoords - myPos) <= 100.0

        if IsPedInAnyVehicle(myPed) then
            Citizen.Wait(2000)
        else
            if nearMine then
                wasInMine = true

                local nearAny = false
                
                for i = 1, #miningPos do
                    local dst = #(myPos - miningPos[i].pos)
                    
                    if dst <= 2.0 and miningPos[i].obj then
                        nearAny = i

                        DrawText3D(miningPos[i].pos, "[E] "..miningPos[i].label)
                    
                        if IsControlJustReleased(0, 38) then
                            local p = promise:new()

                            FreezeEntityPosition(myPed, true)

                            local miningAnimation = {
                                dict = "melee@large_wpn@streamed_core",
                                name = "ground_attack_on_spot",
                            }

                            local pickaxeModel = `prop_tool_pickaxe`

                            RequestModel(pickaxeModel)
                            while not HasModelLoaded(pickaxeModel) do
                                Citizen.Wait(1)
                            end

                            local pickaxe = CreateObject(pickaxeModel, 0, 0, 0, true, true, true) 
                            AttachEntityToEntity(pickaxe, myPed, GetPedBoneIndex(myPed, 57005), 0.18, -0.02, -0.02, 350.0, 100.00, 140.0, true, true, false, true, 1, true)

                            RequestAnimDict(miningAnimation.dict)
                            while not HasAnimDictLoaded(miningAnimation.dict) do
                                Citizen.Wait(100)
                            end

                            local animDurr = GetAnimDuration(miningAnimation.dict, miningAnimation.name) * 1000
                            for i = 1, 5 do
                                TaskPlayAnim(myPed, miningAnimation.dict, miningAnimation.name, 8.0, 8.0, -1, 80, 0, 0, 0, 0)
                                
                                Citizen.Wait(animDurr)
                            end

                            ClearPedTasks(myPed)
                            
                            DetachEntity(pickaxe, 1, true)
                            DeleteEntity(pickaxe)

                            DeleteEntity(miningPos[i].obj)

                            Citizen.CreateThread(function()
                                miningPos[i].obj = nil
                                miningPos[i].pick = false
                            end)

                            TriggerServerEvent("rush-mine:breakStone", i, miningPos[i].pick)
                            
                            FreezeEntityPosition(myPed, false)

                            Citizen.Wait(100)
                        end
                    end
                end

                
                if not nearAny then
                    Citizen.Wait(1000)
                end
        
                Citizen.Wait(1)
            elseif wasInMine then
                wasInMine = false
                TriggerServerEvent("rush-mine:exitMine")
            else
                Citizen.Wait(2000)
            end
        end
    end
end)

RegisterNetEvent("rush-mine:spawnCrystal", function(crystalName, stoneId)
    local model = GetHashKey("k4mb1_crystal"..crystalName)

    local color = ""
    if crystalName == "red" then
        color = "~r~Rosu"
    elseif crystalName == "blue" then
        color = "~b~Albastru"
    elseif crystalName == "green" then
        color = "~g~Verde"
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Citizen.Wait(100)
    end

    miningPos[stoneId].crystalObj = CreateObjectNoOffset(model, miningPos[stoneId].pos, true, true, false)
    FreezeEntityPosition(miningPos[stoneId].crystalObj, true)

    while true do
        local dst = #(myPos - miningPos[stoneId].pos)

        if dst <= 2.0 then
            DrawText3D(miningPos[stoneId].pos, "[E] Cristal "..color)

            if IsControlJustReleased(0, 38) then
                ExecuteCommand("e jpickup")
                DeleteEntity(miningPos[stoneId].crystalObj)
                miningPos[stoneId].crystalObj = nil
                TriggerServerEvent("rush-mine:breakCrystal")
                break
            end
        end

        Citizen.Wait(1)
    end
end)

AddEventHandler("onResourceStop", function(resName)
    if resName == GetCurrentResourceName() then
    
        for _, spawn in pairs(miningPos) do
            if spawn.obj then
                DeleteEntity(spawn.obj)
            end

            if spawn.crystalObj then
                DeleteEntity(spawn.crystalObj)
            end
        end
    
    end
end)