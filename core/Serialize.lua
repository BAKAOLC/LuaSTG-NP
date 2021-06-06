local type = type
local tostring = tostring
local loadstring = loadstring
local error = error
local pairs = pairs
local insert = table.insert
local concat = table.concat

local i18n = require("util.Internationalization")

---@class lstg.Serialize 序列化库
local lib = {}
Serialize = lib
lstg.Serialize = lib

--region Json
do
    ---@class lstg.Serialize.Json
    local json = {}
    lib.Json = json

    local indent = "	"

    ---序列化table为json
    ---@param o table @待序列化为json的table
    ---@return string @json字符串
    local function encode(o)
        return cjson.encode(o)
    end
    json.Encode = encode

    ---反序列化json为table
    ---@param s string @待反序列化的json字符串
    ---@return table @反序列化得到的table
    local function decode(s)
        return cjson.decode(s)
    end
    json.Decode = decode

    ---格式化json字符串
    ---@param str string @待格式化的json字符串
    ---@return string @格式化后的json字符串
    local function format(str)
        local ret = {}
        local level = 0
        local inString = false
        local inEscape = false
        for i = 1, #str do
            local s = str:sub(i, i)
            if not (inEscape) then
                if s == "\"" then
                    inString = not (inString)
                    insert(ret, "\"")
                elseif not (inString) then
                    if s == "{" then
                        level = level + 1
                        insert(ret, "{\n" .. indent:rep(level))
                    elseif s == "}" then
                        level = level - 1
                        insert(ret, ("\n%s}"):format(indent:rep(level)))
                    elseif s == ":" then
                        insert(ret, ": ")
                    elseif s == "," then
                        insert(ret, ",\n" .. indent:rep(level))
                    elseif s == '[' and not (inString) then
                        level = level + 1
                        insert(ret, "[\n" .. indent:rep(level))
                    elseif s == ']' and not (inString) then
                        level = level - 1
                        insert(ret, ("\n%s]"):format(indent:rep(level)))
                    else
                        insert(ret, s)
                    end
                else
                    insert(ret, s)
                end
            else
                insert(ret, s)
            end
        end
        return concat(ret)
    end
    json.Format = format
end
--endregion

--region Lua
do
    ---@class lstg.Serialize.Lua
    local lua = {}
    lib.Lua = lua

    local indent = "	"

    ---序列化目标值为lua代码
    ---@param o number|boolean|string|table|nil @待序列化为lua代码的table
    ---@param format boolean @是否格式化lua代码
    ---@param level number @缩进等级
    ---@return string @序列化的lua字符串
    ---@overload fun(o:number|boolean|string|table|nil, format:boolean):string
    ---@overload fun(o:number|boolean|string|table|nil):string
    local function encode(o, format, level)
        level = format and level or 0
        local t = type(o)
        if t == "number" then
            return o
        elseif t == "boolean" then
            return tostring(o)
        elseif t == "string" then
            return ("%q"):format(o)
        elseif t == "table" then
            local ref = {}
            insert(ref, "{\n")
            level = level + 1
            for k, v in pairs(o) do
                insert(ref, ("%s[%s] = %s,\n"):format(indent:rep(level),
                        encode(k, format, level), encode(v, false, level)))
            end
            insert(ref, ("%s}"):format(indent:rep(level - 1)))
            return concat(ref)
        elseif t == "nil" then
            return "nil"
        else
            error(i18n:GetLanguageString("Core.Serialize.Error.UnableSerializeType"):format(t))
        end
    end
    lua.Encode = encode

    ---反序列化lua代码为对应值
    ---@param s number|boolean|string|nil @待反序列化的lua代码
    ---@return number|boolean|string|table|nil @反序列化得到的lua值
    local function decode(s)
        local t = type(s)
        if t == "nil" or not (s:match("%S")) then
            return nil
        elseif t == "number" or t == "string" or t == "boolean" then
            lua = tostring(lua)
        else
            error(i18n:GetLanguageString("Core.Serialize.Error.UnableSerializeType"):format(t))
        end
        lua = "return " .. lua
        local func = loadstring(lua)
        if func == nil then
            return nil
        end
        return func()
    end
    lua.Decode = decode
end
--endregion

return lib