---@class DartDataConfig
---@field key (fun(): string)
---@field base_path string
---@field filename string

---@class DartListConfig
---@field max_darts number

---@class DartConfig
---@field data DartDataConfig
---@field list DartListConfig

local M = {}

---@return DartConfig
function M.get_default_config()
    return {
        data = {
            key = function()
                return vim.loop.cwd()
            end,
            base_path = nil,
            filename = "data.json",
        },
        list = {
            max_darts = 20
        },
    }
end

---@return DartConfig
function M.set_config(config)
    return vim.tbl_extend("force", {}, M.get_default_config(), config or {})
end

return M
