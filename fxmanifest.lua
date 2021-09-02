fx_version 'adamant'

game 'gta5'

description 'ESX DJ Job'

client_scripts {
	'Config.lua',
	'Client/Main.lua'
}

server_scripts {
	'Config.lua',
	'Server/Main.lua'
}

ui_page('Client/html/index.html')

files({
    'Client/html/index.html',
	'Client/html/sounds/*.ogg'
})