local pairs = pairs

local IsValid = IsValid

---默认值
local defaultValue = {
    ---X坐标
    x = 0,
    ---Y坐标
    y = -176,
    ---旋转角度
    rot = 0,
    ---判定大小（宽度）
    a = 0,
    ---判定大小（高度）
    b = 0,
    ---正在锁定状态中
    lock = false,
    ---系统设置用(不建议随意操作)
    forceLock = false,
    ---判定线高度
    collectLine = 96,
    ---高速移动速度
    hSpeed = 4,
    ---低速移动速度
    lSpeed = 2,
    ---正在低速移动中(不建议随意操作)
    slow = false,
    ---低速过渡值
    slowT = 0,
    ---正在射击中(不建议随意操作)
    fire = false,
    ---射击过渡值
    fireT = 0,
    ---是否处于被弹状态(不建议随意操作)
    miss = false,
    ---决死剩余时间
    deathSpellRemainT = 0,
    ---决死总时间
    deathSpellTotalT = 10,
    ---是否处于死亡状态(不建议随意操作)
    death = false,
    ---死亡计时器(不建议随意操作)
    deathT = 0,
    ---是否允许移动
    enableMove = true,
    ---系统设置用(不建议随意操作)
    forceEnableMove = false,
    ---是否允许射击
    enableShoot = true,
    ---下一次射击等待时间
    nextShoot = 0,
    ---系统设置用(不建议随意操作)
    forceEnableShoot = false,
    ---是否允许释放符卡
    enableSpell = true,
    ---下一次释放符卡等待时间
    nextSpell = 0,
    ---系统设置用(不建议随意操作)
    forceEnableSpell = false,
    ---是否处于保护状态(不会根据倒计时自动切换)
    protect = false,
    ---保护时间倒计时
    protectT = 0,
    ---系统设置用(不建议随意操作)
    forceProtect = false,
    ---火力数值
    power = 100,
    ---最低火力数值
    minPower = 100,
    ---最大火力数值
    maxPower = 400,
    ---是否锁定火力数值
    lockPower = false,
    ---系统设置用(不建议随意操作)
    forceLockPower = false,
    ---死亡跌落火力数值
    deathLosePower = 50,
}

---@class lstg.Player.System : plus.Class
---@return lstg.Player.System
local sys = plus.Class()
lstg.PlayerSystem = sys

function sys:init(default)
    self.defaultValue = default or defaultValue
    self:ResetDefaultValue()
end

function sys:ResetDefaultValue()
    for k, v in pairs(defaultValue) do
        self[k] = self.defaultValue[k] or v
    end
end

function sys:UpdateObjectAllValue()
    local obj = self.obj
    if IsValid(obj) then
        obj.x = self.x
        obj.y = self.y
        obj.rot = self.rot
    end
end

---绑定玩家对象
---@param obj object
function sys:BindObject(obj)
    self.obj = obj
end

---更新对象值为自身值
function sys:UpdateObjectValue(key)
    if IsValid(self.obj) then
        self.obj[key] = self[key]
    end
end

---设置玩家X坐标
---@param x number
function sys:SetPositionX(x)
    self.x = x
    self:UpdateObjectValue("x")
end

---设置玩家Y坐标
---@param y number
function sys:SetPositionY(y)
    self.y = y
    self:UpdateObjectValue("y")
end

---设置玩家坐标
---@param x number
---@param y number
function sys:SetPosition(x, y)
    self:SetXPosition(x)
    self:SetYPosition(y)
end

---设置玩家旋转角度
---@param rot number
function sys:SetRotation(rot)
    self.rot = rot
    self:UpdateObjectValue("y")
end

function sys:ResetInput()

end

return sys