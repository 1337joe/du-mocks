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

* P = Partially complete
* F = Fully complete
* - = N/A

| Mock | 1 | 2 | 3 | 4 | 5 |
| ---- | - | - | - | - | - |
| MockElement | F | P | | | - |
| MockSystem | P | | | | - |
| MockControlUnit | P | | | | |
| MockDatabankUnit | F | F | F | F | F |
| MockContainerUnit | F | F | F | | F |
| MockIndustryUnit | P | | | | |
| MockManualSwitchUnit | F | F | F | F | F |
