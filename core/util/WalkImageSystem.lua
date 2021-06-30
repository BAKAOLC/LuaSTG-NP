--[[
动作函数定义:
    接受参数(normal状态下timerMax永远为0)
        参数名称     参数类型                 介绍
        self        lstg.WalkImageSystem    行走图系统
        timer       number                  当前动作执行量计时器
        timerMax    number                  当前动作目标执行量
    返回参数(不提供时将自动使用默认值)
        参数序号     参数类型     介绍                默认值
        1           number      ANM编号             1
        2           number      基准x偏移量          0
        3           number      基准y偏移量          0
        4           number      基准角度偏移量       0
        5           number      基准宽度缩放比       1
        6           number      基准高度缩放比       1
--]]

local int = math.floor
local abs = math.abs
local min = math.min
local deg = math.deg
local rad = math.rad
local _cos = math.cos
local _sin = math.sin
local select = select
local type = type
local insert = table.insert
local unpack = table.unpack or unpack

local Color = lstg.Color
local Draw = RenderTexture

--region 运算函数
---角度制cos
---@param x number
---@return number
local function cos(x)
    return _cos(rad(x))
end

---角度制sin
---@param x number
---@return number
local function sin(x)
    return _sin(rad(x))
end

---获得数字的符号(1/-1/0)
---@param x number
---@return number
local function sign(x)
    return x == 0 and 0 or x > 0 and 1 or -1
end

---插值计算
---@param from number
---@param to number
---@param i number
---@return number
local function interpolation(from, to, i)
    return from + (to - from) * i
end

---easeInOutQuad
---@param x number
---@return number
local function easeInOutQuad(x)
    return x < 0.5 and x * x * 2 or -2 * x * x + 4 * x - 1
end

---获取旋转坐标
---@param cx number @中心x
---@param cy number @中心y
---@param dx number @要旋转的坐标相对x坐标
---@param dy number @要旋转的坐标相对y坐标
---@param a number @要旋转的角度
---@return number, number
local function getPos(cx, cy, dx, dy, a)
    local x0 = dx * cos(a) - dy * sin(a) + cx
    local y0 = dx * sin(a) + dy * cos(a) + cy
    return x0, y0
end
--endregion

--region 默认定义
---基础静止动作
---@param self lstg.WalkImageSystem @行走图系统
---@param timer number @当前动作执行量计时器
---@param timerMax number @当前动作目标执行量
---@return number, number, number, number, number
local _ACT_NORMAL = function(self, timer, timerMax)
    local dy = 0
    if timer < 70 then
        dy = easeInOutQuad(timer / 70) * -3
    else
        timer = timer % 140
        if timer < 70 then
            dy = 3 - easeInOutQuad(timer / 70) * 6
        else
            dy = -3 + easeInOutQuad((timer - 70) / 70) * 6
        end
    end
    return 1, 0, dy, 0, 1, 1
end

---基础移动动作
---@param self lstg.WalkImageSystem @行走图系统
---@param timer number @当前动作执行量计时器
---@param timerMax number @当前动作目标执行量
---@return number, number, number, number, number
local _ACT_MOVE = function(self, timer, timerMax)
    return 1, 0, 0, 0, 1, 1
end

---基础施法动作
---@param self lstg.WalkImageSystem @行走图系统
---@param timer number @当前动作执行量计时器
---@param timerMax number @当前动作目标执行量
---@return number, number, number, number, number
local _ACT_CAST = function(self, timer, timerMax)
    return 1, 0, 0, 0, 1, 1
end
--endregion

---构建帧
---@param tex string @纹理资源名
---@param x number @图像左上角x
---@param y number @图像左上角y
---@param w number @图像宽度
---@param h number @图像高度
---@param dx number @图像渲染偏移x
---@param dy number @图像渲染偏移y
local function buildFrame(tex, x, y, w, h, dx, dy)
    ---@class lstg.WalkImageSystem.FrameData
    return { tex, x or 0, y or 0, w or 0, h or 0, dx or 0, dy or 0 }
