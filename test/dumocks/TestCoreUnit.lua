#!/usr/bin/env lua
--- Tests on dumocks.CoreUnit.
-- @see dumocks.CoreUnit

-- set search path to include src directory
package.path = package.path .. ";src/?.lua"

local lu = require("luaunit")

local mcu = require("dumocks.CoreUnit")
require("test.Utilities")

_G.TestCoreUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestCoreUnit.testConstructor()

    -- default element:
    -- ["dynamic core unit xs"] = {mass = 70.89, maxHitPoints = 50.0, class = "CoreUnitDynamic"}

    local control0 = mcu:new()
    local control1 = mcu:new(nil, 1, "Dynamic Core Unit XS")
    local control2 = mcu:new(nil, 2, "invalid")
    local control3 = mcu:new(nil, 3, "Static Core Unit M")

    local controlClosure0 = control0:mockGetClosure()
    local controlClosure1 = control1:mockGetClosure()
    local controlClosure2 = control2:mockGetClosure()
    local controlClosure3 = control3:mockGetClosure()

    lu.assertEquals(controlClosure0.getId(), 1)
    lu.assertEquals(controlClosure1.getId(), 1)
    lu.assertEquals(controlClosure2.getId(), 2)
    lu.assertEquals(controlClosure3.getId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 70.89
    lu.assertEquals(controlClosure0.getMass(), defaultMass)
    lu.assertEquals(controlClosure1.getMass(), defaultMass)
    lu.assertEquals(controlClosure2.getMass(), defaultMass)
    lu.assertNotEquals(controlClosure3.getMass(), defaultMass)
end
--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. core unit of any type, connected to Programming Board on slot1
--
-- Exercises: getElementClass, g, spawnNumberSticker, spawnArrowSticker, deleteSticker, moveSticker
function _G.TestCoreUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _,element in pairs({"dynamic core unit xs", "space core unit xs", "static core unit xs"}) do
        mock = mcu:new(nil, 1, element)
        closure = mock:mockGetClosure()

        mock.gValue = 9.799163818359375

        result, message = pcall(_G.TestCoreUnit.gameBehaviorHelper, mock, closure)
        if not result then
            lu.fail("Element: " .. element .. ", Error: " .. message)
        end
    end
end

--- Runs characterization tests on the provided element.
function _G.TestCoreUnit.gameBehaviorHelper(mock, slot1)

    -- stub this in directly to supress print in the unit test
    local unit = {}
    unit.exit = function() end
    local system = {}
    system.print = function() end

    ---------------
    -- copy from here to unit.start()
    ---------------
    local class = slot1.getElementClass()
    local isStatic, isSpace, isDynamic
    if class == "CoreUnitStatic" then
        isStatic = true
    elseif class == "CoreUnitSpace" then
        isSpace = true
    elseif class == "CoreUnitDynamic" then
        isDynamic = true
    else
        assert(false, "Unexpected class: " .. class)
    end

    -- verify expected functions
    local expectedFunctions = {"getConstructWorldPos", "getConstructId", "getWorldAirFrictionAngularAcceleration",
                             "getWorldAirFrictionAcceleration", "spawnNumberSticker", "spawnArrowSticker",
                             "deleteSticker", "moveSticker", "rotateSticker", "getElementList", "getElementName",
                             "getElementType", "getElementHitPoints", "getElementMaxHitPoints", "getElementMass",
                             "getElementIdList", "getElementNameById", "getElementTypeById",
                             "getElementHitPointsById", "getElementMaxHitPointsById", "getElementMassById",
                             "getElementPositionById", "getElementRotationById", "getElementTagsById", "getAltitude",
                             "g", "getWorldGravity", "getWorldVertical", "getAngularVelocity",
                             "getWorldAngularVelocity", "getAngularAcceleration", "getWorldAngularAcceleration",
                             "getVelocity", "getWorldVelocity", "getWorldAcceleration", "getAcceleration",
                             "getConstructOrientationUp", "getConstructOrientationRight",
                             "getConstructOrientationForward", "getConstructWorldOrientationUp",
                             "getConstructWorldOrientationRight", "getConstructWorldOrientationForward",
                             "getSchematicInfo", "getElementIndustryStatus"}
    for _, v in pairs(_G.Utilities.elementFunctions) do
        table.insert(expectedFunctions, v)
    end
    if isDynamic then
        table.insert(expectedFunctions, "getConstructMass")
        table.insert(expectedFunctions, "getConstructIMass")
        table.insert(expectedFunctions, "getConstructCrossSection")
        table.insert(expectedFunctions, "getMaxKinematicsParametersAlongAxis")
    end
    _G.Utilities.verifyExpectedFunctions(slot1, expectedFunctions)

    -- test inherited methods
    local data = slot1.getData()
    local expectedFields = {"helperId", "name", "type", "altitude", "gravity"}
    local expectedValues = {}
    expectedValues["type"] = '"core"'
    expectedValues["helperId"] = '"core"'
    if isStatic or isSpace then
        expectedValues["gravity"] = "0.0"
    end
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getMass() > 38.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 0, "core")

    if isDynamic then
        assert(slot1.g() > 0)
    else
        assert(slot1.g() == 0.0)
    end

    local stickerIds = {}
    repeat
        local offset = #stickerIds
        table.insert(stickerIds, slot1.spawnArrowSticker(offset, offset, offset, "down"))
    until stickerIds[#stickerIds] < 0
    assert(#stickerIds - 1 == 10, string.format("Created %d arrow stickers.", #stickerIds - 1))
    local firstSticker = stickerIds[1]
    assert(firstSticker == 19, string.format("Started with: %d", firstSticker))
    assert(slot1.deleteSticker(firstSticker) == 0) -- success
    assert(slot1.deleteSticker(firstSticker) == -1) -- second try fails
    assert(slot1.spawnArrowSticker(0, 0, 2, "up") == firstSticker) -- recreating fills emptied index

    -- max number sticker independent of arrows
    local stickerIds = {}
    repeat
        local offset = #stickerIds
        table.insert(stickerIds, slot1.spawnNumberSticker(offset, offset, offset, offset, "side"))
    until stickerIds[#stickerIds] < 0
    assert(#stickerIds - 1 == 10, string.format("Created %d number stickers.", #stickerIds - 1))
    local firstSticker = stickerIds[1]
    assert(firstSticker == 9, string.format("Started with: %d", firstSticker))
    assert(slot1.deleteSticker(firstSticker) == 0) -- success
    assert(slot1.deleteSticker(firstSticker) == -1) -- second try fails
    assert(slot1.spawnNumberSticker(-1, 0, 0, 1, "front") == firstSticker) -- recreating fills emptied index, out of range nb doesn't fail

    assert(slot1.moveSticker(firstSticker, 1, 2, 3) == 0) -- success
    assert(slot1.moveSticker(-1, 1, 2, 3) == -1) -- failure

    system.print("Success")
    unit.exit()
    ---------------
    -- copy to here to unit.start()
    ---------------
end

os.exit(lu.LuaUnit.run())