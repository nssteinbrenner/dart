local Extensions = require("dart.extensions")

---@return boolean
local function is_valid_location(location)
    -- vim.print(location)
    return location[1] ~= nil and location[1] ~= 0
end


---@class DartLocation
---@field [1] number row
---@field [2] number col

---@class DartList
---@field config DartConfig
---@field items DartLocation[]
---@field _index number
local DartList = {}

DartList.__index = DartList

---@return DartList
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

function DartList:add()
    local location = vim.api.nvim_win_get_cursor(0)
    if #self.items > self.config.list.max_darts then
        for i = self.config.list.max_darts, #self.items do
            table.remove(self.items, i)
        end
        self._index = #self.items
    end

    if #self.items < self.config.list.max_darts then
        table.insert(self.items, location)
        self._index = #self.items
    else
        self._index = (self._index % self.config.list.max_darts) + 1
        self.items[self._index] = location
        table.insert(self.items, self._index, location)
    end

    Extensions.extensions:emit(
        Extensions.event_names.ADD,
        { list = self, item = location, idx = self._index }
    )
end

---@return boolean
function DartList:insert(index)
    local location = vim.api.nvim_win_get_cursor(0)
    if index < self.config.list.max_darts then
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
        -- vim.print("4")
        dest_dart[1] = end_of_file
        self.items[self._index] = dest_dart
    end

    if is_valid_location(dest_dart) then
        -- vim.print("5")
        vim.api.nvim_win_set_cursor(0, dest_dart)
        vim.cmd.normal("zz")
        return true
    end
    return false
end

---@return boolean
function DartList:select(index)
    if self:length() == 0 then
        -- vim.print("1")
        return false
    end

    -- vim.print("2")
    if index < 1 or index > self:length() then
        -- vim.print("3")
        return false
    end

    self._index = index
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

function DartList:clear()
    self.items = {}
end

---@return DartList
---@param config DartConfig
---@param items DartLocation[]
function DartList.Decode(config, items)
    local list_items

    for _, item in ipairs(items) do
        table.insert(list_items, vim.json.decode(item))
    end

    return DartList:new(config, list_items)
end

return DartList
