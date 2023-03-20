local GithubL, Changelog

local Version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) -- Do Not Change This Value
local Github = GetResourceMetadata(GetCurrentResourceName(), 'github', 0) -- Do Not Change This Value
local Updater = false

-------- Check if new update available
CreateThread(function()

    local Resources = GetNumResources()

    for i = 0, Resources, 1 do
        local resource = GetResourceByFindIndex(i)
        UpdateResource(resource)
    end

    Wait(4000)

    if Updater == false then
        if Config.UpdateChecker then
            Updater = not Updater
            UpdateChecker()
        end
    end

end)

function UpdateResource(resource)
    if resource == 'fivem-checker' then
        if GetResourceState(resource) == 'started' or GetResourceState(resource) == 'starting' then
            if Config.UpdateChecker then
                Updater = true
            end
        end
    end
end

----------------

function UpdateChecker()

    if string.find(Github, "github") then
        if string.find(Github, "github.com") then
            GithubL = Github
            Github = string.gsub(Github, "github", "raw.githubusercontent")..'/master/version'
        else
            GithubL = string.gsub(Github, "raw.githubusercontent", "github"):gsub("/master", "")
            Github = Github..'/version'
        end
    end
    PerformHttpRequest(Github, function(Error, V, Header)
        NewestVersion = V
    end)
    repeat
        Wait(10)
    until NewestVersion ~= nil

    local function formatChangelog(text)
        local formattedChangelog = {}
        for line in string.gmatch(text, "<[^>]+>%s*-%s*([^\n]+)") do
            table.insert(formattedChangelog, "- " .. line)
        end
        return table.concat(formattedChangelog, "\n")
    end

    local _, strings = string.gsub(NewestVersion, "\n", "\n")
    Version1 = NewestVersion:match("[^\n]*"):gsub("[<>]", "")
    if strings > 0 then
        Changelog = NewestVersion:gsub(Version1,""):match("(.*" .. Version .. ")"):gsub(Version,"")
        Changelog = formatChangelog(Changelog)
        NewestVersion = Version1
    end

    local function parseVersion(versionStr)
        local major, minor, patch = versionStr:match("(%d+)%.(%d+)%.(%d+)")
        if not major then
            major, minor = versionStr:match("(%d+)%.(%d+)")
            patch = 0
        end
        return {major = tonumber(major), minor = tonumber(minor), patch = tonumber(patch)}
    end

    local currentVersion = parseVersion(Version)
    local newVersion = parseVersion(Version1)

    local function compareVersions(v1, v2)
        if v1.major < v2.major then return -1 end
        if v1.major > v2.major then return 1 end
        if v1.minor < v2.minor then return -1 end
        if v1.minor > v2.minor then return 1 end
        if v1.patch < v2.patch then return -1 end
        if v1.patch > v2.patch then return 1 end
        return 0
    end

    local function getUpdateType(current, new)
        if current.major < new.major then
            return "Major"
        elseif current.minor < new.minor then
            return "Minor"
        else
            return "Patch"
        end
    end

    local versionComparison = compareVersions(currentVersion, newVersion)

    print('')
    print('^9Standalone '..GetResourceMetadata(GetCurrentResourceName(), 'name', 0)..' ('..GetCurrentResourceName()..')') -- ^6KC Car Seat
    if versionComparison == 0 then
        print('^2Version ' .. Version .. ' - Up to date!')
    elseif versionComparison == -1 then
        print('^1Version ' .. Version .. ' - Outdated!')
        print('^1New version: v' .. Version1)
        local updateType = getUpdateType(currentVersion, newVersion)
        print('^3Update type: ' .. updateType)
        if Config.ChangeLog then
            print('\n^3Changelog:')
            print('^4'..Changelog..'\n')
        end
        print('^1Please check the GitHub and download the last update')
        print('^2'..GithubL..'/releases/latest')
    else
        print('^3Version ' .. Version .. ' - You are running a newer version than the latest release!')
    end
    print('')
end

----------------

RegisterNetEvent('baseevents:enteredVehicle', function(vehId)
    local src = source

    TriggerClientEvent('kc-carseat:enteredVehicle', src, vehId)
end)