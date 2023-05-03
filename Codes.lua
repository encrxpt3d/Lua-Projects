print()

local function toHMS(s)
    return s >= 86400 and ("%02i:%02i:%02i:%02i"):format(math.floor(s/86400), math.floor(s/60^2%24), math.floor(s/60%60), math.floor(s%60)) or ("%02i:%02i:%02i"):format(math.floor(s/60^2%24), math.floor(s/60%60), math.floor(s%60))
end

local function toSeconds(hms)
	local days, hours, minutes, seconds
	
	if #hms > 8 then
		days = hms:sub(1, 2) * 86400
		hours = hms:sub(4, 5) * 3600
		minutes = hms:sub(7, 8) * 60
		seconds = hms:sub(10, 11)
	else
		hours = hms:sub(1, 2) * 3600
		minutes = hms:sub(4, 5) * 60
		seconds = hms:sub(7, 8)
	end
	
	return (days or 0) + hours + minutes + seconds
end

-- Module

local Codes = {
    _Codes = {},
}

local _CodeFunctions = {}
_CodeFunctions.__index = _CodeFunctions

function Codes.new(options)
    local newCode = setmetatable({
        Name = options.Name or options,
        Expires = options.Expires or toSeconds("14:00:00:00"),
        Expiry = toHMS(options.Expires or toSeconds("14:00:00:00")),
        Expired = false,
        Message = options.Message or "Code Redeemed!"
    }, _CodeFunctions)

    Codes._Codes[newCode.Name] = newCode

    return newCode
end

function Codes.list(expiredOnly)
    for _, code in pairs(Codes._Codes) do
        if expiredOnly and code.Expired or not expiredOnly then
            print(("Name: %s\nExpires: %s seconds\nExpiry: %s\nExpired: %s\nRedeeem Message: %s\n\n"):format(code.Name, code.Expires, code.Expiry, code.Expired, code.Message))
        end
    end
end

-- Code Functions

function _CodeFunctions:Expire(force)
    if self.Expires <= 0 or force then
        self.Expires = 0
        self.Expiry = toHMS(0)
        self.Expired = true
    end
end

function _CodeFunctions:AddTime(seconds)
    self.Expires = self.Expires + seconds
    self.Expiry = toHMS(self.Expires)
    self:Expire()
end

function _CodeFunctions:ChangeTime(seconds)
    self.Expires = seconds
    self.Expiry = toHMS(seconds)
    self:Expire()
end

function _CodeFunctions:ChangeMessage(msg)
    self.Message = msg
end

-- Testing

local code = Codes.new("TEST")
Codes.new("AnotherCode")
Codes.list()

code:ChangeMessage("This is a test code!")
Codes.list()

code:AddTime(-59871)
Codes.list()

code:ChangeTime(29576)
Codes.list()

code:Expire(true)
Codes.list(true)
