local assert = assert
local type = type
local floor = math.floor

---最大玩家数
local maxPlayer = 4

---玩家队列
local playerSlot = std.list()

---@class lstg.Player.Controller
local lib = {}
lstg.PlayerController = lib

---获取最大玩家数
---@return number
function lib:GetMaxPlayer()
    return maxPlayer
end

---设置最大玩家数
---@param n number
function lib:SetMaxPlayer(n)
    maxPlayer = n
end

---绑定玩家对象
---@param obj object
---@param slot number
---@overload fun(obj:object)
function lib:BindPlayerObject(obj, slot)
    slot = floor(slot or 1)
    assert(type(slot) == "number" and slot > 0 and slot <= maxPlayer)
    ---@class lstg.Player
    local player = {
        slot = slot,
        object = obj
    }
    playerSlot:remove_if(function(v)
        return v.slot == slot
    end)
    playerSlot:insert_if(player, function(v1, v2)
        if v1 == nil and v2 == nil then
            return true
        elseif v1 == nil then
            return slot < v2.slot
        elseif v2 == nil then
            return slot >= v1.slot
        else
            return slot >= v1.slot and slot < v2.slot
        end
    end)
end

---重置玩家对象列表
function lib:ResetPlayerSlot()
    playerSlot = {}
end

---获取玩家对象
---@param slot number
---@return object
---@overload fun():object
function lib:GetPlayerObject(slot)
    slot = floor(slot or 1)
    assert(type(slot) == "number" and slot > 0 and slot <= maxPlayer)
    return playerSlot[slot]
end

---获取玩家数量
---@return number
function lib:GetPlayerCount()
    return playerSlot:size()
end

return lib