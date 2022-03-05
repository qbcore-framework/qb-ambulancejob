local statusCheckPed = nil
local PlayerJob = {}
local onDuty = false
local currentGarage = 1
local inDuty = false
local inStash = false
local inArmory = false
local inVehicle = false
local inHeli = false
local onRoof = false
local inMain = false


-- Functions

local function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

local function GetClosestPlayer()
    local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
    local closestDistance = -1
    local closestPlayer = -1
    local coords = GetEntityCoords(PlayerPedId())

    for i=1, #closestPlayers, 1 do
        if closestPlayers[i] ~= PlayerId() then
            local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
            local distance = #(pos - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = closestPlayers[i]
                closestDistance = distance
            end
        end
	end
	return closestPlayer, closestDistance
end

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][1]
    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, Lang:t('info.amb_plate')..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        if Config.VehicleSettings[vehicleInfo] ~= nil then
            QBCore.Shared.SetDefaultVehicleExtras(veh, Config.VehicleSettings[vehicleInfo].extras)
        end
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
    end, coords, true)
end

function MenuGarage()
    local vehicleMenu = {
        {
            header = Lang:t('menu.amb_vehicles'),
            isMenuHeader = true
        }
    }

    local authorizedVehicles = Config.AuthorizedVehicles[QBCore.Functions.GetPlayerData().job.grade.level]
    for veh, label in pairs(authorizedVehicles) do
        vehicleMenu[#vehicleMenu+1] = {
            header = label,
            txt = "",
            params = {
                event = "ambulance:client:TakeOutVehicle",
                args = {
                    vehicle = veh
                }
            }
        }
    end
    vehicleMenu[#vehicleMenu+1] = {
        header = Lang:t('menu.close'),
        txt = "",
        params = {
            event = "qb-menu:client:closeMenu"
        }

    }
    exports['qb-menu']:openMenu(vehicleMenu)
end

-- Events

RegisterNetEvent('ambulance:client:TakeOutVehicle', function(data)
    local vehicle = data.vehicle
    TakeOutVehicle(vehicle)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    TriggerServerEvent("hospital:server:SetDoctor")
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    exports.spawnmanager:setAutoSpawn(false)
    local ped = PlayerPedId()
    local player = PlayerId()
    TriggerServerEvent("hospital:server:SetDoctor")
    CreateThread(function()
        Wait(5000)
        SetEntityMaxHealth(ped, 200)
        SetEntityHealth(ped, 200)
        SetPlayerHealthRechargeMultiplier(player, 0.0)
        SetPlayerHealthRechargeLimit(player, 0.0)
    end)
    CreateThread(function()
        Wait(1000)
        QBCore.Functions.GetPlayerData(function(PlayerData)
            PlayerJob = PlayerData.job
            onDuty = PlayerData.job.onduty
            SetPedArmour(PlayerPedId(), PlayerData.metadata["armor"])
            if (not PlayerData.metadata["inlaststand"] and PlayerData.metadata["isdead"]) then
                deathTime = Laststand.ReviveInterval
                OnDeath()
                DeathTimer()
            elseif (PlayerData.metadata["inlaststand"] and not PlayerData.metadata["isdead"]) then
                SetLaststand(true, true)
            else
                TriggerServerEvent("hospital:server:SetDeathStatus", false)
                TriggerServerEvent("hospital:server:SetLaststandStatus", false)
            end
        end)
    end)
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
    TriggerServerEvent("hospital:server:SetDoctor")
end)