end

---@class lstg.WalkImageSystem
---@return lstg.WalkImageSystem
local M = plus.Class()

--region 默认参数
---当前状态
M.state = "playing"
---当前动作
M.action = "normal"
---当前动作执行量真实计数器
M._actionCount = 0
---当前动作执行量计时器
M.actionCount = int(M._actionCount)
---当前动作目标执行量
M.actionCountMax = 0
---动作速度
M.actionSpeed = 1
---当前渲染ID
M.id = 1
---当前渲染X坐标
M.x = 0
---当前渲染Y坐标
M.y = 0
---渲染角度
M.rot = 0
---系统计算渲染角度
M._rot = 0
---渲染宽度缩放比
M.hscale = 1
---渲染高度缩放比
M.vscale = 1
---系统计算渲染宽度缩放比
M._hscale = 1
---系统计算渲染高度缩放比
M._vscale = 1
---用户设置渲染X偏移量
M.dx = 0
---用户设置渲染Y偏移量
M.dy = 0
---系统计算渲染X偏移量
M._dx = 0
---系统计算渲染Y偏移量
M._dy = 0
---是否禁用渲染
M.hide = false
---渲染混合模式
M.blend = ""
---渲染颜色
M.color = Color(255, 255, 255, 255)
---受击颜色
M.hurtColor = Color(255, 0, 0, 255)
---受击颜色比例(0~1)
M.hurtColorRate = 0
---对象x移动方向
M.moveDirLR = 0
---对象x移动数值
M.moveLR = 0
---对象y移动方向
M.moveDirUD = 0
---对象y移动数值
M.moveUD = 0

M.anm = {}
M._emptyANM = true
M.actionFunc = {
    normal = _ACT_CAST,
    move = _ACT_MOVE,
    cast = _ACT_CAST,
}
--endregion

function M:init()
    ---帧图像数据集
    self.anm = {}
    ---是否没有帧图像数据
    self._emptyANM = true
    ---动作函数库
    self.actionFunc = {}
    self:BindAction("normal", _ACT_NORMAL)
    self:BindAction("move", _ACT_MOVE)
    self:BindAction("cast", _ACT_CAST)
    self:ResetState()
end

function M:frame()
    if self:GetState() == "playing" then
        self:UpdateActionFrame()
    end
end

function M:render()
    if not (self.hide or self._emptyANM) then
        local c = self.hurtColorRate
        local a1, r1, g1, b1 = self.color:ARGB()
        local a2, r2, g2, b2 = self.hurtColor:ARGB()
        local color = Color(interpolation(a1, a2, c), interpolation(r1, r2, c),
                interpolation(g1, g2, c), interpolation(b1, b2, c))
        local tex, x, y, w, h, dx, dy = self:GetFrameData(self.id)
        local scaleW = self.hscale * self._hscale
        local scaleH = self.vscale * self._vscale
        local drawX = self.x + self.dx + self._dx + dx * scaleW
        local drawY = self.y + self.dy + self._dy + dy * scaleH
        local drawW = w * scaleW / 2
        local drawH = h * scaleH / 2
        local rot = self.rot + self._rot
        local px, py = getPos(drawX, drawY, -drawW, drawH, rot)
        local p1 = { px, py, 0.5, x, y, color }
        px, py = getPos(drawX, drawY, drawW, drawH, rot)
        local p2 = { px, py, 0.5, x + w, y, color }
        px, py = getPos(drawX, drawY, drawW, -drawH, rot)
        local p3 = { px, py, 0.5, x + w, y + h, color }
        px, py = getPos(drawX, drawY, -drawW, -drawH, rot)
        local p4 = { px, py, 0.5, x, y + h, color }
        Draw(tex, self.blend, p1, p2, p3, p4)
    end
end

