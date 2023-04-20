for i = 1, 10 do
	print()
end

local prefix = "/"

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

local commands = {}
local commandTypes = {
	kick = {
		stringArg = true,
	},
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

local function checkForString(source, args)
	for _, char in pairs(source) do
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
					checkForString(source, args)
				elseif source[2] == ">" then
					return print("Invalid string beginning; you must start the string with a <\n  At: " .. source[2])
				end
			end
		end
	end
end

local function checkForTarget(options)
	for _, char in pairs(options.source) do
		if char:find("[A-Za-z]") and not options.args[options.arg] then
			if options.source[1] == "<" or options.source[1] == ">" then break end

			local target = ""
			
			while #options.source > 0 do
				if options.source[1] == nil or options.source[1] == " " then break end
				target = target .. shift(options.source)
			end
			shift(options.source)
			
			if target == "all" or target == "me" or target == "others" then
				table.insert(options.args, target)
			else
				local plr = findPlayer(target)
				if not plr then return print(target .. " could not be found in this server.") end
	
				table.insert(options.args, plr)
			end
		end
	end
	
	if not options.args[options.arg] then
		options.args[options.arg] = options.plr
	end
end

commands["kick"] = function(options)
	checkForTarget({
		plr = options.plr,
		source = options.source,
		args = options.args,
		arg = 2
	})
	if not options.args[2] then return end
	checkForString(options.source, options.args)

	local target = options.args[2]
	local reason = options.args[3]
	local kickMsg = ""

	if target == "all" or target == "others" then
		for _, player in pairs(players) do
			if target == "all" or target == "others" and player.Name ~= options.plr.Name then
				if player.Name == options.plr.Name then
					kickMsg = ("You have been kicked from the server by %s"):format(player.Name)
				else
					kickMsg = ("%s has been kicked from the server by %s"):format(player.Name, options.plr.Name)
				end
				kickMsg = reason and kickMsg .. "; reason: " .. reason or kickMsg .. "."
				print(kickMsg)
			end
		end

		return
	elseif target == "me" or target.Name == options.plr.Name then
		kickMsg = ("You have been kicked from the server by %s"):format(options.plr.Name)
	else
		kickMsg = ("%s has been kicked from the server by %s"):format(target.Name, options.plr.Name)
	end
	
	kickMsg = reason and kickMsg .. "; reason: " .. reason or kickMsg .. "."
	print(kickMsg)
end

local function onMessage(plr, msg)
	if not players[plr.Name] then return end
	if not admins[tostring(plr.UserId)] then return end
	if not msg:sub(1, 1) == prefix then return end
	msg = msg:gsub(prefix, "")
	
	local source = {}
	local args = {}

	for char in msg:gmatch(".") do
		table.insert(source, char)
	end
	
	for _, char in pairs(source) do
		if char:find("[A-Za-z]") and not args[1] then
			local cmd = ""
			
			while #source > 0 and not source[1]:find("%s") do
				cmd = cmd .. shift(source)
			end
			shift(source)
			
			if not commands[cmd:lower()] then return end
			table.insert(args, cmd)

		end
	end

	commands[args[1]]({
		plr = plr,
		source = source,
		args = args
	})
end

pcall(function()
	io.write("Input your username here: ")
	local name = io.read()
	if #name == 0 or name == " " or not name then return end
	
	io.write("Input your display name here: ")
	local displayName = io.read()
	if #displayName == 0 or displayName == " " or not displayName then return end
	
	players[name] = {
		Name = name,
		DisplayName = displayName,
		UserId = 39851908609
	}
	
	admins[tostring(players[name].UserId)] = name
	
	while true do
		io.write("\n/")
	
		local msg
		pcall(function()
			msg = io.read()
		end)
	
		if not msg then
			break
		end
	
		if not msg:find("%s", 1) or msg ~= "/" or msg ~= "" then
			pcall(onMessage, players[name], msg)
		end
	end
end)

print()
print()