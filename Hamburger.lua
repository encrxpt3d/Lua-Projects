local function tableFind(tbl, valueToLookFor)
    for key, value in pairs(tbl) do
        if valueToLookFor == value then
            return key
        end
    end
    return nil
end

local function recursivePrintTbl(printOption, tbl)
    if printOption then
        if type(printOption) == "table" then
            tbl = printOption
        else
            print(printOption) 
        end
    end
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            recursivePrintTbl(value)
        elseif type(value) ~= "function" then
            print(key, ":", value)
        end
    end
end

--------------------------------------------------------------------

local BaseHamburger = {
    Bun = "White",
    Patty = "Medium-Well",
    Additions = {},

    AvailableAdditions = { "Lettuce", "Tomato", "Cheese", "Dressing" }
}
BaseHamburger.__index = BaseHamburger

function BaseHamburger:applySelections(selections)
    for key, value in pairs(selections) do
        if self[key] and type(self[key]) == type(value) then
            if type(value) == "table" and key == "Additions" then
                local additions = value
                for _, item in pairs(additions) do
                    if tableFind(BaseHamburger.AvailableAdditions, item) then
                        self.Additions[#self.Additions+1] = item
                    else
                        print("\"" .. item .. "\" is not available to add onto your burger. Sorry!")
                    end
                end
            else
                self[key] = value
            end
        end
    end
end

BaseHamburger.new = function(selections)
    local self = setmetatable({}, BaseHamburger)

    if selections then self:applySelections(selections) end

    return self
end

--------------------------------------------------------------------

local SuperHamburger = {
    Bun = "Whole-Wheat",
    Patty = "Well-Done",

    Additions = {}
}

SuperHamburger.new = function(selections)
    local self = BaseHamburger.new(SuperHamburger)

    if selections then self:applySelections(selections) end

    return self
end

--------------------------------------------------------------------

local myHamburger = SuperHamburger.new({
    Additions = { "Lettuce" }
})

recursivePrintTbl("Super Burger Additions: ", myHamburger.Additions)

--------------------------------------------------------------------

local myOtherHamburger = BaseHamburger.new({
    Additions = { "Cheese", "Dressing" }
})

recursivePrintTbl("Base Burger Additions: ", myOtherHamburger.Additions)