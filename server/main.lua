local PlayerInjuries = {}
local PlayerWeaponWounds = {}
local QBCore = exports['qb-core']:GetCoreObject()
-- Events

-- Compatibility with txAdmin Menu's heal options.
-- This is an admin only server side event that will pass the target player id or -1.
AddEventHandler('txAdmin:events:healedPlayer', function(eventData)
	if
		GetInvokingResource() ~= "monitor" or 
		type(eventData) ~= "table" or
		type(eventData.id) ~= "number" 
	then
		return
	end

	TriggerClientEvent('hospital:client:Revive', eventData.id)
	TriggerClientEvent("hospital:client:HealInjuries", eventData.id, "full")
end)

RegisterNetEvent('hospital:server:SendToBed', function(bedId, isRevive)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	TriggerClientEvent('hospital:client:SendToBed', src, bedId, Config.Locations["beds"][bedId], isRevive)
	TriggerClientEvent('hospital:client:SetBed', -1, bedId, true)
	Player.Functions.RemoveMoney("bank", Config.BillCost , "respawned-at-hospital")
	TriggerEvent('qb-bossmenu:server:addAccountMoney', "ambulance", Config.BillCost)
	TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
end)

RegisterNetEvent('hospital:server:RespawnAtHospital', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	for k, v in pairs(Config.Locations["beds"]) do
		if not v.taken then
			TriggerClientEvent('hospital:client:SendToBed', src, k, v, true)
			TriggerClientEvent('hospital:client:SetBed', -1, k, true)
			if Config.WipeInventoryOnRespawn then
				Player.Functions.ClearInventory()
				exports.oxmysql:execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
				TriggerClientEvent('QBCore:Notify', src, 'All your possessions have been taken..', 'error')
			end
			Player.Functions.RemoveMoney("bank", Config.BillCost, "respawned-at-hospital")
			TriggerEvent('qb-bossmenu:server:addAccountMoney', "ambulance", Config.BillCost)
			TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
			return
		end
	end
	print("All beds were full, placing in first bed as fallback")
	TriggerClientEvent('hospital:client:SendToBed', src, 1, Config.Locations["beds"][1], true)
	TriggerClientEvent('hospital:client:SetBed', -1, 1, true)
	if Config.WipeInventoryOnRespawn then
		Player.Functions.ClearInventory()
		exports.oxmysql:execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode({}), Player.PlayerData.citizenid })
		TriggerClientEvent('QBCore:Notify', src, 'All your possessions have been taken..', 'error')
	end
	Player.Functions.RemoveMoney("bank", Config.BillCost, "respawned-at-hospital")
	TriggerEvent('qb-bossmenu:server:addAccountMoney', "ambulance", Config.BillCost)
	TriggerClientEvent('hospital:client:SendBillEmail', src, Config.BillCost)
end)

RegisterNetEvent('hospital:server:ambulanceAlert', function(text)
    local src = source
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
            TriggerClientEvent('hospital:client:ambulanceAlert', v.PlayerData.source, coords, text)
        end
    end
end)

RegisterNetEvent('hospital:server:LeaveBed', function(id)
    TriggerClientEvent('hospital:client:SetBed', -1, id, false)
end)

RegisterNetEvent('hospital:server:SyncInjuries', function(data)
    local src = source
    PlayerInjuries[src] = data
end)


RegisterNetEvent('hospital:server:SetWeaponDamage', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		PlayerWeaponWounds[Player.PlayerData.source] = data
	end
end)

RegisterNetEvent('hospital:server:RestoreWeaponDamage', function()
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	PlayerWeaponWounds[Player.PlayerData.source] = nil
end)

RegisterNetEvent('hospital:server:SetDeathStatus', function(isDead)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData("isdead", isDead)
	end
end)

RegisterNetEvent('hospital:server:SetLaststandStatus', function(bool)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData("inlaststand", bool)
	end
end)

RegisterNetEvent('hospital:server:SetArmor', function(amount)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player then
		Player.Functions.SetMetaData("armor", amount)
	end
end)

RegisterNetEvent('hospital:server:TreatWounds', function(playerId)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Patient = QBCore.Functions.GetPlayer(playerId)
	if Patient then
		if Player.PlayerData.job.name =="ambulance" then
			Player.Functions.RemoveItem('bandage', 1)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['bandage'], "remove")
			TriggerClientEvent("hospital:client:HealInjuries", Patient.PlayerData.source, "full")
		end
	end
end)

RegisterNetEvent('hospital:server:SetDoctor', function()
	local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
            amount = amount + 1
        end
	end
	TriggerClientEvent("hospital:client:SetDoctorCount", -1, amount)
end)

RegisterNetEvent('hospital:server:RevivePlayer', function(playerId, isOldMan)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Patient = QBCore.Functions.GetPlayer(playerId)
	local oldMan = isOldMan or false
	if Patient then
		if oldMan then
			if Player.Functions.RemoveMoney("cash", 5000, "revived-player") then
				Player.Functions.RemoveItem('firstaid', 1)
				TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['firstaid'], "remove")
				TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
			else
				TriggerClientEvent('QBCore:Notify', src, "You don\'t have enough money on you..", "error")
			end
		else
			Player.Functions.RemoveItem('firstaid', 1)
			TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['firstaid'], "remove")
			TriggerClientEvent('hospital:client:Revive', Patient.PlayerData.source)
		end
	end
end)

RegisterNetEvent('hospital:server:SendDoctorAlert', function()
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			TriggerClientEvent('QBCore:Notify', v.PlayerData.source, 'A doctor is needed at Pillbox Hospital', 'ambulance')
		end
	end
end)

