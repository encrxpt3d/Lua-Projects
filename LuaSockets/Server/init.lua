package.path = package.path .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/share/lua/5.3/socket/?.lua"
package.path = package.path .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/share/lua/5.3/?.lua"
package.cpath = package.cpath .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/lib/lua/5.3/socket/?.so"
package.cpath = package.cpath .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/lib/lua/5.3/?.so"

local socket = require("socket")
local server = socket.tcp()
server:setoption("reuseaddr", true)
server:bind("localhost", 12345)
server:listen(1)
print("\nServer [" .. server:getsockname() .. "] initialized.")

while true do
    local client = server:accept()
    client:settimeout(5)

    print("Client [" .. client:getpeername() .. "] has been connected.\n")
    
    local data, err = client:receive()
    if not err then
        print("Server received: " .. data)

        client:send(data)
    else
        print("Error:", err)
    end

    --print("Client [" .. client:getpeername() .. "] has been disconnected.\n")
end
