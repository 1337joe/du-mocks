#!/usr/bin/env lua
--- Tests on dumocks.CoreUnit.
-- @see dumocks.CoreUnit

-- set search path to include src directory
package.path = "src/?.lua;" .. package.path

local lu = require("luaunit")

local mcu = require("dumocks.CoreUnit")
local utilities = require("test.Utilities")

_G.TestCoreUnit = {}

--- Verify constructor arguments properly handled and independent between instances.
function _G.TestCoreUnit.testConstructor()

    -- default element:
    -- ["dynamic core unit xs"] = {mass = 70.89, maxHitPoints = 50.0, itemId = 183890713, class = "CoreUnitDynamic"}

    local control0 = mcu:new()
    local control1 = mcu:new(nil, 1, "Dynamic Core Unit XS")
    local control2 = mcu:new(nil, 2, "invalid")
    local control3 = mcu:new(nil, 3, "Static Core Unit M")

    local controlClosure0 = control0:mockGetClosure()
    local controlClosure1 = control1:mockGetClosure()
    local controlClosure2 = control2:mockGetClosure()
    local controlClosure3 = control3:mockGetClosure()

    lu.assertEquals(controlClosure0.getLocalId(), 1)
    lu.assertEquals(controlClosure1.getLocalId(), 1)
    lu.assertEquals(controlClosure2.getLocalId(), 2)
    lu.assertEquals(controlClosure3.getLocalId(), 3)

    -- prove default element is selected only where appropriate
    local defaultMass = 70.89
    lu.assertEquals(controlClosure0.getMass(), defaultMass)
    lu.assertEquals(controlClosure1.getMass(), defaultMass)
    lu.assertEquals(controlClosure2.getMass(), defaultMass)
    lu.assertNotEquals(controlClosure3.getMass(), defaultMass)

    local defaultId = 183890713
    lu.assertEquals(controlClosure0.getItemId(), defaultId)
    lu.assertEquals(controlClosure1.getItemId(), defaultId)
    lu.assertEquals(controlClosure2.getItemId(), defaultId)
    lu.assertNotEquals(controlClosure3.getItemId(), defaultId)
end
--- Characterization test to determine in-game behavior, can run on mock and uses assert instead of luaunit to run
-- in-game.
--
-- Test setup:
-- 1. core unit of any type, connected to Programming Board on slot1
--
-- Exercises: getClass, getItemId, getName, getWidgetData g, spawnNumberSticker, spawnArrowSticker, deleteSticker,
--   moveSticker
function _G.TestCoreUnit.testGameBehavior()
    local mock, closure
    local result, message
    for _, element in pairs({"dynamic core unit xs", "space core unit xs", "static core unit xs"}) do
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
    unit.exit = function()
    end
    local system = {}
    system.print = function(_)
    end

    ---------------
    -- copy from here to unit.onStart()
    ---------------
    local class = slot1.getClass()
    local expectedName, expectedIds
    local isStatic, isSpace, isDynamic
    if class == "CoreUnitStatic" then
        isStatic = true
        expectedName = "static"
        expectedIds = {[2738359963] = true, [2738359893] = true, [909184430] = true, [910155097] = true}
    elseif class == "CoreUnitSpace" then
        isSpace = true
        expectedName = "space"
        expectedIds = {[3624942103] = true, [3624940909] = true, [5904195] = true, [5904544] = true}
    elseif class == "CoreUnitDynamic" then
        isDynamic = true
        expectedName = "dynamic"
        expectedIds = {[183890713] = true, [183890525] = true, [1418170469] = true, [1417952990] = true}
    else
        assert(false, "Unexpected class: " .. class)
    end
    expectedName = expectedName .. " core unit %w+ %[1]"
    assert(string.match(string.lower(slot1.getName()), expectedName), slot1.getName())
    assert(expectedIds[slot1.getItemId()], "Unexpected ID: " .. slot1.getItemId())

    -- verify expected functions
    local expectedFunctions = {"getConstructWorldPos", "getConstructId", "getWorldAirFrictionAngularAcceleration",
                               "getWorldAirFrictionAcceleration", "spawnNumberSticker", "spawnArrowSticker",
                               "deleteSticker", "moveSticker", "rotateSticker", "getElementIdList",
                               "getElementNameById", "getElementTypeById", "getElementHitPointsById",
                               "getElementMaxHitPointsById", "getElementMassById", "getElementPositionById",
                               "getElementTagsById", "getAltitude", "g", "getWorldGravity",
                               "getWorldVertical", "getAngularVelocity", "getWorldAngularVelocity",
                               "getAngularAcceleration", "getWorldAngularAcceleration", "getVelocity",
                               "getWorldVelocity", "getWorldAcceleration", "getAcceleration",
                               "getConstructOrientationUp", "getConstructOrientationRight",
                               "getConstructOrientationForward", "getConstructWorldOrientationUp",
                               "getConstructWorldOrientationRight", "getConstructWorldOrientationForward",
                               "getSchematicInfo", "getElementIndustryStatusById", "getPvPTimer", "getPlayersOnBoard",
                               "getDockedConstructs", "isPlayerBoarded", "isConstructDocked", "forceDeboard",
                               "forceUndock", "getBoardedPlayerMass", "getDockedConstructMass", "getParent",
                               "getCloseParents", "getClosestParent", "dock", "undock", "setDockingMode",
                               "getDockingMode", "getMaxCoreStress", "getCoreStress", "getCoreStressRatio",
                               "getElementUpById", "getAbsoluteVelocity", "getWorldAbsoluteVelocity",
                               "getParentForward", "getConstructWorldRight", "getConstructName", "getParentWorldUp",
                               "getParentWorldForward", "getElementRightById", "getParentRight", "getParentUp",
                               "getParentWorldPosition", "getParentPosition", "getParentWorldRight",
                               "getOrientationUnitId", "getElementForwardById", "getConstructWorldUp",
                               "getCurrentPlanetId", "getConstructWorldForward", "getPlayersOnBoardInVRStation",
                               "isPlayerBoardedInVRStation", "getBoardedInVRStationAvatarMass",
                               "forceInterruptVRSession", "getMaxSpeedPerAxis", "getMaxAngularSpeed", "getMaxSpeed", "getElementIndustryInfoById", "getGravityIntensity", "getElementClassById", "getElementItemIdById", "getElementDisplayNameById"}
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
    local data = slot1.getWidgetData()
    local expectedFields = {"helperId", "name", "type", "altitude", "gravity", "currentStress", "maxStress"}
    local expectedValues = {}
    expectedValues["type"] = '"core"'
    expectedValues["helperId"] = '"core"'
    expectedValues["currentStress"] = "0.0"
    if isStatic or isSpace then
        expectedValues["gravity"] = "0.0"
    end
    _G.Utilities.verifyWidgetData(data, expectedFields, expectedValues)

    assert(slot1.getMaxHitPoints() >= 50.0)
    assert(slot1.getMass() > 38.0)
    _G.Utilities.verifyBasicElementFunctions(slot1, 0, "core")

    if isDynamic then
        assert(slot1.getGravityIntensity() > 0)
    else
        assert(slot1.getGravityIntensity() == 0.0)
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
    -- copy to here to unit.onStart()
    ---------------
end

os.exit(lu.LuaUnit.run())
