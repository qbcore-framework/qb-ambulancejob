local animDict = 'missfbi5ig_0'
local animName = 'lyinginpain_loop_steve'
local inBedDicts = "anim@gangops@morgue@table@"
local inBedAnims = "ko_front"
local PickUpObject = nil

RegisterNetEvent("police:client:deleteObject")
AddEventHandler("police:client:deleteObject", function()
	local bed = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 10.0, GetHashKey('v_med_emptybed'))
	local wheelchair = GetClosestObjectOfType(GetEntityCoords(PlayerPedId()), 10.0, GetHashKey('prop_wheelchair_01'))

	if DoesEntityExist(bed) then
        DeleteEntity(bed)
	elseif DoesEntityExist(wheelchair) then
		DeleteEntity(wheelchair)
	end
end)

RegisterNetEvent("qb-ambulancejob:client:bed")
AddEventHandler("qb-ambulancejob:client:bed", function()
	local playerPed = PlayerPedId()
	local coords  = GetEntityCoords(playerPed)
	local forward = GetEntityForwardVector(playerPed)
	local x, y, z = table.unpack(coords + forward * 1.0)
	local model = GetHashKey('v_med_emptybed')

	LoadModel(model)	

	local obj = CreateObject(model, x, y + 1.0, z - 2.0, true, false, true)
	SetEntityHeading(obj, GetEntityHeading(payerPed))
	PlaceObjectOnGroundProperly(obj)
	SetEntityCollision(obj, true, true)
end)

RegisterNetEvent("qb-ambulancejob:client:wheelchair")
AddEventHandler("qb-ambulancejob:client:wheelchair", function()
	local playerPed = PlayerPedId()
	local coords  = GetEntityCoords(playerPed)
	local forward = GetEntityForwardVector(playerPed)
	local x, y, z = table.unpack(coords + forward * 1.0)
	local model = GetHashKey('prop_wheelchair_01')

	LoadModel(model)	

	local obj = CreateObject(model, x, y + 1.0, z - 2.0, true, false, true)
	SetEntityHeading(obj, GetEntityHeading(payerPed))
	PlaceObjectOnGroundProperly(obj)
	SetEntityCollision(obj, true, true)
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 500

		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

        local closestBed = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("v_med_emptybed"), false)
		local closestChair = GetClosestObjectOfType(pedCoords, 3.0, GetHashKey("prop_wheelchair_01"), false)

		if DoesEntityExist(closestBed) then
			sleep = 5

			local stretcherCoords = GetEntityCoords(closestBed)
			local stretcherForward = GetEntityForwardVector(closestBed)
			local sitCoords = (stretcherCoords + stretcherForward * - 0.5)
			local pickupCoords = (stretcherCoords + stretcherForward * 1.2)

			if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 1.5 then
				DrawText3Ds(sitCoords, "[G] Lay down")

				if IsDisabledControlJustPressed(0, 47) then
					LayOut(closestBed)
				end
			end

			if not IsEntityAttached(closestBed) and GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 2.5 and isLoggedIn and QBCore ~= nil and PlayerJob.name == 'ambulance' then
				DrawText3Ds(pickupCoords, "[H] Grab")

				if IsControlJustPressed(0, 74) then
					PickUp(closestBed)
				end
            end
		elseif DoesEntityExist(closestChair) then
			sleep = 5

			local wheelChairCoords = GetEntityCoords(closestChair)
			local wheelChairForward = GetEntityForwardVector(closestChair)
			
			local sitCoords = (wheelChairCoords + wheelChairForward * - 0.5)
			local pickupCoords = (wheelChairCoords + wheelChairForward * 0.3)

			if GetDistanceBetweenCoords(pedCoords, sitCoords, true) <= 1.0 then
				DrawText3Ds(sitCoords, "[E] Sit", 0.4)

				if IsControlJustPressed(0, 38) then
					ChairSit(closestChair)
				end
			end

			if GetDistanceBetweenCoords(pedCoords, pickupCoords, true) <= 1.0 then
				DrawText3Ds(pickupCoords, "[E] Pick up", 0.4)

				if IsControlJustPressed(0, 38) then
					ChairPickUp(closestChair)
				end
			end
		end

		Citizen.Wait(sleep)
	end
end)

