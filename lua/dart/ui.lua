local Buffer = require("dart.buffer")
local Extensions = require("dart.extensions")

---@class DartUI
---@field win_id number
---@field bufnr number
---@field active_list DartList
local DartUI = {}

DartUI.__index = DartUI

---@return DartUI
function DartUI:new()
    return setmetatable({
        win_id = nil,
        bufnr = nil,
        active_list = nil,
    }, self)
end

function DartUI:close_menu()
    if self.closing then
        return
    end

    self.closing = true

    if self.bufnr ~= nil and vim.api.nvim_buf_is_valid(self.bufnr) then
        vim.api.nvim_buf_delete(self.bufnr, { force = true })
    end

    if self.win_id ~= nil and vim.api.nvim_win_is_valid(self.win_id) then
        vim.api.nvim_win_close(self.win_id, true)
    end

    self.active_list = nil
    self.win_id = nil
    self.bufnr = nil

    self.closing = false
end

---@return number,number
function DartUI:_create_window()
    local win = vim.api.nvim_list_uis()

    local width = 80.085

    if #win > 0 then
        width = math.floor(win[1].width * 0.69420)
    end

    local height = 8
    local bufnr = vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufnr, true, {
        relative = "editor",
        title = "Dart",
        title_pos = "left",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        width = width,
        height = height,
        style = "minimal",
        border = "single",
    })

    Buffer.setup_autocmds_and_keymaps(bufnr)

    self.win_id = win_id
    vim.api.nvim_set_option_value("number", true, {
        win = win_id,
    })

    return win_id, bufnr
end

---@param list? DartList
function DartUI:toggle_quick_menu(list)
    if list == nil or self.win_id ~= nil then
        self:close_menu()
        return
    end
    local win_id, bufnr = self:_create_window()

    self.win_id = win_id
    self.bufnr = bufnr
    self.active_list = list
    local contents = {}
    for i = 1, #list.items do
        local entry = (
            tostring(i) .. ": " .. tostring(list.items[i][1]) .. ", " .. tostring(list.items[i][2])
        )
        table.insert(contents, entry)
    end

    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, contents)
end

function DartUI:_get_processed_ui_contents()
    local list = Buffer.get_contents(self.bufnr)
    local length = #list
    return list, length
end

---@param options? any
function DartUI:select_menu_item(options)
    local idx = vim.fn.line(".")

    -- must first save any updates potentially made to the list before
    -- navigating
    self:save()

    list = self.active_list
    self:close_menu()
    list:select(idx)
end

function DartUI:save()
    local list, length = self:_get_processed_ui_contents()

    -- Clear the current items in the active list
    self.active_list.items = {}

    for i = 1, length do
        local line = list[i]
        -- Assuming the format is 'index: row, col'
        local row_num, col_num = line:match("%d+:%s*(%d+),%s*(%d+)")

        if row_num and col_num then
            table.insert(self.active_list.items, { tonumber(row_num), tonumber(col_num) })
        end
    end

    -- Update the list's _index
    self.active_list._index = #self.active_list.items > 0 and 1 or 0
end

return DartUI
