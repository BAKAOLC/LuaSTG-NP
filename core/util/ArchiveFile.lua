local open = io.open
local assert = assert
local error = error
local type = type
local pairs = pairs
local setmetatable = setmetatable
local getmetatable = getmetatable

local Encode = cjson.encode
local Decode = cjson.dncode
local mkdir = lfs.mkdir
local attributes = lfs.attributes
local UTF8ToANSI = plus.UTF8ToANSI

---检查文件是否存在
---@param filename string
---@return boolean
local function FileExist(filename)
    return not (attributes(filename) == nil)
end

local makeSaveTable, newIndex, spairs, buildDataTable

---转化table为储存表
---@param t table
---@return table
function makeSaveTable(t)
    assert(type(t) == "table")
    local save = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            makeSaveTable(v)
        end
        save[k], t[k] = v, nil
    end
    local meta = getmetatable(t) or {}
    meta.__newindex = newIndex
    meta.__index = save
    setmetatable(t, meta)
    return t
end

---设置值时的检查
---@param t table
---@param k string|number
---@param v string|number|boolean|table|nil
function newIndex(t, k, v)
    local tk = type(k)
    if tk ~= "string" and tk ~= "number" then
        error(("Invalid key type %q"):format(tk))
    else
        local tv = type(v)
        if tv == "function" or tv == "userdata" or tv == "thread" then
            error(("Invalid value type %q"):format(tv))
        else
            if tv == "table" then
                makeSaveTable(v)
            end
            getmetatable(t).__index[k] = v
        end
    end
end

---枚举元表目标值
function spairs(t)
    return pairs(getmetatable(t).__index)
end

---构建数据表
---@param t table
---@return table
function buildDataTable(t)
    local result = {}
    for k, v in spairs(t) do
        if type(v) == "table" then
            v = buildDataTable(v)
        end
        result[k] = v
    end
    return result
end

---@class lstg.ArchiveFile : plus.Class @存档文件库
---@overload fun(file:string):lstg.ArchiveFile
---@return lstg.ArchiveFile
local lib = plus.Class()
lstg.ArchiveFile = lib

---@param file string @目标文件路径
function lib:init(file)
    local a, b = file:match("^(.-/?)([^/]+)$")
    ---文件路径
    self.path = a
    ---文件
    self.file = b
    self:Load()
end

---获取路径
---@return string
function lib:GetPath()
    return self.path
end

---获取文件名(带后缀名)
---@return string
function lib:GetName()
    return self.file
end

---获取文件路径
---@return string
function lib:GetFilePath()
    return self.path .. self.name
end

---获取当前数据表
---@return table
function lib:GetDataTable()
    return buildDataTable(self.data)
end

---清空数据表
function lib:ClearDataTable()
    self.data = makeSaveTable({})
end

---设置数据表值
---@param key string|number
---@param value string|number|boolean|table|nil
function lib:SetDataValue(key, value)
    self.data[key] = value
end

---设置数据表值
---@param key string
---@param value string|number|boolean|table|nil
function lib:SetDataTreeValue(key, value)
    self.data[key] = value
end

---获取数据表值
---@param key string|number
---@param default string|number|boolean|table
---@return string|number|boolean|table|nil
---@overload fun(key:string|number):string|number|boolean|table|nil
function lib:GetDataValue(key, default)
    if default ~= nil and self.data[key] == nil then
        return type(default) == "table" and makeSaveTable(default) or default
    end
    return self.data[key]
end

---读取文件数据
---@return table
function lib:Load()
    local file = UTF8ToANSI(self:GetFilePath())
    if FileExist(file) then
        local f = assert(open(file, "r"))
        self.data = makeSaveTable(Decode(f:read("*a")))
        f:close()
    else
        self.data = makeSaveTable({})
    end
end

function lib:Save()
    mkdir(UTF8ToANSI(self:GetPath()))
    local file = UTF8ToANSI(self:GetFilePath())
    local f = assert(open(file, "w"))
    f:write(Encode(self:GetDataTable()))
    f:close()
end

return lib