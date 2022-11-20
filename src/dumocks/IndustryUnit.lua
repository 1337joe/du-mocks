--- An industry unit is a machine designed to produce different types of elements.
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
-- Extends: @{Element}
-- @module IndustryUnit
-- @alias M

local MockElement = require "dumocks.Element"

local elementDefinitions = {}
elementDefinitions["3d printer m"] = {mass = 1997.46, maxHitPoints = 5512.0, itemId = 409410678}
elementDefinitions["assembler xs"] = {mass = 100.93, maxHitPoints = 2250.0, itemId = 1762226876}
elementDefinitions["assembler s"] = {mass = 522.14, maxHitPoints = 7829.0, itemId = 983225818}
elementDefinitions["assembler m"] = {mass = 2802.36, maxHitPoints = 26422.0, itemId = 983225808}
elementDefinitions["assembler l"] = {mass = 15382.4, maxHitPoints = 89176.0, itemId = 983225811}
elementDefinitions["assembler xl"] = {86293.68, maxHitPoints = 300967.0, itemId = 1762226819}
elementDefinitions["chemical industry m"] = {mass = 2302.34, maxHitPoints = 5563.0, itemId = 2681009434}
elementDefinitions["electronics industry m"] = {mass = 1620.46, maxHitPoints = 1095.0, itemId = 2702446443}
elementDefinitions["glass furnace m"] = {mass = 2834.56, maxHitPoints = 2655.0, itemId = 1215026169}
elementDefinitions["honeycomb refinery m"] = {mass = 2989.96, maxHitPoints = 6440.0, itemId = 3857150880}
elementDefinitions["metalwork industry m"] = {mass = 2598.96, maxHitPoints = 4892.0, itemId = 2022563937}
elementDefinitions["recycler m"] = {mass = 2353.96, maxHitPoints = 18029.0, itemId = 3914155468}
elementDefinitions["refiner m"] = {mass = 2302.34, maxHitPoints = 5540.0, itemId = 3701755071}
elementDefinitions["smelter m"] = {mass = 2057.34, maxHitPoints = 7697.0, itemId = 2556123438}
elementDefinitions["transfer unit l"] = {mass=10147.65, maxHitPoints = 1329.0, itemId = 4139262245}
local DEFAULT_ELEMENT = "assembler m"

local M = MockElement:new()
M.elementClass = "IndustryUnit"

-- constants to make code more readable
M.status = {
    STOPPED = 1,
    RUNNING = 2,
    JAMMED_MISSING_INGREDIENT = 3,
    JAMMED_OUTPUT_FULL = 4,
    JAMMED_NO_OUTPUT_CONTAINER = 5,
    PENDING = 6,
    JAMMED_MISSING_SCHEMATICS = 7,
}

