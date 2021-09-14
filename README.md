# qb-ambulancejob
EMS Job and Death/Wound Logic for QB-Core Framework :ambulance:

# License

    QBCore Framework
    Copyright (C) 2021 Joshua Eger

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-radialmenu](https://github.com/qbcore-framework/qb-radialmenu) - Job Actions Menu 
- [qb-logs](https://github.com/qbcore-framework/qb-logs) - Keeping logs
- [qb-hud](https://github.com/qbcore-framework/qb-hud) - 
- [qb-phone](https://github.com/qbcore-framework/qb-phone) - EMS Emails and other stuff
- [qb-policejob](https://github.com/qbcore-framework/qb-policejob) - Things across departments (See each others blip on map, panic button, alerts etc.)
- [qb-inventory](https://github.com/qbcore-framework/qb-inventory) - Inventory related stuff (Armory) 
- [qb-vehiclekeys](https://github.com/qbcore-framework/qb-vehiclekeys) - Job vehicle's ownership

## Screenshots
![Check In](https://imgur.com/ZrshDaK.png)
![Bed](https://imgur.com/AvS7I7b.png)
![Healed](https://imgur.com/7SAzgqc.png)
![Duty Toggle](https://imgur.com/5FTagcG.png)
![Radialmenu](https://imgur.com/VGrSMDy.png)
![Elevator](https://imgur.com/UyYLksU.png)
![Armory](https://imgur.com/uqTeGL1.png)
![Vehicles](https://imgur.com/bgsQtpA.png)
![Heliopter](https://imgur.com/VG5yQU7.png)

## Features
- Job actions menu (qb-radialmenu needed)
- On Duty/Off Duty
- Colleague blips on map
- Elevator for hospital
- Wounding & bleeding system with body parts (head, neck, rfinger etc.)
- Painkillers & bandage
- Armory for EMS
- Vehicle & helicopter spawner
- Check in & AI doctor system (usable when less than configured player doctor count)
- Revive & heal & check nearby player
- Last stand & dead system
- Blood drop system

### Commands
- /status - Shows nearby players' status
- /heal - Heals nearby plyer
- /revivep - Revives nearby player
- /revive [id] - Revive a player or yourself (superadmin only)
- /setpain [id] - Sets the pain to a player or yourself (superadmin only)
- /kill [id] - Kill a player or yourself (superadmin only)


## Installation
### Manual
- Download the script and put it in the `[qb]` directory.
- Add the following code to your server.cfg/resouces.cfg
```
ensure qb-core
ensure qb-ambulancejob
ensure qb-radialmenu
ensure qb-logs
ensure qb-hud
ensure qb-phone
ensure qb-policejob
ensure qb-inventory
ensure qb-vehiclekeys
```

## Configuration
```
Config = {} -- Don't touch

Config.MinimalDoctors = 2 -- Minimum doctors needed for AI doctor functions to be disabled

Config.Locations = {
    ["checking"] = vector4(308.19, -595.35, 43.29, 0.0), -- Check in marker
    ["duty"] = {
        [1] = vector4(311.18, -599.25, 43.29, 0.0), -- On Duty/Off Duty marker
        [2] = vector4(-254.88, 6324.5, 32.58, 0.0),
    },    
    ["vehicle"] = {
        [1] = vector4(294.578, -574.761, 43.179, 35.792), -- Job vehicles marker
        [2] = vector4(-234.28, 6329.16, 32.15, 222.5),
    },
    ["helicopter"] = {
        [1] = vector4(351.58, -587.45, 74.16, 160.5), -- Helicopter spawner marker
        [2] = vector4(-475.43, 5988.353, 31.716, 31.34),
    },    
    ["armory"] = {
        [1] = vector4(309.93, -602.94, 43.29, 90.654), -- Armory location
        [2] = vector4(-245.13, 6315.71, 32.82, 90.654),
    },
    ["roof"] = {
        [1] = vector4(338.5, -583.85, 74.16, 245.5), -- Roof coordinates
    },
    ["main"] = {
        [1] = vector4(298.44, -599.7, 43.29, 76.0), -- Elevator coordinates
    },        
    ["beds"] = { -- Beds for wounded players
        [1] = {coords = vector4(353.1, -584.6, 43.11, 152.08), taken = false, model = 1631638868},
        [2] = {coords = vector4(356.79, -585.86, 43.11, 152.08), taken = false, model = 1631638868},
        [3] = {coords = vector4(354.12, -593.12, 43.1, 336.32), taken = false, model = 2117668672},
        [4] = {coords = vector4(350.79, -591.8, 43.1, 336.32), taken = false, model = 2117668672},
        [5] = {coords = vector4(346.99, -590.48, 43.1, 336.32), taken = false, model = 2117668672}, 
        [6] = {coords = vector4(360.32, -587.19, 43.02, 152.08), taken = false, model = -1091386327},
        [7] = {coords = vector4(349.82, -583.33, 43.02, 152.08), taken = false, model = -1091386327}, 
        [8] = {coords = vector4(326.98, -576.17, 43.02, 152.08), taken = false, model = -1091386327},
    }, 
    ["stations"] = { -- Blips
        [1] = {label = "Doctor's Post Paleto", coords = vector4(-254.88, 6324.5, 32.58, 3.5)},
        [2] = {label = "Pillbox Hospital", coords = vector4(304.27, -600.33, 43.28, 272.249)}
    }
}

Config.Vehicles = { -- Allowed vehicles for EMS
    ["ambulance"] = "Ambulance",
}

Config.Whitelist = { -- Armory whitelist
    "GAA35566",
}

Config.Helicopter = "polmav" -- Allowed helicopters

Config.Items = { -- Armory items
    label = "Hospital safe", -- Armory label
    slots = 30,
    items = {
        [1] = {
            name = "radio", -- Item name
            price = 0, -- Item price
            amount = 50, -- Item stock (resets on server restart)
            info = {}, -- Don't touch
            type = "item", -- Don't touch
            slot = 1, -- Item's position on the armory
        },
        [2] = {
            name = "bandage",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 2,
        },
        [3] = {
            name = "painkillers",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 3,
        },
        [4] = {
            name = "firstaid",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 4,
        },
        [5] = {
            name = "weapon_flashlight",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 5,
        },
        [6] = {
            name = "weapon_fireextinguisher",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 6,
        },
    }
}

Config.BillCost = 2000 -- Treatment cost
Config.DeathTime = 300 -- Needed time to be dead after last stand (seconds)
Config.CheckTime = 10 -- Check In time (seconds)

Config.PainkillerInterval = 60 -- (seconds)

------------------ CONFIG SETTINGS BELOW THIS ARE EXPLAINED IN THE CONFIG.LUA ------------------
```
