# DU Mocks

Mock objects for use testing DU scripts offline.

To use this project simply place the project root directory on your lua package path and load modules with the `dumocks.` prefix, like so:

```lua
package.path = package.path..";../du-mocks/?.lua"
local mockWarpDrive = require("dumocks.WarpDriveUnit")
```

Note: If you get a `module 'dumocks.Element' not found` on loading a module besides Element, your path is probably pointing to the inside of the `dumocks` package instead of one level above it like the path should be.

## Documentation

The mock files are commented to match the codex. To generate a browsable documentation file run the following in the base directory:

```sh
ldoc .
```

Output can be found at `doc/index.html`. Note that the documentation won't show the package prefix (`dumocks.`), but it's still needed to load modules.

## Testing

Unit tests are provided to validate the funcionality and demonstrate usage of the mocks. The tests depend on lua modules `luaunit` and `luacov` for the unit test framework and code coverage, respectively. To run all tests run the following script from the repository base directory:

```sh
./tests/runTests.sh
```

Luaunit arguments may be passed in, such as `-o junit` to produce junit-style xml result files (though the junit file path is hardcoded to output to `tests/results/`).

Individual test files are executable and may be run directly from within the tests directory.

## Progress

### Steps Required for Each Mock to be Complete

1. Full documentation matching the Codex.
2. Implementation to allow each method to be used for testing.
3. Unit testing for each method.
4. A game-behavior test that can be run in-game and using the mock to validate behavior.
5. Element definitions for the in-game elements that the mock applies to.

### Current State

* P = In Progress
* :heavy_check_mark: = Completed
* `-` = N/A

| Unit | 1 | 2 | 3 | 4 | 5 |
| ---- | - | - | - | - | - |
| Element | :heavy_check_mark: | P | P | | - |
| ContainerUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | :heavy_check_mark: |
| ControlUnit | :heavy_check_mark: | | P | | |
| DatabankUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| DoorUnit | :heavy_check_mark: | :heavy_check_mark: | P | | P |
| EngineUnit | :heavy_check_mark: | P | P | | |
| FireworksUnit | :heavy_check_mark: | P | P | | |
| ForceFieldUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| LandingGearUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| LightUnit | :heavy_check_mark: | :heavy_check_mark: | P | | P |
| AntiGravityGeneratorUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| IndustryUnit | :heavy_check_mark: | P | P | | |
| CounterUnit | :heavy_check_mark: | :heavy_check_mark: | P | | P |
| EmitterUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| ReceiverUnit | :heavy_check_mark: | P | P | | |
| CoreUnit | :heavy_check_mark: | P | P | | |
| ScreenUnit | :heavy_check_mark: | | P | | |
| DetectionZoneUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| GyroUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| LaserDetectorUnit | :heavy_check_mark: | :heavy_check_mark: | P | | P |
| LaserEmitterUnit | :heavy_check_mark: | :heavy_check_mark: | P | | P |
| ManualButtonUnit | :heavy_check_mark: | :heavy_check_mark: | P | | :heavy_check_mark: |
| ManualSwitchUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| PressureTileUnit | :heavy_check_mark: | :heavy_check_mark: | P | | :heavy_check_mark: |
| RadarUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| TelemeterUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| WarpDriveUnit | :heavy_check_mark: | :heavy_check_mark: | P | | |
| Library | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | - | - |
| System | :heavy_check_mark: | P | P | | - |
