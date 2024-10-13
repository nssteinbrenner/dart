local Data = require("dart.data")
local Events = require("dart.events")
local List = require("dart.list")
local Ui = require("dart.ui")

---@class DartHandler
---@field config DartConfig
---@field data DartData
---@field lists {[string]: DartList}
local DartHandler = {}

DartHandler.__index = DartHandler

---@return {[string]: DartList}
---@param config DartListConfig
---@param data DartData
local function get_lists(config, data)
    local lists = {}
    for file, locations in pairs(data._data) do
        lists[file] = List:new(config, locations)
    end

    return lists
end

---@return DartHandler
function DartHandler:new(config)
    local data = Data:new(config.data)
    data:_set_initial_data()

    local dart_handler = setmetatable({
        config = config,
        data = data,
        lists = get_lists(config.list, data),
        ui = Ui:new(config.ui),
    }, self)

    Events.events:add_listener({
        ADD = function() dart_handler:sync() end,
        REMOVE = function() dart_handler:sync() end,
        UI_SAVE = function() dart_handler:sync() end,
    })

    return dart_handler
end

---@return DartList
function DartHandler:list()
    local current_file = vim.fn.expand("%:t")
    local target_list = self.lists[current_file]
    if target_list ~= nil then
        return target_list
    else
        self.lists[current_file] = List:new(self.config.list)
    end

    return self.lists[current_file]
end

---@return nil
function DartHandler:sync()
    local raw_data = {}
    for file, dart_list in pairs(self.lists) do
        raw_data[file] = dart_list.items
    end

    self.data:update_data(raw_data)
    self.data:write_data()
end

return DartHandler
