package = "du-mocks"
version = "0.25.1-1"
source = {
   url = "git://github.com/1337joe/du-mocks",
   tag = "v0.25.1",
}
description = {
   summary = "Mock objects to simulate the Dual Universe lua environment.",
   detailed = "Mock objects for generating a more useful codex and for use testing Dual Universe scripts offline.",
   homepage = "https://github.com/1337joe/du-mocks",
   license = "MIT",
}
dependencies = {
   "lua >= 5.2",

   -- build/test dependencies
   "ldoc",
   "luaunit",
   "luacov",
}
build = {
   type = "builtin",
   modules = {
      ["dumocks.AntiGravityGeneratorUnit"] = "src/dumocks/AntiGravityGeneratorUnit.lua",
      ["dumocks.ContainerUnit"] = "src/dumocks/ContainerUnit.lua",
      ["dumocks.ControlUnit"] = "src/dumocks/ControlUnit.lua",
      ["dumocks.CoreUnit"] = "src/dumocks/CoreUnit.lua",
      ["dumocks.CounterUnit"] = "src/dumocks/CounterUnit.lua",
      ["dumocks.DatabankUnit"] = "src/dumocks/DatabankUnit.lua",
      ["dumocks.DetectionZoneUnit"] = "src/dumocks/DetectionZoneUnit.lua",
      ["dumocks.DoorUnit"] = "src/dumocks/DoorUnit.lua",
      ["dumocks.Element"] = "src/dumocks/Element.lua",
      ["dumocks.ElementWithState"] = "src/dumocks/ElementWithState.lua",
      ["dumocks.ElementWithToggle"] = "src/dumocks/ElementWithToggle.lua",
      ["dumocks.EmitterUnit"] = "src/dumocks/EmitterUnit.lua",
      ["dumocks.EngineUnit"] = "src/dumocks/EngineUnit.lua",
      ["dumocks.FireworksUnit"] = "src/dumocks/FireworksUnit.lua",
      ["dumocks.ForceFieldUnit"] = "src/dumocks/ForceFieldUnit.lua",
      ["dumocks.GyroUnit"] = "src/dumocks/GyroUnit.lua",
      ["dumocks.IndustryUnit"] = "src/dumocks/IndustryUnit.lua",
      ["dumocks.LandingGearUnit"] = "src/dumocks/LandingGearUnit.lua",
      ["dumocks.LaserDetectorUnit"] = "src/dumocks/LaserDetectorUnit.lua",
      ["dumocks.LaserEmitterUnit"] = "src/dumocks/LaserEmitterUnit.lua",
      ["dumocks.Library"] = "src/dumocks/Library.lua",
      ["dumocks.LightUnit"] = "src/dumocks/LightUnit.lua",
      ["dumocks.ManualButtonUnit"] = "src/dumocks/ManualButtonUnit.lua",
      ["dumocks.ManualSwitchUnit"] = "src/dumocks/ManualSwitchUnit.lua",
      ["dumocks.PressureTileUnit"] = "src/dumocks/PressureTileUnit.lua",
      ["dumocks.RadarUnit"] = "src/dumocks/RadarUnit.lua",
      ["dumocks.ReceiverUnit"] = "src/dumocks/ReceiverUnit.lua",
      ["dumocks.ScreenUnit"] = "src/dumocks/ScreenUnit.lua",
      ["dumocks.System"] = "src/dumocks/System.lua",
      ["dumocks.TelemeterUnit"] = "src/dumocks/TelemeterUnit.lua",
      ["dumocks.WarpDriveUnit"] = "src/dumocks/WarpDriveUnit.lua",
   },
   copy_directories = {
   }
}
