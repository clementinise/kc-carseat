Config                              = Config or {}

-- Base
Config.WaitForDoubleInput           = 300       -- Longer wait times allow for more time to double press (Milliseconds)
Config.Distance                     = 6.0       -- The distance from the vehicle beyond which the function should not activate
Config.FacingOnly                   = false     -- Should it only detect cars in front of the player when attempting to enter them? This can be helpful when close to two cars, but it may occasionally be inaccurate

-- Locale
Config.Language						= 'en'		-- Currently Available: fr, en

-- Misc
Config.Debug                        = false     -- If you suspect that something isn't working correctly, set 'Config.Debug' to true. This will print debug logs in your console
Config.UpdateChecker                = false     -- Set to false if you don't want to check for resource updates on startup (No need to change this if you're using fivem-checker)
Config.ChangeLog                    = false     -- Set to false if you don't want to display the changelog when a new version is found (No need to change this if you're using fivem-checker)