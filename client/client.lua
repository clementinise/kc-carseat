local Leaving, Entering, EnterDoublePressed = false, false, false
local doors = {
    ["-1"] = { Name = "front driver", SeatIndex = -1, ThroughSeatIndex = 0},
    ["0"] = { Name = "front passenger", SeatIndex = 0, ThroughSeatIndex = -1},
    ["1"] = { Name = "rear driver", SeatIndex = 1, ThroughSeatIndex = 2},
    ["2"] = { Name = "rear passenger", SeatIndex = 2, ThroughSeatIndex = 1}
}

local function CheckMoves()
    local moveKeys, CurrentGameTimer = {33, 34, 35}, GetGameTimer()
    repeat
        Wait(50)
        for _, v in pairs(moveKeys) do
            if IsControlPressed(0, v) then
                ClearPedTasks(PlayerPedId())
                return
            end
        end
    until IsPedSittingInAnyVehicle(PlayerPedId()) or GetGameTimer() > CurrentGameTimer + 5000
end

local function GetNumberOfVehicleSeats(vehicle)
    local seats, numberOfSeats = { "seat_dside_f", "seat_dside_r", "seat_dside_r1", "seat_dside_r2", "seat_dside_r3", "seat_dside_r4", "seat_dside_r5", "seat_dside_r6", "seat_dside_r7", "seat_pside_f", "seat_pside_r", "seat_pside_r1", "seat_pside_r2", "seat_pside_r3", "seat_pside_r4", "seat_pside_r5", "seat_pside_r6", "seat_pside_r7" }, 0

    for _, v in pairs(seats) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfSeats = numberOfSeats + 1
        end
    end

    return numberOfSeats
end

local function GetNumberOfVehicleRegularSeats(vehicle)
    local seats, numberOfSeats = { "seat_dside_f", "seat_dside_r", "seat_pside_f", "seat_pside_r" }, 0

    for _, v in pairs(seats) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfSeats = numberOfSeats + 1
        end
    end

    return numberOfSeats
end

local function GetNumberOfVehicleExtraSeats(vehicle)
    local seatsExtra, numberOfExtraSeats = { "seat_dside_r1", "seat_dside_r2", "seat_dside_r3", "seat_dside_r4", "seat_dside_r5", "seat_dside_r6", "seat_dside_r7", "seat_pside_r1", "seat_pside_r2", "seat_pside_r3", "seat_pside_r4", "seat_pside_r5", "seat_pside_r6", "seat_pside_r7" }, 0

    for _, v in pairs(seatsExtra) do
        if GetEntityBoneIndexByName(vehicle, v) ~= -1 then
            numberOfExtraSeats = numberOfExtraSeats + 1
        end
    end

    return numberOfExtraSeats
end

