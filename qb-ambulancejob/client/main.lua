Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, 
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, 
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, 
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

DoScreenFadeIn(100)

inBedDict = "misslamar1dead_body"
inBedAnim = "dead_idle"

getOutDict = 'switch@franklin@bed'
getOutAnim = 'sleep_getup_rubeyes'

isLoggedIn = false

isInHospitalBed = false
canLeaveBed = true

bedOccupying = nil
bedObject = nil
bedOccupyingData = nil
currentTp = nil
usedHiddenRev = false

isBleeding = 0
bleedTickTimer, advanceBleedTimer = 0, 0
fadeOutTimer, blackoutTimer = 0, 0

legCount = 0
armcount = 0
headCount = 0

playerHealth = nil
playerArmour = nil

isDead = false
inCarry = false

patient = false
recovering = false
injuredTime = 0

closestBed = nil

isStatusChecking = false
statusChecks = {}
statusCheckPed = nil
statusCheckTime = 0

isHealingPerson = false
healAnimDict = "mini@cpr@char_a@cpr_str"
healAnim = "cpr_pumpchest"

doctorsSet = false
doctorCount = 0

PlayerJob = {}
onDuty = false
insideHopsital = false

BodyParts = {
    ['HEAD'] = { label = 'head', causeLimp = false, isDamaged = false, severity = 0 },
    ['NECK'] = { label = 'neck', causeLimp = false, isDamaged = false, severity = 0 },
    ['SPINE'] = { label = 'spine', causeLimp = true, isDamaged = false, severity = 0 },
    ['UPPER_BODY'] = { label = 'upper body', causeLimp = false, isDamaged = false, severity = 0 },
    ['LOWER_BODY'] = { label = 'lower body', causeLimp = true, isDamaged = false, severity = 0 },
    ['LARM'] = { label = 'left arm', causeLimp = false, isDamaged = false, severity = 0 },
    ['LHAND'] = { label = 'left hand', causeLimp = false, isDamaged = false, severity = 0 },
    ['LFINGER'] = { label = 'left fingers', causeLimp = false, isDamaged = false, severity = 0 },
    ['LLEG'] = { label = 'left leg', causeLimp = true, isDamaged = false, severity = 0 },
    ['LFOOT'] = { label = 'left foot', causeLimp = true, isDamaged = false, severity = 0 },
    ['RARM'] = { label = 'right arm', causeLimp = false, isDamaged = false, severity = 0 },
    ['RHAND'] = { label = 'right hand', causeLimp = false, isDamaged = false, severity = 0 },
    ['RFINGER'] = { label = 'right fingers', causeLimp = false, isDamaged = false, severity = 0 },
    ['RLEG'] = { label = 'right leg', causeLimp = true, isDamaged = false, severity = 0 },
    ['RFOOT'] = { label = 'right foot', causeLimp = true, isDamaged = false, severity = 0 },
}

injured = {}

QBCore = nil
Citizen.CreateThread(function() 
    while QBCore == nil do
        TriggerEvent("QBCore:GetObject", function(obj) QBCore = obj end)    
        Citizen.Wait(200)
    end
end)

RegisterNetEvent("qb-carry:beingCarried")
AddEventHandler("qb-carry:beingCarried", function(bool)
    inCarry = bool
end)

CreateThread(function()
    while true do
        pedId = PlayerPedId()
        plyId = PlayerId()
        Wait(5000)
    end
end)

