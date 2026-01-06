fx_version 'cerulean'
game 'gta5'

name 'cdg-crafting'
author 'CodyDaGrizz'
description 'Modern crafting benches w/ blueprint system'
version '1.2.0'

lua54 'yes'

shared_scripts {
  '@ox_lib/init.lua',
  'shared/config.lua',
}

client_scripts {
  'client/main.lua',
}

server_scripts {
  'server/db.lua',
  'server/main.lua',
}

ui_page 'web/index.html'

files {
  'web/index.html',
  'web/style.css',
  'web/app.js',
  'README.md',
  'sql/install.sql',
}
