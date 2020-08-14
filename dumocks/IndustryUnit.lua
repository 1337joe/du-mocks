--- Can mass-produce produce any item/element.
-- @module IndustryUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["3d printer m"] = {mass = 1997.46, maxHitPoints = 5512.0}
elementDefinitions["assembler xs"] = {mass = 100.93, maxHitPoints = 2250.0}
elementDefinitions["assembler s"] = {mass = 522.14, maxHitPoints = 7829.0}
elementDefinitions["assembler m"] = {mass = 2802.36, maxHitPoints = 26422.0}
elementDefinitions["assembler l"] = {mass = 15382.4, maxHitPoints = 89176.0}
elementDefinitions["assembler xl"] = {86293.68, maxHitPoints = 300967.0}
elementDefinitions["chemical industry m"] = {mass = 2302.34, maxHitPoints = 5563.0}
elementDefinitions["electronics industry m"] = {mass = 1620.46, maxHitPoints = 1095.0}
elementDefinitions["glass furnace m"] = {mass = 2834.56, maxHitPoints = 2655.0}
elementDefinitions["honeycomb refinery m"] = {mass = 2989.96, maxHitPoints = 6440.0}
elementDefinitions["metalwork industry m"] = {mass = 2598.96, maxHitPoints = 4892.0}
elementDefinitions["recycler m"] = {mass = 2353.96, maxHitPoints = 18029.0}
elementDefinitions["refiner m"] = {mass = 2302.34, maxHitPoints = 5540.0}
elementDefinitions["smelter"] = {mass = 2057.34, maxHitPoints = 7697.0}
elementDefinitions["transfer unit"] = {mass=10147.65, maxHitPoints = 1329.0}
local DEFAULT_ELEMENT = "assembler m"

local M = MockElement:new()
M.elementClass = "IndustryUnit"

M.status = {
    STOPPED = "STOPPED",
    RUNNING = "RUNNING",
    PENDING = "PENDING",
    JAMMED_MISSING_INGREDIENT = "JAMMED_MISSING_INGREDIENT",
    JAMMED_OUTPUT_FULL = "JAMMED_OUTPUT_FULL",
    JAMMED_NO_OUTPUT_CONTAINER = "JAMMED_NO_OUTPUT_CONTAINER",
}
M.mode = {
    INFINITE = "INFINITE",
    BATCH = "BATCH",
    MAINTAIN = "MAINTAIN",
    SOFT_STOP = "SOFT_STOP",
}

function M:new(o, id, elementName)
    local elementDefinition = MockElement.findElement(elementDefinitions, elementName, DEFAULT_ELEMENT)

    o = o or MockElement:new(o, id, elementDefinition)
    setmetatable(o, self)
    self.__index = self

    o.currentTime = 0 -- used to populate startedTime and calculate uptime in the absense of a mock clock

    o.currentMode = nil
    o.currentStatus = M.status.STOPPED
    o.hasInputContainer = true
    o.hasInputIngredients = true
    o.hasInputSpace = true
    o.hasOutput = true
    o.hasOutputSpace = true
    o.startedTime = 0
    o.cycles = 0
    o.remainingJobs = 0 -- batch mode
    o.targetCount = 0 -- maintain mode
    o.outputCount = 0 -- maintain mode
    o.runningTime = 0

    self.completedCallbacks = {}
    self.statusChangedCallbacks = {}

    return o
end

--- Start the production, and it will run unless it is stopped or the input resources run out.
function M:start()
    self.currentMode = M.mode.INFINITE
    self.startedTime = self.currentTime
    self.cycles = 0

    if self.hasInputContainer and self.hasInputIngredients then
        if self.hasOutput and not self.hasOutputSpace then
            self.currentStatus = M.status.JAMMED_OUTPUT_FULL
        elseif not self.hasOutput then
            self.currentStatus = M.status.JAMMED_NO_OUTPUT_CONTAINER
        else
            self.currentStatus = M.status.RUNNING
        end
    else
        self.currentStatus = M.status.JAMMED_MISSING_INGREDIENT
    end
end

--- Start maintaining the specified quantity. Resumes production when the quantity in the output container is too low,
-- and pauses production when it is equal or higher.
-- @tparam int quantity Quantity to maintain inside output containers.
function M:startAndMaintain(quantity)
    self.currentMode = M.mode.MAINTAIN
    self.targetCount = quantity
    self.startedTime = self.currentTime
    self.cycles = 0

    if self.targetCount >= self.outputCount then
        self.currentStatus = M.status.PENDING
    elseif self.hasInputContainer and self.hasInputIngredients then
        if self.hasOutput and not self.hasOutputSpace then
            self.currentStatus = M.status.JAMMED_OUTPUT_FULL
        elseif not self.hasOutput then
            self.currentStatus = M.status.JAMMED_NO_OUTPUT_CONTAINER
        else
            self.currentStatus = M.status.RUNNING
        end
    else
        self.currentStatus = M.status.JAMMED_MISSING_INGREDIENT
    end
end

