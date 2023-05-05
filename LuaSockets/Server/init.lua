package.path = package.path .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/share/lua/5.3/socket/?.lua"
package.path = package.path .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/share/lua/5.3/?.lua"
package.cpath = package.cpath .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/lib/lua/5.3/socket/?.so"
package.cpath = package.cpath .. ";/workspaces/Lua-Projects/lua-5.3.5/luarocks-3.8.0/lua_modules/lib/lua/5.3/?.so"

local socket = require("socket")
local server = socket.tcp()
server:setoption("reuseaddr", true)
server:bind("localhost", 12345)
server:listen()
print("\nServer [" .. server:getsockname() .. "] initialized.\n")

local function handle_client(client)
    local pName = client:getpeername()
    local cName = "Client [" .. client:getpeername() .. "]"
    print("-----------------------------------\n" .. cName .. " has been connected.")

    while true do
        local data, err = client:receive("*l")

        if not err then
            print("-----------------------------------\nServer received: " .. data .. "\n\tfrom: " .. pName)
            client:send(data .. "\n")
        else
            print(cName .. " has failed to respond.\n\tReason:", err)
            break
        end
    end

    print(cName .. " has been disconnected.")
    client:close()
end

while true do
    local client = server:accept()

    local co = coroutine.create(handle_client)
    coroutine.resume(co, client)
end