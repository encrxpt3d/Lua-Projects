print()
local prefix = "/"

local commands = {
	kick = function(plr, target, reason)
		
	end,
}

local commandTypes = {
	kick = {
		stringArg = true,
	},
}

local players = {
	["encrxpted"] = {
		Name = "encrxpted",
		DisplayName = "encrypted",
		UserId = 106098306,
	},
	
	["the_Byte"] = {
		Name = "the_Byte",
		DisplayName = "bytecode",
		UserId = 350898790,
	},
}

local admins = {
	["106098306"] = "encrxpt3d",
}

local function findPlayer(shortName)
	for _, plr in pairs(players) do
		if plr.Name:lower():match(shortName:lower()) or plr.DisplayName:lower():match(shortName:lower()) then
			return plr
		end
	end
end

local function find(tbl, valueToLookFor)
    for key, value in pairs(tbl) do
        if valueToLookFor == value then
            return key
        end
    end
end

local function shift(tbl)
	local res = tbl[1]
    table.remove(tbl, find(tbl, res))
    return res
end

local function onMessage(plr, msg)
	if not players[plr.Name] then return end
	if not admins[tostring(plr.UserId)] then return end
	if not msg:sub(1, 1) == prefix then return end
	
	local originalMsg = msg
	msg = msg:lower():gsub(prefix, "")
	
	local source = {}
	for char in msg:gmatch(".") do
		table.insert(source, char)
	end
	
	local args = {}
	
	for _, char in pairs(source) do
		if char:find("[A-Za-z]") and not args[1] then
			local cmd = ""
			
			while #source > 0 and not source[1]:find("%s") do
				cmd = cmd .. shift(source)
			end
			shift(source)
			
			if not commands[cmd] then return end
			table.insert(args, cmd)

		end
	end

	for _, char in pairs(source) do
		if char:find("[A-Za-z]") and not args[2] then
			local target = ""
			
			while #source > 0 and not source[1]:find("%s") do
				target = target .. shift(source)
			end
			shift(source)
			
			local plr = findPlayer(target)
			if not plr then return warn(target .. " could not be found in this server.") end

			table.insert(args, plr)
		end
	end

	local function checkForString()
		for _, char in ipairs(source) do
			if char == "<" and commandTypes[args[1]] and commandTypes[args[1]].stringArg then
				local str = ""

				repeat
					shift(source)
				until source[1] ~= "<"

				if source[1] == ">" then return print("Incomplete string; cannot parse an empty string\n  At: " .. source[1]) end
				if source[1] == nil then return print("Incomplete string; there must be content in the string\n  At: <") end

				while #source > 0 do
					if source[1] == ">" then break end
					str = str .. shift(source)
					if source[1] == "<" then return print("Invalid string end; you must end the string with a >\n  At: " .. str) end
					if source[1] == nil then return print("Incomplete string end; did you forget to add a >?\n  At: " .. str) end
				end

				if source[1] ~= ">" then
					return print("Incomplete string end; did you forget to add a \"?\n  At: " .. str)
				else
					shift(source)
					table.insert(args, str)
					if source[2] == "<" then
						checkForString()
					elseif source[2] == ">" then
						return print("Invalid string beginning; you must start the string with a <\n  At: " .. source[2])
					end
				end
			elseif not char:find("[%s<]") then
				return print("Invalid character: " .. char)
			end
		end
	end
	checkForString()
	
	print(string.format("%-12s %s", "Message:", originalMsg))
	print(string.format("%-12s %s", "Command:", args[1]))
	print(string.format("%-12s %s", "Target:", args[2].Name))
	
	if commandTypes[args[1]] and commandTypes[args[1]].stringArg then
		for i = 3, #args do
			print(string.format("%-12s %s", "String #" .. i - 2 .. ":", args[i]))
		end
	end
end

onMessage(findPlayer("enc"), "/kick byte <is bad>")
print()
onMessage(findPlayer("enc"), "/kick by <another string hehe! xd> easports")
print()
onMessage(findPlayer("enc"), "/kick by <hehe> <yesir works!> <yet another> <fourth str wow> <oo fifth>")
print()