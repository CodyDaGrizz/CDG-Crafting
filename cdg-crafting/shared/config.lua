Config = Config or {}

-- Toggle ox_target interaction for benches
Config.UseTarget = true

-- Skill categories + XP thresholds
Config.Categories = {
  weapons = {
    label = "Weapons",
    levels = { [1]=0, [2]=500, [3]=1200, [4]=2500, [5]=5000, [6]=8000, [7]=10000, [8]=12000, [9]=15000, [10]=20000 }
  },


 -- crafting = {
  --  label = "Crafting",
  --  levels = { [1]=0, [2]=150, [3]=400, [4]=900, [5]=1600, [6]=2500, [7]=4000, [8]=6000, [9]=8500, [10]=12000 }
 -- },
}

--==================================================================== BENCHES ====================================================================--
Config.Benches = {
  {
    id = "gun_bench",
    label = "Gun Bench",
    coords = vec3(1877.55, 3692.21, 33.55),
    radius = 1.6,
    icon = 'fa-solid fa-gun',
    recipes = {
      "pistol_ammo",
      "pistol_ammo2",
      "pistol_ammo3",
      "rifle_ammo",
      "rifle_ammo2",
      "sniper_ammo",
      "shorgun_ammo",
      "gunpowder",
      "weapon_pistol",
      "weapon_combatpistol",
      "weapon_appistol",
      "weapon_pistol50",
      "weapon_snspistol",
      "weapon_heavypistol",
      "weapon_revolver",
      "weapon_microsmg",
      "weapon_smg",
      "weapon_assaultsmg",
      "weapon_pumpshotgun",
      "weapon_sawnoffshotgun",
      "weapon_assaultrifle",
      "weapon_carbinerifle",
      "weapon_advancedrifle",
      "weapon_sniperrifle"
    }
  }
}

