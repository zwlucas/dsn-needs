--[[
    BlackoutActive: A boolean flag indicating whether a blackout event is currently active.

    showingWarning: A table tracking the display state of warning messages for player needs.
        - hygiene: Boolean, true if the hygiene warning is currently being shown.
        - sleep: Boolean, true if the sleep warning is currently being shown.
]]
local BlackoutActive = false
local showingWarning = {
    hygiene = false,
    sleep = false
}

--[[
    Event Handler: 'dsn-needs:client:updateEffects'
    -----------------------------------------------
    Handles updates to player needs effects such as hygiene and sleep.

    Parameters:
        data (table): Contains the following fields:
            - hygiene (number): The player's current hygiene level.
            - sleep (number): The player's current sleep level.

    Functionality:
        - Checks if the player's hygiene or sleep levels fall below their respective thresholds as defined in Config.Needs.
        - If a need is below its threshold and a warning is not already being shown, displays a notification alert for that need.
        - Resets the warning state if the need returns above the threshold.
        - If sleep is below its threshold, activates a blackout effect by setting BlackoutActive to true and starting the blackout thread.
        - Deactivates the blackout effect if sleep returns above the threshold.

    Dependencies:
        - Config.Needs: Configuration table containing threshold values for needs.
        - Config.Notifications: Notification messages for each need.
        - lib.notify: Function to display notifications.
        - showingWarning: Table tracking which warnings are currently being shown.
        - BlackoutActive: Boolean indicating if the blackout effect is active.
        - StartBlackoutThread: Function to initiate the blackout effect.
--]]
RegisterNetEvent('dsn-needs:client:updateEffects', function(data)
    local hygiene = data.hygiene
    local sleep = data.sleep

    if hygiene < Config.Needs.hygiene.threshold and not showingWarning.hygiene then
        showingWarning.hygiene = true
        lib.notify({
            title = Config.Notifications.hygiene,
            type = 'alert',
        })
    elseif hygiene >= Config.Needs.hygiene.threshold then
        showingWarning.hygiene = false
    end

    if sleep < Config.Needs.sleep.threshold and not showingWarning.sleep then
        showingWarning.sleep = true
        lib.notify({
            title = Config.Notifications.sleep,
            type = 'alert',
        })
    elseif sleep >= Config.Needs.sleep.threshold then
        showingWarning.sleep = false
    end

    if sleep < Config.Needs.sleep.threshold then
        BlackoutActive = true
        StartBlackoutThread()
    elseif sleep >= Config.Needs.sleep.threshold then
        BlackoutActive = false
    end
end)

--- Starts a new thread that continuously toggles a blackout effect on the player's screen.
-- While `BlackoutActive` is true, the screen will fade out and in repeatedly,
-- with each fade lasting for `Config.Blackout.duration` milliseconds.
-- After each fade-in, there is an additional random wait of up to 3 seconds before repeating.
function StartBlackoutThread()
    CreateThread(function()
        while BlackoutActive do
            DoScreenFadeOut(Config.Blackout.duration)
            Wait(Config.Blackout.duration)
            DoScreenFadeIn(Config.Blackout.duration)
            Wait(Config.Blackout.duration + math.random(0, 3000))
        end
    end)
end

--[[
    Event Handler: 'dsn-needs:client:startInteraction'

    Triggered when a player starts interacting with a specific "need" (e.g., hunger, thirst).

    Parameters:
        need (string): The type of need the player is interacting with.

    Functionality:
        - Retrieves the animation configuration for the specified need from Config.Anims.
        - If no animation is found, the function exits.
        - Starts the corresponding scenario animation for the player's ped.
        - Freezes the player's position to prevent movement during the interaction.
        - Displays a progress bar with settings defined by the animation configuration.
        - After the progress bar completes, clears the player's tasks and unfreezes their position.
        - Calls a server callback ('dsn-needs:server:useLocation') to handle the need usage logic on the server side.
]]
AddEventHandler('dsn-needs:client:startInteraction', function(need)
    local anim = Config.Anims[need]
    if not anim then return end

    local ped = PlayerPedId()
    TaskStartScenarioInPlace(ped, anim.scenario, 0, true)
    FreezeEntityPosition(ped, true)

    lib.progressBar({
        duration = anim.duration,
        label = anim.label,
        useWhileDead = false,
        canCancel = false,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    })

    ClearPedTasksImmediately(ped)
    FreezeEntityPosition(ped, false)

    lib.callback.await('dsn-needs:server:useLocation', false, need)
end)

--[[
    Initializes interactive zones for bath and sleep locations using the ox_target resource.

    For each location defined in Config.BathLocations:
        - Adds a box zone at the specified coordinates.
        - Sets the zone size to 1.5x1.5x2.0 units.
        - Registers an interaction option:
            - Name: 'banho'
            - Icon: Shower icon (fas fa-shower)
            - Label: 'Tomar Banho'
            - On selection, triggers the 'dsn-needs:client:startInteraction' event with 'hygiene' as the argument.

    For each location defined in Config.SleepLocations:
        - Adds a box zone at the specified coordinates.
        - Sets the zone size to 1.5x1.5x2.0 units.
        - Registers an interaction option:
            - Name: 'sono'
            - Icon: Bed icon (fas fa-bed)
            - Label: 'Dormir'
            - On selection, triggers the 'dsn-needs:client:startInteraction' event with 'sleep' as the argument.

    This setup allows players to interact with specific locations in the game world to perform hygiene or sleep actions.
]]
CreateThread(function()
    for _, location in pairs(Config.BathLocations) do
        exports["ox_target"]:addBoxZone({
            coords = location.coords,
            size = vec3(1.5, 1.5, 2.0),
            rotation = 0,
            options = {
                {
                    name = 'banho',
                    icon = 'fas fa-shower',
                    label = 'Tomar Banho',
                    onSelect = function()
                        TriggerEvent('dsn-needs:client:startInteraction', 'hygiene')
                    end
                }
            }
        })
    end

    for _, location in pairs(Config.SleepLocations) do
        exports["ox_target"]:addBoxZone({
            coords = location.coords,
            size = vec3(1.5, 1.5, 2.0),
            rotation = 0,
            options = {
                {
                    name = 'sono',
                    icon = 'fas fa-bed',
                    label = 'Dormir',
                    onSelect = function()
                        TriggerEvent('dsn-needs:client:startInteraction', 'sleep')
                    end
                }
            }
        })
    end
end)