--region 帧数据集相关
---注册帧数据
---@param tex string @纹理资源名
---@param x number @图像左上角x
---@param y number @图像左上角y
---@param w number @图像宽度
---@param h number @图像高度
---@param dx number @图像渲染偏移x
---@param dy number @图像渲染偏移y
---@return number
function M:AddFrame(tex, x, y, w, h, dx, dy)
    insert(self.anm, buildFrame(tex, x, y, w, h, dx, dy))
    self._emptyANM = false
    return #self.anm
end

---获取帧数据
---@param id number
---@return string, number, number, number, number, number, number
function M:GetFrameData(id)
    return unpack(self.anm[id])
end
--endregion

--region 坐标相关
---设置渲染X坐标
---@param x number
function M:SetPositionX(x)
    self.x = x
end

---设置渲染Y坐标
---@param y number
function M:SetPositionY(y)
    self.y = y
end

---设置渲染坐标
---@param x number
---@param y number
function M:SetPosition(x, y)
    self.x, self.y = x, y
end

---获取渲染X坐标
---@return number
function M:GetPositionX()
    return self.x
end

---获取渲染X坐标
---@return number
function M:GetPositionY()
    return self.y
end

---获取渲染坐标
---@return number, number
function M:GetPosition()
    return self.x, self.y
end

---设置渲染偏移X坐标
---@param dx number
function M:SetDPositionX(dx)
    self.dx = dx
end

---设置渲染偏移Y坐标
---@param dy number
function M:SetDPositionY(dy)
    self.dy = dy
end

---设置渲染偏移坐标
---@param dx number
---@param dy number
function M:SetDPosition(dx, dy)
    self.dx, self.dy = dx, dy
end

---获取渲染偏移X坐标
---@return number
function M:GetDPositionX()
    return self.dx
end

---获取渲染偏移X坐标
---@return number
function M:GetDPositionY()
    return self.dy
end

---获取渲染偏移坐标
---@return number, number
function M:GetDPosition()
    return self.dx, self.dy
end
--endregion

--region 角度相关
---设置渲染角度
---@param rot number
function M:SetRotation(rot)
    self.rot = rot
end

---获取渲染角度
---@return number
function M:GetRotation()
    return self.rot
end
--endregion

--region 渲染样式相关
---设置宽度缩放比
---@param hscale number
function M:SetScaleH(hscale)
    self.hscale = hscale
end

---设置高度缩放比
---@param vscale number
function M:SetScaleV(vscale)
    self.vscale = vscale
end

---设置缩放比
---@param hscale number
---@param vscale number
function M:SetScale(hscale, vscale)
    self.hscale, self.vscale = hscale, vscale
end

---获取宽度缩放比
---@return number
function M:GetScaleH()
    return self.hscale
end

---获取高度缩放比
---@return number
function M:GetScaleV()
    return self.vscale
end

---获取缩放比
---@return number, number
function M:GetScale()
    return self.hscale, self.vscale
end

---设置渲染混合模式
---@param blend string
function M:SetBlend(blend)
    self.blend = blend or ""
end

---获取渲染混合模式
---@return string
function M:GetBlend()
    return self.blend
end

---设置禁用渲染
function M:Hide()
    self.hide = true
end

---设置启用渲染
function M:Show()
    self.hide = false
end

---获取是否禁用渲染
---@return boolean
function M:IsHide()
    return self.hide
end

--region 渲染颜色
---设置渲染不透明度
---@param alpha number
function M:SetColorAlpha(alpha)
    local _, r, g, b = self.color:ARGB()
    self:SetColor(alpha, r, g, b)
end

---设置渲染红色色度
---@param red number
function M:SetColorRed(red)
    local a, _, g, b = self.color:ARGB()
    self:SetColor(a, red, g, b)
end

---设置渲染绿色色度
---@param green number
function M:SetColorGreen(green)
    local a, r, _, b = self.color:ARGB()
    self:SetColor(a, r, green, b)
end

---设置渲染蓝色色度
---@param blue number
function M:SetColorRed(blue)
    local a, r, g, _ = self.color:ARGB()
    self:SetColor(a, r, g, blue)