CreateThread(function()
    while true do
        if pedId then
            GLOBAL_COORDS = GetEntityCoords(pedId)
        end
        Wait(200)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        local armor = GetPedArmour(ped)

        if not playerHealth then
            playerHealth = health
        end

        if not playerArmor then
            playerArmor = armor
        end

        local armorDamaged = (playerArmor ~= armor and armor < (playerArmor - Config.ArmorDamage) and armor > 0) -- Players armor was damaged
        local healthDamaged = (playerHealth ~= health) -- Players health was damaged

        local damageDone = (playerHealth - health)

        if armorDamaged or healthDamaged then
            local hit, bone = GetPedLastDamageBone(ped)
            local bodypart = Config.Bones[bone]
            local weapon = GetDamagingWeapon(ped)

            if hit and bodypart ~= 'NONE' then
                local checkDamage = true
                if damageDone >= Config.HealthDamage then
                    if weapon ~= nil then
                        if armorDamaged and (bodypart == 'SPINE' or bodypart == 'UPPER_BODY') or weapon == Config.WeaponClasses['NOTHING'] then
                            checkDamage = false -- Don't check damage if the it was a body shot and the weapon class isn't that strong
                            if armorDamaged then
                                TriggerServerEvent("hospital:server:SetArmor", GetPedArmour(PlayerPedId()))
                            end
                        end
    
                        if checkDamage then
    
                            if IsDamagingEvent(damageDone, weapon) then
                                CheckDamage(ped, bone, weapon, damageDone)
                            end
                        end
                    end
                elseif Config.AlwaysBleedChanceWeapons[weapon] then
                    if armorDamaged and (bodypart == 'SPINE' or bodypart == 'UPPER_BODY') or weapon == Config.WeaponClasses['NOTHING'] then
                        checkDamage = false -- Don't check damage if the it was a body shot and the weapon class isn't that strong
                    end
                    if math.random(100) < Config.AlwaysBleedChance and checkDamage then
                        ApplyBleed(1)
                    end
                end
            end

            CheckWeaponDamage(ped)
        end

        playerHealth = health
        playerArmor = armor

        if not isInHospitalBed then
            ProcessDamage(ped)
        end
        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait((1000 * Config.MessageTimer))
        DoLimbAlert()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        SetClosestBed()
        if isStatusChecking then
            statusCheckTime = statusCheckTime - 1
            if statusCheckTime <= 0 then
                statusChecks = {}
                isStatusChecking = false
            end
        end
    end
end)

RegisterNetEvent('hospital:client:injurystart')
AddEventHandler('hospital:client:injurystart', function(time)
	TriggerEvent("DoShortHudText", "You are injured please take a rest", 2)
	recovering = true
	injuredTime = time
	TriggerServerEvent("hospital:server:SetInjuredStatus", injuredTime)
end)

CreateThread(function()
	while true do 
        Wait(7)
        if injuredTime > 0 and recovering then
            Wait(1000 * 60)
			if injuredTime > 0 and recovering then
                injuredTime = injuredTime - 1
                RecoveringAlert()
				if injuredTime <= 0 then
					injuredTime = 0
                    TriggerEvent("DoShortHudText", "You are now fully healed.")
                    recovering = false
				end
				TriggerServerEvent("hospital:server:SetInjuredStatus", injuredTime)
			end
		else
			Wait(5000)
		end
	end
end)

CreateThread(function()
    while true do
        sleep = 1000
        local ped = PlayerPedId()
        local health = GetEntityHealth(ped)
        if recovering then
            sleep = 5
            DisableControlAction(0, 21, true)
            if IsPedShooting(PlayerPedId()) then
                SetEntityHealth(ped, health - 2)
            end
        end
        Wait(sleep)
    end
end)

