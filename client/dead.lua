local deadAnimDict = "dead"
local deadAnim = "dead_a"
local deadCarAnimDict = "veh@low@front_ps@idle_duck"
local deadCarAnim = "sit"
local hold = 5

deathTime = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local player = PlayerId()
		if NetworkIsPlayerActive(player) then
            local playerPed = PlayerPedId()
            if IsEntityDead(playerPed) and not isDead then
                local killer_2, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
                local killer = GetPedSourceOfDeath(playerPed)
                
                if killer_2 ~= 0 and killer_2 ~= -1 then
                    killer = killer_2
                end

                local killerId = NetworkGetPlayerIndexFromPed(killer)
                local killerName = killerId ~= -1 and GetPlayerName(killerId) .. " " .. "("..GetPlayerServerId(killerId)..")" or "NPC"
                local weaponLabel = PSCore.Shared.Weapons[killerWeapon] ~= nil and PSCore.Shared.Weapons[killerWeapon]["label"] or "Unknown"
                local weaponName = PSCore.Shared.Weapons[killerWeapon] ~= nil and PSCore.Shared.Weapons[killerWeapon]["name"] or "Unknown_Weapon"
                TriggerServerEvent("qb-log:server:CreateLog", "death", GetPlayerName(player) .. " ("..GetPlayerServerId(player)..") Died", "red", "**".. killerName .. "** killed ".. GetPlayerName(player) .." with **".. weaponLabel .. "** (" .. weaponName .. ")")
                deathTime = Config.DeathTime
                OnDeath()
                DeathTimer()
            end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(7)
        local ped = PlayerPedId()
		if isDead then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            EnableControlAction(0, 245, true)
            EnableControlAction(0, 38, true)
            EnableControlAction(0, 0, true)
            EnableControlAction(0, 322, true)
            EnableControlAction(0, 288, true)
            EnableControlAction(0, 213, true)
            
            if isDead then
                if not isInHospitalBed then 
                    if deathTime > 0 then
                        DrawTxt(0.93, 1.44, 1.0,1.0,0.6, "RESPAWN IN: ~b~" .. math.ceil(deathTime) .. "~w~ SECONDS", 255, 255, 255, 255)
                    else
                        DrawTxt(0.865, 1.44, 1.0, 1.0, 0.6, "~w~ HOLD ~w~[~b~E~w~] (~r~"..hold.."~w~)~w~ FOR RESPAWN (~g~€~w~"..Config.BillCost..") OR WAIT FOR EMS", 255, 255, 255, 255)
                    end
                end

                if IsPedInAnyVehicle(ped, false) then
                    loadAnimDict("veh@low@front_ds@idle_duck")
                    if not IsEntityPlayingAnim(ped, "veh@low@front_ds@idle_duck", "steer_lean_left", 3) then
                        TaskPlayAnim(ped, "veh@low@front_ds@idle_duck", "steer_lean_left", 1.0, 8.0, -1, 1, -1, false, false, false)
                    end
                else
                    if isInHospitalBed then 
                        if not IsEntityPlayingAnim(ped, inBedDict, inBedAnim, 3) then
                            loadAnimDict(inBedDict)
                            TaskPlayAnim(ped, inBedDict, inBedAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                        end
                    else
                        if not IsEntityPlayingAnim(ped, deadAnimDict, deadAnim, 3) then
                            loadAnimDict(deadAnimDict)
                            TaskPlayAnim(ped, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                        end
                    end
                end

                SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
            end
		else
			Citizen.Wait(500)
		end
	end
end)


function OnDeath(spawn)
    if not isDead then
        isDead = true
        TriggerServerEvent("hospital:server:SetDeathStatus", true)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
        local player = PlayerPedId()

        if isDead then
            local pos = GetEntityCoords(player)
            local heading = GetEntityHeading(player)


            NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
            SetEntityInvincible(player, true)
            if IsPedInAnyVehicle(player, false) then
                loadAnimDict("veh@low@front_ds@idle_duck")
                TaskPlayAnim(player, "veh@low@front_ds@idle_duck", "steer_lean_left", 1.0, 8.0, -1, 1, -1, false, false, false)
            else
                loadAnimDict(deadAnimDict)
                TaskPlayAnim(player, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
            end
            TriggerEvent("hospital:client:AiCall")
        end
    end
end

function DeathTimer()
    hold = 5
    while isDead do
        Citizen.Wait(1000)
        deathTime = deathTime - 1

        if deathTime <= 0 then
            if IsControlPressed(0, 38) and hold <= 0 and not isInHospitalBed then
                TriggerEvent("hospital:client:RespawnAtHospital")
                hold = 5
            end

            if IsControlPressed(0, 38) then
                if hold - 1 >= 0 then
                    hold = hold - 1
                else
                    hold = 0
                end
            end

            if IsControlReleased(0, 38) then
                hold = 5
            end
        end
    end
end

function DrawTxt(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end
