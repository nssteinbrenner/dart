---@class DartEvents
---@field listeners DartEvent[]
local DartEvents = {}

---@class DartEvent
---@field ADD? (fun(...): nil)
---@field REMOVE? (fun(...): nil)
---@field SELECT? (fun(...): nil)
---@field UI_SAVE? (fun(...): nil)

DartEvents.__index = DartEvents

---@return DartEvents
function DartEvents:new()
    return setmetatable({
        listeners = {}
    }, self)
end

---@param event DartEvent
---@return nil
function DartEvents:add_listener(event)
    table.insert(self.listeners, event)
end

---@return nil
function DartEvents:clear_listeners()
    self.listeners = {}
end

---@param type string
---@param ... any
---@return nil
function DartEvents:emit(type, ...)
    for _, callback in ipairs(self.listeners) do
        if callback[type] then
            callback[type](...)
        end
    end
end

local events = DartEvents:new()

return {
    events = events,
    event_names = {
        ADD = "ADD",
        REMOVE = "REMOVE",
        SELECT = "SELECT",
        UI_SAVE = "UI_SAVE",
    },
}