--==================================================================== RECIPES ====================================================================--
Config.Recipes = {
  pistol_ammo = {
    label = "9 Ammo",
    category = "weapons",
    levelRequired = 2,
    craftTime = 2000,
    xpGain = 5,
    -- requiresBlueprint defaults to true if omitted
    ingredients = {
      { item = "copper", count = 10 },
      { item = "gunpowder", count = 10 },
    },
    outputs = {
      { item = "ammo-9", count = 30 }
    }
  },

  pistol_ammo2 = {
    label = "45 Ammo",
    category = "weapons",
    levelRequired = 4,
    craftTime = 2500,
    xpGain = 7,
    ingredients = {
      { item = "copper", count = 16 },
      { item = "gunpowder", count = 14 },
    },
    outputs = {
      { item = "ammo-45", count = 24 }
    }
  },

  rifle_ammo = {
    label = "5.56 Ammo",
    category = "weapons",
    levelRequired = 5,
    craftTime = 3000,
    xpGain = 9,
    ingredients = {
      { item = "copper", count = 18 },
      { item = "gunpowder", count = 16 },
    },
    outputs = {
      { item = "ammo-rifle", count = 30 }
    }
  },

  rifle_ammo2 = {
    label = "7.62 Ammo",
    category = "weapons",
    levelRequired = 7,
    craftTime = 3500,
    xpGain = 11,
    ingredients = {
      { item = "copper", count = 24 },
      { item = "gunpowder", count = 20 },
    },
    outputs = {
      { item = "ammo-rifle2", count = 30 }
    }
  },

  shotgun_ammo = {
    label = "Shotgun Ammo",
    category = "weapons",
    levelRequired = 5,
    craftTime = 2800,
    xpGain = 9,
    ingredients = {
      { item = "copper", count = 14 },
      { item = "gunpowder", count = 18 },
    },
    outputs = {
      { item = "ammo-shotgun", count = 12 }
    }
  },

  sniper_ammo = {
    label = "Sniper Ammo",
    category = "weapons",
    levelRequired = 8,
    craftTime = 4500,
    xpGain = 14,
    ingredients = {
      { item = "copper", count = 26 },
      { item = "gunpowder", count = 22 },
    },
    outputs = {
      { item = "ammo-sniper", count = 10 }
    }
  },

  pistol_ammo3 = {
    label = ".50 Ammo",
    category = "weapons",
    levelRequired = 6,
    craftTime = 3200,
    xpGain = 10,
    ingredients = {
      { item = "copper", count = 20 },
      { item = "gunpowder", count = 20 },
    },
    outputs = {
      { item = "ammo-50", count = 18 }
    }
  },

  gunpowder = {
    label = "Gunpowder",
    category = "weapons",
    levelRequired = 1,
    craftTime = 1000,
    xpGain = 1,
    requiresBlueprint = false,
    ingredients = {
      { item = "charcoal", count = 1 },
      { item = "sulfur", count = 1 },
    },
    outputs = {
      { item = "gunpowder", count = 1 }
    }
  },

  -- Pistols
  weapon_pistol = {
    label = "Pistol",
    category = "weapons",
    levelRequired = 2,
    craftTime = 12000,
    xpGain = 25,
    ingredients = {
      { item = "steel", count = 30 },
      { item = "plastic", count = 20 },
      { item = "rubber", count = 12 },
      { item = "titanium", count = 8 },
      { item = "gunpowder", count = 5 },
    },
    outputs = { { item = "weapon_pistol", count = 1 } }
  },

  weapon_combatpistol = {
    label = "Combat Pistol",
    category = "weapons",
    levelRequired = 3,
    craftTime = 14000,
    xpGain = 30,
    ingredients = {
      { item = "steel", count = 36 },
      { item = "plastic", count = 24 },
      { item = "rubber", count = 14 },
      { item = "titanium", count = 10 },
      { item = "gunpowder", count = 6 },
    },
    outputs = { { item = "weapon_combatpistol", count = 1 } }
  },

  weapon_appistol = {
    label = "AP Pistol",
    category = "weapons",
    levelRequired = 4,
    craftTime = 16000,
    xpGain = 35,
    ingredients = {
      { item = "steel", count = 42 },
      { item = "plastic", count = 26 },
      { item = "rubber", count = 16 },
      { item = "titanium", count = 12 },
      { item = "gunpowder", count = 8 },
    },
    outputs = { { item = "weapon_appistol", count = 1 } }
  },

  weapon_pistol50 = {
    label = "Pistol .50",
    category = "weapons",
    levelRequired = 5,
    craftTime = 18000,
    xpGain = 45,
    ingredients = {
      { item = "steel", count = 50 },
      { item = "plastic", count = 28 },
      { item = "rubber", count = 18 },
      { item = "titanium", count = 14 },
      { item = "gunpowder", count = 10 },
    },
    outputs = { { item = "weapon_pistol50", count = 1 } }
  },

  weapon_snspistol = {
    label = "SNS Pistol",
    category = "weapons",
    levelRequired = 1,
    craftTime = 11000,
    xpGain = 20,
    ingredients = {
      { item = "steel", count = 22 },
      { item = "plastic", count = 16 },
      { item = "rubber", count = 10 },
      { item = "titanium", count = 5 },
      { item = "gunpowder", count = 5 },
    },
    outputs = { { item = "weapon_snspistol", count = 1 } }
  },

  weapon_heavypistol = {
    label = "Heavy Pistol",
    category = "weapons",
    levelRequired = 4,
    craftTime = 17000,
    xpGain = 40,
    ingredients = {
      { item = "steel", count = 46 },
      { item = "plastic", count = 26 },
      { item = "rubber", count = 16 },
      { item = "titanium", count = 12 },
      { item = "gunpowder", count = 9 },
    },
    outputs = { { item = "weapon_heavypistol", count = 1 } }
  },

  weapon_revolver = {
    label = "Revolver",
    category = "weapons",
    levelRequired = 4,
    craftTime = 17000,
    xpGain = 40,
    ingredients = {
      { item = "steel", count = 48 },
      { item = "plastic", count = 22 },
      { item = "rubber", count = 14 },
      { item = "titanium", count = 12 },
      { item = "gunpowder", count = 10 },
    },
    outputs = { { item = "weapon_revolver", count = 1 } }
  },

  -- SMGs
  weapon_microsmg = {
    label = "Micro SMG",
    category = "weapons",
    levelRequired = 5,
    craftTime = 22000,
    xpGain = 55,
    ingredients = {
      { item = "steel", count = 70 },
      { item = "plastic", count = 40 },
      { item = "rubber", count = 24 },
      { item = "titanium", count = 18 },
      { item = "gunpowder", count = 14 },
    },
    outputs = { { item = "weapon_microsmg", count = 1 } }
  },

  weapon_smg = {
    label = "SMG",
    category = "weapons",
    levelRequired = 6,
    craftTime = 24000,
    xpGain = 60,
    ingredients = {
      { item = "steel", count = 80 },
      { item = "plastic", count = 44 },
      { item = "rubber", count = 26 },
      { item = "titanium", count = 20 },
      { item = "gunpowder", count = 16 },
    },
    outputs = { { item = "weapon_smg", count = 1 } }
  },

  weapon_assaultsmg = {
    label = "Assault SMG",
    category = "weapons",
    levelRequired = 7,
    craftTime = 26000,
    xpGain = 70,
    ingredients = {
      { item = "steel", count = 90 },
      { item = "plastic", count = 48 },
      { item = "rubber", count = 28 },
      { item = "titanium", count = 22 },
      { item = "gunpowder", count = 18 },
    },
    outputs = { { item = "weapon_assaultsmg", count = 1 } }
  },

  -- Shotguns
  weapon_pumpshotgun = {
    label = "Pump Shotgun",
    category = "weapons",
    levelRequired = 6,
    craftTime = 26000,
    xpGain = 65,
    ingredients = {
      { item = "steel", count = 95 },
      { item = "plastic", count = 34 },
      { item = "rubber", count = 22 },
      { item = "titanium", count = 18 },
      { item = "gunpowder", count = 16 },
    },
    outputs = { { item = "weapon_pumpshotgun", count = 1 } }
  },

  weapon_sawnoffshotgun = {
    label = "Sawed-Off Shotgun",
    category = "weapons",
    levelRequired = 5,
    craftTime = 23000,
    xpGain = 58,
    ingredients = {
      { item = "steel", count = 80 },
      { item = "plastic", count = 30 },
      { item = "rubber", count = 20 },
      { item = "titanium", count = 16 },
      { item = "gunpowder", count = 14 },
    },
    outputs = { { item = "weapon_sawnoffshotgun", count = 1 } }
  },

  -- Rifles
  weapon_assaultrifle = {
    label = "Assault Rifle",
    category = "weapons",
    levelRequired = 8,
    craftTime = 32000,
    xpGain = 90,
    ingredients = {
      { item = "steel", count = 140 },
      { item = "plastic", count = 60 },
      { item = "rubber", count = 34 },
      { item = "titanium", count = 28 },
      { item = "gunpowder", count = 24 },
    },
    outputs = { { item = "weapon_assaultrifle", count = 1 } }
  },

  weapon_carbinerifle = {
    label = "Carbine Rifle",
    category = "weapons",
    levelRequired = 9,
    craftTime = 34000,
    xpGain = 100,
    ingredients = {
      { item = "steel", count = 150 },
      { item = "plastic", count = 64 },
      { item = "rubber", count = 36 },
      { item = "titanium", count = 30 },
      { item = "gunpowder", count = 26 },
    },
    outputs = { { item = "weapon_carbinerifle", count = 1 } }
  },

  weapon_advancedrifle = {
    label = "Advanced Rifle",
    category = "weapons",
    levelRequired = 10,
    craftTime = 36000,
    xpGain = 115,
    ingredients = {
      { item = "steel", count = 160 },
      { item = "plastic", count = 70 },
      { item = "rubber", count = 38 },
      { item = "titanium", count = 34 },
      { item = "gunpowder", count = 28 },
    },
    outputs = { { item = "weapon_advancedrifle", count = 1 } }
  },

  -- Sniper 
  weapon_sniperrifle = {
    label = "Sniper Rifle",
    category = "weapons",
    levelRequired = 10,
    craftTime = 42000,
    xpGain = 140,
    ingredients = {
      { item = "steel", count = 190 },
      { item = "plastic", count = 60 },
      { item = "rubber", count = 34 },
      { item = "titanium", count = 40 },
      { item = "gunpowder", count = 30 },
    },
    outputs = { { item = "weapon_sniperrifle", count = 1 } }
  },
}

