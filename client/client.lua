local ThroughSeat = false

local function CheckMoves()
    local moveKeys = {33, 34, 35}
    while not IsPedSittingInAnyVehicle(PlayerPedId()) do
        Wait(0)
        for k, v in pairs(moveKeys) do
            if IsControlJustPressed(1, v) then
                ClearPedTasks(PlayerPedId())
                return
            end
        end
    end
end

local function GetClosestVehicleFromPly(ply, maxDistance, facingOnly)
    if GetVehiclePedIsIn(ply) ~= 0 then return GetVehiclePedIsIn(ply) end

    local plyCoo = GetEntityCoords(ply)
    local plyFwd = GetEntityForwardVector(ply)
    local vehs = GetGamePool('CVehicle')
    local nearestDist, nearestVeh = math.huge, nil

    for i = 0, #vehs do
        local vehCoo = GetEntityCoords(vehs[i])
        local dist = #(vehCoo - plyCoo)
        if dist <= maxDistance then
            local isFacing = true
            if facingOnly then
                local vecToVeh = vehCoo - plyCoo
                local dot = vecToVeh.x * plyFwd.x + vecToVeh.y * plyFwd.y + vecToVeh.z * plyFwd.z
                isFacing = dot > 0
            end
            if isFacing and dist < nearestDist then
                nearestDist = dist
                nearestVeh = vehs[i]
            end
        end
    end

    return nearestVeh
end

local function EnteringCar()
    local ply = PlayerPedId()
    local plyCoo = GetEntityCoords(ply)
    local veh = GetClosestVehicleFromPly(ply, 3.0, Config.FacingOnly)

    if IsPedInAnyVehicle(ply, false) or (veh == nil or veh == 0) or GetVehicleDoorLockStatus(veh) == 2 or #(GetEntityCoords(veh) - plyCoo) > Config.Distance then return end

    if Config.Debug then print("Distance from veh: "..#(GetEntityCoords(veh) - plyCoo)) end

    Wait(0)

    if ThroughSeat then return end

    local seatChoosen, CurrentGameTimer = true, GetGameTimer()

    CreateThread(function()
        while seatChoosen do
            Wait(0)
            ClearPedTasks(ply)
        end
        TerminateThisThread() -- I'm sure this is unnecessary
    end)

    repeat
        Wait(0)
        if IsControlJustPressed(1, 49) then
            ThroughSeat = true
        end
    until ThroughSeat or GetGameTimer() > CurrentGameTimer + Config.WaitForDoubleInput

    if Config.Debug then print("\nThroughSeat: "..tostring(ThroughSeat)) end

    local doors = {
        { name = "rear left", pos = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "handle_dside_r")), seatIndex = 2, altSeatIndex = 1 },
        { name = "front left", pos = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "handle_dside_f")), seatIndex = 0, altSeatIndex = -1 },
        { name = "rear right", pos = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "handle_pside_r")), seatIndex = 1, altSeatIndex = 2 },
        { name = "front right", pos = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, "handle_pside_f")), seatIndex = -1, altSeatIndex = 0 }
    }

    local minDistance = math.huge
    local minDoorIndex = nil

    if Config.Debug then
        print("---------------------")
    end

    for i, door in ipairs(doors) do
        local distance = #(door.pos - plyCoo)

        if distance < minDistance then
            minDistance = distance
            minDoorIndex = i
        end

        if Config.Debug then
            print("Distance from "..door.name.." door: "..distance)
        end
    end

    if Config.Debug then
        print("---------------------")
    end
    if minDoorIndex ~= nil then
        local door = doors[minDoorIndex]

        if minDistance < 2.0 and not DoesEntityExist(GetPedInVehicleSeat(veh, door.altSeatIndex)) then
            if Config.Debug then
                print("Entering "..door.name.." door\n")
            end

            seatChoosen = false

            Wait(0)

            if ThroughSeat then
                TaskEnterVehicle(ply, veh, 10000, door.seatIndex, 1.0, 1, 0)
            else
                TaskEnterVehicle(ply, veh, 10000, door.altSeatIndex, 1.0, 1, 0)
            end

            CheckMoves()
        end
    end

    Wait(2000)

    ThroughSeat = false
end

RegisterCommand('entercar', function() EnteringCar() end, false)
RegisterKeyMapping('entercar', Locale[Config.Language].SettingsText, 'KEYBOARD', 'F')
--RegisterKeyMapping('entercar', Locale[Config.Language].SettingsText, 'PAD_DIGITALBUTTON', 'RUP_INDEX')


RegisterNetEvent('kc-carseat:enteredVehicle')
AddEventHandler('kc-carseat:enteredVehicle', function(veh)
    local ply = PlayerPedId()
    local waitTime = 0
    while IsPedInAnyVehicle(ply, false) do
        if IsPedInAnyVehicle(ply, false) and not ThroughSeat then
            if GetPedInVehicleSeat(veh, 0) == ply then
                if GetIsTaskActive(ply, 165) then
                    SetPedIntoVehicle(ply, veh, 0)
                    SetPedConfigFlag(ply, 184, true)
                end
                waitTime = 0
            else
                waitTime = 500
            end
        end
        Wait(waitTime)
    end
end)