fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Greken!'
description 'Job-based stash system using ox_lib, ox_inventory, qbx_core, and ox_target/sleepless_interact'
version '1.0.5'

shared_script {
  '@ox_lib/init.lua',
  'config.lua',
}

files {
  'locales/*.json',
}

client_scripts {
  'client/*.lua',
}

server_scripts {
  'server/*.lua',
  '@oxmysql/lib/MySQL.lua'
}

dependencies {
  'ox_lib',
  'ox_inventory',
  'qbx_core',
  'ox_target',
  'oxmysql',
}