--==================================================================== BLUEPRINTS ====================================================================--
Config.Blueprints = Config.Blueprints or {}


Config.Blueprints['blueprint_pistol_ammo'] = {
  label = "Blueprint: 9 Ammo",
  teaches = { "pistol_ammo" },
  consumeOnUse = true,
}

Config.Blueprints['blueprint_pistol_ammo2'] = {
  label = "Blueprint: 45 Ammo",
  teaches = { "pistol_ammo2" },
  consumeOnUse = true,
}

Config.Blueprints['blueprint_rifle_ammo'] = {
  label = "Blueprint: 5.56 Ammo",
  teaches = { "rifle_ammo" },
  consumeOnUse = true,
}

Config.Blueprints['blueprint_rifle_ammo2'] = {
  label = "Blueprint: 7.62 Ammo",
  teaches = { "rifle_ammo2" },
  consumeOnUse = true,
}

Config.Blueprints['blueprint_shotgun_ammo'] = {
  label = "Blueprint: Shotgun Ammo",
  teaches = { "shotgun_ammo" },
  consumeOnUse = true,
}

Config.Blueprints['blueprint_sniper_ammo'] = {
  label = "Blueprint: Sniper Ammo",
  teaches = { "sniper_ammo" },
  consumeOnUse = true,
}

