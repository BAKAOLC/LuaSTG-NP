local unpack = table.unpack or unpack

local SetPerspective = SetPerspective
local SetViewport = SetViewport
local SetFog = SetFog
local SetImageScale = SetImageScale

---@class lstg.View3d
local lib = {}
lstg.View3d = lib

---@class lstg.View3d.View.Default
local defaultView = {
    eye = { 0, 0, -1 },
    at = { 0, 0, 0 },
    up = { 0, 1, 0 },
    fovy = PI_2,
    z = { 0, 2 },
    fog = { 0, 0, Color(0x00000000) }
}

---@type lstg.View3d.View
local currentView

---获取当前视角
---@return lstg.View3d.View
local function getCurrentView3d()
    return currentView
end
lib.GetCurrentView3d = getCurrentView3d

---@class lstg.View3d.View : lstg.View3d.View.Default
---@return lstg.View3d.View
local view = plus.Class()

---重置视角
local function resetView()
    currentView = view()
end
lib.ResetView3d = resetView

function view:init()
    self:Reset()
end

---重置视角
function view:Reset()
    self:SetEye(unpack(defaultView.eye))
    self:SetAt(unpack(defaultView.at))
    self:SetUp(unpack(defaultView.up))
    self:SetFovy(defaultView.fovy)
    self:SetZ(unpack(defaultView.z))
    self:SetFog(unpack(defaultView.fog))
end

---设置眼睛位置
---@param x number
---@param y number
---@param z number
function view:SetEye(x, y, z)
    self.eye = self.eye or {}
    self.eye[1] = x
    self.eye[2] = y
    self.eye[3] = z
end

---设置视线目标位置
---@param x number
---@param y number
---@param z number
function view:SetAt(x, y, z)
    self.at = self.at or {}
    self.at[1] = x
    self.at[2] = y
    self.at[3] = z
end

---设置正上方向
---@param x number
---@param y number
---@param z number
function view:SetUp(x, y, z)
    self.up = self.up or {}
    self.up[1] = x
    self.up[2] = y
    self.up[3] = z
end

---设置视角
---@param fovy number @视角
function view:SetFovy(fovy)
    self.fovy = fovy
end

---设置Z范围
---@param zMin number @Z最小值
---@param zMax number @Z最大值
function view:SetZ(zMin, zMax)
    self.z = self.z or {}
    self.z[1] = zMin
    self.z[2] = zMax
end

---设置雾
---@param from number @雾起始距离
---@param to number @雾结束距离
---@param color lstg.Color @雾颜色
function view:SetFog(from, to, color)
    self.fog = self.fog or {}
    self.fog[1] = from
    self.fog[2] = to
    self.fog[3] = color
end

lstg.eventDispatcher:addListener("core.init", function()
    require("View").AddViewType("3d", function(screen, world, offset, view3d)
        local scale = screen.GetScale()
        local dx = screen.GetDx()
        local dy = screen.GetDy()
        SetViewport(world.scrl * scale + dx, world.scrr * scale + dx,
                world.scrb * scale + dy, world.scrt * scale + dy)
        SetPerspective(
                view3d.eye[1], view3d.eye[2], view3d.eye[3],
                view3d.at[1], view3d.at[2], view3d.at[3],
                view3d.up[1], view3d.up[2], view3d.up[3],
                view3d.fovy, world:GetWidth() / world:GetHeight(),
                view3d.z[1], view3d.z[2]
        )
        SetFog(view3d.fog[1], view3d.fog[2], view3d.fog[3])
        SetImageScale(1)
    end)
end, 12, "core.view3d.init")

return lib