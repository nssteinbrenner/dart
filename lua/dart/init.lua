local DartHandler = require("dart.handler")
local Config = require("dart.config")

local M = {}

---@param config? DartConfig
---@return DartHandler
function M.setup(config)
    local merged_config = Config.merge_config(config)

    return DartHandler:new(merged_config)
end

return M