end

---设置渲染颜色
---@param a number @不透明度
---@param r number @红色
---@param g number @绿色
---@param b number @绿色
---@overload fun(argb:number)
---@overload fun(lstg.Color:userdata)
function M:SetColor(a, r, g, b)
    if a and r and g and b then
        self.color = Color(a, r, g, b)
    elseif type(a) == "userdata" then
        self.color = a
    elseif a then
        self.color = Color(a)
    end
end

---获取渲染不透明度
---@return number
function M:GetColorAlpha()
    return (self.color:ARGB())
end

---获取渲染红色色度
---@return number
function M:GetColorRed()
    return (select(2, self.color:ARGB()))
end

---获取渲染绿色色度
---@return number
function M:GetColorGreen()
    return (select(3, self.color:ARGB()))
end

---获取渲染蓝色色度
---@return number
function M:GetColorBlue()
    return (select(4, self.color:ARGB()))
end

---获取渲染颜色
---@return number, number, number, number
function M:GetColor()
    return self.color:ARGB()
end
--endregion

--region 受击颜色
---设置渲染受击不透明度
---@param alpha number
function M:SetHurtColorAlpha(alpha)
    local _, r, g, b = self.hurtColor:ARGB()
    self:SetHurtColor(alpha, r, g, b)
end

---设置渲染受击红色色度
---@param red number
function M:SetHurtColorRed(red)
    local a, _, g, b = self.hurtColor:ARGB()
    self:SetHurtColor(a, red, g, b)
end

---设置渲染受击绿色色度
---@param green number
function M:SetHurtColorGreen(green)
    local a, r, _, b = self.hurtColor:ARGB()
    self:SetHurtColor(a, r, green, b)
end

---设置渲染受击蓝色色度
---@param blue number
function M:SetHurtColorRed(blue)
    local a, r, g, _ = self.hurtColor:ARGB()
    self:SetHurtColor(a, r, g, blue)
end

---设置渲染受击颜色
---@param a number @不透明度
---@param r number @红色
---@param g number @绿色
---@param b number @绿色
---@overload fun(argb:number)
---@overload fun(lstg.HurtColor:userdata)
function M:SetHurtColor(a, r, g, b)
    if a and r and g and b then
        self.hurtColor = Color(a, r, g, b)
    elseif type(a) == "userdata" then
        self.hurtColor = a
    elseif a then
        self.hurtColor = Color(a)
    end
end

---获取渲染受击不透明度
---@return number
function M:GetHurtColorAlpha()
    return (self.hurtColor:ARGB())
end

---获取渲染受击红色色度
---@return number
function M:GetHurtColorRed()
    return (select(2, self.hurtColor:ARGB()))
end

---获取渲染受击绿色色度
---@return number
function M:GetHurtColorGreen()
    return (select(3, self.hurtColor:ARGB()))
end

---获取渲染受击蓝色色度
---@return number
function M:GetHurtColorBlue()
    return (select(4, self.hurtColor:ARGB()))
end

---获取受击渲染受击颜色
---@return number, number, number, number
function M:GetHurtColor()
    return self.hurtColor:ARGB()
end

---设置受击渲染颜色深度
---@param rate number
function M:SetHurtColorRate(rate)
    self.hurtColorRate = rate
end

---获取受击渲染颜色深度
---@return number
function M:GetHurtColorRate()
    return self.hurtColorRate
end
--endregion
--endregion

--region 动作相关
---绑定动作函数
---@param action string
---@param func function
function M:BindAction(action, func)
    self.actionFunc[action] = func
end

---移除动作函数
---@param action string
function M:RemoveAction(action)
    self.actionFunc[action] = nil
end

---获取动作函数
---@param action string
---@return function
function M:GetActionFunc(action)
    return self.actionFunc[action] or M.actionFunc[action]
end

