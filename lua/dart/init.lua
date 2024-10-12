local Config = require("dart.config")
local Data = require("dart.data")
local Extensions = require("dart.extensions")
local List = require("dart.lists")

---@class Dart
---@field config DartConfig
---@field data DartData
---@field lists {[string]: DartList[]}
local Dart = {}

Dart.__index = Dart

---@param dart Dart
local function sync_on_change(dart)
    local function sync(...)
        return function()
            dart:sync()
        end
    end

    Extensions.extensions:add_listener({
        ADD = sync("ADD"),
        REMOVE = sync("REMOVE"),
        REORDER = sync("REORDER"),
        LIST_CHANGE = sync("LIST_CHANGE"),
        POSITION_UPDATED = sync("POSITION_UPDATED")
    })
end

---@return {[string]: DartList[]}
---@param config DartConfig
---@param data DartData
local function get_lists(config, data)
    local lists = {}
    for file, locations in pairs(data._data) do
        lists[file] = List:new(config, locations)
    end

    return lists
end

---@return Dart
function Dart:new()
    local config = Config.get_default_config()

    local data = Data:new(config)
    data:_set_initial_data()

    local dart = setmetatable({
        _extensions = Extensions.extensions,
        config = config,
        data = data,
        lists = get_lists(config, data),
    }, self)
    sync_on_change(dart)

    return dart
end

---@return DartList
function Dart:list()
    local current_file = vim.fn.expand("%:t")
    local target_list = self.lists[current_file]
    if target_list ~= nil then
        return target_list
    else
        self.lists[current_file] = List:new(self.config)
    end

    return self.lists[current_file]
end

function Dart:sync()
    local raw_data = {}
    for file, dart_list in pairs(self.lists) do
        raw_data[file] = dart_list.items
    end

    self.data:update_data(raw_data)
    self.data:write_data()
end

local dart = Dart:new()

return dart
