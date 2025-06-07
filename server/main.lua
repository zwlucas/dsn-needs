--[[
    This script initializes core dependencies for the server-side needs system.

    Dependencies:
    - QBox: Exports from the "qbx_core" resource, providing core framework functionality.
    - Player: Module required from 'server.player', likely handling player-related logic.

    Usage:
    - QBox is used to access shared core functions and data.
    - Player module is required for managing player-specific operations.
]]
local QBox = exports["qbx_core"]
local Player = require 'server.player'

--[[
    Initializes the database table for player needs when the MySQL connection is ready.

    - Creates a table named 'dsn_needs' if it does not already exist.
    - The table contains the following columns:
        - citizenid: Unique identifier for the player (VARCHAR(50)), serves as the primary key.
        - hygiene: Integer value representing the player's hygiene level, defaults to 100.
        - sleep: Integer value representing the player's sleep level, defaults to 100.
    - Ensures the table structure is set up before any further database operations.
]]
MySQL.ready(function()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS dsn_needs (
            citizenid VARCHAR(50),
            hygiene INT DEFAULT 100,
            sleep INT DEFAULT 100,
            PRIMARY KEY (citizenid)
        );
    ]])
end)

--[[
    Event Handler: 'QBCore:Server:OnPlayerLoaded'
    This event is triggered when a player has successfully loaded into the server.

    Parameters:
        None explicitly, but 'source' is implicitly available and refers to the player's server ID.

    Actions:
        Calls the Player function with the player's server ID (source) as an argument.
        (Note: The Player function should be defined elsewhere in the codebase.)

    Usage:
        Used to perform actions or initialize data when a player joins the server.
]]
AddEventHandler('QBCore:Server:OnPlayerLoaded', function()
    Player(source)
end)

--[[
    Event handler for 'QBCore:Server:OnPlayerUnload'.

    This function is triggered when a player unloads (disconnects or leaves the server).
    It retrieves the player object using the provided source ID.
    If the player object exists, it calls the Destroy method to clean up and release any resources associated with the player.

    Parameters:
        source (number): The server ID of the player who is unloading.
]]
AddEventHandler('QBCore:Server:OnPlayerUnload', function(source)
    local player = Player:Get(source)
    if player then
        player:Destroy()
    end
end)

--- Registers a server-side callback for handling the use of specific player needs locations.
-- This function checks if the player can use a specified need (e.g., 'hygiene' or 'sleep') based on cooldowns,
-- resets the need if allowed, and notifies the player of the result.
-- @callback dsn-needs:server:useLocation
-- @param source number The source/player ID invoking the callback.
-- @param need string The type of need to be used ('hygiene' or 'sleep').
-- @return boolean Returns true if the need was successfully used and reset, false otherwise.
lib.callback.register('dsn-needs:server:useLocation', function(source, need)
    local player = Player:Get(source)
    if not player then return false end

    if not player:CanUse(need, Config.Needs[need].cooldown) then
        QBox:Notify(source, 'Você precisa esperar um pouco antes de usar isso novamente.', 'error')
        return false
    end

    if need ~= 'hygiene' and need ~= 'sleep' then return false end

    player:Reset(need)

    local message = need == 'hygiene' and 'Você está limpo agora!' or 'Você está descansado agora!'
    QBox:Notify(source, message, 'inform')
    return true
end)

--[[
    Periodically updates player needs (hygiene and sleep) for all players.

    This thread runs in an infinite loop, waiting for a configured interval (`Config.UpdateInterval`)
    between each iteration. For every player object found in `debug.getregistry()._classes.Player`:
      - Decreases the player's hygiene and sleep needs by their respective configured decrease values.
      - Updates the player's needs using `player:SetNeed`.
      - Triggers a client event (`dsn-needs:client:updateEffects`) to update the player's effects on the client side,
        passing the current hygiene and sleep values.

    Dependencies:
      - `Config.UpdateInterval`: Time (in ms) between each update cycle.
      - `Config.Needs.hygiene.decrease`: Amount to decrease hygiene per cycle.
      - `Config.Needs.sleep.decrease`: Amount to decrease sleep per cycle.
      - `player:SetNeed(needType, value)`: Method to update a player's need.
      - `TriggerClientEvent`: Function to send events to the client.

    Note:
      - Assumes that `debug.getregistry()._classes.Player` contains all active player objects.
      - Assumes each player object has `needs` table with `hygiene` and `sleep` fields, and a `source` identifier.
]]
CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        for _, player in pairs(debug.getregistry()._classes.Player) do
            if player then
                local hygiene = player.needs.hygiene - Config.Needs.hygiene.decrease
                local sleep = player.needs.sleep - Config.Needs.sleep.decrease
                
                player:SetNeed('hygiene', hygiene)
                player:SetNeed('sleep', sleep)

                if player.source then
                    TriggerClientEvent('dsn-needs:client:updateEffects', player.source, {
                        hygiene = player.needs.hygiene,
                        sleep = player.needs.sleep
                    })
                end
            end
        end
    end
end)