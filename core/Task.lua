local create = coroutine.create
local yield = coroutine.yield
local resume = coroutine.resume
local status = coroutine.status
local running = coroutine.running
local ipairs = ipairs
local error = error
local tostring = tostring
local insert = table.insert
local remove = table.remove
local traceback = debug.traceback

local max = max
local int = int
local sign = sign
local CombinNum = CombinNum

local i18n = require("util.Internationalization")
local calc = require("util.MathCalculation")

---@class lstg.Task
local lib = {}
Task = lib
lstg.Task = lib

local stackTarget = {}

---@return object
local function getSelf()
    local s = stackTarget[#stackTarget]
    return s._taskTarget or s
end
lib.GetSelf = getSelf

---新建一个task
---@param f function
function lib:New(f)
    self.task = self.task or {}
    local co = create(f)
    insert(self.task, co)
    return co
end

---刷新并执行一遍task
function lib:Do()
    if self.task then
        for _, co in ipairs(self.task) do
            if status(co) ~= 'dead' then
                insert(stackTarget, self)
                local success, errmsg = resume(co)
                if not (success) then
                    error(tostring(errmsg or i18n:GetLanguageString("Core.Task.Error.UnknownException"))
                            .. "\n========== " .. i18n:GetLanguageString("Core.Task.CoroutineTraceback") .. " ==========\n"
                            .. traceback(co)
                            .. "\n========== " .. i18n:GetLanguageString("Core.Task.CTraceback") .. " ==========")
                end
                remove(stackTarget)
            end
        end
    end
end

---清理所有task
---@param keepCurrent boolean @是否保留当前task
function lib:Clear(keepCurrent)
    if keepCurrent then
        local flag = false
        local co = running()
        for i = 1, #self.task do
            if self.task[i] == co then
                flag = true
                break
            end
        end
        self.task = flag and { co } or nil
    else
        self.task = nil
    end
end

---暂停task运行
---@param t number @要暂停的轮数
function lib.Wait(t)
    t = max(0, int(t or 1))
    for _ = 1, t do
        yield()
    end
end

---在timer到达指定值之前暂停task运行
---@param t number @目标timer值
function lib.Until(t)
    t = int(t or 0)
    local self = lib.GetSelf()
    while self.timer < t do
        yield()
    end
end

---匀速移动
MOVE_NORMAL = 0
---加速移动
MOVE_ACCEL = 1
---减速移动
MOVE_DECEL = 2
---先加速后减速运动
MOVE_ACC_DEC = 3

---移动到指定坐标
---@param x number @目标x坐标
---@param y number @目标y坐标
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:MoveTo(x, y, t, mode)
    t = max(1, int(t))
    local xs = self.x
    local ys = self.y
    local dx = x - xs
    local dy = y - ys
    local calcFunc
    if mode == 1 then
        calcFunc = calc.EaseInQuad
    elseif mode == 2 then
        calcFunc = calc.EaseOutQuad
    elseif mode == 3 then
        calcFunc = calc.EaseInOutQuad
    else
        calcFunc = calc.Linear
    end
    for s in calc.Iterator(0, 1, t, false, true, calcFunc) do
        self.x = xs + s * dx
        self.y = ys + s * dy
        yield()
    end
end

---移动指定距离
---@param x number @目标移动x坐标
---@param y number @目标移动y坐标
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:MoveToEx(x, y, t, mode)
    t = max(1, int(t))
    local dx = x
    local dy = y
    local slast = 0
    local calcFunc
    if mode == 1 then
        calcFunc = calc.EaseInQuad
    elseif mode == 2 then
        calcFunc = calc.EaseOutQuad
    elseif mode == 3 then
        calcFunc = calc.EaseInOutQuad
    else
        calcFunc = calc.Linear
    end
    for s in calc.Iterator(0, 1, t, false, true, calcFunc) do
        s, slast = (s - slast), s
        self.x = self.x + s * dx
        self.y = self.y + s * dy
        yield()
    end
end

---贝塞尔曲线
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:BezierMoveTo(t, mode, ...)
    local arg = { ... }
    t = max(1, int(t))
    local count = #arg / 2
    local x, y = { self.x }, { self.y }
    for i = 1, count do
        insert(x, arg[i * 2 - 1])
        insert(y, arg[i * 2])
    end
    local com_num = {}
    for i = 0, count do
        insert(com_num, CombinNum(i, count))
    end
    local calcFunc
    if mode == 1 then
        calcFunc = calc.EaseInQuad
    elseif mode == 2 then
        calcFunc = calc.EaseOutQuad
    elseif mode == 3 then
        calcFunc = calc.EaseInOutQuad
    else
        calcFunc = calc.Linear
    end
    for s in calc.Iterator(0, 1, t, false, true, calcFunc) do
        local _x, _y = 0, 0
        for j = 0, count do
            _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
            _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
        end
        self.x, self.y = _x, _y
        yield()
    end
end

---增量版本贝塞尔曲线
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:BezierMoveToEx(t, mode, ...)
    local arg = { ... }
    t = max(1, int(t))
    local count = #arg / 2
    local last_x = 0;
    local last_y = 0;
    local x, y = { 0 }, { 0 }
    t = int(t)
    t = max(1, t)
    for i = 1, count do
        insert(x, arg[i * 2 - 1])
        insert(y, arg[i * 2])
    end
    local com_num = {}
    for i = 0, count do
        insert(com_num, CombinNum(i, count))
    end
    local calcFunc
    if mode == 1 then
        calcFunc = calc.EaseInQuad
    elseif mode == 2 then
        calcFunc = calc.EaseOutQuad
    elseif mode == 3 then
        calcFunc = calc.EaseInOutQuad
    else
        calcFunc = calc.Linear
    end
    for s in calc.Iterator(0, 1, t, false, true, calcFunc) do
        local _x, _y = 0, 0
        for j = 0, count do
            _x = _x + x[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
            _y = _y + y[j + 1] * com_num[j + 1] * (1 - s) ^ (count - j) * s ^ j
        end
        self.x, self.y = self.x + _x - last_x, self.y + _y - last_y
        last_x, last_y = _x, _y
        yield()
    end
end

---埃尔金样条
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:CRMoveTo(t, mode, ...)
    local arg = { ... }
    t = max(1, int(t))
    local count = #arg / 2
    local x, y = { self.x }, { self.y }
    for i = 1, count do
        insert(x, arg[i * 2 - 1])
        insert(y, arg[i * 2])
    end
    insert(x, 2 * x[#x] - x[#x - 1])
    insert(x, 1, 2 * x[1] - x[2])
    insert(y, 2 * y[#y] - y[#y - 1])
    insert(y, 1, 2 * y[1] - y[2])
    local timeMark = {}
    if mode == 1 then
        for i = 1, t do
            timeMark[i] = count * (i / t) * (i / t)
        end
    elseif mode == 2 then
        for i = 1, t do
            timeMark[i] = count * ((i / t) * 2 - (i / t) * (i / t))
        end
    elseif mode == 3 then
        for i = 1, t do
            if i / t < 0.5 then
                timeMark[i] = count * (i / t) * (i / t) * 2
            else
                timeMark[i] = count * (-2 * (i / t) * (i / t) + 4 * (i / t) - 1)
            end
        end
    else
        for i = 1, t do
            timeMark[i] = count * (i / t)
        end
    end
    for i = 1, t - 1 do
        local s = int(timeMark[i]) + 1
        local j = timeMark[i] % 1
        local j2, j3 = j ^ 2, j ^ 3
        local _x = x[s] * (-0.5 * j3 + j2 - 0.5 * j)
                + x[s + 1] * (1.5 * j3 - 2.5 * j2 + 1.0)
                + x[s + 2] * (-1.5 * j3 + 2.0 * j2 + 0.5 * j)
                + x[s + 3] * (0.5 * j3 - 0.5 * j2)
        local _y = y[s] * (-0.5 * j3 + j2 - 0.5 * j)
                + y[s + 1] * (1.5 * j3 - 2.5 * j2 + 1.0)
                + y[s + 2] * (-1.5 * j3 + 2.0 * j2 + 0.5 * j)
                + y[s + 3] * (0.5 * j3 - 0.5 * j2)
        self.x = _x
        self.y = _y
        yield()
    end
    self.x, self.y = x[count + 2], y[count + 2]
    yield()
end

---增量版本埃尔金样条
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:CRMoveToEx(t, mode, ...)
    local arg = { ... }
    t = max(1, int(t))
    local count = #arg / 2
    local last_x = 0;
    local last_y = 0;
    local x, y = { 0 }, { 0 }
    for i = 1, count do
        insert(x, arg[i * 2 - 1])
        insert(y, arg[i * 2])
    end
    insert(x, 2 * x[#x] - x[#x - 1])
    insert(x, 1, 2 * x[1] - x[2])
    insert(y, 2 * y[#y] - y[#y - 1])
    insert(y, 1, 2 * y[1] - y[2])
    local timeMark = {}
    if mode == 1 then
        for i = 1, t do
            timeMark[i] = count * (i / t) * (i / t)
        end
    elseif mode == 2 then
        for i = 1, t do
            timeMark[i] = count * ((i / t) * 2 - (i / t) * (i / t))
        end
    elseif mode == 3 then
        for i = 1, t do
            if i / t < 0.5 then
                timeMark[i] = count * (i / t) * (i / t) * 2
            else
                timeMark[i] = count * (-2 * (i / t) * (i / t) + 4 * (i / t) - 1)
            end
        end
    else
        for i = 1, t do
            timeMark[i] = count * (i / t)
        end
    end
    for i = 1, t - 1 do
        local s = int(timeMark[i]) + 1
        local j = timeMark[i] % 1
        local j2, j3 = j ^ 2, j ^ 3
        local _x = x[s] * (-0.5 * j3 + j2 - 0.5 * j)
                + x[s + 1] * (1.5 * j3 - 2.5 * j2 + 1.0)
                + x[s + 2] * (-1.5 * j3 + 2.0 * j2 + 0.5 * j)
                + x[s + 3] * (0.5 * j3 - 0.5 * j2)
        local _y = y[s] * (-0.5 * j3 + j2 - 0.5 * j)
                + y[s + 1] * (1.5 * j3 - 2.5 * j2 + 1.0)
                + y[s + 2] * (-1.5 * j3 + 2.0 * j2 + 0.5 * j)
                + y[s + 3] * (0.5 * j3 - 0.5 * j2)
        self.x = self.x + _x - last_x
        self.y = self.y + _y - last_y
        last_x = _x
        last_y = _y
        yield()
    end
    self.x = self.x + x[count + 2] - last_x
    self.y = self.y + y[count + 2] - last_y
    yield()
end

---二次B样条,过采样点间的中点，为二次曲线
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:Basis2MoveTo(t, mode, ...)
    local arg = { ... }
    t = max(1, int(t))
    local count = #arg / 2
    local x, y = { self.x }, { self.y }
    for i = 1, count do
        insert(x, arg[i * 2 - 1])
        insert(y, arg[i * 2])
    end
    --检查采样点数量，如果不足3个，则插值到3个
    if count < 2 then
        --只有两个采样点时，取中点插值
        insert(x, 2, (x[1] + x[2]) / 2)
        insert(y, 2, (y[1] + y[2]) / 2)
    elseif count < 1 then
        --只有一个采样点时，只能这样了
        for _ = 1, 2 do
            insert(x, x[1])
            insert(y, y[1])
        end
    end
    count = max(2, count)
    --储存末点，给末尾使用
    local fx, fy = x[#x], y[#y]
    --对首末采样点特化处理
    do
        --首点处理
        x[1] = x[2] + 2 * (x[1] - x[2])
        y[1] = y[2] + 2 * (y[1] - y[2])
        --末点处理
        x[count + 1] = x[count] + 2 * (x[count + 1] - x[count])
        y[count + 1] = y[count] + 2 * (y[count + 1] - y[count])
        --插入尾数据解决越界报错
        x[count + 2] = x[count + 1]
        y[count + 2] = y[count + 1]
    end
    --准备采样方式函数
    local calcFunc
    if mode == 1 then
        calcFunc = calc.EaseInQuad
    elseif mode == 2 then
        calcFunc = calc.EaseOutQuad
    elseif mode == 3 then
        calcFunc = calc.EaseInOutQuad
    else
        calcFunc = calc.Linear
    end
    --开始运动
    for i = 1 / t, 1 + 0.5 / t, 1 / t do
        local j = (count - 1) * calcFunc(i)--采样方式
        local se = int(j) + 1        --3采样选择
        local ct = j - int(j)        --切换
        local _x = 0
                + x[se] * (0.5 * (ct - 1) ^ 2) --基函数1
                + x[se + 1] * (0.5 * (-2 * ct ^ 2 + 2 * ct + 1)) --基函数2
                + x[se + 2] * (0.5 * ct ^ 2)              --基函数3
        local _y = 0
                + y[se] * (0.5 * (ct - 1) ^ 2) --基函数1
                + y[se + 1] * (0.5 * (-2 * ct ^ 2 + 2 * ct + 1)) --基函数2
                + y[se + 2] * (0.5 * ct ^ 2)              --基函数3
        self.x, self.y = _x, _y
        yield()
    end
    --末尾处理，解决曲线采样带来的误差
    self.x, self.y = fx, fy
    --待改善：采样方式。希望以后采样能更加精确
end

---增量版本二次B样条,过采样点间的中点，为二次曲线
---@param t number @移动时长
---@param mode number @速度变化方式
function lib:Basis2MoveToEX(t, mode, ...)
    local arg = { ... }
    t = max(1, int(t))
    local last_x, last_y = 0, 0
    local count = #arg / 2
    local x, y = { 0 }, { 0 }
    for i = 1, count do
        insert(x, arg[i * 2 - 1])
        insert(y, arg[i * 2])
    end
    --检查采样点数量，如果不足3个，则插值到3个
    if count < 2 then
        --只有两个采样点时，取中点插值
        insert(x, 2, (x[1] + x[2]) / 2)
        insert(y, 2, (y[1] + y[2]) / 2)
    elseif count < 1 then
        --只有一个采样点时，只能这样了
        for _ = 1, 2 do
            insert(x, x[1])
            insert(y, y[1])
        end
    end
    count = max(2, count)
    --储存末点，给末尾使用
    local fx, fy = x[#x], y[#y]
    --对首末采样点特化处理
    do
        --首点处理
        x[1] = x[2] + 2 * (x[1] - x[2])
        y[1] = y[2] + 2 * (y[1] - y[2])
        --末点处理
        x[count + 1] = x[count] + 2 * (x[count + 1] - x[count])
        y[count + 1] = y[count] + 2 * (y[count + 1] - y[count])
        --插入尾数据解决越界报错
        x[count + 2] = x[count + 1]
        y[count + 2] = y[count + 1]
    end
    --准备采样方式函数
    local calcFunc
    if mode == 1 then
        calcFunc = calc.EaseInQuad
    elseif mode == 2 then
        calcFunc = calc.EaseOutQuad
    elseif mode == 3 then
        calcFunc = calc.EaseInOutQuad
    else
        calcFunc = calc.Linear
    end
    --开始运动
    for i = 1 / t, 1, 1 / t do
        local j = (count - 1) * calcFunc(i)--采样方式
        local se = int(j) + 1        --3采样选择
        local ct = j - int(j)        --切换
        local _x = 0
                + x[se] * (0.5 * (ct - 1) ^ 2) --基函数1
                + x[se + 1] * (0.5 * (-2 * ct ^ 2 + 2 * ct + 1)) --基函数2
                + x[se + 2] * (0.5 * ct ^ 2)              --基函数3
        local _y = 0
                + y[se] * (0.5 * (ct - 1) ^ 2) --基函数1
                + y[se + 1] * (0.5 * (-2 * ct ^ 2 + 2 * ct + 1)) --基函数2
                + y[se + 2] * (0.5 * ct ^ 2)              --基函数3
        self.x = self.x + _x - last_x
        self.y = self.y + _y - last_y
        last_x = _x
        last_y = _y
        yield()
    end
    --末尾处理，解决曲线采样带来的误差
    self.x = self.x + fx - last_x
    self.y = self.y + fy - last_y
    --待改善：采样方式。希望以后采样能更加精确
end

return lib