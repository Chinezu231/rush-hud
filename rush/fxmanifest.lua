fx_version "bodacious"
game "gta5"
lua54 "yes"

description "Rush Romania @21proxy"


ui_page "prime-ui/dist/index.html" --[["http://localhost:5173"]] --prime-ui/dist/index.html

server_scripts {
    "@vrp/lib/utils.lua",
    "server.lua",
    "scripts/**/server.lua",
}

client_scripts {
    "client.lua",
    "scripts/**/client.lua",
}

shared_scripts {
    "scripts/**/shared.lua",
}

files {
    "prime-ui/dist/**/**",
}