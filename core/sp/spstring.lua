--[[
LuaSTG Special Plus 系 rep函数库
data by OLC
]]

--[[
本系统使用UTF8编码进行字符串处理
UTF8的编码规则：
    1. 字符的第一个字节范围： 0x00—0x7F(0-127),或者 0xC2—0xF4(194-244); UTF8 是兼容 ascii 的，所以 0~127 就和 ascii 完全一致
    2. 0xC0, 0xC1,0xF5—0xFF(192, 193 和 245-255)不会出现在UTF8编码中 
    3. 0x80—0xBF(128-191)只会出现在第二个及随后的编码中(针对多字节编码，如汉字) 
]]

local insert = table.insert
local concat = table.concat

---@class sp.String : plus.Class
---@return sp.String
local lib = plus.Class()
sp.string = lib

---@param str string @要处理的字符串
function lib:init(str)
    self:Set(str)
end

---获取设置的字符串
---@return string
function lib:Get()
    return self._string
end

---设置新字符串
---@param str string @要处理的字符串
function lib:Set(str)
    self._string = str
    self.string = self:HandleString(str)
end

---将字符串按字符整理成表
---@param str string @要处理的字符串
---@return table<number, string>
function lib:HandleString(str)
    local st = {}
    for utfChar in str:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        insert(st, utfChar)
    end
    return st
end

---获取字符数
---@return number
function lib:GetCharCount()
    return #self.string
end

---获取占位长度
---@return number
function lib:GetLength()
    local sTable = self.string
    local len = 0
    local charLen = 0
    for i = 1, #sTable do
        local utfCharLen = sTable[i]:len()
        if utfCharLen > 1 then
            charLen = 2
        else
            charLen = 1
        end
        len = len + charLen
    end
    return len
end

---获取真实长度
---@return number
function lib:GetCurrentLength()
    return self._string:len()
end

---截取字符串
---@param index number @始位标
---@param toindex number @末位标
---@return string
function lib:Sub(index, toindex)
    index = index or 1
    if index < 0 then
        index = self:GetLength() + index + 1
    end
    toindex = toindex or index
    if toindex < 0 then
        toindex = self:GetLength() + toindex + 1
    end
    local length = (toindex - index) + 1
    local sTable = self.string
    local s = {}
    for n = index, index + (length - 1) do
        if sTable[n] then
            insert(s, sTable[n])
        else
            insert(s, " ")
        end
    end
    return concat(s, "")
end

---获取反转字符串
---@return string
function lib:GetReverse()
    local sTable = self.string
    local s = {}
    for i = #sTable, 1, -1 do
        insert(s, sTable[i])
    end
    return concat(s, "")
end