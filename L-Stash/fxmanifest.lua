fx_version 'adamant'
game 'gta5'

author 'MadeByLommel'
description 'L-Stash'
version '1.0.0'

client_scripts {
  '@es_extended/locale.lua',
  'client/client.lua',
  --'locales/nl.lua',
  --'config.lua'
}

server_scripts {
  '@mysql-async/lib/MySQL.lua',
  'server/server.lua',
  --'locales/nl.lua',
  --'config.lua'
}