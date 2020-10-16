# DU Mocks

Mock objects for use testing Dual Universe scripts offline.

To use this project simply place the project root directory on your lua package path and load modules with the `dumocks.` prefix, like so:

```lua
package.path = package.path..";../du-mocks/?.lua"
local mockWarpDrive = require("dumocks.WarpDriveUnit")
```

Note: If you get a `module 'dumocks.Element' not found` on loading a module besides Element, your path is probably pointing to the inside of the `dumocks` package instead of one level above it like the path should be.

## Documentation

The mock files are commented to match the codex as much as possible. In the case that the codex does not acurately or fully describe the Lua API the mocks should follow actual API behavior instead of the codex. To generate a browsable documentation file run the following in the base directory:

```sh
ldoc .
```

Output can be found at `doc/index.html`. Note that the documentation won't show the package prefix (`dumocks.`) in file names, but it's still needed to load modules.

An already compiled and uploaded copy of the documentation can be found at: https://du.w3asel.com

## Testing

Unit tests are provided to validate the funcionality and demonstrate usage of the mocks. The tests depend on lua modules `luaunit` and `luacov` for the unit test framework and code coverage, respectively. To run all tests run the following script from the repository base directory:

```sh
./tests/runTests.sh
```

Luaunit arguments may be passed in, such as `-o junit` to produce junit-style xml result files (though the junit file path is hardcoded to output to `tests/`).

Individual test files are executable and may be run directly from within the tests directory.

### Characterization Tests

Many, eventually all, unit tests include characterization tests that can be run in-game to validate expected behavior as well as on the relevant mock object to verify the mock behaves as the game does. These are aided by an extraction tool that can parse out the code blocks and build a document that can be pasted in-game to a control module. To run this tool, execute (replacing `TestFile` with the appropriate test file path/name):

```sh
./tests/bundleCharacterizationTest.lua TestFile
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

Format notes:

* The start and end blocks should match on method signatures. 
* `slot1` indicates what slot should receive the code (other options besides a numbered slot are `library`, `system`, and `unit`).
* `statusChanged(status)` must match the method signature of the handler you want to create. If in doubt create one in-game and export the configuration to clipboard, then paste in notepad to examine it.
* Arguments to be passed in follow the method signature (optionally indictaed by a colon), and should be separated by spaces or commas in the case of multiple arguments.

## Progress

### Steps Required for Each Mock to be Complete

1. Full documentation matching or exceeding the Codex.
2. Implementation to allow each method to be used for testing.
3. Unit testing for each method.
4. A characterization (game-behavior) test that can be run in-game and using the mock to validate behavior matches.
5. Element definitions for the in-game elements that the mock applies to.

### Current State

* P = In Progress
* :heavy_check_mark: = Completed
* `-` = N/A
* U = Untested

| Unit | 1 | 2 | 3 | 4 | 5 |
| ---- | - | - | - | - | - |
| Element | :heavy_check_mark: | P | P | | - |
| ContainerUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | :heavy_check_mark: |
| ControlUnit | :heavy_check_mark: | | P | | P |
| DatabankUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| DoorUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | P |
| EngineUnit | :heavy_check_mark: | P | P | | P |
| FireworksUnit | :heavy_check_mark: | P | P | | |
| ForceFieldUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| LandingGearUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | P |
| LightUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| AntiGravityGeneratorUnit | :heavy_check_mark: | :heavy_check_mark: | P | | P |
| IndustryUnit | :heavy_check_mark: | P | P | P | :heavy_check_mark: |
| CounterUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| EmitterUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | P |
| ReceiverUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | P |
| CoreUnit | :heavy_check_mark: | P | P | | P |
| ScreenUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark:| | :heavy_check_mark: |
| DetectionZoneUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | U | :heavy_check_mark: |
| GyroUnit | :heavy_check_mark: | :heavy_check_mark: | P | | :heavy_check_mark: |
| LaserDetectorUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | :heavy_check_mark: |
| LaserEmitterUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | :heavy_check_mark: |
| ManualButtonUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| ManualSwitchUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| PressureTileUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| RadarUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| TelemeterUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| WarpDriveUnit | :heavy_check_mark: | :heavy_check_mark: | P | | :heavy_check_mark: |
| Library | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | - | - |
| System | :heavy_check_mark: | P | P | | - |
