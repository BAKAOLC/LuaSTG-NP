local setmetatable = setmetatable

local Color = lstg.Color
local DefaultRenderFunc = DefaultRenderFunc
local SetImgState = SetImgState

local Del = RawDel
local PreserveObject = PreserveObject

---@class lstg.BulletLibrary
local lib = {}
BulletLibrary = lib

---@class lstg.GameObject.Bullet : lstg.Object
local class = Class(object)
lib.Class = class

---@param define lstg.BulletLibrary.BulletStructure
---@param x number @初始化x位置
---@param y number @初始化y位置
---@param rot number @初始化角度
function class:init(define, x, y, rot)
    ---使用的结构
    self.structure = define
    self.x, self.y = x, y
    self.rot = rot or 0
    self.img = self.structure.img
    self.hscale, self.vscale = self.structure.hscale, self.structure.vscale
    self.a, self.b, self.rect = self.structure.a, self.structure.b, self.structure.rect
    ---当前状态
    ---@type string|'"delay"'|'"normal"'|'"break"'
    self.state = "delay"
    self.state_timer = 0
    self.state_timer_max = 0
    lib.SetIsDelay(self, self.structure.delay_length)
    lib.RunFunc(self, "init")
end

function class:frame()
    if self.state ~= "normal" and self.state_timer >= self.state_timer_max then
        if self.state == "delay" then
            lib.SetIsNormal(self)
        else
            Del(self)
        end
    else
        self.state_timer = self.state_timer + 1
    end
    if self.state == "delay" then
        lib.RunFunc(self, "delay_frame")
    elseif self.state == "break" then
        lib.RunFunc(self, "break_frame")
    else
        lib.RunFunc(self, "frame")
    end
end

function class:render()
    if self.state == "delay" then
        lib.RunFunc(self, "delay_render")
    elseif self.state == "break" then
        lib.RunFunc(self, "break_render")
    else
        lib.RunFunc(self, "render")
    end
end

function class:kill()
    lib.RunFunc(self, "kill")
end

function class:del()
    lib.RunFunc(self, "del")
end

---@class lstg.BulletLibrary.BulletStructure
local base_structure = {
    ---图像
    img = "",
    ---于基准layer的偏移量
    layer = 0,
    ---混合模式
    blend = "",
    ---颜色
    color = Color(255, 255, 255, 255),
    ---基础宽度缩放比
    hscale = 1,
    ---基础高度缩放比
    vscale = 1,
    ---判定宽度
    a = 0,
    ---判定高度
    b = 0,
    ---是否为矩形判定
    rect = false,
    ---雾化时长
    delay_length = 10,
    ---消弹时长
    break_length = 24,
    ---初始化函数
    ---@param self lstg.GameObject.Bullet
    init = function(self)
    end,
    ---帧逻辑函数
    ---@param self lstg.GameObject.Bullet
    frame = function(self)
    end,
    ---渲染函数
    ---@param self lstg.GameObject.Bullet
    render = function(self)
        if self._blend and self._a and self._r and self._g and self._b then
            SetImgState(self, self._blend, self._a, self._r, self._g, self._b)
            DefaultRenderFunc(self)
            SetImgState(self, self.structure.blend, self.structure.color:ARGB())
        else
            DefaultRenderFunc(self)
        end
    end,
    ---雾化帧逻辑函数
    ---@param self lstg.GameObject.Bullet
    delay_frame = function(self)
    end,
    ---雾化渲染函数
    ---@param self lstg.GameObject.Bullet
    delay_render = function(self)
        local r = 2 - self.state_timer / self.state_timer_max
        local _h, _v = self.hscale, self.vscale
        self.hscale, self.vscale = _h * r, _v * r
        DefaultRenderFunc(self)
        self.hscale, self.vscale = _h, _v
    end,
    ---消亡帧逻辑函数
    ---@param self lstg.GameObject.Bullet
    break_frame = function(self)

    end,
    ---消亡渲染函数
    ---@param self lstg.GameObject.Bullet
    break_render = function(self)
        local r = 1 + self.state_timer / self.state_timer_max
        local _h, _v = self.hscale, self.vscale
        self.hscale, self.vscale = _h * r, _v * r
        DefaultRenderFunc(self)
        self.hscale, self.vscale = _h, _v
    end,
    ---消弹操作回调
    ---@param self lstg.GameObject.Bullet
    kill = function(self)
        PreserveObject(self)
        if self.state ~= "break" then
            lib.SetIsBreak(self, self.structure.break_length)
        end
    end,
    ---删除操作回调
    ---@param self lstg.GameObject.Bullet
    del = function(self)
        PreserveObject(self)
        if self.state ~= "break" then
            lib.SetIsBreak(self, self.structure.break_length)
        end
    end,
    ---继承类
    ---@type lstg.BulletLibrary.BulletStructure
    base = nil
}

---设置当前为雾化状态
---@param obj lstg.GameObject.Bullet
---@param timer_max number @雾化时长
function lib.SetIsDelay(obj, timer_max)
    obj.state = "delay"
    obj.state_timer = 0
    obj.state_timer_max = timer_max
    obj.layer = LAYER_ENEMY_BULLET_EF - obj.structure.layer / 1000
end

---设置当前为消亡状态
---@param obj lstg.GameObject.Bullet
---@param timer_max number @消亡时长
function lib.SetIsBreak(obj, timer_max)
    obj.state = "break"
    obj.state_timer = 0
    obj.state_timer_max = timer_max
    obj.layer = LAYER_ENEMY_BULLET - 50 - obj.structure.layer / 1000
end

---设置当前为通常状态
---@param obj lstg.GameObject.Bullet
function lib.SetIsNormal(obj)
    obj.state = "normal"
    obj.state_timer = 0
    obj.state_timer_max = 0
    obj.layer = LAYER_ENEMY_BULLET - obj.structure.layer / 1000
end

---执行上级函数
---@param obj lstg.GameObject.Bullet
---@param type string|'"init"'|'"frame"'|'"render"'|'"delay_frame"'|'"delay_render"'|'"break_frame"'|'"break_render"'|'"kill"'|'"del"'
function lib.RunUpperFunc(obj, type)
    if obj.structure.base and obj.structure.base[type] then
        obj.structure.base[type](obj)
    end
end

---定义子弹结构
---@param base lstg.BulletLibrary.BulletStructure
---@return lstg.BulletLibrary.BulletStructure
---@overload fun():lstg.BulletLibrary.BulletStructure
function lib.DefineClass(base)
    base = base or base_structure
    return setmetatable({ base = base }, { __index = base })
end