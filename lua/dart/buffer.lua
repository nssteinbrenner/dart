local DartGroup = require("dart.augroup")

local M = {}

local DART_MENU = "__dart-menu__"

local dart_menu_id = math.random(9001)

---@return nil
local function get_dart_menu_name()
    dart_menu_id = dart_menu_id + 100
    return DART_MENU .. dart_menu_id
end

---@param dart_ui DartUI
---@return nil
function M.run_select_command(dart_ui)
    dart_ui:select_menu_item()
end

---@param dart_ui DartUI
---@return nil
function M.run_toggle_command(dart_ui)
    dart_ui:toggle_quick_menu()
end

---@param bufnr number
---@param dart_ui DartUI
---@return nil
function M.setup_autocmds_and_keymaps(bufnr, dart_ui)
    vim.print(dart_ui)
    if vim.api.nvim_buf_get_name(bufnr) == "" then
        vim.api.nvim_buf_set_name(bufnr, get_dart_menu_name())
    end

    vim.api.nvim_set_option_value("filetype", "dart", {
        buf = bufnr,
    })
    vim.api.nvim_set_option_value("buftype", "acwrite", { buf = bufnr })
    vim.keymap.set("n", "q", function()
        M.run_toggle_command(dart_ui)
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("n", "<Esc>", function()
        M.run_toggle_command(dart_ui)
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("n", "<CR>", function()
        M.run_select_command(dart_ui)
    end, { buffer = bufnr, silent = true })

    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
        group = DartGroup,
        buffer = bufnr,
        callback = function()
            dart_ui:save()
            vim.schedule(function()
                dart_ui:toggle_quick_menu()
            end)
        end,
    })

    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        group = DartGroup,
        buffer = bufnr,
        callback = function()
            dart_ui:toggle_quick_menu()
        end,
    })
end

---@param bufnr number
---@return string[]
function M.get_contents(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local indices = {}

    for _, line in pairs(lines) do
        table.insert(indices, line)
    end

    return indices
end

---@return nil
function M.set_contents(bufnr, contents)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
end

return M
