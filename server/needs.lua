--[[
    This file defines player-related logic for the dsn-needs resource.

    Variables:
    - Players: Table to store player instances or data.
    - Player: Class definition for player objects, created using lib.class().
    - QBox: Reference to the exported "qbx_core" resource, used for core framework functionality.

    Dependencies:
    - lib.class(): Assumed to be a class utility for object-oriented programming.
    - qbx_core: External resource providing core server functionality.

    Usage:
    - This file is intended to manage player state and interactions within the dsn-needs system.
]]
local Players = {}
local Needs = lib.class()
local QBox = exports["qbx_core"]

--- Clamps a number to be within the specified minimum and maximum values.
-- @param value number: The value to clamp.
-- @param min number: The minimum value.
-- @param max number: The maximum value.
-- @return number: The clamped value, constrained between min and max.
math.clamp = function(value, min, max)
    return math.max(min, math.min(max, value))
end

--- Initializes a new Player instance.
-- @param source The source identifier for the player.
-- @field source The player's source identifier.
-- @field citizenid The player's citizen ID, retrieved from QBox.
-- @field needs A table containing the player's needs (hygiene and sleep).
-- @field lastUsed A table tracking the last usage times for certain actions.
-- @field saveTimer A timer that periodically saves the player's data every 5 minutes.
-- @usage local player = Player:constructor(source)
function Needs:constructor(source)
    self.source = source
    self.citizenid = QBox:GetPlayer(source)
    self.needs = { hygiene = 100, sleep = 100 }
    self.lastUsed = {}

    Players[self.source] = self

    self:LoadFromDB()

    self.saveTimer = lib.setInterval(300000, function()
        self:Save()
    end)
end

--- Retrieves the Player object associated with the given source.
-- @param source The unique identifier for the player.
-- @return Player The Player object corresponding to the provided source, or nil if not found.
function Needs:Get(source)
    return Players[source]
end

--- Loads the player's hygiene and sleep needs from the database.
-- If the player's data exists in the `dsn_needs` table, their hygiene and sleep values are loaded into `self.needs`.
-- If no data is found for the player, a new entry is created in the database with the player's `citizenid`.
-- @function Player:LoadFromDB
-- @usage Player:LoadFromDB()
-- @see MySQL.query
function Needs:LoadFromDB()
    MySQL.query('SELECT hygiene, sleep FROM dsn_needs WHERE citizenid = ?', { self.citizenid }, function(result)
        if result and result[1] then
            self.needs.hygiene = result[1].hygiene or 100
            self.needs.sleep = result[1].sleep or 100
        else
            MySQL.query('INSERT INTO dsn_needs (citizenid) VALUES (?)', { self.citizenid })
        end
    end)
end

--- Saves the player's current needs (hygiene and sleep) to the database.
-- Updates the 'dsn_needs' table for the player identified by 'citizenid' with the current hygiene and sleep values.
-- @function Player:Save
-- @usage player:Save()
-- @see MySQL.query
function Needs:Save()
    MySQL.query('UPDATE dsn_needs SET hygiene = ?, sleep = ? WHERE citizenid = ?', {
        self.needs.hygiene,
        self.needs.sleep,
        self.citizenid
    })
end

--- Sets the value of a specified need for the player, clamping it between 0 and 100.
-- @param need string The name of the need to set (e.g., "hunger", "thirst").
-- @param value number The new value to assign to the need.
-- @return nil
function Needs:SetNeed(need, value)
    if not self.needs[need] then return end

    local clamped = math.clamp(value, 0, 100)

    if self.needs[need] ~= clamped then
        self.needs[need] = clamped
    end
end

--- Resets the specified need for the player to its maximum value.
-- @param need string The name of the need to reset (e.g., "hunger", "thirst").
-- If the need exists, sets its value to 100, updates the last used time to the current time,
-- and saves the player's state.
function Needs:Reset(need)
    if self.needs[need] then
        self.needs[need] = 100
        self.lastUsed[need] = os.time()
        self:Save()
    end
end

--- Determines if the player can use a specified need based on cooldown.
-- @param need string The name of the need to check.
-- @param cooldown number The cooldown period in seconds.
-- @return boolean True if the need can be used (cooldown has passed), false otherwise.
function Needs:CanUse(need, cooldown)
    local last = self.lastUsed[need]
    return not last or (os.time() - last >= cooldown)
end

--- Destroys the player instance by performing cleanup operations.
-- Clears the player's save timer if it exists, saves the player's data,
-- and removes the player from the global Players table.
function Needs:Destroy()
    if self.saveTimer then
        lib.clearInterval(self.saveTimer)
        self.saveTimer = nil
    end

    self:Save()
    Players[self.source] = nil
end

return Needs