RegisterNetEvent('hospital:client:CheckStatus', function()
    local player, distance = GetClosestPlayer()
    if player ~= -1 and distance < 5.0 then
        local playerId = GetPlayerServerId(player)
        statusCheckPed = GetPlayerPed(player)
        QBCore.Functions.TriggerCallback('hospital:GetPlayerStatus', function(result)
            if result then
                for k, v in pairs(result) do
                    if k ~= "BLEED" and k ~= "WEAPONWOUNDS" then
                        statusChecks[#statusChecks+1] = {bone = Config.BoneIndexes[k], label = v.label .." (".. Config.WoundStates[v.severity] ..")"}
                    elseif result["WEAPONWOUNDS"] then
                        for k, v in pairs(result["WEAPONWOUNDS"]) do
                            TriggerEvent('chat:addMessage', {
                                color = { 255, 0, 0},
                                multiline = false,
                                args = {Lang:t('info.status'), WeaponDamageList[v]}
                            })
                        end
                    elseif result["BLEED"] > 0 then
                        TriggerEvent('chat:addMessage', {
                            color = { 255, 0, 0},
                            multiline = false,
                            args = {Lang:t('info.status'), Lang:t('info.is_status', {status = Config.BleedingStates[v].label})}
                        })
                    else
                        QBCore.Functions.Notify(Lang:t('success.healthy_player'), 'success')
                    end
                end
                isStatusChecking = true
                statusCheckTime = Config.CheckTime
            end
        end, playerId)
    else
        QBCore.Functions.Notify(Lang:t('error.no_player'), 'error')
    end
end)

RegisterNetEvent('hospital:client:RevivePlayer', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                isHealingPerson = true
                QBCore.Functions.Progressbar("hospital_revive", Lang:t('progress.revive'), 5000, false, true, {
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
                    QBCore.Functions.Notify(Lang:t('success.revived'), 'success')
                    TriggerServerEvent("hospital:server:RevivePlayer", playerId)
                end, function() -- Cancel
                    isHealingPerson = false
                    StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                    QBCore.Functions.Notify(Lang:t('error.cancled'), "error")
                end)
            else
                QBCore.Functions.Notify(Lang:t('error.no_player'), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t('error.no_firstaid'), "error")
        end
    end, 'firstaid')
end)

RegisterNetEvent('hospital:client:TreatWounds', function()
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasItem)
        if hasItem then
            local player, distance = GetClosestPlayer()
            if player ~= -1 and distance < 5.0 then
                local playerId = GetPlayerServerId(player)
                isHealingPerson = true
                QBCore.Functions.Progressbar("hospital_healwounds", Lang:t('progress.healing'), 5000, false, true, {
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
                    QBCore.Functions.Notify(Lang:t('success.helped_player'), 'success')
                    TriggerServerEvent("hospital:server:TreatWounds", playerId)
                end, function() -- Cancel
                    isHealingPerson = false
                    StopAnimTask(PlayerPedId(), healAnimDict, "exit", 1.0)
                    QBCore.Functions.Notify(Lang:t('error.canceled'), "error")
                end)
            else
                QBCore.Functions.Notify(Lang:t('error.no_player'), "error")
            end
        else
            QBCore.Functions.Notify(Lang:t('error.no_bandage'), "error")
        end
    end, 'bandage')
end)

-- Threads