RegisterNetEvent('hospital:server:UseFirstAid', function(targetId)
	local src = source
	local Target = QBCore.Functions.GetPlayer(targetId)
	if Target then
		TriggerClientEvent('hospital:client:CanHelp', targetId, src)
	end
end)

RegisterNetEvent('hospital:server:CanHelp', function(helperId, canHelp)
	local src = source
	if canHelp then
		TriggerClientEvent('hospital:client:HelpPerson', helperId, src)
	else
		TriggerClientEvent('QBCore:Notify', helperId, "You can\'t help this person..", "error")
	end
end)

-- Callbacks

QBCore.Functions.CreateCallback('hospital:GetDoctors', function(source, cb)
	local amount = 0
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
			amount = amount + 1
		end
	end
	cb(amount)
end)

QBCore.Functions.CreateCallback('hospital:GetPlayerStatus', function(source, cb, playerId)
	local Player = QBCore.Functions.GetPlayer(playerId)
	local injuries = {}
	injuries["WEAPONWOUNDS"] = {}
	if Player then
		if PlayerInjuries[Player.PlayerData.source] then
			if (PlayerInjuries[Player.PlayerData.source].isBleeding > 0) then
				injuries["BLEED"] = PlayerInjuries[Player.PlayerData.source].isBleeding
			end
			for k, v in pairs(PlayerInjuries[Player.PlayerData.source].limbs) do
				if PlayerInjuries[Player.PlayerData.source].limbs[k].isDamaged then
					injuries[k] = PlayerInjuries[Player.PlayerData.source].limbs[k]
				end
			end
		end
		if PlayerWeaponWounds[Player.PlayerData.source] then
			for k, v in pairs(PlayerWeaponWounds[Player.PlayerData.source]) do
				injuries["WEAPONWOUNDS"][k] = v
			end
		end
	end
    cb(injuries)
end)

QBCore.Functions.CreateCallback('hospital:GetPlayerBleeding', function(source, cb)
	local src = source
	if PlayerInjuries[src] and PlayerInjuries[src].isBleeding then
		cb(PlayerInjuries[src].isBleeding)
	else
		cb(nil)
	end
end)

-- Commands

QBCore.Commands.Add('911e', 'EMS Report', {{name='message', help='Message to be sent'}}, false, function(source, args)
	local src = source
	if args[1] then message = table.concat(args, " ") else message = 'Civilian Call' end
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    local players = QBCore.Functions.GetQBPlayers()
    for k,v in pairs(players) do
        if v.PlayerData.job.name == 'ambulance' and v.PlayerData.job.onduty then
            TriggerClientEvent('hospital:client:ambulanceAlert', v.PlayerData.source, coords, message)
        end
    end
end)

QBCore.Commands.Add("status", "Check A Players Health", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:CheckStatus", src)
	else
		TriggerClientEvent('QBCore:Notify', src, "You Are Not EMS", "error")
	end
end)

QBCore.Commands.Add("heal", "Heal A Player", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:TreatWounds", src)
	else
		TriggerClientEvent('QBCore:Notify', src, "You Are Not EMS", "error")
	end
end)

QBCore.Commands.Add("revivep", "Revive A Player", {}, false, function(source, args)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.PlayerData.job.name == "ambulance" then
		TriggerClientEvent("hospital:client:RevivePlayer", src)
	else
		TriggerClientEvent('QBCore:Notify', src, "You Are Not EMS", "error")
	end
end)

QBCore.Commands.Add("revive", "Revive A Player or Yourself (Admin Only)", {{name="id", help="Player ID (may be empty)"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:Revive', Player.PlayerData.source)
		else
			TriggerClientEvent('QBCore:Notify', src, "Player Not Online", "error")
		end
	else
		TriggerClientEvent('hospital:client:Revive', src)
	end
end, "admin")

QBCore.Commands.Add("setpain", "Set Yours or A Players Pain Level (Admin Only)", {{name="id", help="Player ID (may be empty)"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:SetPain', Player.PlayerData.source)
		else
			TriggerClientEvent('QBCore:Notify', src, "Player Not Online", "error")
		end
	else
		TriggerClientEvent('hospital:client:SetPain', src)
	end
end, "admin")

QBCore.Commands.Add("kill", "Kill A Player or Yourself (Admin Only)", {{name="id", help="Player ID (may be empty)"}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:KillPlayer', Player.PlayerData.source)
		else
			TriggerClientEvent('QBCore:Notify', src, "Player Not Online", "error")
		end
	else
		TriggerClientEvent('hospital:client:KillPlayer', src)
	end
end, "admin")

QBCore.Commands.Add('aheal', 'Heal A Player or Yourself (Admin Only)', {{name='id', help='Player ID (may be empty)'}}, false, function(source, args)
	local src = source
	if args[1] then
		local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
		if Player then
			TriggerClientEvent('hospital:client:adminHeal', Player.PlayerData.source)
		else
			TriggerClientEvent('QBCore:Notify', src, "Player Not Online", "error")
		end
	else
		TriggerClientEvent('hospital:client:adminHeal', src)
	end
end, 'admin')

-- Items

QBCore.Functions.CreateUseableItem("bandage", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UseBandage", src)
	end
end)

QBCore.Functions.CreateUseableItem("painkillers", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UsePainkillers", src)
	end
end)

QBCore.Functions.CreateUseableItem("firstaid", function(source, item)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	if Player.Functions.GetItemByName(item.name) ~= nil then
		TriggerClientEvent("hospital:client:UseFirstAid", src)
	end
end)
