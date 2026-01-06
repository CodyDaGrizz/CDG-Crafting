# cdg-crafting

Modern crafting for FiveM:
- Bench locations with per-bench recipe pools
- Per-category XP + leveling
- Permanent blueprint learning (use once, learn forever)
- True server-side crafting queue
- Missing materials shown in UI

## Dependencies
- `qbx_core`
- `ox_lib`
- `ox_inventory`
- `ox_target`
- `oxmysql`

## Installation
1. Drop the folder into your resources (recommended):
   `resources/[cdg]/cdg-crafting`

2. Import SQL:
   - Run `sql/install.sql` on your server database.

3. Ensure in `server.cfg` **in this order**:
   ```
   ensure qbx_core
   ensure ox_lib
   ensure ox_inventory
   ensure ox_target
   ensure cdg-crafting
   ```

4. Restart your server, or:
   ```
   restart cdg-crafting
   ```

## Creating New Blueprints
A blueprint is simply:
1) An **ox_inventory item** (so it exists + can be used)
2) A `Config.Blueprints` entry in `shared/config.lua` that defines what it teaches

### Step 1: Add blueprint item to ox_inventory
Add to your items file (commonly `ox_inventory/data/items.lua`):
```lua
['blueprint_example'] = {
  label = 'Blueprint: Example',
  weight = 50,
  stack = true,
  close = true,
  description = 'A crafting blueprint that permanently unlocks an example recipe.'
},
```

### Step 2: Add blueprint to cdg-crafting config
In `cdg-crafting/shared/config.lua`:
```lua
Config.Blueprints['blueprint_example'] = {
  label = 'Blueprint: Example',
  teaches = { 'example_recipe_id' },
  consumeOnUse = true
}
```

### Step 3: Ensure the recipe exists
The recipe ID in `teaches` must exist in `Config.Recipes`.

## Blueprint Requirements Per Recipe
- By default: recipes require blueprints
- To make a recipe craftable without a blueprint:
```lua
requiresBlueprint = false
```

## ox_inventory Items to Add
Below are the base crafting materials used for all crafts.

```lua
['steel'] = { label = 'Steel', weight = 600, stack = true, close = true, description = 'Refined steel used in construction and manufacturing.' },
['aluminum'] = { label = 'Aluminum', weight = 300, stack = true, close = true, description = 'Lightweight metal commonly used in crafting and repairs.' },
['copper'] = { label = 'Copper', weight = 350, stack = true, close = true, description = 'Highly conductive metal used in wiring and electronics.' },
['electronics'] = { label = 'Electronics', weight = 250, stack = true, close = true, description = 'Salvaged electronic components and circuitry.' },
['plastic'] = { label = 'Plastic', weight = 200, stack = true, close = true, description = 'Reusable plastic materials from various sources.' },
['glass'] = { label = 'Glass', weight = 300, stack = true, close = true, description = 'Broken and intact glass suitable for recycling.' },
['rubber'] = { label = 'Rubber', weight = 250, stack = true, close = true, description = 'Durable rubber materials reclaimed from old goods.' },
['titanium'] = { label = 'Titanium', weight = 700, stack = true, close = true, description = 'High-strength lightweight metal used in advanced crafting.' },

['gunpowder'] = { label = 'Gunpowder', weight = 200, stack = true, close = true, description = 'A Source of ignition for all ammo.' },
['charcoal'] = { label = 'Charcoal', weight = 200, stack = true, close = true, description = 'A core resource for crafting.' },
['sulfur'] = { label = 'Sulfur', weight = 200, stack = true, close = true, description = 'A core resource for crafting.' },

['silver_nugget'] = { label = 'Silver Nugget', weight = 200, stack = true, close = true, description = 'A semi-valuable nugget.' },
['gold_nugget'] = { label = 'Gold Nugget', weight = 200, stack = true, close = true, description = 'A valuable nugget.' },

['gold_bar'] = { label = 'Gold bar', weight = 800, stack = true, close = true, description = 'A very valuable metal bar.' },
['silver_bar'] = { label = 'Silver bar', weight = 800, stack = true, close = true, description = 'A valuable metal bar.' },
```

## Blueprint Items to Add (Ammo + Realistic Guns)
```lua
['blueprint_pistol_ammo'] = {
  label = 'Blueprint: Pistol Ammo',
  weight = 50,
  stack = true,
  close = true,
  description = 'A crafting blueprint that permanently unlocks the Basic Pistol Ammo recipe.'
},

['blueprint_weapon_pistol'] = { label='Blueprint: Pistol', weight=50, stack=true, close=true, description='Permanently unlocks the Pistol craft.' },
['blueprint_weapon_combatpistol'] = { label='Blueprint: Combat Pistol', weight=50, stack=true, close=true, description='Permanently unlocks the Combat Pistol craft.' },
['blueprint_weapon_appistol'] = { label='Blueprint: AP Pistol', weight=50, stack=true, close=true, description='Permanently unlocks the AP Pistol craft.' },
['blueprint_weapon_pistol50'] = { label='Blueprint: Pistol .50', weight=50, stack=true, close=true, description='Permanently unlocks the Pistol .50 craft.' },
['blueprint_weapon_snspistol'] = { label='Blueprint: SNS Pistol', weight=50, stack=true, close=true, description='Permanently unlocks the SNS Pistol craft.' },
['blueprint_weapon_heavypistol'] = { label='Blueprint: Heavy Pistol', weight=50, stack=true, close=true, description='Permanently unlocks the Heavy Pistol craft.' },
['blueprint_weapon_revolver'] = { label='Blueprint: Revolver', weight=50, stack=true, close=true, description='Permanently unlocks the Revolver craft.' },

['blueprint_weapon_microsmg'] = { label='Blueprint: Micro SMG', weight=50, stack=true, close=true, description='Permanently unlocks the Micro SMG craft.' },
['blueprint_weapon_smg'] = { label='Blueprint: SMG', weight=50, stack=true, close=true, description='Permanently unlocks the SMG craft.' },
['blueprint_weapon_assaultsmg'] = { label='Blueprint: Assault SMG', weight=50, stack=true, close=true, description='Permanently unlocks the Assault SMG craft.' },

['blueprint_weapon_pumpshotgun'] = { label='Blueprint: Pump Shotgun', weight=50, stack=true, close=true, description='Permanently unlocks the Pump Shotgun craft.' },
['blueprint_weapon_sawnoffshotgun'] = { label='Blueprint: Sawed-Off Shotgun', weight=50, stack=true, close=true, description='Permanently unlocks the Sawed-Off Shotgun craft.' },

['blueprint_weapon_assaultrifle'] = { label='Blueprint: Assault Rifle', weight=50, stack=true, close=true, description='Permanently unlocks the Assault Rifle craft.' },
['blueprint_weapon_carbinerifle'] = { label='Blueprint: Carbine Rifle', weight=50, stack=true, close=true, description='Permanently unlocks the Carbine Rifle craft.' },
['blueprint_weapon_advancedrifle'] = { label='Blueprint: Advanced Rifle', weight=50, stack=true, close=true, description='Permanently unlocks the Advanced Rifle craft.' },

['blueprint_weapon_sniperrifle'] = { label='Blueprint: Sniper Rifle', weight=50, stack=true, close=true, description='Permanently unlocks the Sniper Rifle craft.' },

