---@class DartDataConfig
---@field dir (fun(): string)
---@field base_path string

---@class DartListConfig
---@field max_darts number
---@field center_cursor_on_jump boolean

---@class DartUiConfig
---@field regex_format string
---@field format_darts (fun(list: DartList): string[])

---@class DartConfig
---@field data DartDataConfig
---@field list DartListConfig
---@field ui DartUiConfig

local M = {}

---@return DartConfig
function M.get_default_config()
    return {
        data = {
            -- Current directory name by default.
            -- Hashed to create config filename corresponding to this directory in data dir.
            dir = function()
                return vim.loop.cwd()
            end,

            -- Alternative to use instead of Neovim's data dir.
            base_path = nil,
        },
        list = {
            -- Maximum number of elements in list.
            -- At max_darts num of elements, index will loop to 1 and overwrite from the start.
            max_darts = 20,

            -- Execute zz on jump to center cursor
            center_cursor_on_jump = true,
        },
        ui = {
            -- Needs to match the format of the darts in the quick menu
            regex_format = "%d+:%s*(%d+),%s*(%d+)",

            -- Used to determine the format of the darts in the quick menu
            -- Default is: <Index>: <Line>, <Col>
            ---@return string[]
            ---@param list DartList
            format_darts = function(list)
                local contents = {}
                for i = 1, #list.items do
                    local entry = (
                        tostring(i) .. ": " .. tostring(list.items[i][1]) .. ", " .. tostring(list.items[i][2])
                    )
                    table.insert(contents, entry)
                end
                return contents
            end,
        }
    }
end

---@param config? DartConfig
---@return DartConfig
function M.merge_config(config)
    local default_config = M.get_default_config()
    if config == nil then
        return default_config
    end
    local merged_config = {}

    for section_name, section_value in pairs(default_config) do
        merged_config[section_name] = vim.tbl_extend(
            "force", {}, section_value, config[section_name] or {}
        )
    end

    return merged_config
end

return M