CreateThread(function()
    while true do
        Wait(10)
        if isStatusChecking then
            for k, v in pairs(statusChecks) do
                local x,y,z = table.unpack(GetPedBoneCoords(statusCheckPed, v.bone))
                exports['qb-core']:DrawText('x ' ..x.. ' y ' ..y.. ' z ' ..z.. ' bone ' ..v.bone, 'left')
            end
        end
        if isHealingPerson then
            local ped = PlayerPedId()
            if not IsEntityPlayingAnim(ped, healAnimDict, healAnim, 3) then
                loadAnimDict(healAnimDict)
                TaskPlayAnim(ped, healAnimDict, healAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end
    end
end)

if Config.UseTarget then
    CreateThread(function()
        for k, v in pairs(Config.Locations["duty"]) do
            exports['qb-target']:AddBoxZone("duty"..k, vector3(v.x, v.y, v.z), 1, 1, {
                name = "duty"..k,
                debugPoly = false,
                heading = -20,
                minZ = 41,
                maxZ = 45,
            }, {
                options = {
                    {
                        type = "client",
                        event = "EMSToggle:Duty",
                        icon = "fa fa-clipboard",
                        label = "Sign In/Off duty",
                        job = "ambulance"
                    }
                },
                distance = 1.5
            })
        end
    end)
    RegisterNetEvent('EMSToggle:Duty', function()
        onDuty = not onDuty
        TriggerServerEvent("QBCore:ToggleDuty")
        TriggerServerEvent("police:server:UpdateBlips")
    end)
    CreateThread(function()
        for k, v in pairs(Config.Locations["stash"]) do
            exports['qb-target']:AddBoxZone("stash"..k, vector3(v.x, v.y, v.z), 1, 1, {
                name = "stash"..k,
                debugPoly = false,
                heading = -20,
                minZ = 41,
                maxZ = 45,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-ambulancejob:stash",
                        icon = "fa fa-hand",
                        label = "Open Stash",
                        job = "ambulance"
                    }
                },
                distance = 1.5
            })
        end
    end)
    RegisterNetEvent('qb-ambulancejob:stash', function()
        if onDuty then
            TriggerServerEvent("inventory:server:OpenInventory", "stash", "ambulancestash_"..QBCore.Functions.GetPlayerData().citizenid)
            TriggerEvent("inventory:client:SetCurrentStash", "ambulancestash_"..QBCore.Functions.GetPlayerData().citizenid)
        end
    end)
    CreateThread(function()
        for k, v in pairs(Config.Locations["armory"]) do
            exports['qb-target']:AddBoxZone("armory"..k, vector3(v.x, v.y, v.z), 1, 1, {
                name = "armory"..k,
                debugPoly = false,
                heading = -20,
                minZ = 41,
                maxZ = 45,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-ambulancejob:armory",
                        icon = "fa fa-hand",
                        label = "Open Armory",
                        job = "ambulance"
                    }
                },
                distance = 1.5
            })
        end
    end)
    RegisterNetEvent('qb-ambulancejob:armory', function()
        if onDuty then
            TriggerServerEvent("inventory:server:OpenInventory", "shop", "hospital", Config.Items)
        end
    end)
    CreateThread(function()
        for k, v in pairs(Config.Locations["vehicle"]) do
            exports['qb-target']:AddBoxZone("vehicle"..k, vector3(v.x, v.y, v.z), 5, 5, {
                name = "vehicle"..k,
                debugPoly = false,
                heading = -20,
                minZ = 41,
                maxZ = 45,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-ambulancejob:viewvehicle",
                        icon = "fas fa-ambulance",
                        label = "View Garage list",
                        job = "ambulance"
                    },
                    {
                        type = "client",
                        event = "qb-ambulancejob:storevehicle",
                        icon = "fas fa-ambulance",
                        label = "Store vehicle",
                        job = "ambulance"
                        
                    }
                },
                distance = 8
            })
        end
    end)
    RegisterNetEvent('qb-ambulancejob:viewvehicle', function()
        for k, v in pairs(Config.Locations["vehicle"]) do
            if PlayerJob.name =="ambulance" and onDuty then
                MenuGarage()
                currentGarage = k
            end
        end
    end)
    RegisterNetEvent('qb-ambulancejob:storevehicle', function()
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
        end
    end)
    CreateThread(function()
        for k, v in pairs(Config.Locations["helicopter"]) do
            exports['qb-target']:AddBoxZone("helicopter"..k, vector3(v.x, v.y, v.z), 5, 5, {
                name = "helicopter"..k,
                debugPoly = false,
                heading = -20,
                minZ = 72,
                maxZ = 75,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-ambulancejob:pullheli",
                        icon = "fas fa-helicopter",
                        label = "Take out Helicopter",
                        job = "ambulance"
                    },
                    {
                        type = "client",
                        event = "qb-ambulancejob:storeheli",
                        icon = "fa fa-hand",
                        label = "Store Helicopter",
                        job = "ambulance"
                        
                    }
                },
                distance = 8
            })
        end
    end)
    RegisterNetEvent('qb-ambulancejob:pullheli', function()
        local coords = Config.Locations["helicopter"][currentGarage]
        local ped = PlayerPedId()
        QBCore.Functions.SpawnVehicle(Config.Helicopter, function(veh)
            SetVehicleNumberPlateText(veh, Lang:t('info.heli_plate')..tostring(math.random(1000, 9999)))
            SetEntityHeading(veh, coords.w)
            SetVehicleLivery(veh, 1) -- Ambulance Livery
            exports['LegacyFuel']:SetFuel(veh, 100.0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
            SetVehicleEngineOn(veh, true, true)
        end, coords, true)
    end)
    RegisterNetEvent('qb-ambulancejob:storeheli', function()
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
        end
    end)
    CreateThread(function()
        for k, v in pairs(Config.Locations["roof"]) do
            exports['qb-target']:AddBoxZone("roof"..k, vector3(v.x, v.y, v.z), 2, 2, {
                name = "roof"..k,
                debugPoly = false,
                heading = -20,
                minZ = 72,
                maxZ = 75,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-ambulancejob:elevator_roof",
                        icon = "fas fa-hand-point-up",
                        label = "Take Elevator",
                        job = "ambulance"
                    },
                },
                distance = 8
            })
        end
    end)
    RegisterNetEvent('qb-ambulancejob:elevator_roof', function()
        local ped = PlayerPedId()
        for k, v in pairs(Config.Locations["roof"])do
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do
                Wait(10)
            end

            currentHospital = k

            local coords = Config.Locations["main"][currentHospital]
            SetEntityCoords(ped, coords.x, coords.y, coords.z, 0, 0, 0, false)
            SetEntityHeading(ped, coords.w)

            Wait(100)

            DoScreenFadeIn(1000)
        end
    end)
    CreateThread(function()
        for k, v in pairs(Config.Locations["main"]) do
            exports['qb-target']:AddBoxZone("main"..k, vector3(v.x, v.y, v.z), 2, 2, {
                name = "main"..k,
                debugPoly = false,
                heading = -20,
                minZ = 42,
                maxZ = 44.50,
            }, {
                options = {
                    {
                        type = "client",
                        event = "qb-ambulancejob:elevator_main",
                        icon = "fas fa-hand-point-up",
                        label = "Take Elevator",
                        job = "ambulance"
                    },
                },
                distance = 8
            })
        end
    end)
    RegisterNetEvent('qb-ambulancejob:elevator_main', function()
        local ped = PlayerPedId()
        for k, v in pairs(Config.Locations["main"])do
            DoScreenFadeOut(500)
            while not IsScreenFadedOut() do
                Wait(10)
            end

            currentHospital = k

            local coords = Config.Locations["roof"][currentHospital]
            SetEntityCoords(ped, coords.x, coords.y, coords.z, 0, 0, 0, false)
            SetEntityHeading(ped, coords.w)

            Wait(100)

            DoScreenFadeIn(1000)
        end
    end)
