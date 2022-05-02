# DU Mocks

Mock objects for generating a more useful codex and for use testing Dual Universe scripts offline.

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

Note: If you get an error similar to `module 'dumocks.Element' not found` on loading a module besides Element, your path is probably pointing to the inside of the `dumocks` package instead of one level above it.

## Documentation

The mock files are commented to match the codex as much as possible. In the case that the codex does not acurately or fully describe the Lua API the mocks should follow actual API behavior instead of the codex. To generate a browsable documentation file run the following in the base directory:

```sh
ldoc .
```

Output can be found at `doc/index.html`. Note that the documentation won't show the package prefix (`dumocks.`) in file names, but it's still needed to load modules.

An already compiled and uploaded copy of the documentation can be found on my website with and without documentation for mock methods:

 * https://du.w3asel.com/du-mocks/mock-codex
 * https://du.w3asel.com/du-mocks/web-codex

## Developer Dependencies

Luarocks can be used to install all dependencies: `luarocks install --only-deps du-mocks-scm-0.rockspec`

* [ldoc](https://github.com/lunarmodules/LDoc): For producing nice to read documentation.

* [luaunit](https://github.com/bluebird75/luaunit): For automated testing.

* [luacov](https://keplerproject.github.io/luacov/): For tracking code coverage when running all tests. Can be removed from `runTests.sh` if not desired. To view results using luacov-html (which is a separate package) simply run `luacov -r html` after running tests and open `luacov-html/index.html`.

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
-- copy from here to slot1.statusChanged(status): *
---------------

<CODE GOES HERE>

---------------
-- copy to here to slot1.statusChanged(status): *
---------------
```

#### Format notes:

* The start and end blocks should match on method signatures. 
* `slot1` indicates what slot should receive the code (other options besides a numbered slot are `library`, `system`, and `unit`).
* `statusChanged(status)` must match the method signature of the handler you want to create. If in doubt create one in-game and export the configuration to clipboard, then paste in notepad to examine it.
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
| Library | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_minus_sign: :heavy_check_mark: | :heavy_minus_sign: |
| System | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_minus_sign: |
| Element | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :heavy_minus_sign: :heavy_minus_sign: | :heavy_minus_sign: |
| AntiGravityGeneratorUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| BaseShieldGeneratorUnit | :soon: :white_large_square: | :white_large_square: | :white_large_square: | :white_large_square: :white_large_square: | :white_large_square: |
| ContainerUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :soon: |
| ControlUnit | :heavy_check_mark: :white_large_square: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| CoreUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| CounterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| DatabankUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| DetectionZoneUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| DoorUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| EmitterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| EngineUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :soon: |
| FireworksUnit | :heavy_check_mark: :white_large_square: | :soon: | :soon: | :white_large_square: :white_large_square: | :white_large_square: |
| ForceFieldUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| GyroUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| IndustryUnit | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| LandingGearUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| LaserDetectorUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| LaserEmitterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| LightUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| ManualButtonUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| ManualSwitchUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| MiningUnit | :heavy_check_mark: :heavy_minus_sign: | :soon: | :soon: | :soon: :heavy_check_mark: | :heavy_check_mark: |
| PressureTileUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| RadarUnit | :heavy_check_mark: :white_large_square: | :heavy_check_mark: | :soon: | :soon: :heavy_check_mark: | :soon: |
| ReceiverUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| ScreenRenderer | :heavy_check_mark: :heavy_minus_sign: | :soon: | | :soon: :heavy_check_mark: | - |
| ScreenUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark:| :soon: :heavy_check_mark: | :heavy_check_mark: |
| ShieldGeneratorUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :soon: |
| TelemeterUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| TransponderUnit | :heavy_check_mark: :heavy_minus_sign: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| WarpDriveUnit | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: | :soon: | :heavy_check_mark: :heavy_check_mark: | :heavy_check_mark: |
| WeaponUnit | :heavy_check_mark: :heavy_check_mark: | :soon: | :soon: | :soon: :heavy_check_mark: | :soon: |

## Support

Many mocks are incomplete (until I code something that needs them for testing), but documentation should be up to date. If you encounter a function that's not documented here (or where my documentation doesn't match the function) either send me a message or file a GitHub Issue (or fork the project, fix it, and send me a pull request).

Discord: 1337joe#6186

In-Game: W3asel

My game/coding time is often limited so I can't promise a quick response.