Config.Blueprints['blueprint_pistol_ammo3'] = {
  label = "Blueprint: 50 Ammo",
  teaches = { "pistol_ammo3" },
  consumeOnUse = true,
}


-- Base Weapons GTA (realistic list)
Config.Blueprints['blueprint_weapon_pistol']          = { label = 'Blueprint: Pistol', teaches = { 'weapon_pistol' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_combatpistol']    = { label = 'Blueprint: Combat Pistol', teaches = { 'weapon_combatpistol' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_appistol']        = { label = 'Blueprint: AP Pistol', teaches = { 'weapon_appistol' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_pistol50']        = { label = 'Blueprint: Pistol .50', teaches = { 'weapon_pistol50' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_snspistol']       = { label = 'Blueprint: SNS Pistol', teaches = { 'weapon_snspistol' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_heavypistol']     = { label = 'Blueprint: Heavy Pistol', teaches = { 'weapon_heavypistol' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_revolver']        = { label = 'Blueprint: Revolver', teaches = { 'weapon_revolver' }, consumeOnUse = true }

Config.Blueprints['blueprint_weapon_microsmg']        = { label = 'Blueprint: Micro SMG', teaches = { 'weapon_microsmg' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_smg']             = { label = 'Blueprint: SMG', teaches = { 'weapon_smg' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_assaultsmg']      = { label = 'Blueprint: Assault SMG', teaches = { 'weapon_assaultsmg' }, consumeOnUse = true }

Config.Blueprints['blueprint_weapon_pumpshotgun']     = { label = 'Blueprint: Pump Shotgun', teaches = { 'weapon_pumpshotgun' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_sawnoffshotgun']  = { label = 'Blueprint: Sawed-Off Shotgun', teaches = { 'weapon_sawnoffshotgun' }, consumeOnUse = true }

Config.Blueprints['blueprint_weapon_assaultrifle']    = { label = 'Blueprint: Assault Rifle', teaches = { 'weapon_assaultrifle' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_carbinerifle']    = { label = 'Blueprint: Carbine Rifle', teaches = { 'weapon_carbinerifle' }, consumeOnUse = true }
Config.Blueprints['blueprint_weapon_advancedrifle']   = { label = 'Blueprint: Advanced Rifle', teaches = { 'weapon_advancedrifle' }, consumeOnUse = true }

Config.Blueprints['blueprint_weapon_sniperrifle']     = { label = 'Blueprint: Sniper Rifle', teaches = { 'weapon_sniperrifle' }, consumeOnUse = true }