--- State labels.
--
-- Note: These are grouped in a table for documentation purposes only, this table doesn't exist in-game.
-- @table State
M.State = {
    [1] = "STOPPED", -- Stopped
    [2] = "RUNNING", -- Running
    [3] = "JAMMED_MISSING_INGREDIENT", -- Jammed missing ingredient
    [4] = "JAMMED_OUTPUT_FULL", -- Jammed output full
    [5] = "JAMMED_NO_OUTPUT_CONTAINER", -- Jammed no output container
    [6] = "PENDING", -- Pending
    [7] = "JAMMED_MISSING_SCHEMATICS", -- Jammed missing schematics
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
    o.currentState = 1
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

--- <b>Deprecated:</b> Start the production, and it will run unless it is stopped or the input resources run out.
--
-- This method is deprecated: startRun should be used instead
-- @see startRun
function M:start()
    M.deprecated("start", "startRun")
    return self:startRun()
end

--- Start the production, will run unless it is stopped or the input resources run out.
function M:startRun()
    self.currentMode = M.mode.INFINITE
    self.startedTime = getTime(self.currentTime)
    self.stateTimeStamps = {}
    self.cycles = 0

    self:mockDoEvaluateStatus()
end

--- <b>Deprecated:</b> Start maintaining the specified quantity. Resumes production when the quantity in the output container is too low,
-- and pauses production when it is equal or higher.
--
-- This method is deprecated: startMaintain should be used instead
-- @see startMaintain
-- @tparam int quantity Quantity to maintain inside output containers.
function M:startAndMaintain(quantity)
    M.deprecated("startAndMaintain", "startMaintain")
    return self:startMaintain(quantity)
end

--- Start maintaining the specified quantity. Resumes production when the quantity in the output container is too low,
-- and pauses production when it is equal or higher.
-- @tparam int quantity Quantity to maintain inside output containers.
function M:startMaintain(quantity)
    self.currentMode = M.mode.MAINTAIN
    self.targetCount = quantity
    self.startedTime = getTime(self.currentTime)
    self.stateTimeStamps = {}
    self.cycles = 0

    self:mockDoEvaluateStatus()
end

--- <b>Deprecated:</b> Start the production of numBatches and then stop.
--
-- This method is deprecated: startFor should be used instead
-- @see startFor
-- @tparam int numBatches Number of batches to run before unit stops.
function M:batchStart(numBatches)
    M.deprecated("batchStart", "startFor")
    return self:startFor(numBatches)
end

--- Start the production of numBatches and then stop.
-- @tparam int numBatches Number of batches to run before unit stops.
function M:startFor(numBatches)
    self.currentMode = M.mode.BATCH
    self.remainingJobs = numBatches
    self.startedTime = getTime(self.currentTime)
    self.stateTimeStamps = {}
    self.cycles = 0

    self:mockDoEvaluateStatus()
end

--- <b>Deprecated:</b> End the job and stop. The production keeps going until it is complete, then it switches to "STOPPED" status. If the
-- output container is full, then it switches to "JAMMED".
--
-- This method is deprecated: stop should be used instead
-- @see stop
function M:softStop()
    M.deprecated("softStop", "stop")
    return self:stop(false, false)
end

--- <b>Deprecated:</b> Stop production immediately. The resources are given back to the input container. If there is not enough room in the
-- input containers, production stoppage is skipped if `allowIngredientLoss` is set to 0, or ingredients are lost if set
-- to 1.
--
-- This method is deprecated: stop should be used instead
-- @see stop
-- @tparam 0/1 allowIngredientLoss 0 = forbid loss, 1 = enable loss.
function M:hardStop(allowIngredientLoss)
    M.deprecated("hardStop", "stop")
    return self:stop(true, allowIngredientLoss)
end

--- Stop the production of the industry unit.
-- @tparam bool force True if you want to force the production to stop immediately (optional, defaults to false).
-- @tparam bool allowLoss True if you want to allow the industry unit to lose components when recovering in-use
--   components (optional, defaults to false).
function M:stop(force, allowLoss)
    -- accepts 1 or true, as well as anything parseable as a whole number besides 0
    local numberForce = tonumber(force)
    force = (force == true) or (numberForce and numberForce ~= 0 and numberForce % 1 == 0)
    local numberAllowLoss = tonumber(allowLoss)
    allowLoss = (allowLoss == true) or (numberAllowLoss and numberAllowLoss ~= 0 and numberAllowLoss % 1 == 0)

    if not force then
        self.currentMode = M.mode.SOFT_STOP
    else
        -- TODO how to handle this state, set to nil or create new mode?
    end

    self:mockDoEvaluateStatus()
end

--- <b>Deprecated:</b> Get the status of the industry.
--
-- This event is deprecated: getState should be used instead.
-- @see getState
-- @treturn string The status of the industry can be: STOPPED, RUNNING, JAMMED_MISSING_INGREDIENT, JAMMED_OUTPUT_FULL,
-- JAMMED_NO_OUTPUT_CONTAINER.
function M:getStatus()
    M.deprecated("getStatus", "getState")
    return M.State[self:getState()]
end

--- Returns the current running state of the industry.
-- @treturn int The current running state of the industry. See @{State} for possible values.
-- @see State
function M:getState()
    return self.currentState
end

--- Returns the complete information of the industry.
-- @treturn table The complete state of the industry, a table with fields {[integer] state, [bool] stopRequested,
--   [integer] schematicsRemaining, [integer] unitsProduced, [integer] remainingTime, [integer] batchesRequested,
--   [integer] batchesRemaining, [number] maintainProductAmount, [integer] currentProductAmmount,
--   [table] currentProducts:{{[integer] id, [number] quantity},...}}
function M:getInfo()
end

--- <b>Deprecated:</b> Get the count of completed cycles since the player started the unit.
--
-- This method is deprecated: getCyclesCompleted should be used instead
-- @see getCyclesCompleted
-- @treturn int The count of completed cycles since startup.
function M:getCycleCountSinceStartup()
    M.deprecated("getCycleCountSinceStartup", "getCyclesCompleted")
    return self:getCyclesCompleted()
end

--- Get the count of completed cycles since the player started the unit.
-- @treturn int The count of completed cycles since startup.
function M:getCyclesCompleted()
    return self.cycles
end

--- Get the efficiency of the industry.
-- @treturn float The efficiency rate between 0 and 1.
function M:getEfficiency()
    if self.currentState == M.status.STOPPED then
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

--- Returns the time elapsed in seconds since the player started the unit for the latest time.
-- @treturn float The time elapsed in seconds.
function M:getUptime()
    -- even if stopped this shows the count since last started
    return getTime(self.currentTime) - self.startedTime
end

--- <b>Deprecated:</b> Set the loaded schematic, based on its id. Use getCurrentSchematic to learn about your schematic id. Does not work
-- while the industry unit is running.
--
-- This method is deprecated: setOutput should be used instead
-- @see setOutput
-- @tparam int id The schematic id to be loaded.
-- @see getCurrentSchematic
function M:setCurrentSchematic(id)
    M.deprecated("setCurrentSchematic", "setOutput")
end

--- Set the item to produce from its ID.
-- @tparam int itemId The item ID of the item to produce.
-- @treturn int The result of the operation: 0 for a success, -1 if the industry is running.
function M:setOutput(itemId)
end

--- <b>Deprecated:</b> Get the id of the currently loaded schematic.
--
-- This method is deprecated: getOutputs should be used instead
-- @see getOutputs
-- @treturn int The schematic id or 0 if no valid schematic is loaded.
function M:getCurrentSchematic()
    M.deprecated("getCurrentSchematic", "getOutputs")
end

--- Returns the list of IDs of the items currently produced.
-- @treturn table The first entry in the table is always the main product produced.
function M:getOutputs()
end

--- Returns the list of items required to run the selected output product.
-- @treturn table Returns the list of inputs.
function M:getInputs()
end

--- Send a request to get an update of the contents of the schematic bank, limited to one call allowed per 30 seconds.
-- @treturn float If the request is not yet possible, returns the remaining time to wait for.
function M:updateBank()
    return 0
end

--- Returns a table describing the contents of the schematic bank, as a pair itemId and quantity per slot.
-- @treturn table The content of the schematic bank as a table with fields {[integer] id, [number] quantity} per slot.
function M:getBank()
    return {}
end

--- Event: Emitted when the industry unit has started a new production process per product.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The item ID of the product.
-- @tparam float quantity The quantity to be produced.
function M.EVENT_onStarted(id, quantity)
    assert(false, "This is implemented for documentation purposes.")
end

--- <b>Deprecated:</b> Event: Emitted when the industry unit has completed a run.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onCompleted should be used instead.
-- @see EVENT_onCompleted
function M.EVENT_completed()
    M.deprecated("EVENT_completed", "EVENT_onCompleted")
    M.EVENT_onCompleted()
end

--- Event: Emitted when the industry unit has completed a run per product.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int id The item ID of the product.
-- @tparam float quantity The quantity produced.
function M.EVENT_onCompleted(id, quantity)
    assert(false, "This is implemented for documentation purposes. For test usage see mockRegisterCompleted")
end

--- <b>Deprecated:</b> Event: Emitted when the industry status has changed.
--
-- Note: This is documentation on an event handler, not a callable method.
--
-- This event is deprecated: EVENT_onStatusChanged should be used instead.
-- @see EVENT_onStatusChanged
-- @tparam string status The status of the industry can be: STOPPED, RUNNING, JAMMED_MISSING_INGREDIENT,
-- JAMMED_OUTPUT_FULL, JAMMED_NO_OUTPUT_CONTAINER.
function M.EVENT_statusChanged(status)
    M.deprecated("EVENT_statusChanged", "EVENT_onStatusChanged")
    M.EVENT_onStatusChanged(status)
end

--- Event: Emitted when the industry status has changed.
--
-- Note: This is documentation on an event handler, not a callable method.
-- @tparam int status The state of the industry. See @{State} for possible values.
-- @see State
function M.EVENT_onStatusChanged(status)
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
    if self.currentState ~= M.status.RUNNING then
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
    local oldState = self.currentState
    local newState = oldState

    if self.currentMode == M.mode.INFINITE then
        if self.hasInputContainer and self.hasInputIngredients then
            -- go to running on start, show error after time has passed for job to finish
            if getTime(self.currentTime) == self.startedTime or (self.hasOutput and self.hasOutputSpace) then
                newState = M.status.RUNNING
            elseif not self.hasOutputSpace then
                newState = M.status.JAMMED_NO_OUTPUT_CONTAINER
            else
                newState = M.status.JAMMED_OUTPUT_FULL
            end
        else
            newState = M.status.JAMMED_MISSING_INGREDIENT
        end
    elseif self.currentMode == M.mode.MAINTAIN then
        if self.targetCount >= self.outputCount then
            newState = M.status.PENDING
        elseif self.hasInputContainer and self.hasInputIngredients then
            if self.hasOutput and not self.hasOutputSpace then
                newState = M.status.JAMMED_OUTPUT_FULL
            elseif not self.hasOutput then
                newState = M.status.JAMMED_NO_OUTPUT_CONTAINER
            else
                newState = M.status.RUNNING
            end
        else
            newState = M.status.JAMMED_MISSING_INGREDIENT
        end
    elseif self.currentMode == M.mode.BATCH then
        if self.remainingJobs == 0 then
            newState = M.status.STOPPED
        elseif self.hasInputContainer and self.hasInputIngredients then
            if self.hasOutput and not self.hasOutputSpace then
                newState = M.status.JAMMED_OUTPUT_FULL
            elseif not self.hasOutput then
                newState = M.status.JAMMED_NO_OUTPUT_CONTAINER
            else
                newState = M.status.RUNNING
            end
        else
            newState = M.status.JAMMED_MISSING_INGREDIENT
        end
    elseif self.currentMode == M.mode.SOFT_STOP then
        if self.remainingJobs == 0 or oldState ~= M.status.RUNNING then
            newState = M.status.STOPPED
        end
    end

    --if no change then no need to notify
    if oldState == newState then
        return
    end

    -- perform status change
    self.currentState = newState

    -- track time for efficiency
    table.insert(self.stateTimeStamps, {status = newState, time = getTime(self.currentTime)})

    -- call callbacks in order, saving exceptions until end
    local errors = ""
    for i,callback in pairs(self.statusChangedCallbacks) do
        if callback.filter == "*" or callback.filter == newState then
            local status,err = pcall(callback.callback, newState)
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
    closure.startRun = function() return self:startRun() end
    closure.startAndMaintain = function(quantity) return self:startAndMaintain(quantity) end
    closure.startMaintain = function(quantity) return self:startMaintain(quantity) end
    closure.batchStart = function(numBatches) return self:batchStart(numBatches) end
    closure.startFor = function(numBatches) return self:startFor(numBatches) end
    closure.softStop = function() return self:softStop() end
    closure.hardStop = function(allowIngredientLoss) return self:hardStop(allowIngredientLoss) end
    closure.stop = function(force, allowLoss) return self:stop(force, allowLoss) end
    closure.getStatus = function() return self:getStatus() end
    closure.getState = function() return self:getState() end
    closure.getInfo = function() return self:getInfo() end
    closure.getCycleCountSinceStartup = function() return self:getCycleCountSinceStartup() end
    closure.getCyclesCompleted = function() return self:getCyclesCompleted() end
    closure.getEfficiency = function() return self:getEfficiency() end
    closure.getUptime = function() return self:getUptime() end
    closure.setCurrentSchematic = function(id) return self:setCurrentSchematic(id) end
    closure.setOutput = function(itemId) return self:setOutput(itemId) end
    closure.getCurrentSchematic = function() return self:getCurrentSchematic() end
    closure.getOutputs = function() return self:getOutputs() end
    closure.getInputs = function() return self:getInputs() end
    closure.updateBank = function() return self:updateBank() end
    closure.getBank = function() return self:getBank() end
    return closure
end

return M