local function EnteringCar(veh)

    local ply = PlayerPedId()
    local plyCoo = GetEntityCoords(ply)

    if (veh == nil or veh == 0) or GetVehicleDoorLockStatus(veh) == 2 or #(GetEntityCoords(veh) - plyCoo) > Config.Distance or IsEntityDead(ply) then return end

    ClearPedTasks(ply)
    ClearPedSecondaryTask(ply)

    if Entering then return end

    if Config.Debug then print("Distance from veh: "..#(GetEntityCoords(veh) - plyCoo)) end

    local CurrentGameTimer, EnterControlPressed = GetGameTimer(), 0

    repeat
        Wait(0)

        if IsControlJustPressed(0, 75) then
            EnterDoublePressed = true
        elseif IsControlPressed(0, 75) then
            EnterControlPressed = EnterControlPressed + 1
        elseif IsControlJustReleased(0, 75) then
            EnterControlPressed = 0
        end
        if Config.Debug then print("Checking for double input. Result: "..tostring(EnterDoublePressed).." Time passed: "..tostring(GetGameTimer() - CurrentGameTimer)) end
    until EnterDoublePressed or GetGameTimer() > CurrentGameTimer + Config.WaitForEnterInput or EnterControlPressed > 20

    Entering = true

    if Config.Debug then print("Result: "..(EnterDoublePressed and "Double Press" or EnterControlPressed > 20 and "Long Press" or "Normal Press")) end

    if Config.Debug and EnterDoublePressed then print("Going to other seat.") end

    local minDistance, minDoorIndex

    if Config.Debug then
        print("---------------------")
    end

    if EnterControlPressed > 20 and GetNumberOfVehicleExtraSeats(veh) > 0 then
        for i = GetNumberOfVehicleRegularSeats(veh), GetNumberOfVehicleRegularSeats(veh) + GetNumberOfVehicleExtraSeats(veh) - 1, 1 do
            Wait(0)
            local distance = #(GetEntryPositionOfDoor(veh, i) - plyCoo)
            if IsVehicleSeatFree(veh, i - 1) then
                if minDistance == nil then
                    minDistance = distance
                    minDoorIndex = i
                end
                if distance < minDistance then
                    minDistance = distance
                    minDoorIndex = i
                end
            end

            if Config.Debug then
                print("Distance from "..(i + 1).."th door: "..distance)
            end
        end
    else
        for i = 0, GetNumberOfVehicleSeats(veh) - 1, 1 do
            Wait(0)
            local distance = #(GetEntryPositionOfDoor(veh, i) - plyCoo)
            if IsVehicleSeatFree(veh, i - 1) then
                if i < 4 and not IsVehicleSeatFree(veh, doors[tostring(i - 1)].ThroughSeatIndex) then EnterDoublePressed = false end
                if minDistance == nil then
                    minDistance = distance
                    minDoorIndex = i
                end
                if distance < minDistance then
                    minDistance = distance
                    minDoorIndex = i
                end
            end

            if Config.Debug then
                if i < 4 then
                    print("Distance from "..doors[tostring(i - 1)].Name.." door: "..distance)
                else
                    print("Distance from "..(i + 1).."th door: "..distance)
                end
            end
        end
    end


    if Config.Debug then
        print("---------------------")
    end

    Wait(0)

    if minDoorIndex then
        minDoorIndex = minDoorIndex - 1

        if minDoorIndex < 3 then
            if Config.Debug then
                if EnterDoublePressed then
                    print("Entering "..doors[tostring(minDoorIndex)].Name.." door, going into "..doors[tostring(doors[tostring(minDoorIndex)].ThroughSeatIndex)].Name.." seat")
                else
                    print("Entering "..doors[tostring(minDoorIndex)].Name.." door")
                end
            end
            TaskEnterVehicle(ply, veh, 10000, EnterDoublePressed and doors[tostring(minDoorIndex)].ThroughSeatIndex or doors[tostring(minDoorIndex)].SeatIndex, 1.0, 1, 0)
        else
            if Config.Debug then
                print("Going to "..(minDoorIndex + 2).."th seat")
            end
            TaskEnterVehicle(ply, veh, 10000, minDoorIndex, 1.0, 1, 0)
        end

        if Config.CheckForMovements then CheckMoves() end
    end

    Wait(1000)

    Entering = false
    EnterDoublePressed = false
end

local function LeavingCar(veh)

    local ply = PlayerPedId()

    if (veh == nil or veh == 0) or GetVehicleDoorLockStatus(veh) == 2 or IsEntityDead(ply) then return end

    if Leaving then return end

    local CurrentGameTimer, ExitControlPressed, ExitDoublePressed = GetGameTimer(), 0, false

    repeat
        Wait(0)
        if IsControlJustPressed(0, 75) then
            ExitDoublePressed = true
        elseif IsControlPressed(0, 75) then
            ExitControlPressed = ExitControlPressed + 1
        elseif IsControlJustReleased(0, 75) then
            ExitControlPressed = 0
        end
        if Config.Debug then print("Checking for exit input. Time pressed: "..tostring(ExitControlPressed)) end
    until ExitDoublePressed or GetGameTimer() > CurrentGameTimer + Config.WaitForExitInput or ExitControlPressed > 14

    Leaving = true

    if Config.Debug then print("Result: "..(ExitDoublePressed and "Double Press" or ExitControlPressed > 14 and "Long Press" or "Normal Press")) end

    if ExitDoublePressed then
        SetVehicleEngineOn(veh, true, true, false)
        TaskLeaveVehicle(ply, veh, 0)
    elseif ExitControlPressed > 14 then
        SetVehicleEngineOn(veh, true, true, false)
        TaskLeaveVehicle(ply, veh, 256)
    end

    Wait(0)

    Leaving = false
end

RegisterCommand('entercar', function()

    Wait(0)

    if IsPedInAnyVehicle(PlayerPedId()) then
        local veh = GetVehiclePedIsIn(PlayerPedId())
        if Config.WaitForExitInput ~= 0 then LeavingCar(veh) end
    else
        local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
        EnteringCar(veh)
    end
end, false)
RegisterKeyMapping('entercar', Locale[Config.Language].SettingsText, 'KEYBOARD', 'F')
--RegisterKeyMapping('entercar', Locale[Config.Language].SettingsText, 'PAD_DIGITALBUTTON', 'RUP_INDEX')


RegisterNetEvent('kc-carseat:enteredVehicle')
AddEventHandler('kc-carseat:enteredVehicle', function(veh)
    local ply = PlayerPedId()
    local waitTime = EnterDoublePressed and 3500 or 50
    while IsPedInAnyVehicle(ply, false) do
        Wait(waitTime)
        if IsPedInAnyVehicle(ply, false) then
            if GetPedInVehicleSeat(veh, 0) == ply then
                if GetIsTaskActive(ply, 165) then
                    SetPedIntoVehicle(ply, veh, 0)
                    SetPedConfigFlag(ply, 184, true)
                end
                waitTime = 50
            else
                waitTime = 300
            end
        end
    end
end)
