local Events = require("dart.events")

---@return boolean
local function is_valid_location(location)
    return location[1] ~= nil and location[1] ~= 0
end


---@class DartLocation
---@field [1] number row
---@field [2] number col

---@class DartList
---@field config DartListConfig
---@field items DartLocation[]
---@field _index number
local DartList = {}

DartList.__index = DartList

---@return DartList
---@param config DartListConfig
---@param items? DartLocation[]
function DartList:new(config, items)
    items = items or {}
    return setmetatable({
        config = config,
        items = items,
        _index = #items > 0 and 1 or 0,
    }, self)
end

---@return number
function DartList:length()
    return #self.items
end

---@return nil
function DartList:add()
    local location = vim.api.nvim_win_get_cursor(0)
    if #self.items > self.config.max_darts then
        for i = self.config.max_darts, #self.items do
            table.remove(self.items, i)
        end
        self._index = #self.items
    end

    if #self.items < self.config.max_darts then
        table.insert(self.items, location)
        self._index = #self.items
    else
        self._index = (self._index % self.config.max_darts) + 1
        self.items[self._index] = location
        table.insert(self.items, self._index, location)
    end

    Events.events:emit(
        Events.event_names.ADD,
        { list = self, item = location, idx = self._index }
    )
end

---@return boolean
function DartList:insert(index)
    local location = vim.api.nvim_win_get_cursor(0)
    if index < self.config.max_darts then
        table.insert(self.items, index, location)
        return true
    end
    return false
end

---@return boolean
function DartList:delete(index)
    if index <= self:length() then
        table.remove(self.items, index)
        return true
    end
    return false
end

---@return boolean
function DartList:jump()
    local end_of_file = vim.api.nvim_buf_line_count(0)
    local dest_dart = self.items[self._index]
    if dest_dart[1] > end_of_file then
        dest_dart[1] = end_of_file
        self.items[self._index] = dest_dart
    end

    if is_valid_location(dest_dart) then
        vim.api.nvim_win_set_cursor(0, dest_dart)
        if self.config.center_cursor_on_jump then
            vim.cmd.normal("zz")
        end
        return true
    end
    return false
end

---@return boolean
function DartList:select(index)
    if self:length() == 0 then
        return false
    end

    if index < 1 or index > self:length() then
        return false
    end

    self._index = index

    Events.events:emit(
        Events.event_names.SELECT,
        { list = self, item = self.items[self._index], idx = self._index }
    )

    return self:jump()
end

---@return boolean
function DartList:next()
    if self:length() == 0 then
        return false
    end

    if self._index >= self:length() then
        self._index = 1
    else
        self._index = self._index + 1
    end
    return self:jump()
end

---@return boolean
function DartList:prev()
    if self:length() == 0 then
        return false
    end

    if self._index <= 1 then
        self._index = self:length()
    else
        self._index = self._index - 1
    end
    return self:jump()
end

---@return nil
function DartList:clear()
    self.items = {}
end

return DartList
