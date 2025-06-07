fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'dsn.lucas(_mm_shuffle_epi32) <dsn.lucas@outlook.com>'
description 'Basic needs system for QBox, including hygiene and sleep management.'
version '1.0.0'

dependency 'ox_lib'

shared_scripts(
    '@ox_lib/init.lua',
    'config.lua'
)

client_scripts(
    'client/main.lua'
)

server_scripts(
    '@oxmysql/lib/MySQL.lua',
    'server/player.lua',
    'server/main.lua'
)