else
    CreateThread(function()
        local signPoly = {}
        for k, v in pairs(Config.Locations["duty"]) do
            signPoly[#signPoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 1, 1, {
                name="sign" .. k,
                debugPoly = false,
                heading = -20,
                minZ = 41,
                maxZ = 45,
            })
        end

        local signCombo = ComboZone:Create(signPoly, {name = "signCombo", debugPoly = false})
        signCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inDuty = true
                if not onDuty and PlayerJob.name =="ambulance" then
                    exports['qb-core']:DrawText(Lang:t('text.onduty_button'),'left')
                else
                    exports['qb-core']:DrawText(Lang:t('text.offduty_button'),'left')
                end
            else
                inDuty = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
                if inDuty then
                    sleep = 5
                    if IsControlJustReleased(0, 38) then
                        exports['qb-core']:KeyPressed(38)
                        onDuty = not onDuty
                        TriggerServerEvent("QBCore:ToggleDuty")
                        TriggerServerEvent("police:server:UpdateBlips")
                    end
                end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        local stashPoly = {}
        for k, v in pairs(Config.Locations["stash"]) do
            stashPoly[#stashPoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 1, 1, {
                name="stash" .. k,
                debugPoly = false,
                heading = -20,
                minZ = 41,
                maxZ = 44.50,
            })
        end

        local stashCombo = ComboZone:Create(stashPoly, {name = "stashCombo", debugPoly = false})
        stashCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inStash = true
                if onDuty and PlayerJob.name =="ambulance" then
                    exports['qb-core']:DrawText(Lang:t('text.pstash_button'),'left')
                end
            else
                inStash = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
                if inStash then
                    sleep = 5
                    if IsControlJustReleased(0, 38) then
                        exports['qb-core']:KeyPressed(38)
                        TriggerServerEvent("inventory:server:OpenInventory", "stash", "ambulancestash_"..QBCore.Functions.GetPlayerData().citizenid)
                        TriggerEvent("inventory:client:SetCurrentStash", "ambulancestash_"..QBCore.Functions.GetPlayerData().citizenid)
                    end
                end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        local armoryPoly = {}
        for k, v in pairs(Config.Locations["armory"]) do
            armoryPoly[#armoryPoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 1, 1, {
                name="armory" .. k,
                debugPoly = false,
                heading = 70,
                minZ = 41,
                maxZ = 44.50,
            })
        end

        local armoryCombo = ComboZone:Create(armoryPoly, {name = "armoryCombo", debugPoly = false})
        armoryCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inArmory = true
                if onDuty and PlayerJob.name =="ambulance" then
                    exports['qb-core']:DrawText(Lang:t('text.armory_button'),'left')
                end
            else
                inArmory = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
                if inArmory then
                    sleep = 5
                    if IsControlJustReleased(0, 38) then
                        exports['qb-core']:KeyPressed(38)
                        TriggerServerEvent("inventory:server:OpenInventory", "shop", "hospital", Config.Items)
                    end
                end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        local vehiclePoly = {}
        for k, v in pairs(Config.Locations["vehicle"]) do
            vehiclePoly[#vehiclePoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 5, 5, {
                name="vehicle" .. k,
                debugPoly = false,
                heading = 70,
                minZ = 41,
                maxZ = 44.50,
            })
        end

        local ped = PlayerPedId()
        local vehicleCombo = ComboZone:Create(vehiclePoly, {name = "vehicleCombo", debugPoly = false})
        vehicleCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inVehicle = true
                if onDuty and IsPedInAnyVehicle(ped, false) and PlayerJob.name =="ambulance" then
                    exports['qb-core']:DrawText(Lang:t('text.storeveh_button'), 'left')
                else
                    exports['qb-core']:DrawText(Lang:t('text.veh_button'), 'left')
                end
            else
                inVehicle = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
            local ped = PlayerPedId()
                if inVehicle then
                    for k, v in pairs(Config.Locations["vehicle"]) do
                        sleep = 5
                        if IsControlJustReleased(0, 38) then
                            exports['qb-core']:KeyPressed(38)
                            if IsPedInAnyVehicle(ped, false) then
                                QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
                            else
                                MenuGarage()
                                currentGarage = k
                            end
                        end
                    end
                end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        local helicopterPoly = {}
        for k, v in pairs(Config.Locations["helicopter"]) do
            helicopterPoly[#helicopterPoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 5, 5, {
                name="helicopter" .. k,
                debugPoly = false,
                heading = 70,
                minZ = 72,
                maxZ = 75,
            })
        end

        local ped = PlayerPedId()
        local helicopterCombo = ComboZone:Create(helicopterPoly, {name = "helicopterCombo", debugPoly = false})
        helicopterCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inHeli = true
                if onDuty and IsPedInAnyVehicle(ped, false) and PlayerJob.name =="ambulance" then
                    exports['qb-core']:DrawText(Lang:t('text.storeheli_button'), 'left')
                else
                    exports['qb-core']:DrawText(Lang:t('text.heli_button'), 'left')
                end
            else
                inHeli = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
            local ped = PlayerPedId()
                if inHeli then
                    sleep = 5
                    if IsControlJustReleased(0, 38) then
                        exports['qb-core']:KeyPressed(38)
                        if IsPedInAnyVehicle(ped, false) and PlayerJob.name =="ambulance" then
                            QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
                        else
                            local coords = Config.Locations["helicopter"][currentGarage]
                            QBCore.Functions.SpawnVehicle(Config.Helicopter, function(veh)
                                SetVehicleNumberPlateText(veh, Lang:t('info.heli_plate')..tostring(math.random(1000, 9999)))
                                SetEntityHeading(veh, coords.w)
                                SetVehicleLivery(veh, 1) -- Ambulance Livery
                                exports['LegacyFuel']:SetFuel(veh, 100.0)
                                TaskWarpPedIntoVehicle(ped, veh, -1)
                                TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                                SetVehicleEngineOn(veh, true, true)
                            end, coords, true)
                        end
                    end
                end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        local roofPoly = {}
        for k, v in pairs(Config.Locations["roof"]) do
            roofPoly[#roofPoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 2, 2, {
                name="roof" .. k,
                debugPoly = false,
                heading = 70,
                minZ = 71,
                maxZ = 75.50,
            })
        end

        local roofCombo = ComboZone:Create(roofPoly, {name = "roofCombo", debugPoly = false})
        roofCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                onRoof = true
                if onDuty then
                    exports['qb-core']:DrawText(Lang:t('text.elevator_main'),'left')
                else
                    exports['qb-core']:DrawText(Lang:t('error.not_ems'),'left')
                end
            else
                onRoof = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
            local ped = PlayerPedId()
                if onRoof then
                    for k, v in pairs(Config.Locations["roof"]) do
                        sleep = 5
                        if PlayerJob.name =="ambulance" and IsControlJustReleased(0, 38) then
                            exports['qb-core']:KeyPressed(38)
                            DoScreenFadeOut(500)
                            while not IsScreenFadedOut() do
                                Wait(10)
                            end

                            currentHospital = k

                            local coords = Config.Locations["main"][currentHospital]
                            SetEntityCoords(ped, coords.x, coords.y, coords.z, 0, 0, 0, false)
                            SetEntityHeading(ped, coords.w)

                            Wait(100)

                            DoScreenFadeIn(1000)
                        end
                    end
                end
            Wait(sleep)
        end
    end)
    CreateThread(function()
        local mainPoly = {}
        for k, v in pairs(Config.Locations["main"]) do
            mainPoly[#mainPoly+1] = BoxZone:Create(
                vector3(vector3(v.x, v.y, v.z)), 2, 2, {
                name="main" .. k,
                debugPoly = false,
                heading = 70,
                minZ = 41,
                maxZ = 44.50,
            })
        end

        local mainCombo = ComboZone:Create(mainPoly, {name = "mainPoly", debugPoly = false})
        mainCombo:onPlayerInOut(function(isPointInside)
            if isPointInside then
                inMain = true
                if onDuty then
                    exports['qb-core']:DrawText(Lang:t('text.elevator_roof'),'left')
                else
                    exports['qb-core']:DrawText(Lang:t('error.not_ems'),'left')
                end
            else
                inMain = false
                exports['qb-core']:HideText()
            end
        end)
    end)
    CreateThread(function()
        while true do
            local sleep = 1000
            local ped = PlayerPedId()
                if onRoof then
                    for k, v in pairs(Config.Locations["main"]) do
                        sleep = 5
                        if PlayerJob.name =="ambulance" and  IsControlJustReleased(0, 38) then
                            exports['qb-core']:KeyPressed(38)
                            DoScreenFadeOut(500)
                            while not IsScreenFadedOut() do
                                Wait(10)
                            end

                            currentHospital = k

                            local coords = Config.Locations["roof"][currentHospital]
                            SetEntityCoords(ped, coords.x, coords.y, coords.z, 0, 0, 0, false)
                            SetEntityHeading(ped, coords.w)

                            Wait(100)

                            DoScreenFadeIn(1000)
                        end
                    end
                end
            Wait(sleep)
        end
    end)
end