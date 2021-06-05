local type = type
local GetKeyState = GetKeyState
local BuildKeyMap = Setting.Control.BuildKeyMap
local BuildSystemKeyMap = Setting.Control.BuildSystemKeyMap

---@class lstg.Input
local lib = {}
Input = lib
lstg.Input = lib

---@class lstg.Input.GameInput.State
local gameKeyState = {}

---@class lstg.Input.GameInput.State.Pre
local gameKeyStatePre = {}

---@class lstg.Input.SystemInput.State
local systemKeyState = {}

---@class lstg.Input.SystemInput.State.Pre
local systemKeyStatePre = {}

---@type table<string, number|table<number, number>>
local gameKeyMap = {}

---@type table<string, number|table<number, number>>
local systemKeyMap = {}

---刷新游戏输入键值表
local function refreshGameInputKeyMap()
    gameKeyMap = BuildKeyMap()
    gameKeyStatePre = {}
    gameKeyState = {}
end
lib.RefreshGameInputKeyMap = refreshGameInputKeyMap

---刷新游戏输入键值表
local function refreshSystemInputKeyMap()
    systemKeyMap = BuildSystemKeyMap()
    systemKeyStatePre = {}
    systemKeyState = {}
end
lib.RefreshSystemInputKeyMap = refreshSystemInputKeyMap

---更新游戏input输入
local function updateGameInput()
    for key, data in pairs(gameKeyMap) do
        gameKeyStatePre[key] = gameKeyState[key]
        local flag = false
        for _, code in ipairs(data) do
            if (GetKeyState(code)) then
                flag = true
                break
            end
        end
        gameKeyState[key] = flag
    end
end
lib.UpdateGameInput = updateGameInput

---更新系统input输入
local function updateSystemInput()
    for key, data in pairs(systemKeyMap) do
        systemKeyStatePre[key] = systemKeyState[key]
        local flag = false
        for _, code in ipairs(data) do
            if (GetKeyState(code)) then
                flag = true
                break
            end
        end
        systemKeyState[key] = flag
    end
end
lib.UpdateSystemInput = updateSystemInput

---获取游戏按键是否按下
---@param key string @键名
---@return boolean
local function gameKeyIsDown(key)
    return gameKeyState[key]
end
lib.GameKeyIsDown = gameKeyIsDown

---获取游戏按键是否按下
---@param key string @键名
---@return boolean
local function gameKeyIsPressed(key)
    return gameKeyState[key] and not (gameKeyStatePre[key])
end
lib.GameKeyIsPressed = gameKeyIsPressed

---获取游戏按键是否按下
---@param key string @键名
---@return boolean
local function systemKeyIsDown(key)
    return systemKeyState[key]
end
lib.SystemKeyIsDown = systemKeyIsDown

---获取游戏按键是否按下
---@param key string @键名
---@return boolean
local function systemKeyIsPressed(key)
    return systemKeyState[key] and not (systemKeyStatePre[key])
end
lib.SystemKeyIsPressed = systemKeyIsPressed