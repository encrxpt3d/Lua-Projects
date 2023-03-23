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

function Queue:add(key, value)
    if not value then
        self.Queue[getNumIndexes(self.Queue) + 1] = key
    else
        self.Queue[key] = value
    end
end

function Queue:remove(data)
    if self.Queue[data] then
        self.Queue[data] = nil
    else
        local key = getKeyFromValue(self.Queue, data)
        if key then
            self.Queue[key] = nil
        end
    end
end

function Queue:done()
    self:remove(1)
end

function Queue:next()
    return self.Queue[getNumIndexes(self.Queue) + 1]
end

function Queue:run(...)
    self:add(getNumIndexes(self.Queue) + 1, "_run")
    repeat until getNumIndexes(self.Queue) <= 1
    self.Func(...)
    self:done()
end

-- Test

local TestQueue = Queue.new("Test")

TestQueue.Func = function(...)
    print(string.format("Waiting for %s seconds...", ...))
    repeat until wait(...)
    print(string.format("Done waiting for %s seconds!\n", ...))
end

print()
TestQueue:run(5)
TestQueue:run(2)
TestQueue:run(4)