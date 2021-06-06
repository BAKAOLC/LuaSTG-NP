local error = error
local type = type

local SetOrtho = SetOrtho
local SetViewport = SetViewport
local SetFog = SetFog
local SetImageScale = SetImageScale

local World = require("World")
local WorldOffset = require("WorldOffset")
local Screen = require("Screen")
local Setting = require("Setting")

local getCurrentWorld = World.GetCurrentWorld
local getCurrentWorldOffset = WorldOffset.GetCurrentWorldOffset
local CurrentGraphicsSetting = Setting.Graphics

---@class lstg.View
local lib = {}
lstg.View = View

---@type table<string, lstg.View.Type>
local viewType = {}

---@type string
local currentViewTypeName

---获取当前视口类型
---@return string
local function getCurrentViewTypeName()
    return currentViewTypeName
end
lib.GetCurrentViewTypeName = getCurrentViewTypeName

---获取当前视口定义
---@return fun(screen:lstg.Screen, world:lstg.World, offset:lstg.WorldOffset, view3d:lstg.View3d.View)
local function getCurrentViewType()
    if viewType[currentViewTypeName] then
        return viewType[currentViewTypeName]
    else
        error("Invalid arguement.")
    end
end
lib.GetCurrentViewType = getCurrentViewType

---设置当前视口
---@param name string @视口名称
---@param force boolean @是否强制刷新视口
---@overload fun(name:string)
local function setCurrentViewType(name, force)
    if force or currentViewTypeName ~= name then
        currentViewTypeName = name
        getCurrentViewType()(Screen, getCurrentWorld(), getCurrentWorldOffset(), require("View3d").GetCurrentView3d())
    end
end
lib.SetCurrentViewType = setCurrentViewType

---添加一个视口定义
---@param name string @视口名称
---@param view fun(screen:lstg.Screen, world:lstg.World, offset:lstg.WorldOffset, view3d:lstg.View3d.View) @视口定义
local function addViewType(name, view)
    viewType[name] = view
end
lib.AddViewType = addViewType

---设置渲染矩形（会被setCurrentViewType覆盖）
---@param l number @坐标系左边界
---@param r number @坐标系右边界
---@param b number @坐标系下边界
---@param t number @坐标系上边界
---@param scrl number @渲染系左边界
---@param scrr number @渲染系右边界
---@param scrb number @渲染系下边界
---@param scrt number @渲染系上边界
---@overload fun(info:table):nil @坐标系信息
local function setRenderRect(l, r, b, t, scrl, scrr, scrb, scrt)
    local scale = Screen.GetScale()
    local dx = Screen.GetDx()
    local dy = Screen.GetDy()
    if l and r and b and t and scrl and scrr and scrb and scrt then
        --设置坐标系
        SetOrtho(l, r, b, t)
        --设置视口
        SetViewport(
                scrl * scale + dx,
                scrr * scale + dx,
                scrb * scale + dy,
                scrt * scale + dy
        )
        --清空fog
        SetFog()
        --设置图像缩放比
        SetImageScale(1)
    elseif type(l) == "table" then
        --设置坐标系
        SetOrtho(l.l, l.r, l.b, l.t)
        --设置视口
        SetViewport(
                l.scrl * scale + dx,
                l.scrr * scale + dx,
                l.scrb * scale + dy,
                l.scrt * scale + dy
        )
        --清空fog
        SetFog()
        --设置图像缩放比
        SetImageScale(1)
    else
        error("Invalid arguement.")
    end
end
lib.SetRenderRect = setRenderRect

local function worldToUI(x, y)
    local w = getCurrentWorld()
    return w.scrl + w:GetScreenWidth() * (x - w.l) / w:GetWidth(), w.scrb + w:GetScreenHeight() * (y - w.b) / w:GetHeight()
end
lib.WorldToUI = worldToUI

local function worldToScreen(x, y)
    local w = getCurrentWorld()
    local settingWidth = CurrentGraphicsSetting.GetWidth()
    local settingHeight = CurrentGraphicsSetting.GetHeight()
    local screenWidth = Screen.GetWidth()
    local screenHeight = Screen.GetHeight()
    local scale = Screen.GetScale()
    if settingWidth > settingHeight then
        return (settingWidth - settingHeight * screenWidth / screenHeight) / 2 / scale +
                w.scrl + w:GetScreenWidth() * (x - w.l) / w:GetWidth(), w.scrb + w:GetScreenHeight() * (y - w.b) / w:Height()
    else
        return w.scrl + w:GetScreenWidth() * (x - w.l) / (w.r - w.l),
        (settingHeight - settingWidth * screenHeight / screenWidth) / 2 / scale + w.scrb + w:GetScreenHeight() * (y - w.b) / w:GetHeight()
    end
end
lib.WorldToScreen = worldToScreen

local function screenToWorld(x, y)
    --该功能并不完善
    local dx, dy = worldToScreen(0, 0)
    return x - dx, y - dy
end
lib.ScreenToWorld = screenToWorld

addViewType("world", function(screen, world, offset, view3d)
    local width = world:GetWidth() * (1 / offset.hscale)--缩放后的宽度
    local height = world:GetHeight() * (1 / offset.vscale)--缩放后的高度
    local dx = offset.dx * (1 / offset.hscale)--水平整体偏移
    local dy = offset.dy * (1 / offset.vscale)--垂直整体偏移
    --计算world最终参数
    local l = offset.x - (width / 2) + dx
    local r = offset.x + (width / 2) + dx
    local b = offset.y - (height / 2) + dy
    local t = offset.y + (height / 2) + dy
    --应用参数
    setRenderRect(l, r, b, t, world.scrl, world.scrr, world.scrb, world.scrt)
end)
addViewType("ui", function(screen, world, offset, view3d)
    local width = screen.GetWidth()
    local height = screen.GetHeight()
    setRenderRect(0, width, 0, height, 0, width, 0, height)
end)

return lib