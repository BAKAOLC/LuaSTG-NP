local max = math.max
local int = math.floor
local select = select
local insert = table.insert
local unpack = table.unpack or unpack
local create = coroutine.create
local yield = coroutine.yield
local resume = coroutine.resume
local status = coroutine.status

local stringEmpty = ""

---捕获所有返回值
---@return number, table
local function packageResult(...)
    return select("#", ...), { ... }
end

---@class lstg.TaskFactory
local lib = {}
lstg.TaskFactory = lib

---@class lstg.TaskFactory.DataPackage : plus.Class
---@return lstg.TaskFactory.DataPackage
local dataPackage = plus.Class()
lib.DataPackage = dataPackage

function dataPackage:init()
    ---数据收集量
    self.total = 0
    ---储存的数据
    self.data = {}
end

---获取数据收集量
---@return number
function dataPackage:Count()
    return self.total
end

---收集数据
function dataPackage:Collect(...)
    self.total = self.total + 1
    insert(self.data, { select("#", ...), ... })
end

---取回数据
---@param index number
function dataPackage:Extract(index)
    if self.data[index] then
        return unpack(self.data[index], 2, self.data[index][1] + 1)
    end
end

---枚举数据
---@return number, table
function dataPackage:ForEach()
    return ipairs(self.data)
end

---清空数据
function dataPackage:Clear()
    self.data = {}
    self.total = 0
end

---克隆一份当前状态
---@return lstg.TaskFactory.DataPackage
function dataPackage:Clone()
    ---@type lstg.TaskFactory.DataPackage
    local data = getmetatable(self).__original()
    for _, o in self:ForEach() do
        data:Collect(unpack(o, 2, o[1] + 1))
    end
    return data
end

---进行等待并传出参数
function lib.Yield(...)
    return yield(...)
end

---设置跳过指定次数运行
---@param times number
---@param data lstg.TaskFactory.DataPackage
---@return lstg.TaskFactory.DataPackage
---@overload fun():lstg.TaskFactory.DataPackage
function lib.Wait(times, data)
    times = max(int(times or 1), 0)
    local package = dataPackage()
    if data then
        for i = 1, times do
            package:Collect(yield(data:Extract(i)))
        end
    else
        for _ = 1, times do
            package:Collect(yield())
        end
    end
    return package
end

---@class lstg.TaskFactory.Task : plus.Class
---@return lstg.TaskFactory.Task
local task = plus.Class()
lib.Task = task

---@param f function
function task:init(f, ...)
    return self:SetFunction(f, ...)
end

---@param f function
function task:SetFunction(f, ...)
    ---基础任务函数
    self.baseFunc = f
    ---基础参数
    self.baseParam = { select("#", ...), ... }
    ---工作任务函数
    self.workFunc = create(f)
    ---是否处于暂停状态
    self.pause = false
    ---是否已经运行完成
    self.finish = false
    ---是否触发错误
    self.error = false
    ---错误信息
    self.exception = stringEmpty
    return self:Work(...)
end

---获取基础函数
---@return function
function task:GetBaseFunc()
    return self.baseFunc
end

---获取基础参数
function task:GetBaseParameter()
    return unpack(self.baseParam, 2, self.baseParam[1] + 1)
end

---获取工作函数
---@return thread
function task:GetWorkFunc()
    return self.workFunc
end

---尝试重置task
function task:Reset()
    self:SetFunction(self:GetBaseFunc(), self:GetBaseParameter())
end

---标记暂停
function task:Pause()
    self.pause = true
end

---解除暂停
function task:Resume()
    self.pause = false
end

---标记执行完毕
function task:Finish()
    self.finish = true
end

---判断是否处于可工作状态
---@return string|'"normal"'|'"pause"'|'"finish"'|'"error"'
function task:Status()
    if self.error then
        return "error"
    elseif self.finish then
        return "finish"
    elseif self.pause then
        return "pause"
    else
        return "normal"
    end
end

---执行task
function task:Work(...)
    if self:Status() == "normal" then
        local co = self:GetWorkFunc()
        local num, data = packageResult(resume(co, ...))
        if data[1] then
            local s = status(co)
            if s == "dead" then
                self:Finish()
            end
            return unpack(data, 2, num)
        else
            self.error = true
            self.exception = data[2]
        end
    end
end

return lib