Citizen.CreateThread(function()
    local blip = AddBlipForCoord(-254.88, 6324.5, 32.58)
    SetBlipSprite(blip, 61)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 25)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Doctor's post Paleto")
    EndTextCommandSetBlipName(blip)

    local blip = AddBlipForCoord(304.27, -600.33, 43.28)
    SetBlipSprite(blip, 61)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 25)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Hospital")
    EndTextCommandSetBlipName(blip)
    while GLOBAL_COORDS == nil do Wait(100); end
    local alreadyEnteredZone = false
    local text = nil
    while true do
        sleep = 1000
        if insideHopsital then
            local inZone = false
            for k, v in pairs(Config.Locations["checking"]) do
                local checkin = vector3(v.x, v.y, v.z)
                local checkindis = #(GLOBAL_COORDS - checkin)
                if checkindis <= 1.5 then
                    sleep = 1
                    inZone = true
                    if not patient then
                        if doctorCount >= Config.MinimalDoctors then
                            --QBCore.Functions.DrawText3D(checkin.x, checkin.y, checkin.z, "[E] - Call doctor")
                            text = '[E] - To call doctor'
                        else
                            --QBCore.Functions.DrawText3D(checkin.x, checkin.y, checkin.z, "[E] - Check In")
                            text = '[E] - To check in'
                        end
                    else
                        --QBCore.Functions.DrawText3D(checkin.x, checkin.y, checkin.z, "You need to check out because you have a pending debt in hospital")
                        text = 'You need to check out because you have a pending debt in hospital'
                    end
                    if IsControlJustReleased(0, 38) then -- E
                        if not patient then
                            if doctorCount >= Config.MinimalDoctors then
                                TriggerServerEvent("hospital:server:SendDoctorAlert")
                            else
                                TriggerEvent('animations:client:EmoteCommandStart', {"notepad"})
                                QBCore.Functions.Progressbar("hospital_checkin", "Checking in..", 2000, false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {}, {}, {}, function() -- Done
                                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                                    local bedId = GetAvailableBed()
                                    if bedId ~= nil then 
                                        TriggerServerEvent("hospital:server:SendToBed", bedId, true)
                                        patient = true
                                        TriggerServerEvent("hospital:server:SetPatientStatus", true)
                                    else
                                        TriggerEvent("DoShortHudText", "Beds are occupied..", 2)
                                    end
                                end, function() -- Cancel
                                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                                    TriggerEvent("DoShortHudText", "Checking in failed!", 2)
                                end)
                            end
                        else
                            TriggerEvent('DoLongHudText', 'Meh! pay the bills first', 2)
                        end
                        TriggerEvent('qb-interact:HideUI')
                    end
                end
            end
        
            if closestBed ~= nil and not isInHospitalBed then
                local bed = vector3(Config.Locations["beds"][closestBed].x, Config.Locations["beds"][closestBed].y, Config.Locations["beds"][closestBed].z)
                local beddis = #(GLOBAL_COORDS - bed)
                if beddis <= 1.5 then
                sleep = 1
                inZone = true
                    --QBCore.Functions.DrawText3D(Config.Locations["beds"][closestBed].x, Config.Locations["beds"][closestBed].y, Config.Locations["beds"][closestBed].z + 0.3, "~g~E~w~ - To lie in bed")
                    text = '[E] - To lie in bed'
                    if IsControlJustReleased(0, 38) then -- E
                        if GetAvailableBed(closestBed) ~= nil then 
                            TriggerServerEvent("hospital:server:SendToBed", closestBed, false)
                            patient = true
                            TriggerServerEvent("hospital:server:SetPatientStatus", true)
                        else
                            TriggerEvent("DoShortHudText", "Beds are occupied..", 2)
                        end
                        TriggerEvent('qb-interact:HideUI')
                    end
                end
            end

            if patient then
                local checkoutMarker = vector3(Config.Locations["checkout"].x, Config.Locations["checkout"].y, Config.Locations["checkout"].z)
                local checkoutMarkerdis = #(GLOBAL_COORDS - checkoutMarker)
                if checkoutMarkerdis <= 1.5 then
                sleep = 1
                inZone = true
                    --QBCore.Functions.DrawText3D(checkoutMarker.x, checkoutMarker.y, checkoutMarker.z, "[E] - checkout")
                    text = '[E] - To checkout'
                    if IsControlJustReleased(0, 38) then -- E
                        TriggerEvent('animations:client:EmoteCommandStart', {"notepad"})
                        QBCore.Functions.Progressbar("hospital_checkout", "Bill Out", 6000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true,
                        }, {}, {}, {}, function() -- Done
                            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                            TriggerServerEvent("hospital:server:BillOut")
                            patient = false
                            TriggerServerEvent("hospital:server:SetPatientStatus", false)
                        end, function() -- Cancel
                            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                            TriggerEvent("DoShortHudText", "Not checked out!", 2)
                        end)
                        TriggerEvent('qb-interact:HideUI')
                    end
                end
            end

            if inZone and not alreadyEnteredZone then
                alreadyEnteredZone = true
                TriggerEvent('qb-interact:ShowUI', 'show', text)
            end

            if not inZone and alreadyEnteredZone then
                alreadyEnteredZone = false
                TriggerEvent('qb-interact:HideUI')
            end
        end
        Wait(sleep)
    end
