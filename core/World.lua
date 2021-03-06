local error = error
local type = type
local pairs = pairs
local select = select
local SetBound = SetBound

local i18n = require("util.Internationalization")

---@class lstg.WorldLibrary
local lib = {}
lstg.World = lib

--region Default World
---基础默认的world参数，只读
---@class lstg.World.Default.Raw
local rawDefaultWorld = {
    ---坐标系左边界
    l = -192,
    ---坐标系右边界
    r = 192,
    ---坐标系底边界
    b = -224,
    ---坐标系顶边界
    t = 224,
    ---消弹范围左边界
    boundl = -224,
    ---消弹范围右边界
    boundr = 224,
    ---消弹范围底边界
    boundb = -256,
    ---消弹范围顶边界
    boundt = 256,
    ---渲染左边界位置
    scrl = 32,
    ---渲染右边界位置
    scrr = 416,
    ---渲染底边界位置
    scrb = 16,
    ---渲染顶边界位置
    scrt = 464,
    ---自机移动范围左边界
    pl = -192,
    ---自机移动范围右边界
    pr = 192,
    ---自机移动范围底边界
    pb = -224,
    ---自机移动范围顶边界
    pt = 224,
    ---世界编号(请勿修改)
    world = 15
}

---获取最基础的默认world
---@return lstg.World.Default.Raw
local function getRawDefaultWorld()
    local w = {}
    for k, v in pairs(rawDefaultWorld) do
        w[k] = v
    end
    return w
end
lib.GetRawDefaultWorld = getRawDefaultWorld

---默认world参数，可修改
---@class lstg.World.Default : lstg.World.Default.Raw
local defaultWorld = {}
for k, v in pairs(rawDefaultWorld) do
    defaultWorld[k] = v
end

---设置默认世界
local function setDefaultWorld(l, r, b, t, bl, br, bb, bt, sl, sr, sb, st, pl, pr, pb, pt, m)
    local w = {}
    w.l = l
    w.r = r
    w.b = b
    w.t = t
    w.boundl = bl
    w.boundr = br
    w.boundb = bb
    w.boundt = bt
    w.scrl = sl
    w.scrr = sr
    w.scrb = sb
    w.scrt = st
    w.pl = pl
    w.pr = pr
    w.pb = pb
    w.pt = pt
    w.world = m
    defaultWorld = w
end
lib.SetDefaultWorld = setDefaultWorld

---自动计算设置默认世界
local function autoSetDefaultWorld(l, b, w, h, bound, m)
    setDefaultWorld(
    --l,r,b,t,
            (-w / 2), (w / 2), (-h / 2), (h / 2),
    --bl,br,bb,bt,
            (-w / 2) - bound, (w / 2) + bound, (-h / 2) - bound, (h / 2) + bound,
    --sl,sr,sb,st,
            (l), (l + w), (b), (b + h),
    --pl,pr,pb,pt
            (-w / 2), (w / 2), (-h / 2), (h / 2),
    --world mask
            m
    )
end
lib.AutoSetDefaultWorld = autoSetDefaultWorld

---获取默认world
---@return lstg.World.Default
local function getDefaultWorld()
    local w = {}
    for k, v in pairs(defaultWorld) do
        w[k] = v
    end
    return w
end
lib.GetDefaultWorld = getDefaultWorld

---重置默认world至最初始的默认世界
local function resetRawWorld()
    defaultWorld = getRawDefaultWorld()
end
lib.ResetRawWorld = resetRawWorld
--endregion

---@type lstg.World
local currentWorld

local function getCurrentWorld()
    return currentWorld
end
lib.GetCurrentWorld = getCurrentWorld

---@class lstg.World : lstg.World.Default
---@return lstg.World
local world = plus.Class()

local function resetWorld()
    currentWorld = world()
end
lib.ResetWorld = resetWorld

function world:init()
    self:Reset()
end

---重置世界
function world:Reset()
    self:Set(getDefaultWorld())
end

---获取世界宽度
---@return number
function world:GetWidth()
    return self.r - self.l
end

---获取世界高度
---@return number
function world:GetHeight()
    return self.t - self.b
