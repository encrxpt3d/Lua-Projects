local players = {
    ["encrxpt3d"] = {
        Name = "encrxpt3d",
        DisplayName = "encrxpt3d",
        Data = {
            UsedCodes = {},
        }
    }
}

-- Module Utilities

local function toHMS(s)
    return s >= 86400 and ("%02id %02ih %02im %02is"):format(math.floor(s/86400), math.floor(s/60^2%24), math.floor(s/60%60), math.floor(s%60)) or ("%02ih %02im %02is"):format(math.floor(s/60^2%24), math.floor(s/60%60), math.floor(s%60))
end

local function toSeconds(hms)
	local days, hours, minutes, seconds = 0, 0, 0, 0
    
	if #hms > 11 then
		days = hms:sub(1, 2) * 86400
		hours = hms:sub(5, 6) * 3600
		minutes = hms:sub(9, 10) * 60
		seconds = hms:sub(13, 14)
	else
		hours = hms:sub(1, 2) * 3600
		minutes = hms:sub(5, 6) * 60
		seconds = hms:sub(9, 10)
	end
	
	return days + hours + minutes + seconds
end

-- Codes

local Codes = {
    _Codes = {},
}

local _CodeFunctions = {}
_CodeFunctions.__index = _CodeFunctions

function Codes.new(options)
    if Codes._Codes[options.Name or options] then return io.write("Cannot overwrite code.") end

    local newCode = setmetatable({
        Name = options.Name or options,
        Expires = options.Expires and toSeconds(options.Expires) or toSeconds("14d 00h 00m 00s"),
        HMS = options.Expires or "14d 00h 00m 00s",
        Message = options.Message or "Code Redeemed!",
        Expired = false,
    }, _CodeFunctions)

    Codes._Codes[newCode.Name] = newCode

    return newCode
end

function Codes.use(plr, code)
    local returnMessage = ""
    local failed = false

    local codeData = Codes._Codes[code]
    local playerData = players[plr.Name].Data

    returnMessage = 
        not codeData and "Invalid Code"
        or playerData.UsedCodes[code] and "Already Used"
        or codeData.Expired and "Expired Code"
        or codeData.Message

    failed = not codeData or not returnMessage == codeData.Message
    return { Status = failed and "Failed" or "Successful", Message = returnMessage }
end

function Codes.expire(code)
    if not Codes._Codes[code] then
        return "Failed: Invalid Code"
    end

    Codes._Codes[code]:Expire(true)
    return "Success: \"" .. code .. "\" is now invalid."
end

function Codes.list(expiredOnly)
    local foundCode = false

    for _, code in pairs(Codes._Codes) do
        if not foundCode then foundCode = true end
        if expiredOnly and code.Expired or not expiredOnly then
            print(("Name: %s || Expiry: %s || Expired: %s || Redeem Message: %s"):format(code.Name, code.HMS, code.Expired, code.Message))
        end
    end

    if not foundCode then
        io.write("No codes found in database.")
    end
end

-- Code Functions

function _CodeFunctions:UpdateHMS(seconds)
    self.HMS = toHMS(seconds or 0)
end

function _CodeFunctions:Expire(force)
    if self.Expires <= 0 or force then
        self.Expires = 0
        self.Expired = true
        self:UpdateHMS()
    end
end

function _CodeFunctions:IncreaseExpiry(seconds)
    self.Expires = self.Expires + seconds
    self:UpdateHMS(self.Expires)
    self:Expire()
end

function _CodeFunctions:DecreaseExpiry(seconds)
    self.Expires = self.Expires + seconds
    self:UpdateHMS(self.Expires)
    self:Expire()
end

function _CodeFunctions:ChangeTime(seconds)
    self.Expires = seconds
    self:UpdateHMS(seconds)
    self:Expire()
end

function _CodeFunctions:ChangeMessage(msg)
    self.Message = msg
end

-- Testing

local options = {
    N = function()
        io.write("\n[NAME]\n> ")
        local codeName = io.read("l")

        if #codeName <= 0 then
            return io.write("Message does not meet the length requirement.")
        elseif Codes._Codes[codeName] then
            return io.write("Cannot overwrite code.")
        end

        io.write("\n[EXPIRES]\n> ")
        local hms = io.read("l")

        io.write("\n[MESSAGE]\n> ")
        local msg = io.read("l") or nil

        hms = #hms > 1 and hms or nil
        msg = #msg > 1 and msg or nil

        Codes.new({
            Name = codeName,
            Expires = hms,
            Message = msg
        })

        io.write("Successfully created code \"" .. codeName .. "\"\n")
    end,

    U = function()
        io.write("\n[CODE]\n> ")

        local codeName = io.read("l")
        local returned = Codes.use(players["encrxpt3d"], codeName)
        print(returned.Status .. ": " .. returned.Message .. "\n")
    end,

    E = function()
        io.write("\n[CODE]\n")

        local codeName = io.read("l")
        print(Codes.expire(codeName) .. "\n")
    end,

    L = function()
        Codes.list()
        print()
    end,
}

while true do
    io.write("\n[N] = New Code\n[U] = Use Code\n[E] = Expire Code\n[L] = List Codes\n\n> ")

    local option = string.upper(io.read("l"))
    local foundOption = options[option]

    if foundOption then
        foundOption()
    else
        print()
    end
end
