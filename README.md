# DU Mocks

Mock objects for use testing DU scripts offline.

## Documentation

The mock files are commented to match the codex. To generate a browsable documentation file run `ldoc .` in the base directory. Output can be found at `doc/index.html`.

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

| Mock | 1 | 2 | 3 | 4 | 5 |
| ---- | - | - | - | - | - |
| MockElement | :heavy_check_mark: | P | | | - |
| MockContainerUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | | :heavy_check_mark: |
| MockControlUnit | P | | | | |
| MockDatabankUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| MockDoorUnit | | | | | |
| MockEngineUnit | | | | | |
| MockFireworksUnit | | | | | |
| MockForceFieldUnit | | | | | |
| MockLandingGearUnit | | | | | |
| MockLightUnit | | | | | |
| MockAntiGravityGeneratorUnit | | | | | |
| MockIndustryUnit | :heavy_check_mark: | P | | | |
| MockCounterUnit | | | | | |
| MockEmitterUnit | | | | | |
| MockReceiverUnit | | | | | |
| MockCoreUnit | | | | | |
| MockScreenUnit | | | | | |
| MockDetectionZoneUnit | | | | | |
| MockGyroUnit | | | | | |
| MockLaserDetectorUnit | | | | | |
| MockLaserEmitterUnit | | | | | |
| MockManualButtonUnit | | | | | |
| MockManualSwitchUnit | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: |
| MockPressureTileUnit | | | | | |
| MockRadarUnit | | | | | |
| MockTelemeterUnit | :heavy_check_mark: | :heavy_check_mark: | | | |
| MockWarpDriveUnit | :heavy_check_mark: | :heavy_check_mark: | | | |
| MockLibrary | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | - | - |
| MockSystem | P | | | | - |
