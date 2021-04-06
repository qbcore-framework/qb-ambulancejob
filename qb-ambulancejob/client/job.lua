function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

local currentGarage = 1
CreateThread(function()
    while GLOBAL_COORDS == nil do Wait(100); end
    local alreadyEnteredZone = false
    local text = nil
    while true do
        local sleep = 7
        if insideHopsital then
            local inZone = false
            local active = false
            if PlayerJob.name == "ambulance" then
                for k, v in pairs(Config.Locations["duty"]) do
                    local takeAway = vector3(v.x, v.y, v.z)
                    local dist = #(GLOBAL_COORDS - takeAway)
                    if dist <= 3.0 then
                        active = true
                        if dist <= 1.5 then
                            inZone = true
                            if not onDuty then
                                --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - On Duty")
                                text = '[E] - To on duty'
                            else
                                --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~r~E~w~ - Off Duty")
                                text = '[E] - To off duty'
                            end
                            if IsControlJustReleased(0, 38) then -- E
                                onDuty = not onDuty
                                TriggerServerEvent("QBCore:ToggleDuty")
                                TriggerServerEvent("police:server:UpdateBlips")
                                TriggerEvent('qb-interact:HideUI')
                            end
                        end  
                    end
                end

              for k, v in pairs(Config.Locations["outfits"]) do
                    local takeAway = vector3(v.x, v.y, v.z)
                    local dist = #(GLOBAL_COORDS - takeAway)
                    if dist <= 3.0 then
                        active = true
                        if dist <= 1.5 then
                            inZone = true
                            --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Change Outfit")
                            text = '[E] - To change outfit'
                            if IsControlJustReleased(0, 38) then -- E
                                TriggerServerEvent("qb-outfits:server:openUI", true)
                                TriggerEvent('qb-interact:HideUI')
                            end
                        end  
                    end
                end

                for k, v in pairs(Config.Locations["armory"]) do
                    local takeAway = vector3(v.x, v.y, v.z)
                    local dist = #(GLOBAL_COORDS - takeAway)
                    if dist <= 3.0 then
                        active = true
                        if dist <= 1.5 then
                        if onDuty and PlayerJob.isboss then
                            inZone = true
                                --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Safe")
                                text = '[E] - To open safe'
                                if IsControlJustReleased(0, 38) then -- E
                                    TriggerServerEvent("inventory:server:OpenInventory", "shop", "hospital", Config.Items)
                                    TriggerEvent('qb-interact:HideUI')
                                end
                            end  
                        end
                    end
                end
        
                for k, v in pairs(Config.Locations["vehicle"]) do
                    local takeAway = vector3(v.x, v.y, v.z)
                    local dist = #(GLOBAL_COORDS - takeAway)
                    if dist <= 3.0 then
                        active = true
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if dist <= 1.5 then
                            inZone = true
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Store the vehicle")
                                text = '[E] - To store the vehicle'
                            else
                                --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Vehicles")
                                text = '[E] - To open vehicle list'
                            end
                            if IsControlJustReleased(0, 38) then -- E
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                else
                                    MenuGarage()
                                    currentGarage = k
                                    Menu.hidden = not Menu.hidden
                                end
                            end
                            TriggerEvent('qb-interact:HideUI')
                            Menu.renderGUI()
                        end
                    end
                end
        
                for k, v in pairs(Config.Locations["helicopter"]) do
                    local takeAway = vector3(v.x, v.y, v.z)
                    local dist = #(GLOBAL_COORDS - takeAway)
                    if dist <= 3.0 then
                        active = true
                        if onDuty then
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                            if dist <= 1.5 then
                                inZone = true
                                if IsPedInAnyVehicle(PlayerPedId(), false) then
                                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Store the helicopter")
                                    text = '[E] - To store the helicopter'
                                else
                                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Spawn Helicopter")
                                    text = '[E] - To spawn helicopter'
                                end
                                if IsControlJustReleased(0, 38) then -- E
                                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                                        QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    else
                                        local coords = Config.Locations["helicopter"][k]
                                        QBCore.Functions.SpawnVehicle(Config.Helicopter, function(veh)
                                            SetVehicleLivery(veh, 1)
                                            SetVehicleNumberPlateText(veh, "LIFE"..tostring(math.random(1000, 9999)))
                                            SetEntityHeading(veh, coords.h)
                                            exports['qb-hud']:SetFuel(veh, 100)
                                            closeMenuFull()
                                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                            TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
                                            SetVehicleEngineOn(veh, true, true)
                                        end, coords, true)
                                    end
                                    TriggerEvent('qb-interact:HideUI')
                                end
                            end  
                        end
                    end
                end
                
                for k, v in pairs(Config.Locations["boss"]) do
                    local takeAway = vector3(v.x, v.y, v.z)
                    local dist = #(GLOBAL_COORDS - takeAway)
                    if dist <= 3.0 then
                    active = true
                     if dist <= 1.5 then
                        if onDuty and PlayerJob.isboss then
                            inZone = true
                                --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Boss Menu")
                                text = '[E] - To open boss menu'
                                if IsControlJustReleased(0, 38) then -- E
                                    TriggerServerEvent("qb-bossmenu:server:openMenu")
                                    TriggerEvent('qb-interact:HideUI')
                                end
                            end  
                        end
                    end
                end
            else
                sleep = 2000
            end

            local currentHospital = 1

            for k, v in pairs(Config.Locations["main"]) do
                local takeAway = vector3(v.x, v.y, v.z)
                local dist = #(GLOBAL_COORDS - takeAway)
                if dist <= 1.5 then
                    active = true
                    inZone = true
                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Take the elevator to the roof")
                    text = '[E] - To take the elevator to the roof'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('qb-interact:HideUI')
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Wait(10)
                        end

                        currentHospital = k

                        local coords = Config.Locations["roof"][currentHospital]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 0, 0, 0, false)
                        SetEntityHeading(PlayerPedId(), coords.h)

                        Wait(100)

                        DoScreenFadeIn(1000)
                    end
                end
            end

            for k, v in pairs(Config.Locations["roof"]) do
                local takeAway = vector3(v.x, v.y, v.z)
                local dist = #(GLOBAL_COORDS - takeAway)
                if dist <= 1.5 then
                    active = true
                    inZone = true
                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Take the elevator down")
                    text = '[E] - To take the elevator down'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('qb-interact:HideUI')
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Wait(10)
                        end

                        currentHospital = k

                        local coords = Config.Locations["main"][currentHospital]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 0, 0, 0, false)
                        SetEntityHeading(PlayerPedId(), coords.h)

                        Wait(100)

                        DoScreenFadeIn(1000)
                    end
                end
            end

            for k, v in pairs(Config.Locations["up"]) do
                local takeAway = vector3(v.x, v.y, v.z)
                local dist = #(GLOBAL_COORDS - takeAway)
                if dist <= 1.5 then
                    active = true
                    inZone = true
                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Take the elevator to the upper floor")
                    text = '[E] - To take the elevator to the upper floor'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('qb-interact:HideUI')
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Wait(10)
                        end

                        currentHospital = k

                        local coords = Config.Locations["lower"][currentHospital]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 0, 0, 0, false)
                        SetEntityHeading(PlayerPedId(), coords.h)

                        Wait(100)

                        DoScreenFadeIn(1000)
                    end
                end
            end

            for k, v in pairs(Config.Locations["lower"]) do
                local takeAway = vector3(v.x, v.y, v.z)
                local dist = #(GLOBAL_COORDS - takeAway)
                if dist <= 1.5 then
                    active = true
                    inZone = true
                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Take the elevator to the ground floor")
                    text = '[E] - To take the elevator to the ground floor'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('qb-interact:HideUI')
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Wait(10)
                        end

                        currentHospital = k

                        local coords = Config.Locations["up"][currentHospital]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 0, 0, 0, false)
                        SetEntityHeading(PlayerPedId(), coords.h)

                        Wait(100)

                        DoScreenFadeIn(1000)
                    end
                end
            end

            for k, v in pairs(Config.Locations["up1"]) do
                local takeAway = vector3(v.x, v.y, v.z)
                local dist = #(GLOBAL_COORDS - takeAway)
                if dist <= 1.5 then
                    active = true
                    inZone = true
                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Take the elevator to the upper floor")
                    text = '[E] - To take the elevator to the upper floor'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('qb-interact:HideUI')
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Wait(10)
                        end

                        currentHospital = k

                        local coords = Config.Locations["garageparking"][currentHospital]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 0, 0, 0, false)
                        SetEntityHeading(PlayerPedId(), coords.h)

                        Wait(100)

                        DoScreenFadeIn(1000)
                    end
                end
            end

            for k, v in pairs(Config.Locations["garageparking"]) do
                local takeAway = vector3(v.x, v.y, v.z)
                local dist = #(GLOBAL_COORDS - takeAway)
                if dist <= 1.5 then
                    active = true
                    inZone = true
                    --DrawText3D(takeAway.x, takeAway.y, takeAway.z, "~g~E~w~ - Take the elevator to the ground floor")
                    text = '[E] - To take the elevator to the ground floor'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('qb-interact:HideUI')
                        DoScreenFadeOut(500)
                        while not IsScreenFadedOut() do
                            Wait(10)
                        end

                        currentHospital = k

                        local coords = Config.Locations["up1"][currentHospital]
                        SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, 0, 0, 0, false)
                        SetEntityHeading(PlayerPedId(), coords.h)

                        Wait(100)

                        DoScreenFadeIn(1000)
                    end
                end
            end
    
            if inZone and not alreadyEnteredZone then
                active = true
                alreadyEnteredZone = true
                TriggerEvent('qb-interact:ShowUI', 'show', text)
            end
    
            if not inZone and alreadyEnteredZone then
                active = false
                alreadyEnteredZone = false
                TriggerEvent('qb-interact:HideUI')
            end

            if not active then
                sleep = 1000
            end
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isStatusChecking then
            for k, v in pairs(statusChecks) do
                local x,y,z = table.unpack(GetPedBoneCoords(statusCheckPed, v.bone))
                DrawText3D(x, y, z, v.label)
            end
        end

        if isHealingPerson then
            if not IsEntityPlayingAnim(PlayerPedId(), healAnimDict, healAnim, 3) then
                loadAnimDict(healAnimDict)	
                TaskPlayAnim(PlayerPedId(), healAnimDict, healAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end
    end
end)