end)

function GetAvailableBed(bedId)
    local retval = nil
    if bedId == nil then 
        for k, v in pairs(Config.Locations["beds"]) do
            if not Config.Locations["beds"][k].taken then
                retval = k
            end
        end
    else
        if not Config.Locations["beds"][bedId].taken then
            retval = bedId
        end
    end
    return retval
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(7)
        if QBCore ~= nil then
            if isInHospitalBed and canLeaveBed then
                local pos = GetEntityCoords(PlayerPedId())
                QBCore.Functions.DrawText3D(pos.x, pos.y, pos.z, "~g~E~w~ - To get out of bed..")
                if IsControlJustReleased(0, 38) then -- E
                    LeaveBed()
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent('hospital:client:Revive')
AddEventHandler('hospital:client:Revive', function()
    local player = PlayerPedId()

    if isDead then
		local playerPos = GetEntityCoords(player, true)
        NetworkResurrectLocalPlayer(playerPos, true, true, false)
        isDead = false
        SetEntityInvincible(PlayerPedId(), false)
        patient = true
		TriggerEvent("hospital:client:injurystart", 20)
        TriggerServerEvent("hospital:server:SetPatientStatus", true)
    end

    if isInHospitalBed then
        loadAnimDict(inBedDict)
        TaskPlayAnim(player, inBedDict , inBedAnim, 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
        SetEntityInvincible(PlayerPedId(), true)
        canLeaveBed = true
    end

    TriggerServerEvent("hospital:server:RestoreWeaponDamage")

    local ped = PlayerPedId()
    SetEntityMaxHealth(ped, 200)
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(player)
    SetPlayerSprint(PlayerId(), true)

    ResetAll()

    TriggerServerEvent('qb-hud:Server:RelieveStress', 100)
    TriggerServerEvent("hospital:server:SetDeathStatus", false)
    
    TriggerEvent("DoShortHudText", "You are completely healthy again!")
end)

RegisterNetEvent('hospital:client:SetPain')
AddEventHandler('hospital:client:SetPain', function()
    ApplyBleed(math.random(1,4))
    if not BodyParts[Config.Bones[24816]].isDamaged then
        BodyParts[Config.Bones[24816]].isDamaged = true
        BodyParts[Config.Bones[24816]].severity = math.random(1, 4)
        table.insert(injured, {
            part = Config.Bones[24816],
            label = BodyParts[Config.Bones[24816]].label,
            severity = BodyParts[Config.Bones[24816]].severity
        })
    end

    if not BodyParts[Config.Bones[40269]].isDamaged then
        BodyParts[Config.Bones[40269]].isDamaged = true
        BodyParts[Config.Bones[40269]].severity = math.random(1, 4)
        table.insert(injured, {
            part = Config.Bones[40269],
            label = BodyParts[Config.Bones[40269]].label,
            severity = BodyParts[Config.Bones[40269]].severity
        })
    end

    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })
end)

RegisterNetEvent('hospital:client:KillPlayer')
AddEventHandler('hospital:client:KillPlayer', function()
    SetEntityHealth(PlayerPedId(), 0)
end)

RegisterNetEvent('hospital:client:HealInjuries')
AddEventHandler('hospital:client:HealInjuries', function(type)
    if type == "full" then
        ResetAll()
    else
        ResetPartial()
    end
    TriggerServerEvent("hospital:server:RestoreWeaponDamage")
    TriggerEvent("DoShortHudText", "Your wounds have been healed!")
end)

RegisterNetEvent('hospital:client:SendToBed')
AddEventHandler('hospital:client:SendToBed', function(id, data, isRevive)
    bedOccupying = id
    bedOccupyingData = data
    SetBedCam()
    Citizen.CreateThread(function ()
        Citizen.Wait(5)
        local player = PlayerPedId()
        if isRevive then
            TriggerEvent("DoShortHudText", "You are being helped..")
            Citizen.Wait(Config.AIHealTimer * 1000)
            TriggerEvent("hospital:client:Revive")
        else
            canLeaveBed = true
        end
    end)
end)

