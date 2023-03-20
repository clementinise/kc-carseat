fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Clementinise'
name 'KC Car Seat'
description 'Allow players to enter a vehicle through any door'
github 'https://github.com/clementinise/kc-carseat'
version '1.0'

shared_scripts {
	'locales/*.lua',
	'config.lua',
}

client_script 'client/client.lua'

server_script 'server/server.lua'

fivem_checker 'yes'