RegisterNetEvent('hospital:client:SendAlert')
AddEventHandler('hospital:client:SendAlert', function(msg)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    QBCore.Functions.Notify('Pager: '..msg, 'error')
end)

RegisterNetEvent('hospital:client:AiCall')
AddEventHandler('hospital:client:AiCall', function()
    local PlayerPeds = {}
    for _, player in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(player)
        table.insert(PlayerPeds, ped)
    end
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local closestPed, closestDistance = QBCore.Functions.GetClosestPed(coords, PlayerPeds)
    local gender = QBCore.Functions.GetPlayerData().gender
    local s1, s2 = Citizen.InvokeNative(0x2EB41072B4C1E4C0, coords.x, coords.y, coords.z, Citizen.PointerValueInt(), Citizen.PointerValueInt())
    local street1 = GetStreetNameFromHashKey(s1)
    local street2 = GetStreetNameFromHashKey(s2)
    if closestDistance < 50.0 and closestPed ~= 0 then
        MakeCall(closestPed, gender, street1, street2)
    end
end)

function MakeCall(ped, male, street1, street2)
    local callAnimDict = "cellphone@"
    local callAnim = "cellphone_call_listen_base"
    local rand = (math.random(6,9) / 100) + 0.3
    local rand2 = (math.random(6,9) / 100) + 0.3
    local coords = GetEntityCoords(PlayerPedId())
    local blipsettings = {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        sprite = 280,
        color = 4,
        scale = 0.9,
        text = "Injured person"
    }

    if math.random(10) > 5 then
        rand = 0.0 - rand
    end

    if math.random(10) > 5 then
        rand2 = 0.0 - rand2
    end

    local moveto = GetOffsetFromEntityInWorldCoords(PlayerPedId(), rand, rand2, 0.0)

    TaskGoStraightToCoord(ped, moveto, 2.5, -1, 0.0, 0.0)
    SetPedKeepTask(ped, true) 

    local dist = GetDistanceBetweenCoords(moveto, GetEntityCoords(ped), false)

    while dist > 3.5 and isDead do
        TaskGoStraightToCoord(ped, moveto, 2.5, -1, 0.0, 0.0)
        dist = GetDistanceBetweenCoords(moveto, GetEntityCoords(ped), false)
        Citizen.Wait(100)
    end

    ClearPedTasksImmediately(ped)
    TaskLookAtEntity(ped, PlayerPedId(), 5500.0, 2048, 3)
    TaskTurnPedToFaceEntity(ped, PlayerPedId(), 5500)

    Citizen.Wait(3000)

    --TaskStartScenarioInPlace(ped,"WORLD_HUMAN_STAND_MOBILE", 0, 1)
    loadAnimDict(callAnimDict)
    TaskPlayAnim(ped, callAnimDict, callAnim, 1.0, 1.0, -1, 49, 0, 0, 0, 0)

    SetPedKeepTask(ped, true) 

    Citizen.Wait(5000)

    TriggerServerEvent("hospital:server:MakeDeadCall", blipsettings, male, street1, street2)

    SetEntityAsNoLongerNeeded(ped)
    ClearPedTasks(ped)