RegisterNetEvent('hospital:client:SetBed')
AddEventHandler('hospital:client:SetBed', function(id, isTaken)
    Config.Locations["beds"][id].taken = isTaken
end)


RegisterNetEvent('hospital:client:RespawnAtHospital')
AddEventHandler('hospital:client:RespawnAtHospital', function()
    TriggerServerEvent("hospital:server:RespawnAtHospital")
    TriggerEvent("police:client:DeEscort")
end)

RegisterNetEvent('hospital:client:SendBillEmail')
AddEventHandler('hospital:client:SendBillEmail', function(amount)
    SetTimeout(math.random(2500, 4000), function()
        local gender = "Mr."
        if QBCore.Functions.GetPlayerData().charinfo.gender == 1 then
            gender = "Mrs."
        end
        local charinfo = QBCore.Functions.GetPlayerData().charinfo
        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = "Pillbox",
            subject = "Hospital Costs",
            message = "Dear " .. gender .. " " .. charinfo.lastname .. ",<br /><br />Hereby you received an email with the costs of the last hospital visit.<br />The final costs have become: <strong>$"..amount.."</strong><br /><br />We wish you a quick recovery!",
            button = {}
        })
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    TriggerServerEvent("hospital:server:SetDoctor")
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    exports.spawnmanager:setAutoSpawn(false)
    isLoggedIn = true
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = QBCore.Functions.GetPlayerData().job.onduty

    if PlayerJob.name == "ambulance" then
        if PlayerJob.onduty then
            TriggerServerEvent("QBCore:ToggleDuty")
            onDuty = false
        end
    end

    if QBCore.Functions.GetPlayerData().metadata["patient"] then
        patient = true
    end

    TriggerServerEvent("hospital:server:SetDoctor")
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
        onDuty = PlayerData.job.onduty
        SetPedArmour(PlayerPedId(), PlayerData.metadata["armor"])
        isDead = PlayerData.metadata["isdead"]
        if isDead then 
            deathTime = Config.DeathTime
            DeathTimer()
        end
    end)
end)
RegisterNetEvent('hospital:client:SetDoctorCount')
AddEventHandler('hospital:client:SetDoctorCount', function(amount)
    doctorCount = amount
end)

RegisterNetEvent('QBCore:Client:SetDuty')
AddEventHandler('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
    TriggerServerEvent("hospital:server:SetDoctor")
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    TriggerServerEvent("hospital:server:SetDeathStatus", false)
    TriggerServerEvent("hospital:server:SetArmor", GetPedArmour(PlayerPedId()))
    if bedOccupying ~= nil then 
        TriggerServerEvent("hospital:server:LeaveBed", bedOccupying)
    end
    isDead = false
    deathTime = 0
    SetEntityInvincible(PlayerPedId(), false)
    SetPedArmour(PlayerPedId(), 0)
    ResetAll()
end)

function GetDamagingWeapon(ped)
    for k, v in pairs(Config.Weapons) do
        if HasPedBeenDamagedByWeapon(ped, k, 0) then
            ClearEntityLastDamageEntity(ped)
            return v
        end
    end

    return nil
end

function IsDamagingEvent(damageDone, weapon)
    math.randomseed(GetGameTimer())
    local luck = math.random(100)
    local multi = damageDone / Config.HealthDamage

    return luck < (Config.HealthDamage * multi) or (damageDone >= Config.ForceInjury or multi > Config.MaxInjuryChanceMulti or Config.ForceInjuryWeapons[weapon])
end

function RecoveringAlert()
    local player = PlayerPedId()
    if not isDead and tonumber(injuredTime) > 0 then
        TriggerEvent("DoLongHudText", "You are still recovering from your last injuries", 2)
    end
end

