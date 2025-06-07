# dsn-needs

A basic needs system for QBox (FiveM), providing hygiene and sleep management for players.

## Features

- **Hygiene and Sleep Needs:** Players have hygiene and sleep stats that decrease over time.
- **Interactive Locations:** Players can restore hygiene and sleep by interacting with configured locations (e.g., showers, beds).
- **Blackout Effects:** Low sleep triggers blackout screen effects for immersion.
- **Notifications:** Players receive alerts when needs are low.
- **Persistent Storage:** Player needs are saved and loaded from a MySQL database.

## Requirements

- [QBox Framework (`qbx_core`)](https://github.com/Qbox-project/qbx_core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_target](https://github.com/overextended/ox_target)

## Installation

1. Place the `dsn-needs` folder in your `resources` directory.
2. Ensure dependencies (`qbx_core`, `ox_lib`, `oxmysql`, `ox_target`) are started before this resource.
3. Add `ensure dsn-needs` to your `server.cfg`.

## Configuration

Edit [`config.lua`](config.lua) to customize:

- Update intervals and save intervals
- Cooldowns for hygiene and sleep
- Decrease rates and thresholds for needs
- Notification messages
- Blackout effect duration
- Locations for bath and sleep interactions
- Animation settings

## Usage

- Players interact with configured bath and sleep locations to restore their needs.
- Needs decrease automatically over time.
- Low sleep triggers blackout effects; low hygiene or sleep triggers notifications.
- All data is saved automatically.

## Database

The script creates a `dsn_needs` table in your database:

| Column     | Type         | Description                |
|------------|--------------|----------------------------|
| citizenid  | VARCHAR(50)  | Player's unique identifier |
| hygiene    | INT          | Hygiene level (0-100)      |
| sleep      | INT          | Sleep level (0-100)        |

## Events & Exports

- Server and client events are used for updating needs and triggering effects.
- No public exports are provided.

## Credits

- Author: dsn.lucas(_mm_shuffle_epi32) <dsn.lucas@outlook.com>
- Inspired by QBox and ox_lib ecosystem.