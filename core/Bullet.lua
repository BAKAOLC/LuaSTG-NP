local concat = table.concat
local unpack = table.unpack or unpack

local Color = lstg.Color
local LoadImage = LoadImage

---@class lstg.BulletLibrary
local lib = {}
BulletLibrary = lib

---@class lstg.GameObject.Bullet : lstg.Object
local class = Class(object)
lib.Class = class

function class:init(define, x, y, rot)
    self.x, self.y = x, y
    self.rot = rot or 0
end

function class:frame()
end

function class:render()
end

local defaultFunc = {
    ---初始化函数
    ---@param self object @对象自身
    init = function(self)
    end,
    ---帧逻辑函数
    ---@param self object @对象自身
    frame = function(self)
    end,
    ---渲染函数
    ---@param self object @对象自身
    render = function(self)
    end,
    ---雾化渲染函数
    ---@param self object @对象自身
    ---@param timer number @雾化计时器
    ---@param timer_max number @雾化总时长
    delay_render = function(self, timer, timer_max)
    end,
    ---消亡渲染函数
    ---@param self object @对象自身
    ---@param timer number @消亡计时器
    ---@param timer_max number @消亡总时长
    break_render = function(self, timer, timer_max)
    end
}

---@class lstg.BulletLibrary.BulletStructure
local structure = {
    ---图像
    img = "",
    ---是否为动画
    is_animation = false,
    ---混合模式
    blend = "",
    ---颜色
    color = Color(255, 255, 255, 255),
    ---判定大小
    collision = {
        ---宽度碰撞
        0,
        ---高度碰撞
        0,
        ---是否为矩形碰撞
        false
    },
    ---行为函数
    func = {
        ---初始化函数
        init = defaultFunc.init,
        ---帧逻辑函数
        frame = defaultFunc.frame,
        ---渲染函数
        render = defaultFunc.render,
        ---雾化渲染函数
        delay_render = defaultFunc.delay_render,
        ---消亡渲染函数
        break_render = defaultFunc.break_render
    }
}