function DoLimbAlert()
    local player = PlayerPedId()
    if not isDead then
        if #injured > 0 then
            local limbDamageMsg = ''
            if #injured <= Config.AlertShowInfo then
                for k, v in pairs(injured) do
                    limbDamageMsg = limbDamageMsg .. "Your " .. v.label .. " feels "..Config.WoundStates[v.severity]
                    if k < #injured then
                        limbDamageMsg = limbDamageMsg .. " | "
                    end
                end
            else
                limbDamageMsg = "You have pain on many places.."
            end
            TriggerEvent("DoLongHudText", limbDamageMsg)
        end
    end
end

function DoBleedAlert()
    local player = PlayerPedId()
    if not isDead and tonumber(isBleeding) > 0 then
        TriggerEvent("DoLongHudText", "You are "..Config.BleedingStates[tonumber(isBleeding)].label)
    end
end

function IsInjuryCausingLimp()
    for k, v in pairs(BodyParts) do
        if v.causeLimp and v.isDamaged then
            return true
        end
    end

    return false
end

function SetClosestBed() 
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil
    local dist2 = #(pos - vector3(Config.Locations["beds"][k].x, Config.Locations["beds"][k].y, Config.Locations["beds"][k].z)
    for k, v in pairs(Config.Locations["beds"]) do
        if current ~= nil then
            if dist2 < dist)then
                current = k
                dist = dist2
            end
        else
            dist = dist2
            current = k
        end
    end
    if current ~= closestBed and not isInHospitalBed then
        closestBed = current
    end
end

function ResetPartial()
    for k, v in pairs(BodyParts) do
        if v.isDamaged and v.severity <= 2 then
            v.isDamaged = false
            v.severity = 0
        end
    end

    for k, v in pairs(injured) do
        if v.severity <= 2 then
            v.severity = 0
            table.remove(injured, k)
        end
    end

    if isBleeding <= 2 then
        isBleeding = 0
        bleedTickTimer = 0
        advanceBleedTimer = 0
        fadeOutTimer = 0
        blackoutTimer = 0
    end
    
    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })

    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
    DoBleedAlert()

    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })
end

function ResetAll()
    isBleeding = 0
    bleedTickTimer = 0
    advanceBleedTimer = 0
    fadeOutTimer = 0
    blackoutTimer = 0
    onDrugs = 0
    wasOnDrugs = false
    onPainKiller = 0
    wasOnPainKillers = false
    injured = {}

    for k, v in pairs(BodyParts) do
        v.isDamaged = false
        v.severity = 0
    end
    
    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })

    CurrentDamageList = {}
    TriggerServerEvent('hospital:server:SetWeaponDamage', CurrentDamageList)
    ResetPedMovementClipset(PlayerPedId())
    ProcessRunStuff(PlayerPedId())
    DoLimbAlert()
    DoBleedAlert()
    SetEntityHealth(PlayerPedId(), 200)

    TriggerServerEvent('hospital:server:SyncInjuries', {
        limbs = BodyParts,
        isBleeding = tonumber(isBleeding)
    })
    TriggerServerEvent("QBCore:Server:SetMetaData", "hunger", 100)
    TriggerServerEvent("QBCore:Server:SetMetaData", "thirst", 100)
end

function SetBedCam()
    isInHospitalBed = true
    canLeaveBed = false
    local player = PlayerPedId()

    DoScreenFadeOut(1000)

    while not IsScreenFadedOut() do
        Citizen.Wait(100)
    end

	if IsPedDeadOrDying(player) then
		local playerPos = GetEntityCoords(player, true)
		NetworkResurrectLocalPlayer(playerPos, true, true, false)
    end
    
    bedObject = GetClosestObjectOfType(bedOccupyingData.x, bedOccupyingData.y, bedOccupyingData.z, 1.0, bedOccupyingData.model, false, false, false)
    FreezeEntityPosition(bedObject, true)

    SetEntityCoords(player, bedOccupyingData.x, bedOccupyingData.y, bedOccupyingData.z + 0.02)
    --SetEntityInvincible(PlayerPedId(), true)
    Citizen.Wait(500)
    FreezeEntityPosition(player, true)

    loadAnimDict(inBedDict)

    TaskPlayAnim(player, inBedDict , inBedAnim, 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
    SetEntityHeading(player, bedOccupyingData.h)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)
    AttachCamToPedBone(cam, player, 31085, 0, 1.0, 1.0 , true)
    SetCamFov(cam, 90.0)
    SetCamRot(cam, -45.0, 0.0, GetEntityHeading(player) + 180, true)

    DoScreenFadeIn(1000)

    Citizen.Wait(1000)
    FreezeEntityPosition(player, true)
