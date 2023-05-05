package.path = package.path .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/share/lua/5.3/socket/?.lua"
package.path = package.path .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/share/lua/5.3/?.lua"
package.cpath = package.cpath .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/lib/lua/5.3/socket/?.so"
package.cpath = package.cpath .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/lib/lua/5.3/?.so"

local socket = require("socket")
local client = socket.tcp()
client:connect("localhost", 12345)

local peername = client:getpeername()

print("Client [" .. peername .. "] connected.\n")

while true do
    io.write("\n> ")

    local data = io.read("l")
    client:send(data .. "\n")

    local response, err = client:receive()

    if not err then
        print("Client received: " .. response)
    else
        print("Error:", err)
        break
    end
end

print("Client [" .. peername .. "]  disconnected.\n")
client:close()