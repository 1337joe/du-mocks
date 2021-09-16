#!/usr/bin/env lua
--- Reads in a lua unit tests file and extracts the characterization test pieces from it, then bundles them for direct
-- pasting into an in-game control unit.

-- parse arguments
if not arg[1] or arg[1] == "--help" or arg[1] == "-h" then
    print("Expected arguments: inputFile [outputFile]")
    print("If outputFile is not provided will stream results to stdout.")
    -- TODO better help display, more detailed argument handling
    return
end

local testDirPath = string.match(arg[0], "(.*[/\\])%a+%.lua")
local inputFile = arg[1]

local blocks = {}

-- look for inputFile in current working directory and in directory containing script
local function fileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

local SKIP_LINE_PATTERN = "[ -]+%c"
local BLOCK_PATTERN = "--- copy from here to (.-)%c(.-)%c%s--- copy to here to (.-)%c"

local function loadFileToBlocks(file)
    if not fileExists(file) then
        if fileExists(testDirPath..file) then
            file = testDirPath..file
        else
            error("File not found: "..file)
        end
    end

    -- read content
    local inputHandle = io.open(file, "rb")
    local fileContents = io.input(inputHandle):read("*all")
    inputHandle:close()

    -- parse content into blocks
    fileContents = string.gsub(fileContents, SKIP_LINE_PATTERN, "")
    for target,code,target2 in string.gmatch(fileContents, BLOCK_PATTERN) do
        if target ~= target2 then
            print("WARNING: Non-matching labels: "..target.." ~= "..target2)
        end
        table.insert(blocks, {target=target, code=code})
    end
end

loadFileToBlocks(inputFile)
loadFileToBlocks("Utilities.lua")

-- bail early if no code blocks
if #blocks == 0 then
    return
end

-- prepare output
local TARGET_PATTERN = "([a-zA-Z0-9]+)%.([a-zA-Z()*,]+)(.*)"
local ARGS_PATTERN = "([a-zA-Z0-9_*]+)"
local BOILERPLATE_START = [[
{
    "slots":{
        "0":{"name":"slot1","type":{"events":[],"methods":[]}},
        "1":{"name":"slot2","type":{"events":[],"methods":[]}},
        "2":{"name":"slot3","type":{"events":[],"methods":[]}},
        "3":{"name":"slot4","type":{"events":[],"methods":[]}},
        "4":{"name":"slot5","type":{"events":[],"methods":[]}},
        "5":{"name":"slot6","type":{"events":[],"methods":[]}},
        "6":{"name":"slot7","type":{"events":[],"methods":[]}},
        "7":{"name":"slot8","type":{"events":[],"methods":[]}},
        "8":{"name":"slot9","type":{"events":[],"methods":[]}},
        "9":{"name":"slot10","type":{"events":[],"methods":[]}},
        "-1":{"name":"unit","type":{"events":[],"methods":[]}},
        "-2":{"name":"system","type":{"events":[],"methods":[]}},
        "-3":{"name":"library","type":{"events":[],"methods":[]}}
    },
    "handlers":[]]
local BOILERPLATE_END = [[
],
    "methods":[],
    "events":[]
}]]
-- fill with: sanitized code, formatted arguments, method signature, slot number, key number
local CODE_FORMAT = '{"code":"%s","filter":{"args":[%s],"signature":"%s","slotKey":"%d"},"key":"%d"}'
local ARGS_FORMAT = '{"%s":"%s"}'

-- sanitize a block of code
local function sanitize(code)
    local sanitized = code
    sanitized = string.gsub(sanitized, "\\", "\\\\")
    sanitized = string.gsub(sanitized, "\"", "\\\"")
    sanitized = string.gsub(sanitized, "%c", "\\n")
    sanitized = string.gsub(sanitized, "^    ", "") -- collapse initial indent
    sanitized = string.gsub(sanitized, "\\n    ", "\\n") -- collapse each line first indent
    return sanitized
end

-- build output
local output = BOILERPLATE_START
local key = 0
local first = true
for _,block in pairs(blocks) do
    if not first then
        output = output..","
    end
    first = false

    local slot,signature,args = string.match(block.target, TARGET_PATTERN)

    local sanitizedCode = sanitize(block.code)
    local formattedArgs = ""
    for argValue in string.gmatch(args, ARGS_PATTERN) do
        if string.len(formattedArgs) > 0 then
            formattedArgs = formattedArgs..","
        end
        local argLabel = "value"
        if argValue == "*" then
            argLabel = "variable"
        end
        formattedArgs = formattedArgs..string.format(ARGS_FORMAT, argLabel, argValue)
    end
    local slotKey
    if slot == "unit" then
        slotKey = -1
    elseif slot == "system" then
        slotKey = -2
    elseif slot == "library" then
        slotKey = -3
    else
        slotKey = tonumber(string.sub(slot, 5)) - 1
    end

    output = output..string.format(CODE_FORMAT, sanitizedCode, formattedArgs, signature, slotKey, key)

    key = key + 1
end
output = output..BOILERPLATE_END

-- output to file if specified, stdout otherwise
if arg[2] and arg[2] ~= "" then
    local outputHandle = io.open(arg[2], "w")
    io.output(outputHandle):write(output)
    outputHandle:close()
else
    print(output)
end
