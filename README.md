# qb-ambulancejob
EMS Job and Death/Wound Logic for QB-Core Framework :ambulance:

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
    ["checking"] = {x = 309.08, y = -592.91, z = 43.28, h = 0.0}, -- Check in marker
    ["duty"] = {
        [1] = {x = 304.27, y = -600.33, z = 43.28, h = 0.0}, -- On Duty/Off Duty marker
        [2] = {x = -254.88, y = 6324.5, z = 32.58, h = 0.0},
    },    
    ["vehicle"] = {
        [1] = {x = 294.578, y = -574.761, z = 43.179, h = 35.792}, -- Job vehicles marker
        [2] = {x = -234.28, y = 6329.16, z = 32.15, h = 222.5},
    },
    ["helicopter"] = {
        [1] = {x = 351.58, y = -587.45, z = 74.16, h = 160.5}, -- Helicopter spawner marker
        [2] = {x = -475.43, y = 5988.353, z = 31.716, h = 31.34},
    },    
    ["armory"] = {
        [1] = {x = 306.26, y = -601.7, z = 43.28, h = 90.654}, -- Armory location
        [2] = {x = -245.13, y = 6315.71, z = 32.82, h = 90.654},
    },
    ["roof"] = {
        [1] = {x = 338.5, y = -583.85, z = 74.16, h = 245.5}, -- Roof coordinates
    },
    ["main"] = {
        [1] = {x = 332.51, y = -595.74, z = 43.28, h = 76.0}, -- Elevator coordinates
    },        
    ["beds"] = { -- Beds for wounded players
        [1] = {x = 311.13, y = -582.89, z = 43.53, h = 335.65, taken = false, model = 1631638868},
        [2] = {x = 313.96, y = -579.05, z = 43.53, h = 164.5, taken = false, model = 1631638868},
        [3] = {x = 314.58, y = -584.09, z = 43.53, h = 335.65, taken = false, model = 1631638868},
        [4] = {x = 317.74, y = -585.29, z = 43.53, h = 335.65, taken = false, model = 1631638868},
        [5] = {x = 319.47, y = -581.04, z = 43.53, h = 164.5, taken = false, model = 1631638868}, 
        [6] = {x = 366.43, y = -581.54, z = 43.28, h = 66.5, taken = false, model = 1631638868}, 
        [7] = {x = 364.93, y = -585.86, z = 43.28, h = 67.5, taken = false, model = 1631638868}, 
        [8] = {x = 363.82, y = -589.09, z = 43.28, h = 68.5, taken = false, model = 1631638868},
    }
}

Config.Vehicles = { -- Allowed vehicles for EMS
    ["asprinter"] = "Mercedes-Benz Sprinter",
    ["aeklasse"] = "Mercedes-Benz E-Klasse",
}

Config.Whitelist = { -- Armory whitelist
    "GAA35566",
}

Config.Helicopter = "alifeliner" -- Allowed helicopters

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
            name = "weapon_flashlight",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 4,
        },
        [5] = {
            name = "weapon_fireextinguisher",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 5,
        },
    }
}

Config.BillCost = 2000 -- Treatment cost
Config.DeathTime = 300 -- Needed time to be dead after last stand (seconds)
Config.CheckTime = 10 -- Check In time (seconds)

Config.PainkillerInterval = 60 -- (seconds)

------------------ CONFIG SETTINGS BELOW THIS ARE EXPLAINED IN THE CONFIG.LUA ------------------
```
