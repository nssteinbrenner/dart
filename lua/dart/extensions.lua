---@class DartExtensions
---@field listeners DartExtension[]
local DartExtensions = {}

---@class DartExtension
---@field ADD? fun(...): nil
---@field SELECT? fun(...): nil
---@field REMOVE? fun(...): nil
---@field REORDER? fun(...): nil
---@field UI_CREATE? fun(...): nil
---@field SETUP_CALLED? fun(...): nil
---@field LIST_CREATED? fun(...): nil
---@field LIST_READ? fun(...): nil
---@field NAVIGATE? fun(...): nil
---@field POSITION_UPDATED? fun(...): nil

DartExtensions.__index = DartExtensions

function DartExtensions:new()
    return setmetatable({
        listeners = {}
    }, self)
end

---@param extension DartExtension
function DartExtensions:add_listener(extension)
    table.insert(self.listeners, extension)
end

function DartExtensions:clear_listeners()
    self.listeners = {}
end

---@param type string
---@param ... any
function DartExtensions:emit(type, ...)
    for _, cb in ipairs(self.listeners) do
        if cb[type] then
            cb[type](...)
        end
    end
end

local extensions = DartExtensions:new()

return {
    --  builtins = Builtins,
    extensions = extensions,
    event_names = {
        REPLACE = "REPLACE",
        ADD = "ADD",
        SELECT = "SELECT",
        REMOVE = "REMOVE",
        POSITION_UPDATED = "POSITION_UPDATED",

        --- This exists because the ui can change the list in dramatic ways
        --- so instead of emitting a REMOVE, then an ADD, then a REORDER, we
        --- instead just emit LIST_CHANGE
        LIST_CHANGE = "LIST_CHANGE",

        REORDER = "REORDER",
        UI_CREATE = "UI_CREATE",
        SETUP_CALLED = "SETUP_CALLED",
        LIST_CREATED = "LIST_CREATED",
        NAVIGATE = "NAVIGATE",
        LIST_READ = "LIST_READ",
    },
}
