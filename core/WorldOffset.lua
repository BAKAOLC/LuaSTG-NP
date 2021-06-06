local error = error
local type = type
local pairs = pairs

local i18n = require("util.Internationalization")

---@class lstg.WorldOffsetLibrary
local lib = {}
lstg.WorldOffset = lib

--region Default World Offset
---@class lstg.WorldOffset.Default.Raw
local rawDefaultWorldOffset = {
    ---中心X坐标
    x = 0,
    ---中心Y坐标
    y = 0,
    ---宽度比
    hscale = 1,
    ---高度比
    vscale = 1,
    ---X偏移值
    dx = 0,
    ---Y偏移值
    dy = 0
}

---获取最基础的默认world偏移设置
---@return lstg.WorldOffset.Default.Raw
local function getRawDefaultWorldOffset()
    local w = {}
    for k, v in pairs(rawDefaultWorldOffset) do
        w[k] = v
    end
    return w
end
lib.GetRawDefaultWorldOffset = getRawDefaultWorldOffset

---@class lstg.WorldOffset.Default : lstg.WorldOffset.Default.Raw
local defaultWorldOffset = {}
for k, v in pairs(rawDefaultWorldOffset) do
    defaultWorldOffset[k] = v
end

---设置默认world偏移
---@param x number @世界中心x
---@param y number @世界中心y
---@param hscale number @宽度比
---@param vscale number @高度比
---@param dx number @X偏移值
---@param dy number @Y偏移值
local function setDefaultWorldOffset(x, y, hscale, vscale, dx, dy)
    local w = {}
    w.x = x
    w.y = y
    w.hscale = hscale
    w.vscale = vscale
    w.dx = dx
    w.dy = dy
    defaultWorldOffset = w
end
lib.SetDefaultWorldOffset = setDefaultWorldOffset

---获取最基础的默认world偏移设置
---@return lstg.WorldOffset.Default
local function getDefaultWorldOffset()
    local w = {}
    for k, v in pairs(defaultWorldOffset) do
        w[k] = v
    end
    return w
end
lib.GetDefaultWorldOffset = getDefaultWorldOffset

---重置默认world至最初始的默认世界
local function resetRawWorldOffset()
    defaultWorldOffset = getRawDefaultWorldOffset()
end
lib.ResetRawWorldOffset = resetRawWorldOffset
--endregion

---@type lstg.WorldOffset
local currentWorldOffset

---获取当前世界偏移
---@return lstg.WorldOffset
local function getCurrentWorldOffset()
    return currentWorldOffset
end
lib.GetCurrentWorldOffset = getCurrentWorldOffset

---@class lstg.WorldOffset : lstg.WorldOffset.Default
---@return lstg.WorldOffset
local offset = plus.Class()

---重置世界偏移
local function resetWorldOffset()
    currentWorldOffset = offset()
end
lib.ResetWorldOffset = resetWorldOffset

function offset:init()
    self:Reset()
end

---重置世界偏移
function offset:Reset()
    self:Set(getDefaultWorldOffset())
end

---设置世界偏移中心
---@param x number @中心X坐标
---@param y number @中心Y坐标
function offset:SetOffsetCenter(x, y)
    self.x, self.y = x, y
end

---设置世界缩放
---@param hscale number @宽度比
---@param vscale number @高度比
function offset:SetWorldScale(hscale, vscale)
    self.hscale, self.vscale = hscale, vscale
end

---设置世界偏移
---@param dx number @X偏移值
---@param dy number @Y偏移值
function offset:SetOffset(dx, dy)
    self.dx, self.dy = dx, dy
end

---设置世界偏移
---@param x number @中心X坐标
---@param y number @中心Y坐标
---@param hscale number @宽度比
---@param vscale number @高度比
---@param dx number @X偏移值
---@param dy number @Y偏移值
---@overload fun(o:lstg.WorldOffset.Default)
function offset:Set(x, y, hscale, vscale, dx, dy)
    if (x and y and hscale and vscale and dx and dy) then
        self:SetOffsetCenter(x, y)
        self:SetWorldScale(hscale, vscale)
        self:SetOffset(dx, dy)
    elseif (x) then
        if (type(x)) then
            for k, v in pairs(x) do
                self[k] = v
            end
        else
            error(i18n:GetLanguageString("Core.World.Error.InvalidArgumentType"))
        end
    else
        error(i18n:GetLanguageString("Core.World.Error.MismatchParametersNumber"))
    end
end

resetWorldOffset()

return lib