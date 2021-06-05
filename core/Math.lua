---=====================================
---luastg math
---=====================================

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
        error("Can't get factorial of a minus number.")
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

---组合数，目前用于贝塞尔曲线
---@return number
function CombinNum(ord, sum)
    if sum < 0 or ord < 0 then
        error("Can't get combinatorial of minus numbers.")
    end
    ord = int(ord)
    sum = int(sum)
    return Factorial(sum) / (Factorial(ord) * Factorial(sum - ord))
end

----------------------------------------
---随机数系统，用于支持replay系统
do
    ---@class lstg.Random
    local lib = {}
    ran = lib

    local ranx = Rand()

    ---随机整数
    ---@param a number
    ---@param b number
    ---@return number @a~b之间的随机整数
    function lib:Int(a, b)
        return a > b and ranx:Int(b, a) or ranx:Int(a, b)
    end

    ---随机浮点数
    ---@param a number
    ---@param b number
    ---@return number @a~b之间的随机浮点数
    function lib:Float(a, b)
        return ranx:Float(a, b)
    end

    ---随机正负
    ---@return number @随机1或-1
    function lib:Sign()
        return ranx:Sign()
    end

    ---设置随机数种子
    ---@param seed number
    function lib:Seed(seed)
        return ranx:Seed(seed)
    end

    ---获取随机数种子
    ---@return number
    function lib:GetSeed()
        return ranx:GetSeed()
    end
end