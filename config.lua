Config                              = Config or {}

-- Base
Config.WaitForEnterInput            = 300       -- Longer wait times allow for more time to double press, in milliseconds. If you don't want to use this feature, set it to 0
Config.WaitForExitInput             = 200       -- Longer wait times allow for more time to double press, in milliseconds. If you don't want to use this feature, set it to 0
Config.Distance                     = 6.0       -- The distance from the vehicle beyond which the function should not activate
Config.CheckForMovements            = true      -- Should it detects if the player presses any move key (S, D, A except Z) like in regular GTA when entering cars?

-- Locale
Config.Language						= 'en'		-- Currently Available: fr, en

-- Misc
Config.Debug                        = false     -- If you suspect that something isn't working correctly, set 'Config.Debug' to true. This will print debug logs in your console
Config.UpdateChecker                = false     -- Set to false if you don't want to check for resource updates on startup (No need to change this if you're using fivem-checker)
Config.ChangeLog                    = false     -- Set to false if you don't want to display the changelog when a new version is found (No need to change this if you're using fivem-checker)
