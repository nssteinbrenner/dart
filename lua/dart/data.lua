local Path = require("plenary.path")

-- Format { index: [row, col] }
---@alias DartRawData {[string]: DartLocation[]}

---@class DartData
---@field _data DartRawData
---@field config DartDataConfig
---@field path Path
local DartData = {}

DartData.__index = DartData

---@param config DartDataConfig
---@return DartData
function DartData:new(config)
    local base_path = config.base_path or vim.fn.stdpath("data")
    local dart_basedir = Path:new(string.format("%s/dart", base_path))

    if not dart_basedir:exists() then
        dart_basedir:mkdir()
    end

    local dir_hash = vim.fn.sha256(config.dir())
    local file = Path:new(string.format("%s/%s", dart_basedir, (dir_hash .. ".json")))
    if not file:exists() then
        file:write(vim.json.encode({}), "w")
    end

    return setmetatable({
        config = config,
        path = file,
    }, self)
end

---@return DartRawData
function DartData:read_data()
    return vim.json.decode(self.path:read())
end

---@return nil
function DartData:write_data()
    self.path:write(vim.json.encode(self._data), "w")
end

---@param data DartRawData
---@return nil
function DartData:update_data(data)
    self._data = data
end

---@return nil
function DartData:_set_initial_data()
    self._data = self:read_data()
end

return DartData
