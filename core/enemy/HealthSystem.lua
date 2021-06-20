local assert = assert
local error = error
local insert = table.insert
local max = math.max

local IsValid = IsValid
local kill = lstg.Kill

local i18n = require("util.Internationalization")

---默认伤害计算式
---@param dmg number
---@return number
local defaultIncomingDamageFunc = function(dmg)
    return dmg
end

---@type table<number|object, enemyHealthData>
local enemyList = {}

---@class lstg.Enemy.HealthSystem
local lib = {}
lstg.HealthSystem = lib

---默认血量
lib.DefaultHealth = 100

---帧逻辑更新
function lib:frame()
end

---注册血量对象
---@param obj object
---@param maxhp number
---@param hp number
---@overload fun(obj:object, maxhp:number)
---@overload fun(obj:object)
function lib:RegisterEnemy(obj, maxhp, hp)
    maxhp = maxhp or self.DefaultHealth
    hp = hp or maxhp
    ---@class enemyHealthData
    local data = { obj, maxhp, hp, 0, defaultIncomingDamageFunc }
    enemyList[obj] = data
end

---获取对象最大血量
---@param obj object
---@return number
function lib:GetEnemyMaxHealth(obj)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    return enemyList[obj][2]
end

---获取对象血量
---@param obj object
---@return number
function lib:GetEnemyHealth(obj)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    return enemyList[obj][3]
end

---设置对象最大血量
---@param obj object
---@param maxhp number
function lib:SetEnemyMaxHealth(obj, maxhp)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    assert(maxhp > 0, i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidMaxHealth"))
    enemyList[obj][2] = maxhp
end

---设置对象血量
---@param obj object
---@param hp number
function lib:SetEnemyHealth(obj, hp)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    assert(hp > 0, i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.MinusHealth"))
    enemyList[obj][3] = hp
end

---设置对象受击伤害计算式
---@param obj object
---@param func function
function lib:SetEnemyIncomingDamageFunc(obj, func)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    enemyList[obj][5] = func
end

---添加对象受击伤害
---@param obj object
---@param dmg number
function lib:AddEnemyIncomingDamage(obj, dmg)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    enemyList[obj][4] = enemyList[obj][4] + dmg
end

---获取对象受击伤害
---@param obj object
---@return number
function lib:GetEnemyIncomingDamage(obj)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    return enemyList[obj][5](enemyList[obj][4])
end

---获取对象原始受击伤害
---@param obj object
---@return number
function lib:GetEnemyOriginalIncomingDamage(obj)
    assert(enemyList[obj] and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    return enemyList[obj][4]
end

---应用血量并进行血量检查
---@param obj object
function lib:ApplyEnemyHealth(obj)
    local data = enemyList[obj]
    assert(data and IsValid(obj), i18n:GetLanguageString("Core.Enemy.HealthSystem.Error.InvalidObject"))
    local dmg = self:GetEnemyIncomingDamage(obj)
    data[3] = max(0, data[3] - dmg)
    if data[3] == 0 then
        kill(data[1])
    end
end

---应用血量并进行血量检查
---@param data enemyHealthData
function lib:ApplyHealth(data)
    self:ApplyEnemyHealth(data[1])
end

function lib:DeregisterEnemy(obj)
end

---重置对象列表
function lib:ResetList()
    enemyList = {}
end

return lib
