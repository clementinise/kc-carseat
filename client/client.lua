local ThroughSeat = false
local doors = {
    ["-1"] = { Name = "front driver", SeatIndex = -1, ThroughSeatIndex = 0},
    ["0"] = { Name = "front passenger", SeatIndex = 0, ThroughSeatIndex = -1},
    ["1"] = { Name = "rear driver", SeatIndex = 1, ThroughSeatIndex = 2},
    ["2"] = { Name = "rear passenger", SeatIndex = 2, ThroughSeatIndex = 1}
}

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

local function GetNumberOfVehicleSeats(vehicle)
    local seats, numberOfSeats = { "seat_dside_f", "seat_dside_r", "seat_dside_r1", "seat_dside_r2", "seat_dside_r3", "seat_dside_r4", "seat_dside_r5", "seat_dside_r6", "seat_dside_r7", "seat_pside_f", "seat_pside_r", "seat_pside_r1", "seat_pside_r2", "seat_pside_r3", "seat_pside_r4", "seat_pside_r5", "seat_pside_r6", "seat_pside_r7" }, 0

    for k ,v in pairs(seats) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfSeats = numberOfSeats + 1
        end
    end

    return numberOfSeats
end

local function EnteringCar()
    local ply = PlayerPedId()
    local plyCoo = GetEntityCoords(ply)
    local veh = GetClosestVehicleFromPly(ply, Config.Distance, Config.FacingOnly)

    if IsPedInAnyVehicle(ply, false) or (veh == nil or veh == 0) or GetVehicleDoorLockStatus(veh) == 2 or #(GetEntityCoords(veh) - plyCoo) > Config.Distance or IsThisModelACar(GetEntityModel(veh)) ~= 1 then return end

    ClearPedTasksImmediately(ply)

    Wait(0)

    if ThroughSeat then return end

    if Config.Debug then print("Distance from veh: "..#(GetEntityCoords(veh) - plyCoo)) end

    local CurrentGameTimer = GetGameTimer()

    repeat
        Wait(0)
        if IsControlJustPressed(1, 49) then
            ThroughSeat = true
        end
    until ThroughSeat or GetGameTimer() > CurrentGameTimer + Config.WaitForDoubleInput

    if Config.Debug then print("Going to other seat: "..tostring(ThroughSeat)) end

    local minDistance, minDoorIndex

    if Config.Debug then
        print("---------------------")
    end

    for i = 0, GetNumberOfVehicleSeats(veh) - 1, 1 do
        local distance = #(GetEntryPositionOfDoor(veh, i) - plyCoo)
        if minDistance == nil then
            minDistance = distance
            minDoorIndex = i
        end
        if distance < minDistance then
            minDistance = distance
            minDoorIndex = i
        end

        if Config.Debug then
            if i < 4 then
                print("Distance from "..doors[tostring(i - 1)].Name.." door: "..distance)
            else
                print("Distance from "..(i + 1).."th seat: "..distance)
            end
        end
    end*

    if Config.Debug then
        print("---------------------")
    end

    if minDoorIndex then
        minDoorIndex = minDoorIndex - 1

        if minDoorIndex < 3 then
            if Config.Debug then
                if ThroughSeat then
                    print("Entering "..doors[tostring(minDoorIndex)].Name.." door, going into "..doors[tostring(doors[tostring(minDoorIndex)].ThroughSeatIndex)].Name.." seat")
                else
                    print("Entering "..doors[tostring(minDoorIndex)].Name.." door")
                end
            end
            TaskEnterVehicle(ply, veh, 10000, ThroughSeat and doors[tostring(minDoorIndex)].ThroughSeatIndex or doors[tostring(minDoorIndex)].SeatIndex, 1.0, 1, 0)
        else
            if Config.Debug then
                print("Going to "..(minDoorIndex + 2).."th seat")
            end
            TaskEnterVehicle(ply, veh, 10000, minDoorIndex, 1.0, 1, 0)
        end

        CheckMoves()
    end

    Wait(1000)

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
                waitTime = 300
            end
        end
        Wait(waitTime)
    end
end)