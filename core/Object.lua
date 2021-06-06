---=====================================
---luastg object
---=====================================

----------------------------------------
---class

local i18n = require("util.Internationalization")

---@param self object @回调对象自身
local emptyBaseFunc = function(self)
end

---@param self object @回调对象自身
---@param other object @碰撞对象
local emptyColliFunc = function(self, other)
end

---@class lstg.Object 对象基类
local baseObject = {
    ---init callback
    emptyBaseFunc,
    ---del callback
    emptyBaseFunc,
    ---frame callback
    emptyBaseFunc,
    ---render callback
    emptyBaseFunc,
    ---colli callback
    emptyColliFunc,
    ---kill callback
    emptyBaseFunc,
    ---是否是类
    is_class = true,
    ---init callback definition
    init = emptyBaseFunc,
    ---del callback definition
    del = emptyBaseFunc,
    ---frame callback definition
    frame = emptyBaseFunc,
    ---render callback definition
    render = DefaultRenderFunc,
    ---colli callback definition
    colli = emptyColliFunc,
    ---kill callback definition
    kill = emptyBaseFunc,
}
object = baseObject

local classList = {}

table.insert(classList, baseObject)

---定义一个lstg对象类
---@param base lstg.Object
---@param define lstg.Object
---@return lstg.Object
function Class(...)
    local n = select("#", ...)
    local base, define = ...
    if n == 0 then
        base = baseObject
    end
    if type(base) ~= "table" or not (base.is_class) then
        error(i18n:GetLanguageString("Core.Object.Class.Error.InvalidBase"))
    end
    ---@type lstg.Object
    local result = { emptyBaseFunc, emptyBaseFunc, emptyBaseFunc, emptyBaseFunc, emptyColliFunc, emptyBaseFunc }
    result.is_class = true
    result.init = base.init
    result.del = base.del
    result.frame = base.frame
    result.render = base.render
    result.colli = base.colli
    result.kill = base.kill
    result.base = base
    if define and type(define) == "table" then
        for k, v in pairs(define) do
            result[k] = v
        end
    end
    table.insert(classList, result)
    return result
end

---整理目标class的回调函数
---@param class lstg.Object
function InitClass(class)
    class[1] = class.init
    class[2] = class.del
    class[3] = class.frame
    class[4] = class.render
    class[5] = class.colli
    class[6] = class.kill
end

---对所有class的回调函数进行整理，给底层调用
function InitAllClass()
    for _, v in ipairs(classList) do
        InitClass(v)
    end
    classList = {}
end

----------------------------------------
---单位管理

function RawDel(o)
    if o then
        o.status = "del"
    end
end

function RawKill(o)
    if o then
        o.status = "kill"
    end
end

function PreserveObject(o)
    o.status = "normal"
end

---@class object 所有游戏对象类的基类。 | Base of all game class.
---@field x number x坐标 | x coordinates
---@field y number y坐标 | y coordinates
---@field dx number 只读 距离上一次更新的x坐标增量 | difference of x coordinates from last update (read-only)
---@field dy number 只读 距离上一次更新的y坐标增量 | difference of y coordinates from last update (read-only)
---@field rot number 朝向（角度） | orientation (in degrees)
---@field omiga number 朝向角速度 | angular velocity of orientation
---@field timer number 计数器 | update counter
---@field vx number x方向速度 | x velocity
---@field vy number y方向速度 | y velocity
---@field ax number x方向加速度 | x acceleration
---@field ay number y方向加速度 | y acceleration
---@field layer number 渲染层级 | render layer
---@field group number 碰撞组 | collision group
---@field hide boolean 是否隐藏（跳过渲染） | if object will not be rendered
---@field bound boolean 是否越界销毁 | if object will be marked at boundary check
---@field navi boolean 是否根据速度自动更新朝向 | if orientation will be updated according to velocity
---@field colli boolean 是否参与碰撞检测 | if object will be involved in collision check
---@field status string 对象状态，取值为"del"/"kill"/"normal" | status of object, can be "del", "kill" or "normal"
---@field hscale number 横向缩放 | horizontal scale
---@field vscale number 纵向缩放 | verticle scale
---@field class object 对象所属的类 | class of the object
---@field a number 碰撞盒宽 | size of collision box
---@field b number 碰撞盒高 | size of collision box
---@field rect boolean 是否为矩形碰撞盒 | if collision box is rectangle
---@field img string 绑定的可渲染资源的名称 | name of renderable resource on the object
---@field ani number 只读 动画计数器 | animation timer (read-only)
local M = {}