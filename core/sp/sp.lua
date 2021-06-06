sp = sp or {}

--SP+系 math 函数库
lstg.DoFile "core/sp/spmath.lua"
--SP+系 misc 函数库
lstg.DoFile "core/sp/spmisc.lua"
--SP+系 string 函数库
lstg.DoFile "core/sp/spstring.lua"

local type = type
local pairs = pairs
local setmetatable = setmetatable
local getmetatable = getmetatable
local insert = table.insert
local unpack = table.unpack or unpack
local int = math.floor
local max = math.max
local min = math.min

--SP+系函数
---拆解表至同一层级
function sp.GetUnpackList(...)
    local ref, p = {}, { ... }
    for _, v in pairs(p) do
        if type(v) ~= "table" then
            insert(ref, v)
        else
            local tmp = sp.GetUnpackList(unpack(v))
            for _, t in pairs(tmp) do
                insert(ref, t)
            end
        end
    end
    return ref
end

---拆解表至同一层级并解包成参数列
function sp.GetUnpack(...)
    return unpack(sp.GetUnpackList(...))
end

---复制表
---@param t table @要复制的表
---@param all boolean @是否深度复制
---@return table
function sp.copy(t, all)
    if all then
        local lookup = {}
        local function _copy(o)
            if type(o) ~= "table" then
                return o
            elseif lookup[o] then
                return lookup[o]
            end
            local ref = {}
            lookup[o] = ref
            for k, v in pairs(o) do
                ref[_copy(k)] = _copy(v)
            end
            return setmetatable(ref, getmetatable(o))
        end
        return _copy(t)
    else
        local ref = {}
        for k, v in pairs(t) do
            ref[k] = v
        end
        return setmetatable(ref, getmetatable(t))
    end
end

---整理字符串
---@param str string @要处理的字符串
---@param length number @单字符宽度
---@return number, table
function sp.SplitText(str, length)
    local s = 0
    local list = {}
    local len = str:len()
    local i = 1
    while i <= len do
        local c = str:byte(i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
            s = s + 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
            s = s + 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
            s = s + 2
        elseif (c >= 240 and c <= 247) then
            shift = 4
            s = s + 2
        end
        local char = str:sub(i, i + shift - 1)
        i = i + shift
        insert(list, char)
    end
    if length then
        s = s * length
    end
    return s, list
end

---按位置截取信息表
---@param list table @目标表
---@param n number @截取最大长度
---@param pos number @选择位标
---@param s number @锁定位标
---@return table, number
function sp.GetListSection(list, n, pos, s)
    n = int(n or #list)
    s = min(max(int(s or n), 1), n)
    local cut, c, m = {}, #list, pos
    if c <= n then
        cut = list
    elseif pos < s then
        for i = 1, n do
            insert(cut, list[i])
        end
    else
        local t = max(min(pos + (n - s), c), pos)
        for i = t - n + 1, t do
            insert(cut, list[i])
        end
        m = min(max(n - (t - pos), s), n)
    end
    return cut, m
end

---分割字符串迭代器
---@param input string @要分割的字符串
---@param delimiter string @分割符
---@return fun():(string, number)
function sp.Split(input, delimiter)
    local len = #input
    local pos = 0
    local i = 0
    return function()
        local p1, p2 = input:find(delimiter, pos + 1)
        if p1 then
            i = i + 1
            local cut = input:sub(pos + 1, p1 - 1)
            pos = p2
            return cut, i
        elseif pos < len then
            i = i + 1
            local cut = input:sub(pos + 1, len)
            pos = len
            return cut, i
        end
    end
end

---分割字符串
---@param input string @要分割的字符串
---@param delimiter string @分割符
---@return table @分割好的字符串表
function sp.SplitText(input, delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    for st, sp in function()
        return input:find(delimiter, pos, true)
    end do
        insert(arr, input:sub(pos, st - 1))
        pos = sp + 1
    end
    insert(arr, input:sub(pos))
    return arr
end