end

RegisterNetEvent('hospital:client:RevivePlayer')
AddEventHandler('hospital:client:RevivePlayer', function()
    --QBCore.Functions.GetPlayerData(function(PlayerData)
        --if PlayerJob.name == "ambulance" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                --QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                --if result then 
                    local playerId = GetPlayerServerId(player)
                    isHealingPerson = true
                    QBCore.Functions.Progressbar("hospital_revive", "Reviving person..", 5000, false, true, {
                        disableMovement = false,
                        disableCarMovement = false,
                        disableMouse = false,
                        disableCombat = true,
                    }, {
                        animDict = healAnimDict,
                        anim = healAnim,
                        flags = 16,
                    }, {}, {}, function() -- Done
                        isHealingPerson = false
                        StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                        TriggerEvent("DoShortHudText", "You revived the person!")
                        TriggerServerEvent("hospital:server:RevivePlayer", playerId)
                    end, function() -- Cancel
                        isHealingPerson = false
                        StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                        TriggerEvent("DoShortHudText", "Failed!", 2)
                    end)
                else
                    TriggerEvent("DoShortHudText", "You don\'t have medkit on you", 2)
                end
            --end, "medkit")
            else
                QBCore.Functions.Notify('No Player Nearby', 'error')
            end
        --end
    --end)
