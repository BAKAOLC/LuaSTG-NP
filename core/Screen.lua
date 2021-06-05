local min = min
local getResWidth = Setting.Graphics.GetResolutionWidth
local getResHeight = Setting.Graphics.GetResolutionHeight

---@class lstg.Screen
local lib = {}
Screen = lib
lstg.Screen = lib

---屏幕宽度
local screenWidth = 640
---屏幕高度
local screenHeight = 480
---分辨率宽度
local resWidth = screenWidth
---分辨率高度
local resHeight = screenHeight
---屏幕宽度缩放比
local screenWidthScale = 1
---屏幕高度缩放比
local screenHeightScale = 1
---屏幕缩放比
local screenScale = min(screenWidthScale, screenHeightScale)
---屏幕偏移x
local screenDx = 0
---屏幕偏移y
local screenDy = 0
---3d缩放比
local scale3d = 0.007 * screenScale
lstg.scale_3d = scale3d

---设置屏幕宽度
---@param width number
local function setWidth(width)
    screenWidth = width
end
lib.SetWidth = setWidth

---获取屏幕宽度
---@return number
local function getWidth()
    return screenWidth
end
lib.GetWidth = getWidth

---设置屏幕高度
---@param height number
local function setHeight(height)
    screenHeight = height
end
lib.SetHeight = setHeight

---获取屏幕高度
---@return number
local function getHeight()
    return screenHeight
end
lib.GetHeight = getHeight

---设置屏幕宽缩放比
---@param ws number
local function setWidthScale(ws)
    screenWidthScale = ws
end
lib.SetWidthScale = setWidthScale

---获取屏幕宽缩放比
---@return number
local function getWidthScale()
    return screenWidthScale
end
lib.GetWidthScale = getWidthScale

---设置屏幕高缩放比
---@param hs number
local function setHeightScale(hs)
    screenHeightScale = hs
end
lib.SetHeightScale = setHeightScale

---获取屏幕高缩放比
---@return number
local function getHeightScale()
    return screenHeightScale
end
lib.GetHeightScale = getHeightScale

---获取屏幕缩放比
---@return number
local function getScale()
    return screenScale
end
lib.GetScale = getScale

---设置屏幕偏移x
---@param dx number
local function setDx(dx)
    screenDx = dx
end
lib.SetDx = setDx

---获取屏幕偏移x
---@return number
local function getDx()
    return screenDx
end
lib.GetDx = getDx

---设置屏幕偏移y
---@param dy number
local function setDy(dy)
    screenDx = dy
end
lib.SetDy = setDy

---获取屏幕偏移y
---@return number
local function getDy()
    return screenDy
end
lib.GetDy = getDy

---刷新并应用Screen参数
local function ResetScreen()
    resWidth = getResWidth()
    resHeight = getResHeight()
    screenWidthScale = resWidth / screenWidth
    screenHeightScale = resHeight / screenHeight
    local resScale = resWidth / resHeight
    screenScale = min(screenWidthScale, screenHeightScale)
    if resScale >= (screenWidth / screenHeight) then
        screenDx = (resWidth - screenScale * screenWidth) * 0.5
        screenDy = 0
    else
        screenDx = 0
        screenDy = (resHeight - screenScale * screenHeight) * 0.5
    end
    scale3d = 0.007 * screenScale
    lstg.scale_3d = scale3d
end
lib.ResetScreen = ResetScreen