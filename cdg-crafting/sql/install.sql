CREATE TABLE IF NOT EXISTS cdg_crafting_skills (
  citizenid VARCHAR(64) NOT NULL,
  category VARCHAR(64) NOT NULL,
  xp INT NOT NULL DEFAULT 0,
  level INT NOT NULL DEFAULT 1,
  PRIMARY KEY (citizenid, category)
);

CREATE TABLE IF NOT EXISTS cdg_crafting_blueprints (
  citizenid VARCHAR(64) NOT NULL,
  recipe_id VARCHAR(64) NOT NULL,
  learned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (citizenid, recipe_id)
);
