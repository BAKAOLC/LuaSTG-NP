string = string or {}

local tonumber = tonumber
local tostring = tostring
local insert = table.insert
local concat = table.concat
local byte = string.byte
local char = string.char
local format = string.format
local gsub = string.gsub
local gmatch = string.gmatch
local upper = string.upper
local sub = string.sub

---将Lua字符串转成HEX字符串
---@param separator string|nil @分隔符
---@return string, number
function string:ToHex(separator)
    local hex = {}
    ---@param c string
    gsub(self, ".", function(c)
        insert(hex, format("%02X", byte(c)))
    end)
    return concat(hex, separator or ""), #hex
end

---将HEX字符串转成Lua字符串
---@return string, number
function string:FromHex()
    --滤掉分隔符
    self = upper(gsub(self, "[^%x]", ""))
    ---@param c string
    return gsub(self, "%x%x", function(c)
        return char(tonumber(c, 16))
    end)
end

---返回utf8编码字符串的长度
---@return number
function string:UTF8Len()
    local n = 0
    for _ in gmatch(self) do
        n = n + 1
    end
    return n
end

---将数字转为千位符号分割格式
---@return string, number
function string:FormatNumberThousands()
    self = tostring(tonumber(self))
    local total = 0
    local n = 0
    while true do
        self, n = gsub(self, "^(-?%d+)(%d%d%d)", "%1,%2")
        total = total + n
        if n == 0 then
            break
        end
    end
    return self, total
end

---按照指定分隔符分割字符串
---@param delimiter string @分隔符
---@return table<number, string>
function string:Split(delimiter)
    local list, tmp = {}, byte(delimiter)
    if delimiter == "" then
        for i = 1, #self do
            list[i] = sub(self, i, i)
        end
    else
        for substr in gmatch(self .. delimiter, "(.-)" .. (((tmp > 96 and tmp < 123) or (tmp > 64 and tmp < 91) or (tmp > 47 and tmp < 58)) and delimiter or "%" .. delimiter)) do
            insert(list, substr)
        end
    end
    return list
end

---检查字符串是否以指定字串开头
---@param str string
---@return boolean
function string:StartWith(str)
    return self:sub(1, #str) == str
end

---检查字符串是否以指定字串结尾
---@param str string
---@return boolean
function string:EndWith(str)
    return self:sub(-#str) == str
end