local LayOutObject = nil
LayOut = function(stretcherObject)
	local closestPlayer, closestPlayerDist = GetClosestPlayer()

	if closestPlayer ~= nil and closestPlayer ~= 0 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'dead', 'dead_a', 3) then
			QBCore.Functions.Notify("Somebody is already using the stretcher!", 'error')
			return
		end
	end

	LoadAnim("dead")

	AttachEntityToEntity(PlayerPedId(), stretcherObject, 0, 0, 0.0, 1.3, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)

	local heading = GetEntityHeading(stretcherObject)

	LayOutObject = stretcherObject
	while LayOutObject and DoesEntityExist(LayOutObject) do
		Citizen.Wait(5)

		if not IsEntityPlayingAnim(PlayerPedId(), 'dead', 'dead_a', 1) then
			TaskPlayAnim(GetPlayerPed(-1), "dead", "dead_a", 1.0, 1.0, -1, 33, 0, 0, 0, 0)
		end

		if IsDisabledControlJustPressed(0, 47) then
			break
		end

		DisablePlayerFiring(PlayerId(), true)
		DisableControlAction(0, 47, true)  -- Disable weapon
		DisableControlAction(0, 264, true) -- Disable melee
		DisableControlAction(0, 257, true) -- Disable melee
		DisableControlAction(0, 140, true) -- Disable melee
		DisableControlAction(0, 141, true) -- Disable melee
		DisableControlAction(0, 142, true) -- Disable melee
		DisableControlAction(0, 143, true) -- Disable melee
		DisableControlAction(0, 24, true) -- Attack
		DisableControlAction(0, 257, true) -- Attack 2
		DisableControlAction(0, 25, true) -- Aim
		DisableControlAction(0, 263, true) -- Melee Attack 1
	end

	DetachEntity(PlayerPedId(), true, true)
	local x, y, z = table.unpack(GetEntityCoords(stretcherObject) + GetEntityForwardVector(stretcherObject) * - 0.7)
	SetEntityCoords(PlayerPedId(), x,y,z)
	LayOutObject = nil
end

