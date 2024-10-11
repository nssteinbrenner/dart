---@class DartConfig
---@field max_darts? number

local M = {}

function M.get_default_config()
    return {
        max_darts = 20
    }
end

---@return DartConfig
function M.set_config(config)
    return vim.tbl_extend("force", {}, M.get_default_config(), config or {})
end

return M
