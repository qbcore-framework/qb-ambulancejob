local deadAnimDict = "dead"
local deadAnim = "dead_a"
local deadCarAnimDict = "veh@low@front_ps@idle_duck"
local deadCarAnim = "sit"
local hold = 5

deathTime = 0

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local player = PlayerId()
		if NetworkIsPlayerActive(player) then
			local playerPed = PlayerPedId()
			if IsEntityDead(playerPed) and not isDead then
				local killer, killerWeapon = NetworkGetEntityKillerOfPlayer(player)
                local killerId = NetworkGetPlayerIndexFromPed(killer)
                local killerName = killerId ~= -1 and GetPlayerName(killerId) .. " " .. "("..GetPlayerServerId(killerId)..")" or "His self or NPC"
                local weaponLabel = QBCore.Shared.Weapons[killerWeapon] ~= nil and QBCore.Shared.Weapons[killerWeapon]["label"] or "Unknown"
                local weaponName = QBCore.Shared.Weapons[killerWeapon] ~= nil and QBCore.Shared.Weapons[killerWeapon]["name"] or "Unknown_Weapon"
                TriggerServerEvent("qb-log:server:CreateLog", "death", GetPlayerName(player) .. " ("..GetPlayerServerId(player)..") is dead", "red", "**".. killerName .. "** is ".. GetPlayerName(player) .." murdered with a **".. weaponLabel .. "** (" .. weaponName .. ")")
 
                deathTime = Config.DeathTime

                OnDeath()
                
                DeathTimer()
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if isDead then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
			EnableControlAction(0, 2, true)
			EnableControlAction(0, 245, true) -- T
            EnableControlAction(0, 38, true) -- E
            EnableControlAction(0, 0, true) -- V
            EnableControlAction(0, 249, true) -- N
            EnableControlAction(0, 322, true) -- ESC
            EnableControlAction(0, 288, true) -- F1
            EnableControlAction(0, 213, true) -- HOME
			EnableControlAction(0, 303, true) -- U
			EnableControlAction(0, 244, true) -- M
            
            if not isInHospitalBed then 
                if deathTime > 0 then
                    DrawTxt(0.89, 1.44, 1.0,1.0,0.6, "RESPAWN IN: ~r~" .. math.ceil(deathTime) .. "~w~ SECONDS", 255, 255, 255, 255)
                else
                    DrawTxt(0.89, 1.44, 1.0,1.0,0.6, "~w~ KEEP ~r~E ~w~PRESSED TO RESPAWN ($"..Config.BillCost..")", 255, 255, 255, 255)
                end
            end

            if IsPedInAnyVehicle(PlayerPedId(), false) then
                loadAnimDict("veh@low@front_ps@idle_duck")
                if not IsEntityPlayingAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 3) then
                    TaskPlayAnim(PlayerPedId(), "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                end
            else
                if isInHospitalBed then 
                    if not IsEntityPlayingAnim(PlayerPedId(), inBedDict, inBedAnim, 3) then
                        loadAnimDict(inBedDict)
                        TaskPlayAnim(PlayerPedId(), inBedDict, inBedAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                    end
                else
                    if not IsEntityPlayingAnim(PlayerPedId(), deadAnimDict, deadAnim, 3) then
                        loadAnimDict(deadAnimDict)
                        TaskPlayAnim(PlayerPedId(), deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, 0, 0, 0)
                    end
                end
            end

            SetCurrentPedWeapon(PlayerPedId(), GetHashKey("WEAPON_UNARMED"), true)
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

        while GetEntitySpeed(player) > 0.5 or IsPedRagdoll(player) do
            Citizen.Wait(10)
        end

        if isDead then
            local pos = GetEntityCoords(player)
            local heading = GetEntityHeading(player)


            NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z + 0.5, heading, true, false)
            SetEntityInvincible(player, true)
            SetEntityHealth(player, GetEntityMaxHealth(PlayerPedId()))
            if IsPedInAnyVehicle(PlayerPedId(), false) then
                loadAnimDict("veh@low@front_ps@idle_duck")
                TaskPlayAnim(player, "veh@low@front_ps@idle_duck", "sit", 1.0, 1.0, -1, 1, 0, 0, 0, 0)
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