end)

RegisterNetEvent('hospital:client:CheckStatus')
AddEventHandler('hospital:client:CheckStatus', function()
    --QBCore.Functions.GetPlayerData(function(PlayerData)
        --if PlayerJob.name == "ambulance" or PlayerJob.name == "police" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                statusCheckPed = GetPlayerPed(player)
                QBCore.Functions.TriggerCallback('hospital:GetPlayerStatus', function(result)
                    if result ~= nil then
                        for k, v in pairs(result) do
                            if k ~= "BLEED" and k ~= "WEAPONWOUNDS" then
                                table.insert(statusChecks, {bone = Config.BoneIndexes[k], label = v.label .." (".. Config.WoundStates[v.severity] ..")"})
                            elseif result["WEAPONWOUNDS"] ~= nil then 
                                for k, v in pairs(result["WEAPONWOUNDS"]) do
                                    QBCore.Functions.Notify('Status Check: '..WeaponDamageList[v].., 'error')
                                end
                            elseif result["BLEED"] > 0 then
                                QBCore.Functions.Notify('Status Check: Is '..Config.BleedingStates[v].label, 'error')
                            end
                        end
                        isStatusChecking = true
                        statusCheckTime = Config.CheckTime
                    end
                end, playerId)
            else
                QBCore.Functions.Notify('No Player Nearby', 'error')
            end
        --end
    --end)
end)

RegisterNetEvent('hospital:client:TreatWounds')
AddEventHandler('hospital:client:TreatWounds', function()
    --QBCore.Functions.GetPlayerData(function(PlayerData)
        --if PlayerJob.name == "ambulance" then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                isHealingPerson = true
                QBCore.Functions.Progressbar("hospital_healwounds", "Healing wounds..", 5000, false, true, {
                    disableMovement = false,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = healAnimDict,
                    anim = healAnim,
                    flags = 16,
                }, {}, {}, function() -- Done
                    isHealingPerson = false
                    StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                    TriggerEvent("DoShortHudText", "You helped the person!")
                    TriggerServerEvent("hospital:server:TreatWounds", playerId)
                end, function() -- Cancel
                    isHealingPerson = false
                    StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                    TriggerEvent("DoShortHudText", "Failed!", 2)
                end)
            else
                QBCore.Functions.Notify('No Player Nearby', 'error')
            end
        --end
    --end)
end)

function MenuGarage(isDown)
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("My vehicles", "VehicleList", isDown)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Config.Vehicles) do
        Menu.addButton(Config.Vehicles[k], "TakeOutVehicle", {k, isDown}, "Garage", " Engine: 100%", " Body: 100%", " Fuel: 100%")
    end
        
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
    QBCore.Functions.SpawnVehicle(vehicleInfo[1], function(veh)
        SetVehicleNumberPlateText(veh, "AMBU"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.h)
        exports['qb-hud']:SetFuel(veh, 100.0)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end