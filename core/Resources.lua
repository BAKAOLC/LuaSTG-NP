local error = error
local ipairs = ipairs
local insert = table.insert
local select = select
local unpack = table.unpack or unpack

local _loadTexture = lstg.LoadTexture
local _getTextureSize = lstg.GetTextureSize
local _loadAnimation = lstg.LoadAnimation
local setResourceStatus = SetResourceStatus
local _loadTTF = lstg.LoadTTF
local _checkRes = lstg.CheckRes
local _enumRes = lstg.EnumRes
local attributes = lfs.attributes

local int = int

do
    local _status = "global"
    function SetResourceStatus(status)
        setResourceStatus(status)
        _status = status
    end
    function GetResourceStatus()
        return _status
    end
end

local SetResourceStatus = SetResourceStatus
local GetResourceStatus = GetResourceStatus

---@class lstg.Resources
local lib = {}
Resources = lib
lstg.Resources = lib

--region 基础资源系统
local imageList = {}
local imageSize = {}
local _loadImage = LoadImage

local function loadImage(img, ...)
    local arg = { ... }
    imageList[img] = arg
    imageSize[img] = { arg[4], arg[5] }
    _loadImage(img, ...)
end
LoadImage = loadImage

local function getImageScale(img)
    return unpack(imageSize[img])
end
GetImageScale = getImageScale

local function copyImage(newname, img)
    if imageList[img] then
        loadImage(newname, unpack(imageList[img]))
    elseif img then
        error(("The image %q can't be copied."):format(img))
    else
        error("Wrong argument #2 (expect string get nil)")
    end
end
CopyImage = copyImage

local function loadImageGroup(prefix, texname, x, y, w, h, cols, rows, a, b, rect)
    for i = 0, cols * rows - 1 do
        loadImage(prefix .. (i + 1), texname, x + w * (i % cols), y + h * (int(i / cols)), w, h, a or 0, b or 0, rect or false)
    end
end
LoadImageGroup = loadImageGroup

local function loadImageFromFile(teximgname, filename, mipmap, a, b, rect)
    _loadTexture(teximgname, filename, mipmap)
    local w, h = _getTextureSize(teximgname)
    loadImage(teximgname, teximgname, 0, 0, w, h, a or 0, b or 0, rect)
end
LoadImageFromFile = loadImageFromFile

local function loadAniFromFile(texaniname, filename, mipmap, n, m, intv, a, b, rect)
    _loadTexture(texaniname, filename, mipmap)
    local w, h = _getTextureSize(texaniname)
    _loadAnimation(texaniname, texaniname, 0, 0, w / n, h / m, n, m, intv, a, b, rect)
end
LoadAnimation = loadAniFromFile

local function loadImageGroupFromFile(texaniname, filename, mipmap, n, m, a, b, rect)
    _loadTexture(texaniname, filename, mipmap)
    local w, h = _getTextureSize(texaniname)
    loadImageGroup(texaniname, texaniname, 0, 0, w / n, h / m, n, m, a, b, rect)
end
LoadImageGroupFromFile = loadImageGroupFromFile

local function loadTTF(ttfname, filename, size)
    _loadTTF(ttfname, filename, 0, size)
end
LoadTTF = loadTTF

----------------------------------------
---资源判断和枚举

local ENUM_RES_TYPE = { tex = 1, img = 2, ani = 3, bgm = 4, snd = 5, psi = 6, fnt = 7, ttf = 8, fx = 9 }

local function checkRes(typename, resname)
    local t = ENUM_RES_TYPE[typename]
    if t == nil then
        error("Invalid resource type name.")
    else
        return _checkRes(t, resname)
    end
end
CheckRes = checkRes

local function enumRes(typename)
    local t = ENUM_RES_TYPE[typename]
    if t == nil then
        error("Invalid resource type name.")
    else
        return _enumRes(t)
    end
end
EnumRes = enumRes

---检查文件是否存在
---@param filename string
---@return boolean
function lib.FileExist(filename)
    return not (attributes(filename) == nil)
end
--endregion

--region 资源加载列表
local resList = {}

---定义新的资源列表
---@param name string @资源列表名称
local function newResourcesList(name)
    resList[name] = {}
end
lib.NewResourcesList = newResourcesList

---添加新的资源到指定资源列表中
---@param name string @资源列表名称
---@param func function @要执行的函数
---@vararg any @参数
local function addResources(name, func, ...)
    insert(resList[name], { func, select("#", ...), ... })
end
lib.AddResources = addResources

---加载资源列表
---@param name string @资源列表名称
---@param pool '"global"'|'"stage"' @要加载到的目标资源池
local function loadResourcesList(name, pool)
    local _pool = GetResourceStatus()
    pool = pool or _pool
    SetResourceStatus(pool)
    for _, data in ipairs(resList[name]) do
        data[1](unpack(data, 3, 2 + data[2]))
    end
    SetResourceStatus(_pool)
end
lib.LoadResourcesList = loadResourcesList

---加载资源列表
---@param name string @资源列表名称
---@param pool '"global"'|'"stage"' @要加载到的目标资源池
---@return fun():boolean
local function pairsLoadResourcesList(name, pool)
    local target = resList[name]
    local total = #target
    local finish = total <= 0
    local i = 0
    local fun = function()
        if finish then
            return false
        else
            i = i + 1
            local data = target[i]
            if data then
                local _pool = GetResourceStatus()
                pool = pool or _pool
                SetResourceStatus(pool)
                data[1](unpack(data, 3, 2 + data[2]))
                SetResourceStatus(_pool)
                finish = i >= total
            else
                finish = true
            end
            return not (finish)
        end
    end
    return fun
end
lib.PairsLoadResourcesList = pairsLoadResourcesList
--endregion

return lib