# DU Mocks

[![Tests](https://github.com/1337joe/du-mocks/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/1337joe/du-mocks/actions/workflows/test.yml)
[![Coverage](https://codecov.io/gh/1337joe/du-mocks/branch/main/graph/badge.svg)](https://codecov.io/gh/1337joe/du-mocks)

Mock objects for generating a more useful [codex](https://1337joe.github.io/du-mocks) and for use testing Dual Universe scripts offline.

## Documentation

The mock files are commented to match the codex as much as possible. In the case that the codex does not acurately or fully describe the Lua API the mocks should follow actual API behavior instead of the codex. To generate a browsable documentation file (once the project is [cloned/set up](#clone-the-repository)) run the following in the base directory:

```sh
ldoc .
```

Output can be found at `doc/index.html`. Note that the documentation won't show the package prefix (`dumocks.`) in file names, but it's still needed to load modules.

An already compiled and uploaded copy of the documentation can be found on this project's github pages with and without documentation for mock methods:

 * https://1337joe.github.io/du-mocks/mock-codex
 * https://1337joe.github.io/du-mocks/web-codex

## Installing

### Luarocks

The easiest way to install this project is using luarocks:

```sh
luarocks install du-mocks
```

This will install all dependencies and place the `dumocks` modules on your lua path, allowing you to import modules like this:

```lua
local mockWarpDrive = require("dumocks.WarpDriveUnit")
```

Version numbers will follow the game version for major/minor numbers (**0**.**24**.x), while the patch number (x.x.**1**) will represent the du-mocks revision number for the Dual Universe minor release, not the Dual Universe patch number. If DU is patched without changing the Lua api a new du-mocks version may not be pushed immediately.

### Clone the Repository

Alternately, you can clone the repository and simply place the project src directory on your lua package path and load modules with the `dumocks.` prefix, like so:

```lua
package.path = package.path .. ";../du-mocks/src/?.lua"
local mockWarpDrive = require("dumocks.WarpDriveUnit")
```

Or confiuring the path in bash:

```sh
export LUA_PATH="../du-mocks/src/?.lua;;$LUA_PATH"
lua ./test/TestMyModule.lua
```

Note: If you get an error similar to `module 'dumocks.Element' not found` on loading a module besides Element, your path is probably pointing to the inside of the `dumocks` package instead of one level above it.

#### Developer Dependencies

Luarocks can be used to install all dependencies: `luarocks install --only-deps du-mocks-scm-0.rockspec`

* [ldoc](https://github.com/lunarmodules/LDoc): For producing nice to read documentation.

* [luaunit](https://github.com/bluebird75/luaunit): For automated testing.

* [luacov](https://keplerproject.github.io/luacov/): For tracking code coverage when running all tests. Can be removed from `runTests.sh` if not desired. To view results using luacov-html (which is a separate package) simply run `luacov -r html` after running tests and open `luacov-html/index.html`.

## Using the Mocks

The unit tests on the mocks themselves provide an example of how to use the mocks. In short, the mock must be imported, then instantiated (and configured), then bundled into a closure for use by the script you are testing:

```lua
local mockConstruct = require("dumocks.Construct")
local mock = mockConstruct:new()
mock.name = "My Construct"
local construct = mock:mockGetClosure()

local name = construct.getName()

assert(name == "My Construct")
```

For a more complex and real-world example, my factory inventory display has tests that use multiple elements: https://github.com/1337joe/du-factory-inventory/blob/main/test/collector/TestCollectorUnit.lua

### Render Script

Testing render script works a little differently: because render script is run in a sandbox with more limited Lua functionality the render script mock provides an environment to run a script in instead of wrapping itself in a closure like other mocks.

<details><summary>Inline Render Script</summary>

```lua
local rs = require("dumocks.RenderScript")
local renderScript = rs:new()
local environment = renderScript:mockGetEnvironment()

-- Set screen input
renderScript.input = "Test"

-- switch to the sandboxed environment
local oldEnv = _ENV
local _ENV = environment

logMessage(getInput())
-- renderscript can be called here
setOutput("test")

-- restore the old environment
_ENV = oldEnv

-- Print the screen output
print(renderScript.output)
```

</details>

<details><summary>External File Render Script</summary>

```lua
local rs = require("dumocks.RenderScript")
local renderScript = rs:new()
local environment = renderScript:mockGetEnvironment()

local script = assert(loadfile("path/to/my/renderscript.lua", "t", environment))

-- Set screen input (read with readInput())
renderScript.input = "Test"

script()

-- Print the screen output (written with setOutput())
print(renderScript.output)
-- Print the SVG output of the script
print(renderScript:mockGenerateSvg())
```

</details>

<details><summary>ScreenUnit</summary>

```lua
local msu = require("dumocks.ScreenUnit")
local screenUnit = msu:new()
local closure = screenUnit:mockGetClosure()

local script = [[
   assert(getInput() == "test input")
   local xRes, yRes = getResolution()
   setOutput(tostring(xRes))
]]

closure.setScriptInput("test input")
closure.setRenderScript(script)

local renderScript, environment = mock:mockDoRenderScript()

-- Print the output returned to the ScreenUnit
print(closure.getScriptOutput())
-- Print the SVG output of the script
print(renderScript:mockGenerateSvg())

```

</details>

Renderscript screen output can be exported as an SVG image by calling `renderScript.mockGenerateSvg()` (see the external file sample code above).

More fleshed out examples of this as well as an HTML header for including most of the in-game fonts are in [TestRenderScript.lua](https://github.com/1337joe/du-mocks/blob/main/test/dumocks/TestRenderScript.lua). The output of this test script from the latest `main` build can be found [here](https://1337joe.github.io/du-mocks/test-results/TestRenderScript.html).

## Testing

Unit tests are provided to validate the funcionality and demonstrate usage of the mocks. The tests depend on lua modules `luaunit` and `luacov` for the unit test framework and code coverage, respectively. To run all tests run the following script from the repository base directory:

```sh
./test/runTests.sh
```

Luaunit arguments may be passed in, such as `-o junit` to produce junit-style xml result files (though the junit file path is hardcoded to output to `test/results/`).

Individual test files are executable and can be run the project root.

### Characterization Tests

All unit tests include characterization tests that can be run in-game to validate expected behavior as well as on the relevant mock object to verify the mock behaves as the game does. These are aided by an extraction tool that can parse out the code blocks and build a document that can be pasted in-game to a control module. To run this tool, execute (replacing `TestFile` with the appropriate test file path/name):

```sh
./test/bundleCharacterizationTest.lua TestFile
```

This will print the result out in the console (for piping to `xclip -selection c` or `clip.exe`, depending on your platform), or an output file can be specified as a second argument to the program.

Blocks of code to be extracted should be surrounded by comment blocks with the following format:

```lua
---------------
-- copy from here to slot1.onStatusChanged(status): *
---------------

<CODE GOES HERE>

---------------
-- copy to here to slot1.onStatusChanged(status): *
---------------
```

#### Format notes

* The start and end blocks should match on method signatures. 
* `slot1` indicates what slot should receive the code (other options besides a numbered slot are `library`, `system`, and `unit`).
* `onStatusChanged(status)` must match the method signature of the handler you want to create. If in doubt create one in-game and export the configuration to clipboard, then paste in notepad to examine it.
* Arguments to be passed in follow the method signature (optionally indictaed by a colon), and should be separated by spaces or commas in the case of multiple arguments.

## Progress

### Steps Required for Each Mock to be Complete

1. Full documentation matching or exceeding the Codex.
   1. Document widget data format/contents.
2. Implementation to allow each method to be used for testing.
3. Unit testing for each method.
4. A characterization (game-behavior) test that can be run in-game and using the mock to validate behavior matches.
   1. Test verifies only expected methods exist and calls element-inherited methods.
5. Element definitions for the in-game elements that the mock applies to.

### Current State

* :white_large_square: = Missing
* :soon: = In Progress
* :heavy_check_mark: = Completed
* :heavy_minus_sign: = N/A
* U = Untested

| Unit | 1 | 2 | 3 | 4 | 5 |
| ---- | - | - | - | - | - |
| Construct | :heavy_check_mark: :heavy_minus_sign: | :soon: | :white_large_square: | :white_large_square: :heavy_check_mark: | :heavy_minus_sign: |
| Library | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_minus_sign: :heavy_check_mark: | :heavy_minus_sign: |
| Player | :heavy_check_mark: :heavy_minus_sign: | :soon: | :white_large_square: | :soon: :heavy_check_mark: | :heavy_minus_sign: |
| System | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_minus_sign: |
| Element | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :heavy_minus_sign: :heavy_minus_sign: | :heavy_minus_sign: |
| AdjustorUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :white_large_square: | :white_large_square: :heavy_check_mark: | :heavy_check_mark: |
| AirfoilUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :white_large_square: | :white_large_square: :heavy_check_mark: | :heavy_check_mark: |
| AntiGravityGeneratorUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :soon: :soon: | :heavy_check_mark: |
| BaseShieldGeneratorUnit | :heavy_check_mark: :white_large_square: | :white_large_square: | :white_large_square: | :white_large_square: :white_large_square: | :white_large_square: |
| BrakeUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :white_large_square: | :white_large_square: :heavy_check_mark: | :heavy_check_mark: |
| ContainerUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :soon: |
| ControlUnit | :heavy_check_mark: :white_large_square: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| CoreUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| CounterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| DatabankUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| DetectionZoneUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| DoorUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :soon: |
| EmitterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| EngineUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :white_large_square: | :white_large_square: :heavy_check_mark: | :soon: |
| FireworksUnit | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| ForceFieldUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| GyroUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| IndustryUnit | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| LandingGearUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| LaserDetectorUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| LaserEmitterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| LightUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| ManualButtonUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| ManualSwitchUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| MiningUnit | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| PlasmaExtractorUnit | :heavy_check_mark: :white_large_square: | :white_large_square: | :white_large_square: | :white_large_square: :white_large_square: | :soon: |
| PressureTileUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| RadarUnit | :heavy_check_mark: :white_large_square: | :heavy_check_mark: | :soon: | :soon: :heavy_check_mark: | :soon: |
| ReceiverUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| RenderScript | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_minus_sign: |
| ScreenUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark:| :soon: :heavy_check_mark: | :heavy_check_mark: |
| ShieldGeneratorUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :soon: |
| SurfaceEngineUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :white_large_square: | :heavy_check_mark: :heavy_check_mark: | :soon: |
| TelemeterUnit | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| TransponderUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| WarpDriveUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :soon: | :heavy_check_mark: :soon: | :heavy_check_mark: |
| WeaponUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :soon: |

## Support

Many mocks are incomplete (until I code something that needs them for testing), but documentation should be up to date. If you encounter a function that's not documented here (or where my documentation doesn't match the function) either send me a message or file a GitHub Issue (or fork the project, fix it, and send me a pull request).

Discord: 1337joe#6186

In-Game: W3asel

My game/coding time is often limited so I can't promise a quick response.