end

function LeaveBed()
    local player = PlayerPedId()

    RequestAnimDict(getOutDict)
    while not HasAnimDictLoaded(getOutDict) do
        Citizen.Wait(0)
    end
    
    FreezeEntityPosition(player, false)
    SetEntityInvincible(player, false)
    SetEntityHeading(player, bedOccupyingData.h + 90)
    TaskPlayAnim(player, getOutDict , getOutAnim, 100.0, 1.0, -1, 8, -1, 0, 0, 0)
    Citizen.Wait(4000)
    ClearPedTasks(player)
    TriggerServerEvent('hospital:server:LeaveBed', bedOccupying)
    FreezeEntityPosition(bedObject, true)

    
    RenderScriptCams(0, true, 200, true, true)
    DestroyCam(cam, false)

    bedOccupying = nil
    bedObject = nil
    bedOccupyingData = nil
    isInHospitalBed = false
end

function MenuOutfits()
    ped = PlayerPedId();
    MenuTitle = "Outfits"
    ClearMenu()
    Menu.addButton("My Outfits", "OutfitsLijst", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function changeOutfit()
	Wait(200)
    loadAnimDict("clothingshirt")    	
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(3100)
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function OutfitsLijst()
    QBCore.Functions.TriggerCallback('apartments:GetOutfits', function(outfits)
        ped = PlayerPedId();
        MenuTitle = "My Outfits :"
        ClearMenu()

        if outfits == nil then
            QBCore.Functions.Notify("You didnt save any outfits...", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(outfits) do
                Menu.addButton(outfits[k].outfitname, "optionMenu", outfits[k]) 
            end
        end
        Menu.addButton("Back", "MenuOutfits",nil)
    end)
end

function optionMenu(outfitData)
    ped = PlayerPedId();
    MenuTitle = "What now?"
    ClearMenu()

    Menu.addButton("Choose Outfit", "selectOutfit", outfitData) 
    Menu.addButton("Delete Outfit", "removeOutfit", outfitData) 
    Menu.addButton("Back", "OutfitsLijst",nil)
end

function selectOutfit(oData)
    TriggerServerEvent('clothes:selectOutfit', oData.model, oData.skin)
    QBCore.Functions.Notify(oData.outfitname.." chosen", "success", 2500)
    closeMenuFull()
    changeOutfit()
end

function removeOutfit(oData)
    TriggerServerEvent('clothes:removeOutfit', oData.outfitname)
    QBCore.Functions.Notify(oData.outfitname.." has been deleted", "success", 2500)
    closeMenuFull()
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function GetClosestPlayer()
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

function DrawText3D(x, y, z, text)
	SetTextScale(0.3, 0.3)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 400
    DrawRect(0.0, 0.0+0.0110, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function loadAnimDict(dict)
	while(not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(1)
	end
end

  --Name: pillboxhospital | 2021-02-05T03:55:24Z
local hospitalpillbox = PolyZone:Create({
    vector2(308.12768554688, -559.00720214844),
    vector2(294.16653442383, -599.45074462891),
    vector2(356.46575927734, -621.88446044922),
    vector2(372.94000244141, -569.08428955078)
  }, {
    name="pillboxhospital",
    minZ = 0,
    maxZ = 91.0,
    debugGrid = false
  })

local HeadBone = 0x796e;
Citizen.CreateThread(function()
    while true do
        local coord = GetPedBoneCoords(pedId, HeadBone)
        local inPoly = hospitalpillbox:isPointInside(coord)
        -- if true, then player just entered zone
        if inPoly and not insideHopsital then
            insideHopsital = true
        elseif not inPoly and insideHopsital then
            insideHopsital = false
        end
        Citizen.Wait(1500)
    end
end)