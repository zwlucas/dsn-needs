Config = {}

--[[
    Config.UpdateInterval:
    The interval, in milliseconds, at which the needs system updates player statuses.
    Default: 5 minutes (5 * 60 * 1000 ms).

    Config.SaveInterval:
    The interval, in milliseconds, at which the needs system saves player data to persistent storage.
    Default: 15 minutes (15 * 60 * 1000 ms).
]]
Config.UpdateInterval = 5 * 60 * 1000
Config.SaveInterval = 15 * 60 * 1000

--[[
    Config.Cooldowns

    Table containing cooldown durations (in minutes) for various player needs.

    Fields:
      - hygiene: Number. Cooldown time for hygiene-related actions.
      - sleep: Number. Cooldown time for sleep-related actions.
]]
Config.Cooldowns = {
    hygiene = 10
    sleep = 10
}

--[[
Config.Needs table defines the configuration for player needs in the game.

Fields:
- hygiene: Table containing hygiene-related settings.
    - decrease: (number) Amount by which hygiene decreases over time or per event.
    - threshold: (number) The minimum hygiene value before triggering effects or warnings.

- sleep: Table containing sleep-related settings.
    - decrease: (number) Amount by which sleep decreases over time or per event.
    - threshold: (number) The minimum sleep value before triggering effects or warnings.
]]
Config.Needs = {
    hygiene = {
        decrease = 5,
        threshold = 20
    },
    sleep = {
        decrease = 5,
        threshold = 20
    }
}

--[[
Config.Notifications

A table containing notification messages for different player needs.

Fields:
- hygiene: (string) Message displayed when the player's hygiene is low.
- sleep: (string) Message displayed when the player needs to sleep.

Example usage:
    print(Config.Notifications.hygiene) -- Output: 'Você precisa tomar banho'
    print(Config.Notifications.sleep)   -- Output: 'Você precisa dormir'
]]
Config.Notifications = {
    hygiene = 'Você precisa tomar banho',
    sleep = 'Você precisa dormir',
}

--[[
    Config.Blackout

    Configuration table for blackout settings.

    Fields:
    - duration (number): Duration of the blackout in milliseconds. 
      In this configuration, the blackout lasts for 3 seconds (3 * 1000 ms).
]]
Config.Blackout = {
    duration = 3 * 1000
}

--[[
    Config.BathLocations

    A table containing locations where players can take a bath.

    Each entry in the table is a table with the following fields:
      - coords: vec3
          The 3D coordinates (x, y, z) of the bath location.
      - label: string
          A human-readable label describing the bath location.

    Example:
      {
          coords = vec3(-38.67, -581.93, 78.87),
          label = 'Banheiro do Apartamento'
      }
]]
Config.BathLocations = {
    { coords = vec3(-38.67, -581.93, 78.87), label = 'Banheiro do Apartamento' }
}

--[[
    Config.SleepLocations

    A table containing locations where players can sleep.
    Each entry in the table is a table with the following fields:
      - coords: A vec3 object specifying the x, y, z coordinates of the sleep location.
      - label: A string representing the name or description of the sleep location.

    Example:
      {
        coords = vec3(-35.9, -584.01, 78.83),
        label = 'Cama do Apartamento'
      }
]]
Config.SleepLocations = {
    { coords = vec3(-35.9, -584.01, 78.83), label = 'Cama do Apartamento' }
}

--[[
Config.Anims

A table containing animation configurations for different player actions.

Fields:
- hygiene: Table
    - scenario (string): The animation scenario used for hygiene (e.g., taking a bath).
    - duration (number): Duration of the animation in milliseconds.
    - label (string): Description label shown during the animation.
- sleep: Table
    - scenario (string): The animation scenario used for sleeping.
    - duration (number): Duration of the animation in milliseconds.
    - label (string): Description label shown during the animation.
]]
Config.Anims = {
    hygiene = {
        scenario = 'WORLD_HUMAN_BUM_WASH',
        duration = 10000,
        label = 'Tomando banho...'
    },
    sleep = {
        scenario = 'WORLD_HUMAN_SLEEPING',
        duration = 10000,
        label = 'Dormindo...'
    }
}