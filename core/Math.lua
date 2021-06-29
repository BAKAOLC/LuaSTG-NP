---=====================================
---luastg math
---=====================================

local error = error

local i18n = require("util.Internationalization")

int = math.floor
abs = math.abs
max = math.max
min = math.min
rnd = math.random
sqrt = math.sqrt
local int = int
local abs = abs
local sqrt = sqrt

---获得数字的符号(1/-1/0)
---@param x number
---@return number
function sign(x)
    return x == 0 and 0 or x > 0 and 1 or -1
end

---获得数字的余
---@param a number
---@param b number
---@return number
math.mod = math.mod or math.fmod or function(a, b)
    return a >= 0 and a % abs(b) or -abs(b) + a % abs(b)
end
mod = math.mod

---获得(x,y)向量的模长
---@param x number
---@param y number
---@return number
function hypot(x, y)
    return sqrt(x * x + y * y)
end

local fac = {}
---阶乘，目前用于组合数和贝塞尔曲线
---@param num number
---@return number
function Factorial(num)
    if num < 0 then
        error(i18n:GetLanguageString("Core.Math.Factorial.Error.Minus"))
    end
    if num < 2 then
        return 1
    end
    num = int(num)
    if fac[num] then
        return fac[num]
    end
    local result = 1
    for i = 1, num do
        if fac[i] then
            result = fac[i]
        else
            result = result * i
            fac[i] = result
        end
    end
    return result
end
local Factorial = Factorial

---组合数，目前用于贝塞尔曲线
---@return number
function CombinNum(ord, sum)
    if sum < 0 or ord < 0 then
        error(i18n:GetLanguageString("Core.Math.CombinNum.Error.Minus"))
    end
    ord, sum = int(ord), int(sum)
    return Factorial(sum) / (Factorial(ord) * Factorial(sum - ord))
end

--region 随机数
----------------------------------------
---随机数系统，用于支持replay系统
do
    ---@class lstg.Random
    local M = {}
    ran = M

    local ranx = Rand()

    ---随机整数
    ---@param a number
    ---@param b number
    ---@return number @a~b之间的随机整数
    function M:Int(a, b)
        return a > b and ranx:Int(b, a) or ranx:Int(a, b)
    end

    ---随机浮点数
    ---@param a number
    ---@param b number
    ---@return number @a~b之间的随机浮点数
    function M:Float(a, b)
        return ranx:Float(a, b)
    end

    ---随机正负
    ---@return number @随机1或-1
    function M:Sign()
        return ranx:Sign()
    end

    local _min = math.min
    local _max = math.max
    local _abs = math.abs
    local _sign = sign
    ---随机坐标
    ---@param baseX number @基础X坐标
    ---@param baseY number @基础Y坐标
    ---@param minX number @常规X最小范围
    ---@param maxX number @常规X最大范围
    ---@param minY number @常规Y最小范围
    ---@param maxY number @常规Y最大范围
    ---@param minDx number @X最小移动范围
    ---@param maxDx number @X最大移动范围
    ---@param minDy number @Y最小移动范围
    ---@param maxDy number @Y最大移动范围
    ---@param followX number @X跟随目标
    ---@param followY number @Y跟随目标
    ---@param bound boolean @是否强制限制坐标边界范围
    ---@return number, number
    function M:Position(baseX, baseY, minX, maxX, minY, maxY, minDx, maxDx, minDy, maxDy, followX, followY, bound)
        minX, maxX = _min(minX, maxX), _max(minX, maxX)
        minY, maxY = _min(minY, maxY), _max(minY, maxY)
        minDx, maxDx = _min(minDx, maxDx), _max(minDx, maxDx)
        minDy, maxDy = _min(minDy, maxDy), _max(minDy, maxDy)
        local dx, dy = self:Float(minDx, maxDx), self:Float(minDy, maxDy)
        local dirX, dirY = 0, 0
        if baseX < minX then
            dirX = dirX + 1
        end
        if baseX > maxX then
            dirX = dirX - 1
        end
        if baseX - dx < minX then
            dirX = dirX + 1
        end
        if baseX + dx > maxX then
            dirX = dirX - 1
        end
        if (followX and baseX < followX) then
            dirX = dirX + 1
        end
        if (followX and baseX > followX) then
            dirX = dirX - 1
        end
        if dirX == 0 then
            dirX = self:Sign()
        else
            dirX = _sign(dirX)
        end
        if baseY < minY then
            dirY = dirY + 1
        end
        if baseY > maxY then
            dirY = dirY - 1
        end
        if baseY - dy < minY then
            dirY = dirY + 1
        end
        if baseY + dy > maxY then
            dirY = dirY - 1
        end
        if (followY and baseY < followY) then
            dirY = dirY + 1
        end
        if (followY and baseY > followY) then
            dirY = dirY - 1
        end
        if dirY == 0 then
            dirY = self:Sign()
        else
            dirY = _sign(dirY)
        end
        if bound then
            dx = _min(dx, _abs(_min(maxX, _max(minX, baseX + dirX * dx)) - baseX))
            dy = _min(dy, _abs(_min(maxY, _max(minY, baseY + dirY * dy)) - baseY))
        end
        return baseX + dirX * dx, baseY + dirY * dy
    end

    ---设置随机数种子
    ---@param seed number
    function M:Seed(seed)
        return ranx:Seed(seed)
    end

    ---获取随机数种子
    ---@return number
    function M:GetSeed()
        return ranx:GetSeed()
    end
end
--endregion