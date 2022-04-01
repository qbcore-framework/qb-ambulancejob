local statusCheckPed = nil
local PlayerJob = {}
local onDuty = false
local currentGarage = 1

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

local function DrawText3D(x, y, z, text)
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

function TakeOutVehicle(vehicleInfo)
    local coords = Config.Locations["vehicle"][currentGarage]
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

-- Personal Stash
CreateThread(function()
    Wait(1000)
    while true do
        local sleep = 2000
        if LocalPlayer.state.isLoggedIn and PlayerJob.name == "ambulance" then
            local pos = GetEntityCoords(PlayerPedId())
            for k, v in pairs(Config.Locations["stash"]) do
                if #(pos - v) < 4.5 then
                    if onDuty then
                        sleep = 5
                        if #(pos - v) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('text.pstash_button'))
                            if IsControlJustReleased(0, 38) then
                                TriggerServerEvent("inventory:server:OpenInventory", "stash", "ambulancestash_"..QBCore.Functions.GetPlayerData().citizenid)
                                TriggerEvent("inventory:client:SetCurrentStash", "ambulancestash_"..QBCore.Functions.GetPlayerData().citizenid)
                            end
                        elseif #(pos - v) < 2.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('text.pstash'))
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        Wait(10)
        if isStatusChecking then
            for k, v in pairs(statusChecks) do
                local x,y,z = table.unpack(GetPedBoneCoords(statusCheckPed, v.bone))
                DrawText3D(x, y, z, v.label)
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

CreateThread(function()
    while true do
        sleep = 1000
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            if PlayerJob.name =="ambulance" then
                for k, v in pairs(Config.Locations["duty"]) do
                    local dist = #(pos - v)
                    if dist < 5 then
                        sleep = 0
                        if dist < 1.5 then
                            if onDuty then
                                DrawText3D(v.x, v.y, v.z, Lang:t('text.offduty_button'))
                            else
                                DrawText3D(v.x, v.y, v.z, Lang:t('text.onduty_button'))
                            end
                            if IsControlJustReleased(0, 38) then
                                onDuty = not onDuty
                                TriggerServerEvent("QBCore:ToggleDuty")
                                TriggerServerEvent("police:server:UpdateBlips")
                            end
                        elseif dist < 4.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t('text.duty'))
                        end
                    end
                end

                for k, v in pairs(Config.Locations["armory"]) do
                    local dist = #(pos - v)
                    if dist < 4.5 then
                        if onDuty then
                            if dist < 1.5 then
                                sleep = 0
                                DrawText3D(v.x, v.y, v.z, Lang:t('text.armory_button'))
                                if IsControlJustReleased(0, 38) then
                                    TriggerServerEvent("inventory:server:OpenInventory", "shop", "hospital", Config.Items)
                                end
                            elseif dist < 2.5 then
                                DrawText3D(v.x, v.y, v.z, Lang:t('text.armory'))
                            end
                        end
                    end
                end

                for k, v in pairs(Config.Locations["vehicle"]) do
                    local dist = #(pos - vector3(v.x, v.y, v.z))
                    if dist < 4.5 then
                        sleep = 0
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                        if dist < 1.5 then
                            if IsPedInAnyVehicle(ped, false) then
                                DrawText3D(v.x, v.y, v.z, Lang:t('text.storeveh_button'))
                            else
                                DrawText3D(v.x, v.y, v.z, Lang:t('text.veh_button'))
                            end
                            if IsControlJustReleased(0, 38) then
                                if IsPedInAnyVehicle(ped, false) then
                                    QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
                                else
                                    MenuGarage()
                                    currentGarage = k
                                end
                            end
                        end
                    end
                end

                for k, v in pairs(Config.Locations["helicopter"]) do
                    local dist = #(pos - vector3(v.x, v.y, v.z))
                    if dist < 7.5 then
                        if onDuty then
                            sleep = 5
                            DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 0, 0, 222, false, false, false, true, false, false, false)
                            if dist < 1.5 then
                                if IsPedInAnyVehicle(ped, false) then
                                    DrawText3D(v.x, v.y, v.z, Lang:t('text.storeheli_button'))
                                else
                                    DrawText3D(v.x, v.y, v.z, Lang:t('text.heli_button'))
                                end
                                if IsControlJustReleased(0, 38) then
                                    if IsPedInAnyVehicle(ped, false) then
                                        QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(ped))
                                    else
                                        local coords = Config.Locations["helicopter"][k]
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
                        end
                    end
                end
            end

            local currentHospital = 1

            for k, v in pairs(Config.Locations["main"]) do
                local dist = #(pos - v)
                if dist < 1.5 then
                    sleep = 5
                    DrawText3D(v.x, v.y, v.z, Lang:t('text.elevator_roof'))
                    if IsControlJustReleased(0, 38) then
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

            for k, v in pairs(Config.Locations["roof"]) do
                local dist = #(pos - vector3(v.x, v.y, v.z))
                if dist < 1.5 then
                    sleep = 5
                    DrawText3D(v.x, v.y, v.z, Lang:t('text.elevator_main'))
                    if IsControlJustReleased(0, 38) then
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
        end
        Wait(sleep)
    end
end)