end

---获取世界渲染宽度
---@return number
function world:GetScreenWidth()
    return self.scrr - self.scrl
end

---获取世界渲染高度
---@return number
function world:GetScreenHeight()
    return self.scrt - self.scrb
end

---获取世界出版边界宽度
---@return number
function world:GetBoundWidth()
    return self.boundr - self.boundl
end

---获取世界出版边界高度
---@return number
function world:GetBoundHeight()
    return self.boundt - self.boundb
end

---获取世界自机活动区域宽度
---@return number
function world:GetPlayerAreaWidth()
    return self.pr - self.pl
end

---获取世界自机活动区域高度
---@return number
function world:GetPlayerAreaHeight()
    return self.pt - self.pb
end

---设置世界边界
---@param l number @左边界
---@param r number @右边界
---@param b number @底边界
---@param t number @顶边界
function world:SetWorld(l, r, b, t)
    self.l = l
    self.r = r
    self.b = b
    self.r = t
end

---设置渲染位置
---@param l number @左边界位置
---@param r number @右边界位置
---@param b number @底边界位置
---@param t number @顶边界位置
function world:SetScreenWorld(l, r, b, t)
    self.scrl = l
    self.scrr = r
    self.scrb = b
    self.scrr = t
end

---设置自机边界
---@param l number @左边界
---@param r number @右边界
---@param b number @底边界
---@param t number @顶边界
function world:SetPlayerWorld(l, r, b, t)
    self.pl = l
    self.pr = r
    self.pb = b
    self.pr = t
end

---设置渲染位置
---@param l number @左边界
---@param r number @右边界
---@param b number @底边界
---@param t number @顶边界
function world:SetBound(l, r, b, t)
    self.boundl = l
    self.boundr = r
    self.boundb = b
    self.boundt = t
    self:ApplyBound()
end

---设置出屏边界范围
---@param bound number @范围
function world:SetBoundExpandByWorld(bound)
    self:SetBound(self.l - bound, self.r + bound, self.b - bound, self.t + bound)
end

---设置世界编号
---@param w number @世界编号（不建议操作）
function world:SetWorldID(w)
    self.world = w or 15
end

---设置世界
---@overload fun(world:lstg.World.Default)
---@overload fun(l:number, b:number, w:number, h:number, bound:number, m:number)
---@overload fun(l:number, r:number, b:number, t:number, boundl:number, boundr:number, boundb:number, boundt:number, scrl:number, scrr:number, scrb:number, scrt:number, pl:number, pr:number, pb:number, pt:number, m:number)
function world:Set(...)
    local n = select("#", ...)
    if n == 17 then
        local l, r, b, t, bl, br, bb, bt, sl, sr, sb, st, pl, pr, pb, pt, m = ...
        self:SetWorld(l, r, b, t)
        self:SetBound(bl, br, bb, bt)
        self:SetScreenWorld(sl, sr, sb, st)
        self:SetPlayerWorld(pl, pr, pb, pt)
        self:SetWorld(m)
    elseif n == 6 then
        local l, b, w, h, bound, m = ...
        self:SetWorld((-w / 2), (w / 2), (-h / 2), (h / 2))
        self:SetBound((-w / 2) - bound, (w / 2) + bound, (-h / 2) - bound, (h / 2) + bound)
        self:SetScreenWorld((l), (l + w), (b), (b + h))
        self:SetPlayerWorld((-w / 2), (w / 2), (-h / 2), (h / 2))
        self:SetWorld(m)
    elseif n == 1 then
        ---@type lstg.World.Default
        local w = ...
        if type(w) == "table" then
            for k, v in pairs(w) do
                self[k] = v
            end
            self:ApplyBound()
        else
            error(i18n:GetLanguageString("Core.World.Error.InvalidArgumentType"))
        end
    else
        error(i18n:GetLanguageString("Core.World.Error.MismatchParametersNumber"))
    end
end

---应用出屏边界设置
function world:ApplyBound()
    SetBound(self.boundl, self.boundr, self.boundb, self.boundt)
end

lib.ResetWorld()

return lib