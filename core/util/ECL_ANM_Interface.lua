local tonumber = tonumber
local assert = assert
local open = io.open
local lower = string.lower
local byte = string.byte
local sub = string.sub
local gsub = string.gsub
local match = string.match
local gmatch = string.gmatch
local insert = table.insert
local remove = table.remove
local unpack = table.unpack or unpack
local ipairs = ipairs

---协程操作库
local task = require("TaskFactory")
---数学计算库
local calc = require("util.MathCalculation")
---行走图系统库
local anm = require("util.WalkImageSystem")

---按照指定分隔符分割字符串
---@param str string @要分割的字符串
---@param delimiter string @分隔符
---@return table<number, string>
local function Split(str, delimiter)
    local list, tmp = {}, byte(delimiter)
    if delimiter == "" then
        for i = 1, #str do
            list[i] = sub(str, i, i)
        end
    else
        for substr in gmatch(str .. delimiter, "(.-)" .. (((tmp > 96 and tmp < 123) or (tmp > 64 and tmp < 91) or (tmp > 47 and tmp < 58)) and delimiter or "%" .. delimiter)) do
            insert(list, substr)
        end
    end
    return list
end

---绑定函数
---@param self lstg.ECL_ANM_Interface
---@param func function
---@return function
local function bindFunc(self, func)
    return function(...)
        return func(self, ...)
    end
end

---静止状态定义
---@param interface lstg.ECL_ANM_Interface
---@param self lstg.WalkImageSystem
---@param timer number
---@param timerMax number
local _ACT_NORMAL = function(interface, self, timer, timerMax)
    if interface.pause then
        interface.pause = false
    else
        interface.timer = interface.timer + 1
    end
    if interface.status ~= "normal" then
        interface:Reset()
        interface.status = "normal"
    end
    if interface.data.normal[interface.timer] then
        for _, data in ipairs(interface.data.normal[interface.timer]) do
            if interface:RunIns(data) then
                break
            end
        end
    end
    return interface.imgID, interface.imgX, interface.imgY
end

---左移动状态定义
---@param interface lstg.ECL_ANM_Interface
---@param self lstg.WalkImageSystem
---@param timer number
---@param timerMax number
local _ACT_MOVE_LEFT = function(interface, self, timer, timerMax)
    if interface.pause then
        interface.pause = false
    else
        interface.timer = interface.timer + 1
    end
    if interface.status ~= "move_left" then
        interface:Reset()
        interface.status = "move_left"
    end
    if interface.data.left[interface.timer] then
        for _, data in ipairs(interface.data.left[interface.timer]) do
            if interface:RunIns(data) then
                break
            end
        end
    end
    return interface.imgID, interface.imgX, interface.imgY
end

---左移动结束状态定义
---@param interface lstg.ECL_ANM_Interface
---@param self lstg.WalkImageSystem
---@param timer number
---@param timerMax number
local _ACT_MOVE_LEFT_CANCEL = function(interface, self, timer, timerMax)
    if interface.pause then
        interface.pause = false
    else
        interface.timer = interface.timer + 1
    end
    if interface.status ~= "move_left_cancel" then
        interface:Reset()
        interface.status = "move_left_cancel"
    end
    if interface.data.left_cancel[interface.timer] then
        for _, data in ipairs(interface.data.left_cancel[interface.timer]) do
            if interface:RunIns(data) then
                break
            end
        end
    end
    return interface.imgID, interface.imgX, interface.imgY
end

---右移动状态定义
---@param interface lstg.ECL_ANM_Interface
---@param self lstg.WalkImageSystem
---@param timer number
---@param timerMax number
local _ACT_MOVE_RIGHT = function(interface, self, timer, timerMax)
    if interface.pause then
        interface.pause = false
    else
        interface.timer = interface.timer + 1
    end
    interface.timer = interface.timer + 1
    if interface.status ~= "move_right" then
        interface:Reset()
        interface.status = "move_right"
    end
    if interface.data.right[interface.timer] then
        for _, data in ipairs(interface.data.right[interface.timer]) do
            if interface:RunIns(data) then
                break
            end
        end
    end
    return interface.imgID, interface.imgX, interface.imgY
end

---右移动结束状态定义
---@param interface lstg.ECL_ANM_Interface
---@param self lstg.WalkImageSystem
---@param timer number
---@param timerMax number
local _ACT_MOVE_RIGHT_CANCEL = function(interface, self, timer, timerMax)
    if interface.pause then
        interface.pause = false
    else
        interface.timer = interface.timer + 1
    end
    if interface.status ~= "move_right_cancel" then
        interface:Reset()
        interface.status = "move_right_cancel"
    end
    if interface.data.right_cancel[interface.timer] then
        for _, data in ipairs(interface.data.right_cancel[interface.timer]) do
            if interface:RunIns(data) then
                break
            end
        end
    end
    return interface.imgID, interface.imgX, interface.imgY
