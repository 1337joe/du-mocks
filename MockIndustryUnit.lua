--- Industry unit.
-- Can mass-produce produce any item/element.
-- @module MockIndustryUnit
-- @alias M

local MockElement = require "MockElement"

local elementDefinitions = {
-- Assembler XS: mass = 100.93, maxHitPoints = 2250.0
-- Assembler S: mass = 522.14, maxHitPoints = 7829.0
-- Assembler M: mass = 2802.36, maxHitPoints = 26422.0
-- Assembler L: mass = 15382.4, maxHitPoints = 89176.0
-- Assembler XL: mass = 86293.68, maxHitPoints = 300967.0
-- Transfer Unit: mass=10147.65, maxHitPoints = 1329.0
-- Refiner M: mass = 2302.34, maxHitPoints = 5540.0
}

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

function M:new(o, id, size)
    o = o or MockElement:new(o, id)
    setmetatable(o, self)
    self.__index = self

    o.state = M.status.STOPPED
    o.hasInputContainer = true
    o.hasInputIngredients = true
    o.hasInputSpace = true
    o.hasOutput = true
    o.hasOutputSpace = true
    o.startedTime = 0
    o.cycles = 0
    o.mode = nil
    o.remainingJobs = 0 -- batch mode
    o.targetCount = 0 -- maintain mode
    o.outputCount = 0 -- maintain mode
    o.runningTime = 0

    return o
end

--- Start the production, and it will run unless it is stopped or the input resources run out.
function M:start()
    self.mode = M.mode.INFINITE
    self.startedTime = os.time()
    self.cycles = 0

    if self.hasInputContainer and self.hasInputIngredients then
        if self.hasOutput and not self.hasOutputSpace then
            self.state = M.status.JAMMED_OUTPUT_FULL
        elseif not self.hasOutput then
            self.state = M.status.JAMMED_NO_OUTPUT_CONTAINER
        else
            self.state = M.status.RUNNING
        end
    else
        self.state = M.status.JAMMED_MISSING_INGREDIENT
    end
end

--- Start maintaining the specified quantity. Resumes production when the quantity in the output container is too low,
-- and pauses production when it is equal or higher.
-- @tparam int quantity Quantity to maintain inside output containers.
function M:startAndMaintain(quantity)
    self.mode = M.mode.MAINTAIN
    self.targetCount = quantity
    self.startedTime = os.time()
    self.cycles = 0

    if self.targetCount >= self.outputCount then
        self.state = M.status.PENDING
    elseif self.hasInputContainer and self.hasInputIngredients then
        if self.hasOutput and not self.hasOutputSpace then
            self.state = M.status.JAMMED_OUTPUT_FULL
        elseif not self.hasOutput then
            self.state = M.status.JAMMED_NO_OUTPUT_CONTAINER
        else
            self.state = M.status.RUNNING
        end
    else
        self.state = M.status.JAMMED_MISSING_INGREDIENT
    end
end

--- Start the production of numBatches and then stop.
-- @tparam int numBatches Number of batches to run before unit stops.
function M:batchStart(numBatches)
    self.mode = M.mode.MAINTAIN
    self.remainingJobs = numBatches
    self.startedTime = os.time()
    self.cycles = 0

    if self.hasInputContainer and self.hasInputIngredients then
        if self.hasOutput and not self.hasOutputSpace then
            self.state = M.status.JAMMED_OUTPUT_FULL
        elseif not self.hasOutput then
            self.state = M.status.JAMMED_NO_OUTPUT_CONTAINER
        else
            self.state = M.status.RUNNING
        end
    else
        self.state = M.status.JAMMED_MISSING_INGREDIENT
    end
end

--- End the job and stop. The production keeps going until it is complete, then it switches to "STOPPED" status. If the
-- output container is full, then it switches to "JAMMED".
function M:softStop()
    self.mode = M.mode.SOFT_STOP
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
    return self.status
end

--- Get the count of completed cycles since the player started the unit.
-- @treturn int The count of completed cycles since startup.
function M:getCycleCountSinceStartup()
    return self.cycles
end

--- Get the efficiency of the industry.
-- @treturn 0..1 The efficiency rate between 0 and 1.
function M:getEfficiency()
    return 0 -- TODO implement
end

--- Get the time elapsed in seconds since the player started the unit for the latest time.
-- @treturn s The time elapsed in seconds.
function M:getUptime()
    if self.state == M.status.STOPPED then
        return 0
    end
    return os.time() - self.startedTime -- TODO should include fractional part? check game
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


-- TODO register callbacks: completed

function M.doCompleted()

    -- TODO does this hit before or after the callback
    self.cycles = self.cycles + 1

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
end

-- TODO register callbacks: statusChanged

function M.doStatusChanged()
    -- TODO
end

--- Mock only, not in-game: Bundles the object into a closure so functions can be called with "." instead of ":".
-- @treturn table A table encompasing the api calls of object.
-- @see MockElement:mockGetClosure
function M:mockGetClosure()
    local closure = MockElement.mockGetClosure(self)
--    closure.getSelfMass = function() return self:getSelfMass() end
    return closure
end

return M
