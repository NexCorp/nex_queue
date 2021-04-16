fx_version 'cerulean'
games { 'gta5' }

description 'A QueueSystem for NexCore'

version '1.0.0'

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	'config.lua',
	'server.lua'
}

client_script 'client.lua'