end

---施法状态定义
---@param interface lstg.ECL_ANM_Interface
---@param self lstg.WalkImageSystem
---@param timer number
---@param timerMax number
local _ACT_CAST = function(interface, self, timer, timerMax)
    if interface.pause then
        interface.pause = false
    else
        interface.timer = interface.timer + 1
    end
    if interface.status ~= "cast" then
        interface:Reset()
        interface.status = "cast"
    end
    if interface.data.cast[interface.timer] then
        for _, data in ipairs(interface.data.cast[interface.timer]) do
            if interface:RunIns(data) then
                break
            end
        end
    end
    return interface.imgID, interface.imgX, interface.imgY
end

---@class lstg.ECL_ANM_Interface
---@return lstg.ECL_ANM_Interface
local controller = plus.Class()

function controller:init()
    self.data = {
        normal = {},
        left = {},
        right = {},
        left_cancel = {},
        right_cancel = {},
        cast = {}
    }
    ---@type table<number, lstg.TaskFactory.Task>
    self.task = {}
    self.anm = anm()
    self.anm:BindAction("normal", bindFunc(self, _ACT_NORMAL))
    self.anm:BindAction("move_left", bindFunc(self, _ACT_MOVE_LEFT))
    self.anm:BindAction("move_left_cancel", bindFunc(self, _ACT_MOVE_LEFT_CANCEL))
    self.anm:BindAction("move_right", bindFunc(self, _ACT_MOVE_RIGHT))
    self.anm:BindAction("move_right_cancel", bindFunc(self, _ACT_MOVE_RIGHT_CANCEL))
    self.anm:BindAction("cast", bindFunc(self, _ACT_CAST))
    self.imgID = 1
    self.imgX = 0
    self.imgY = 0
    self.timer = 0
    self.pause = false
    self.status = "normal"
end

function controller:frame()
    self:DoTask()
    self.anm:frame()
end

function controller:render()
    self.anm:render()
end

---读取行走图定义数据
---@param tex string
---@param path string
function controller:ReadFile(tex, path)
    ---@type file
    local f = assert(open(path, "r"))
    local chunk
    for line in f:lines() do
        if line:match("%S") then
            ---@type string
            local m = match(line, "^%[(.-)%]%s*$")
            if m then
                chunk = lower(m)
            else
                if chunk == "sprite" then
                    local w, h, x, y = match(line, "^(%d+)%*(%d+)%+(%d+)%+(%d+)%s*$")
                    if w then
                        self.anm:AddFrame(tex, tonumber(x), tonumber(y), tonumber(w), tonumber(h))
                    end
                else
                    local p = Split(match(line, "^.-%s*$"), " ")
                    for i = 1, #p do
                        p[i] = tonumber((gsub(p[i], "f", "")))
                    end
                    local frame = p[1]
                    self.data[chunk][frame] = self.data[chunk][frame] or {}
                    insert(self.data[chunk][frame], { unpack(p, 3) })
                end
            end
        end
    end
end

---插入task
---@param t lstg.TaskFactory.Task
function controller:AddTask(t)
    insert(self.task, t)
end

---执行task
function controller:DoTask()
    local i = 1
    while i <= #self.task do
        local t = self.task[i]
        t:Work()
        if t:Status() == "finish" then
            remove(self.task, i)
        else
            i = i + 1
        end
    end
end

---清空task
function controller:ClearTask()
    self.task = {}
end

function controller:Reset()
    self:ClearTask()
    self.imgID = 1
    self.imgX = 0
    self.imgY = 0
    self.timer = 0
    self.pause = false
end

---执行data
---@param data table<number, number>
---@return boolean
function controller:RunIns(data)
    if data[1] == 3 then
        self.pause = true
        return true
    elseif data[1] == 200 then
        self.timer = data[3]
    elseif data[1] == 300 then
        self.imgID = data[2] + 1
    elseif data[1] == 400 then
        self.imgX, self.imgY = data[2], data[3]
    elseif data[1] == 407 then
        local calcFunc
        if data[3] == 1 then
            calcFunc = calc.EaseInQuad
        elseif data[3] == 4 then
            calcFunc = calc.EaseOutQuad
        elseif data[3] == 9 then
            calcFunc = calc.EaseInOutQuad
        else
            calcFunc = calc.Linear
        end
        local iterator = calc.Iterator(0, 1, data[2], false, true, calcFunc)
        local dx, dy = data[4], data[5]
        self:AddTask(task.Task(function()
            local last = 0
            for _ = 1, data[2] do
                local v = iterator()
                v, last = v - last, v
                self.imgX = self.imgX + v * dx
                self.imgY = self.imgY + v * dy
                task.Yield()
            end
        end))
    end
end

return controller