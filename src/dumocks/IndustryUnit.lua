--- Can mass-produce produce any item/element.
--
-- Element class: IndustryUnit
-- <ul>
--   <li>IndustryUnit: Transfer Unit</li>
--   <li>Industry1: Basic Industry Units</li>
--   <li>Industry2: Uncommon Industry Units</li>
--   <li>Industry3: Advanced Industry Units</li>
--   <li>Industry4: Rare Industry Units</li>
-- </ul>
--
-- Extends: Element
-- @see Element
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

-- Wrapper around accessing the currentTime field to allow for a method to provide time or just set the time directly.
local function getTime(timeProvider)
    if type(timeProvider) == "number" then
        return timeProvider
    elseif type(timeProvider) == "function" then
        return timeProvider()
    end
    return nil
end

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

    o.stateTimeStamps = {} -- for tracking efficiency, list of {status = newStatus, time = getTime(self.currentTime)}

    o.completedCallbacks = {}
    o.statusChangedCallbacks = {}

    return o
end

--- Start the production, and it will run unless it is stopped or the input resources run out.
function M:start()
    self.currentMode = M.mode.INFINITE
    self.startedTime = getTime(self.currentTime)
    self.stateTimeStamps = {}
    self.cycles = 0

    self:mockDoEvaluateStatus()
end

--- Start maintaining the specified quantity. Resumes production when the quantity in the output container is too low,
-- and pauses production when it is equal or higher.
-- @tparam int quantity Quantity to maintain inside output containers.
function M:startAndMaintain(quantity)
    self.currentMode = M.mode.MAINTAIN
    self.targetCount = quantity
    self.startedTime = getTime(self.currentTime)
    self.stateTimeStamps = {}
    self.cycles = 0

    self:mockDoEvaluateStatus()
end

--- Start the production of numBatches and then stop.
-- @tparam int numBatches Number of batches to run before unit stops.
function M:batchStart(numBatches)
    self.currentMode = M.mode.BATCH
    self.remainingJobs = numBatches
    self.startedTime = getTime(self.currentTime)
    self.stateTimeStamps = {}
    self.cycles = 0

    self:mockDoEvaluateStatus()
end

--- End the job and stop. The production keeps going until it is complete, then it switches to "STOPPED" status. If the
-- output container is full, then it switches to "JAMMED".
function M:softStop()
    self.currentMode = M.mode.SOFT_STOP

    self:mockDoEvaluateStatus()
end

--- Stop production immediately. The resources are given back to the input container. If there is not enough room in the
-- input containers, production stoppage is skipped if `allowIngredientLoss` is set to 0, or ingredients are lost if set
-- to 1.
-- @tparam 0/1 allowIngredientLoss 0 = forbid loss, 1 = enable loss.
function M:hardStop(allowIngredientLoss)
    allowIngredientLoss = allowIngredientLoss == 1 -- convert to boolean for convenience

    -- TODO how to handle this state, set to nil or create new mode?

    self:mockDoEvaluateStatus()
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

    local runningTime = 0
    local otherTime = 0

    local previousState = nil
    local previousTime = 0.0
    for _,stateChange in pairs(self.stateTimeStamps) do
        local state = stateChange.status
        local time = stateChange.time

        if previousState == M.status.RUNNING then
            runningTime = runningTime + time - previousTime
        elseif previousState then -- not nil
            otherTime = otherTime + time - previousTime
        end

        previousState = state
        previousTime = time
    end

    if not previousState then
        return 0.0
    elseif previousState == M.status.RUNNING then
        runningTime = runningTime + getTime(self.currentTime) - previousTime
    else
        otherTime = otherTime + getTime(self.currentTime) - previousTime
    end

    if runningTime == 0.0 then
        return 0.0
    end

    return runningTime / (runningTime + otherTime)
end

--- Get the time elapsed in seconds since the player started the unit for the latest time.
-- @treturn s The time elapsed in seconds.
function M:getUptime()
    -- even if stopped this shows the count since last started
    return getTime(self.currentTime) - self.startedTime
end

--- Set the loaded schematic, based on its id. Use getCurrentSchematic to learn about your schematic id. Does not work
-- while the industry unit is running.
-- @tparam int id The schematic id to be loaded.
-- @see getCurrentSchematic
function M:setCurrentSchematic(id)
end

--- Get the id of the currently loaded schematic.
-- @treturn int The schematic id or 0 if no valid schematic is loaded.
function M:getCurrentSchematic()
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

