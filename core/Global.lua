--region 储存变量
---@class lstg.Var.Storage
local storageVar = {}

---设置储存变量
---@param k string
---@param v any
local function setGlobal(k, v)
    storageVar[k] = v
end
lstg.SetGlobal = setGlobal

---读取储存变量
---@param k string
---@return any
local function getGlobal(k)
    return storageVar[k]
end
lstg.GetGlobal = getGlobal

SetGlobal = lstg.SetGlobal
GetGlobal = lstg.GetGlobal
--endregion

--region 临时变量
---@class lstg.Var.Temporary
local tempVar = {}

---设置临时变量
---@param k string
---@param v any
local function setTempVar(k, v)
    tempVar[k] = v
end
lstg.SetTempVar = setTempVar

---读取临时变量
---@param k string
---@return any
local function getTempVar(k)
    return tempVar[k]
end
lstg.GetTempVar = getTempVar

---重置临时变量
local function resetTempVar()
    tempVar = {}
end
lstg.ResetTempVar = resetTempVar

SetTempVar = lstg.SetTempVar
GetTempVar = lstg.GetTempVar
ResetTempVar = lstg.ResetTempVar
--endregion