---设置动作
---@param action string
---@param duration number
---@overload fun(action:string)
function M:SetAction(action, duration)
    self.action = action
    self._actionCount = 0
    self.actionCount = 0
    self.actionCountMax = duration or 0
end

---重置动作到默认状态
function M:StopAction()
    self:SetAction("normal")
end

---获取动作状态
---@return string, number, number
function M:GetAction()
    return self.action, self.actionCount, self.actionCountMax
end

---暂停行走图动作
function M:Pause()
    self.state = "pause"
end

---恢复行走图动作
function M:Resume()
    self.state = "playing"
end

---获取行走图状态
---@return string|'"playing"'|'"pause"'
function M:GetState()
    return self.state
end

---设置动作速度
---@param speed number
function M:SetActionSpeed(speed)
    self.actionSpeed = speed
end

---获取动作速度
---@return number
function M:GetActionSpeed()
    return self.actionSpeed
end
--endregion

--region 动作更新函数
---更新动作帧数据
function M:UpdateActionFrame()
    self._actionCount = self._actionCount + self.actionSpeed
    if self:GetAction() ~= "normal" and self._actionCount > self.actionCountMax then
        local _ac = self._actionCount - self.actionCountMax
        self:SetAction("normal")
        self._actionCount = _ac
    end
    self:CalcActionFrame()
end

---计算当前动作帧数据
function M:CalcActionFrame()
    self.actionCount = min(self.actionCountMax, int(self._actionCount))
    local id, dx, dy, rot, hs, vs = self:GetActionFunc(self:GetAction())(self, self.actionCount, self.actionCountMax)
    self.id = id or M.id
    self._dx = dx or M._drawDx
    self._dy = dy or M._drawDy
    self._rot = rot or M._rot
    self._hscale = hs or M._hscale
    self._vscale = vs or M._vscale
end

---重置状态
function M:ResetState()
    self:ResetSystemCalc()
    self.state = M.state
    self.action = M.action
    self.actionCount = M.actionCount
    self.actionCountMax = M.actionCountMax
    self.actionSpeed = M.actionSpeed
    self:CalcActionFrame()
    self.rot = M.rot
    self.dx = M.dx
    self.dy = M.dy
    self.hscale = M.hscale
    self.vscale = M.vscale
    self.hide = M.hide
    self.blend = M.blend
    self.color = M.color
    self.moveDirLR = M.moveDirLR
    self.moveLR = M.moveLR
    self.moveDirUD = M.moveDirUD
    self.moveUD = M.moveUD
end

---仅重置系统计算值
function M:ResetSystemCalc()
    self._actionCount = M._actionCount
    self._dx = M._drawDx
    self._dy = M._drawDy
    self._rot = M._rot
    self._hscale = M._hscale
    self._vscale = M._vscale
end
--endregion

--region Object 数据同步相关
---使用obj数据更新行走图数据
---@param obj object
function M:UpdateWithObject(obj)
    self:SetPosition(obj.x, obj.y)
    self:UpdateMoveParameter(obj.dx, obj.dy)
    self:SetRotation(obj.rot)
    self:SetScale(obj.hscale, obj.vscale)
    if obj.hide then
        self:Hide()
    else
        self:Show()
    end
    if obj._blend then
        self:SetBlend(obj._blend)
    end
    if obj._a and obj._r and obj._g and obj._b then
        self:SetColor(obj._a, obj._r, obj._g, obj._b)
    else
        if obj._a then
            self:SetColorAlpha(obj._a)
        end
        if obj._r then
            self:SetColorRed(obj._r)
        end
        if obj._g then
            self:SetColorGreen(obj._g)
        end
        if obj._b then
            self:SetColorBlue(obj._b)
        end
    end
end

---提供移动参数
---@param dx number
---@param dy number
function M:UpdateMoveParameter(dx, dy)
    self.moveDirLR, self.moveLR = sign(dx), abs(dx)
    self.moveDirUD, self.moveUD = sign(dy), abs(dy)
end
--endregion

return M