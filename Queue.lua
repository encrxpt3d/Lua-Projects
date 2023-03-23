-- Local Functions
local function getNumIndexes(tbl)
    local num = 0
    for _, _ in pairs(tbl) do
        num = num + 1
    end
    return num
end

local function getKeyFromValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

local function printTable(tbl, depth)
    depth = depth or 0
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            if depth > 0 then
                print(string.rep(" ", depth) .. k .. ":")
            else
                print(k .. ": ")
            end
            printTable(v, depth + 4)
        else
            if depth > 0 then
                print(string.rep(" ", depth) .. k .. ": " .. v .. ",")
            else
                print(k .. ": " .. v .. ",")
            end
        end
    end
end

local function wait(s)
    s = s or 0.01
    local old = os.clock()
    repeat until os.clock() - old >= s
    return true
end

-- Queue Initializer
local Queue = {}
local _Queues = {}
Queue.__index = Queue

Queue.new = function(queueName)
    queueName = queueName or ("Queue_" .. getNumIndexes(_Queues) + 1)

    local self = setmetatable({}, Queue)
    self.Queue = {}

    _Queues[queueName] = self
    return self
end

Queue.delete = function(queueName)
    _Queues[queueName] = nil
end

-- Queue Functions
function Queue:setFunc(fn)
    self._Func = fn
end

function Queue:run(...)
    self:_add(getNumIndexes(self.Queue) + 1, "_run")
    repeat until getNumIndexes(self.Queue) <= 1
    self._Func(...)
    self:_done()
end

-- Private Functions
function Queue:_add(key, value)
    if not value then
        self.Queue[getNumIndexes(self.Queue) + 1] = key
    else
        self.Queue[key] = value
    end
end

function Queue:_remove(data)
    if self.Queue[data] then
        self.Queue[data] = nil
    else
        local key = getKeyFromValue(self.Queue, data)
        if key then
            self.Queue[key] = nil
        end
    end
end

function Queue:_done()
    self:_remove(1)
end

-- Example Queue
local ExampleQueue = Queue.new("Test")

ExampleQueue:setFunc(function(s)
    print(string.format("Waiting for %s seconds...", s))
    repeat until wait(s)
    print(string.format("Done waiting for %s seconds!\n", s))
end)

print()
ExampleQueue:run(5)
ExampleQueue:run(2)
ExampleQueue:run(4)