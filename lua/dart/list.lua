---@return boolean
local function set_mark(name, location)
    return vim.api.nvim_buf_set_mark(0, name, location[1], location[2], {})
end

---@return boolean
local function del_mark(name)
    return vim.api.nvim_buf_del_mark(0, name)
end

---@return boolean
local function is_valid_location(location)
    return location[1] ~= nil and location[1] ~= 0
end

---@return DartLocation
local function get_mark(name)
    return vim.api.nvim_buf_get_mark(0, name)
end

---@return string
local function get_name(index)
    return "dart" .. index
end

---@return DartLocation[]
local function get_darts(max_darts)
    local darts = {}
    for i = 1, max_darts do
        local dart_location = get_mark(get_name(i))
        if is_valid_location(dart_location) then
            table.insert(darts, dart_location)
        end
    end

    return darts
end

local end_of_file = vim.api.nvim_buf_line_count(0)

---@class DartLocation
---@field [1] number line
---@field [2] number col

---@class DartList
---@field config DartConfig
---@field _length number
---@field _index number
---@field items DartLocation[]

local DartList = {}
DartList.__index = DartList

---@return DartList
function DartList:new(config, items)
    items = items or get_darts(config.max_darts)
    return setmetatable({
        items = items,
        config = config,
        _index = #items > 0 and 1 or 0,
    }, self)
end

---@return number
function DartList:length()
    return self._length
end

---@return boolean
function DartList:append_dart()
    local location = vim.api.nvim_win_get_cursor(0)
    local mark_set = set_mark(get_name(self._index), location)
    if mark_set then
        if self._index < self.config.max_darts then
            self._index = self._index + 1
        else
            self._index = 1
        end
        table.insert(self.items, self._index, location)
        return true
    end
    return false
end

---@return boolean
function DartList:insert_dart(index)
    local location = vim.api.nvim_win_get_cursor(0)
    local mark_set = set_mark(get_name(index), location)
    if mark_set then
        if index < self.config.max_darts then
            table.insert(self.items, index, location)
            return true
        end
    end
    return false
end

---@return boolean
function DartList:delete_dart(index)
    if index <= self:length() then
        local mark_deleted = del_mark(get_name(index))
        if mark_deleted then
            table.remove(self.items, index)
            return true
        end
    end
    return false
end

---@return boolean
function DartList:jump_to()
    local dest_mark = self.items[self._index]
    if dest_mark[1] > end_of_file then
        dest_mark[1] = end_of_file
        local mark_set = set_mark(get_name(self._index), dest_mark)
        if not mark_set then
            return false
        end
    end

    if is_valid_location(dest_mark) then
        vim.api.nvim_win_set_cursor(0, dest_mark)
        vim.cmd.normal("normal! zz")
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
    return self:jump_to()
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
    return self:jump_to()
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
    return self:jump_to()
end

return DartList