--- Mock only, not in-game: Simulates the industry unit completing a run. Will update/check internal state and call
-- mockDoEvaluateStatus as necessary. Calling this while the status is not RUNNING will have no effect.
-- @see mockDoEvaluateStatus
function M:mockDoCompleted()
    if self.currentStatus ~= M.status.RUNNING then
        return
    end

    -- bump cycle count before calling callbacks
    self.cycles = self.cycles + 1

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.completedCallbacks) do
        local status,err = pcall(callback)
        if not status then
            errors = errors.."\nError while running callback "..i..": "..err
        end
    end

    if self.currentMode == M.mode.SOFT_STOP then
        self.remainingJobs = 0
    elseif self.currentMode == M.mode.BATCH then
        self.remainingJobs = self.remainingJobs - 1
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end

    -- evaluate to see if state needs to change, after error propagation because it may have its own errors
    self:mockDoEvaluateStatus()
end

--- Mock only, not in-game: Register a handler for the in-game `statusChanged(status)` event.
-- @tparam function callback The function to call when the button is pressed.
-- @tparam string filter The status to filter on, or "*" for all.
-- @treturn int The index of the callback.
-- @see EVENT_statusChanged
function M:mockRegisterStatusChanged(callback, filter)
    -- default to all
    filter = filter or "*"

    local index = #self.statusChangedCallbacks + 1
    self.statusChangedCallbacks[index] = {callback = callback, filter = filter}
    return index
end

--- Mock only, not in-game: Evaluate the state of the element as well as any input and output connections and change the
-- machine status if necessary. This will call status changed listeners if applicable.
function M:mockDoEvaluateStatus()
    local oldStatus = self.currentStatus
    local newStatus = oldStatus

    if self.currentMode == M.mode.INFINITE then
        if self.hasInputContainer and self.hasInputIngredients then
            -- go to running on start, show error after time has passed for job to finish
            if getTime(self.currentTime) == self.startedTime or (self.hasOutput and self.hasOutputSpace) then
                newStatus = M.status.RUNNING
            elseif not self.hasOutputSpace then
                newStatus = M.status.JAMMED_NO_OUTPUT_CONTAINER
            else
                newStatus = M.status.JAMMED_OUTPUT_FULL
            end
        else
            newStatus = M.status.JAMMED_MISSING_INGREDIENT
        end
    elseif self.currentMode == M.mode.MAINTAIN then
        if self.targetCount >= self.outputCount then
            newStatus = M.status.PENDING
        elseif self.hasInputContainer and self.hasInputIngredients then
            if self.hasOutput and not self.hasOutputSpace then
                newStatus = M.status.JAMMED_OUTPUT_FULL
            elseif not self.hasOutput then
                newStatus = M.status.JAMMED_NO_OUTPUT_CONTAINER
            else
                newStatus = M.status.RUNNING
            end
        else
            newStatus = M.status.JAMMED_MISSING_INGREDIENT
        end
    elseif self.currentMode == M.mode.BATCH then
        if self.remainingJobs == 0 then
            newStatus = M.status.STOPPED
        elseif self.hasInputContainer and self.hasInputIngredients then
            if self.hasOutput and not self.hasOutputSpace then
                newStatus = M.status.JAMMED_OUTPUT_FULL
            elseif not self.hasOutput then
                newStatus = M.status.JAMMED_NO_OUTPUT_CONTAINER
            else
                newStatus = M.status.RUNNING
            end
        else
            newStatus = M.status.JAMMED_MISSING_INGREDIENT
        end
    elseif self.currentMode == M.mode.SOFT_STOP then
        if self.remainingJobs == 0 or oldStatus ~= M.status.RUNNING then
            newStatus = M.status.STOPPED
        end
    end

    --if no change then no need to notify
    if oldStatus == newStatus then
        return
    end

    -- perform status change
    self.currentStatus = newStatus

    -- track time for efficiency
    table.insert(self.stateTimeStamps, {status = newStatus, time = getTime(self.currentTime)})

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.statusChangedCallbacks) do
        if callback.filter == "*" or callback.filter == newStatus then
            local status,err = pcall(callback.callback, newStatus)
            if not status then
                errors = errors.."\nError while running callback "..i..": "..err
            end
        end
    end

    -- propagate errors
    if string.len(errors) > 0 then
        error("Errors raised in callbacks:"..errors)
    end
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
    closure.setCurrentSchematic = function(id) return self:setCurrentSchematic(id) end
    closure.getCurrentSchematic = function() return self:getCurrentSchematic() end
    return closure
end

return M