PickUp = function(stretcherObject)
	NetworkRequestControlOfEntity(stretcherObject)

	LoadAnim("anim@heists@box_carry@")

	AttachEntityToEntity(stretcherObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.0, -1.2, -1.0, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

	PickUpObject = stretcherObject
	while PickUpObject and DoesEntityExist(PickUpObject) do
		Citizen.Wait(5)

		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
		end

		if IsControlJustPressed(0, 74) or IsPedDeadOrDying(PlayerPedId()) then
			DetachEntity(stretcherObject, true, true)
			break
		end

		DisablePlayerFiring(PlayerId(), true)
		DisableControlAction(0, 47, true)  -- Disable weapon
		DisableControlAction(0, 264, true) -- Disable melee
		DisableControlAction(0, 257, true) -- Disable melee
		DisableControlAction(0, 140, true) -- Disable melee
		DisableControlAction(0, 141, true) -- Disable melee
		DisableControlAction(0, 142, true) -- Disable melee
		DisableControlAction(0, 143, true) -- Disable melee
		DisableControlAction(0, 24, true) -- Attack
		DisableControlAction(0, 257, true) -- Attack 2
		DisableControlAction(0, 25, true) -- Aim
		DisableControlAction(0, 263, true) -- Melee Attack 1
	end

	PickUpObject = nil
	ClearPedSecondaryTask(PlayerPedId())
end

DrawText3Ds = function(coords, text)
	local x,y,z = coords.x, coords.y, coords.z
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

GetPlayers = function()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

GetClosestPlayer = function()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local ply = GetPlayerPed(PlayerId())
	local plyCoords = GetEntityCoords(ply, 0)
	
	for index,value in ipairs(players) do
		local target = GetPlayerPed(value)
		if(target ~= ply) then
			local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
			local distance = Vdist(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"])
			if(closestDistance == -1 or closestDistance > distance) then
				closestPlayer = value
				closestDistance = distance
			end
		end
	end
	
	return closestPlayer, closestDistance
end

LoadAnim = function(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		
		Citizen.Wait(1)
	end
end

LoadModel = function(model)
	while not HasModelLoaded(model) do
		RequestModel(model)
		
		Citizen.Wait(1)
	end
end

ChairSit = function(wheelchairObject)
	local closestPlayer, closestPlayerDist = GetClosestPlayer()

	if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			QBCore.Functions.Notify("Somebody is already using the wheelchair!", 'error')
			return
		end
	end

	LoadAnim("missfinale_c2leadinoutfin_c_int")

	AttachEntityToEntity(PlayerPedId(), wheelchairObject, 0, 0, 0.0, 0.4, 0.0, 0.0, 180.0, 0.0, false, false, false, false, 2, true)

	local heading = GetEntityHeading(wheelchairObject)

	while IsEntityAttachedToEntity(PlayerPedId(), wheelchairObject) do
		Citizen.Wait(5)

		if not IsEntityPlayingAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 3) then
			TaskPlayAnim(PlayerPedId(), 'missfinale_c2leadinoutfin_c_int', '_leadin_loop2_lester', 8.0, 8.0, -1, 69, 1, false, false, false)
		end

		if IsControlPressed(0, 32) then
			local x, y, z  = table.unpack(GetEntityCoords(wheelchairObject) + GetEntityForwardVector(wheelchairObject) * -0.01)
			SetEntityCoords(wheelchairObject, x,y,z)
			PlaceObjectOnGroundProperly(wheelchairObject)
		end

		if IsControlPressed(1,  34) then
			heading = heading + 0.4

			if heading > 360 then
				heading = 0
			end

			SetEntityHeading(wheelchairObject,  heading)
		end

		if IsControlPressed(1,  9) then
			heading = heading - 0.4

			if heading < 0 then
				heading = 360
			end

			SetEntityHeading(wheelchairObject,  heading)
		end

		if IsControlJustPressed(0, 38) or IsPedDeadOrDying(PlayerPedId()) then
			break
		end

		DisablePlayerFiring(PlayerId(), true)
		DisableControlAction(0, 47, true)  -- Disable weapon
		DisableControlAction(0, 264, true) -- Disable melee
		DisableControlAction(0, 257, true) -- Disable melee
		DisableControlAction(0, 140, true) -- Disable melee
		DisableControlAction(0, 141, true) -- Disable melee
		DisableControlAction(0, 142, true) -- Disable melee
		DisableControlAction(0, 143, true) -- Disable melee
		DisableControlAction(0, 24, true) -- Attack
		DisableControlAction(0, 257, true) -- Attack 2
		DisableControlAction(0, 25, true) -- Aim
		DisableControlAction(0, 263, true) -- Melee Attack 1
	end

	DetachEntity(PlayerPedId(), true, true)

	local x, y, z = table.unpack(GetEntityCoords(wheelchairObject) + GetEntityForwardVector(wheelchairObject) * - 0.7)

	SetEntityCoords(PlayerPedId(), x,y,z)
	ClearPedSecondaryTask(PlayerPedId())
end

ChairPickUp = function(wheelchairObject)
	local closestPlayer, closestPlayerDist = GetClosestPlayer()

	if closestPlayer ~= nil and closestPlayerDist <= 1.5 then
		if IsEntityPlayingAnim(GetPlayerPed(closestPlayer), 'anim@heists@box_carry@', 'idle', 3) then
			QBCore.Functions.Notify("Somebody is already driving the wheelchair!", 'error')
			return
		end
	end

	NetworkRequestControlOfEntity(wheelchairObject)

	LoadAnim("anim@heists@box_carry@")

	AttachEntityToEntity(wheelchairObject, PlayerPedId(), GetPedBoneIndex(PlayerPedId(),  28422), -0.00, -0.3, -0.73, 195.0, 180.0, 180.0, 0.0, false, false, true, false, 2, true)

	while IsEntityAttachedToEntity(wheelchairObject, PlayerPedId()) do
		Citizen.Wait(5)

		if not IsEntityPlayingAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 3) then
			TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 8.0, -1, 50, 0, false, false, false)
		end

		if IsControlJustPressed(0, 38) or IsPedDeadOrDying(PlayerPedId()) then
			break
		end

		DisablePlayerFiring(PlayerId(), true)
		DisableControlAction(0, 47, true)  -- Disable weapon
		DisableControlAction(0, 264, true) -- Disable melee
		DisableControlAction(0, 257, true) -- Disable melee
		DisableControlAction(0, 140, true) -- Disable melee
		DisableControlAction(0, 141, true) -- Disable melee
		DisableControlAction(0, 142, true) -- Disable melee
		DisableControlAction(0, 143, true) -- Disable melee
		DisableControlAction(0, 24, true) -- Attack
		DisableControlAction(0, 257, true) -- Attack 2
		DisableControlAction(0, 25, true) -- Aim
		DisableControlAction(0, 263, true) -- Melee Attack 1
	end

	DetachEntity(wheelchairObject, true, true)
	ClearPedSecondaryTask(PlayerPedId())
end