--- Start the production of numBatches and then stop.
-- @tparam int numBatches Number of batches to run before unit stops.
function M:batchStart(numBatches)
    self.currentMode = M.mode.MAINTAIN
    self.remainingJobs = numBatches
    self.startedTime = self.currentTime
    self.cycles = 0

    if self.hasInputContainer and self.hasInputIngredients then
        if self.hasOutput and not self.hasOutputSpace then
            self.currentStatus = M.status.JAMMED_OUTPUT_FULL
        elseif not self.hasOutput then
            self.currentStatus = M.status.JAMMED_NO_OUTPUT_CONTAINER
        else
            self.currentStatus = M.status.RUNNING
        end
    else
        self.currentStatus = M.status.JAMMED_MISSING_INGREDIENT
    end
end

--- End the job and stop. The production keeps going until it is complete, then it switches to "STOPPED" status. If the
-- output container is full, then it switches to "JAMMED".
function M:softStop()
    self.currentMode = M.mode.SOFT_STOP
end

--- Stop production immediately. The resources are given back to the input container. If there is not enough room in the
-- input containers, production stoppage is skipped if `allowIngredientLoss` is set to 0, or ingredients are lost if set
-- to 1.
-- @tparam 0/1 allowIngredientLoss 0 = forbid loss, 1 = enable loss.
function M:hardStop(allowIngredientLoss)
    allowIngredientLoss = allowIngredientLoss == 1 -- convert to boolean for convenience
end

--- Get the status of the industry.
-- @treturn string The status of the industry can be: STOPPED, RUNNING, JAMMED_MISSING_INGREDIENT, JAMMED_OUTPUT_FULL,
-- JAMMED_NO_OUTPUT_CONTAINER.
function M:getStatus()
    return self.currentStatus
end

--- Get the count of completed cycles since the player started the unit.
-- @treturn int The count of completed cycles since startup.
function M:getCycleCountSinceStartup()
    return self.cycles
end

--- Get the efficiency of the industry.
-- @treturn 0..1 The efficiency rate between 0 and 1.
function M:getEfficiency()
    if self.currentStatus == M.status.STOPPED then
        return 0.0
    end
    return 0 -- TODO implement, need to track time in non-running states after starting?
end

--- Get the time elapsed in seconds since the player started the unit for the latest time.
-- @treturn s The time elapsed in seconds.
function M:getUptime()
    -- even if stopped this shows the count since last started
    return self.currentTime - self.startedTime
end

--- Event: Emitted when the industry unit has completed a run.
--
-- Note: This is documentation on an event handler, not a callable method.
function M.EVENT_completed()
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterCompleted")
end

--- Event: Emitted when the industry status has changed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam string status The status of the industry can be: STOPPED, RUNNING, JAMMED_MISSING_INGREDIENT,
-- JAMMED_OUTPUT_FULL, JAMMED_NO_OUTPUT_CONTAINER.
function M.EVENT_statusChanged(status)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterStatusChanged")
end

--- Mock only, not in-game: Register a handler for the in-game `completed()` event.
-- @tparam function callback The function to call when the button is pressed.
-- @treturn int The index of the callback.
-- @see EVENT_completed
function M:mockRegisterCompleted(callback)
    local index = #self.completedCallbacks + 1
    self.completedCallbacks[index] = callback
    return index
end

--- Mock only, not in-game: Simulates the industry unit completing a run. Will update/check internal state and call mockDoStatusChanged as necessary.
-- @see mockDoStatusChanged
function M.mockDoCompleted()

    -- bump cycle count before calling callbacks
    self.cycles = self.cycles + 1

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.pressedCallbacks) do
        local status,err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end




    --call completed callbacks

    self.remainingJobs = self.remainingJobs - 1

    if self.pendingStop then
        self.remainingJobs = 0
    end

    --manage inventory updates?
    --at least check states

    if self.remainingJobs == 0 then
        --stop

        --call status changed callbacks
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
end


--- Mock only, not in-game: Register a handler for the in-game `statusChanged(status)` event.
-- @tparam function callback The function to call when the button is pressed.
-- @tparam string filter The status to filter on, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_statusChanged
function M:mockRegisterStatusChanged(callback, filter)
    filter = filter or "*"

    local index = #self.statusChangedCallbacks + 1
    self.statusChangedCallbacks[index] = callback
    return index
end

function M.mockDoStatusChanged()
    -- TODO
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see Element:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
    closure.start = function() return self:start() end
    closure.startAndMaintain = function(quantity) return self:startAndMaintain(quantity) end
    closure.batchStart = function(numBatches) return self:batchStart(numBatches) end
    closure.softStop = function() return self:softStop() end
    closure.hardStop = function(allowIngredientLoss) return self:hardStop(allowIngredientLoss) end
    closure.getStatus = function() return self:getStatus() end
    closure.getCycleCountSinceStartup = function() return self:getCycleCountSinceStartup() end
    closure.getEfficiency = function() return self:getEfficiency() end
    closure.getUptime = function() return self:getUptime() end
    return closure
end

return M
