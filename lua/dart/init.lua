local Config = require("dart.config")
local List = require("dart.list")

---@class Dart
---@field config DartConfig
---@field list DartList

local Dart = {}
Dart.__index = Dart

---@return Dart
function Dart:new()
    local config = Config.get_default_config()
    local list = List.new(config)

    local dart = setmetatable({
        config = config,
        list = list,
    }, self)

    return dart
end

local dart = Dart:new()

return dart
