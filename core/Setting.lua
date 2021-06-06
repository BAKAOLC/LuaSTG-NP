local type = type
local assert = assert
local error = error
local min = math.min
local max = math.max
local ipairs = ipairs
local pairs = pairs
local unpack = table.unpack or unpack
local open = io.open

local ChangeVideoMode = ChangeVideoMode
local SetBGMVolume = SetBGMVolume
local SetSEVolume = SetSEVolume

local NULL = KEY.NULL

local i18n = require("util.Internationalization")

local Serialize = require("Serialize")
local _Encode = Serialize.Json.Encode
local _Format = Serialize.Json.Format
---@param o table
---@return string
local Encode = function(o)
    return _Format(_Encode(o))
end
local Decode = Serialize.Json.Decode

---@class lstg.Setting
local lib = {}
lstg.Setting = lib

---配置文件目标路径
local targetFile = "setting"
local function getConfigFilePath()
    return targetFile
end
lib.GetConfigFilePath = getConfigFilePath

--region 用户名

---默认用户名
local defaultUserName = "User"

---用户名
local userName = defaultUserName

---设置用户名
---@param name string
local function setName(name)
    userName = name and name:match("%S") and name or defaultUserName
end
lib.SetName = setName

---获取用户名
---@return string
local function getName()
    return userName
end
lib.GetName = getName
--endregion

--region 渲染设置
do
    ---@class lstg.Setting.Graphics 渲染设置
    local graphics = {}
    lib.Graphics = graphics

    ---是否垂直同步
    local vsync = false
    ---是否窗口化
    local windowed = true
    ---分辨率宽度
    local width = 640
    ---分辨率高度
    local height = 480

    ---设置是否垂直同步
    ---@param use boolean
    local function setVsync(use)
        vsync = use and true
    end
    graphics.SetVsync = setVsync

    ---获取是否启用垂直同步
    ---@return boolean
    local function getVsync()
        return vsync
    end
    graphics.GetVsync = getVsync

    ---设置是否窗口化
    ---@param use boolean
    local function setWindowed(use)
        windowed = use and true
    end
    graphics.SetWindowed = setWindowed

    ---获取是否窗口化
    ---@return boolean
    local function getWindowed()
        return windowed
    end
    graphics.GetWindowed = getWindowed

    ---设置分辨率
    ---@param w number @分辨率宽度
    ---@param h number @分辨率高度
    local function setResolution(w, h)
        assert(type(w) == "number" and type(h) == "number")
        width, height = w, h
    end
    graphics.SetResolution = setResolution

    ---设置分辨率宽度
    ---@param w number @分辨率宽度
    local function setResolutionWidth(w)
        assert(type(w) == "number")
        width = w
    end
    graphics.SetResolutionWidth = setResolutionWidth

    ---设置分辨率高度
    ---@param h number @分辨率高度
    local function setResolutionHeight(h)
        assert(type(h) == "number")
        height = h
    end
    graphics.SetResolutionHeight = setResolutionHeight

    ---获取分辨率
    ---@return number, number
    local function getResolution()
        return width, height
    end
    graphics.GetResolution = getResolution

    ---获取分辨率宽度
    ---@return number
    local function getResolutionWidth()
        return width
    end
    graphics.GetResolutionWidth = getResolutionWidth

    ---获取分辨率高度
    ---@return number
    local function getResolutionHeight()
        return height
    end
    graphics.GetResolutionHeight = getResolutionHeight

    ---应用设置
    local function update()
        ChangeVideoMode(width, height, windowed, vsync)
    end
    graphics.ApplyConfig = update
end
--endregion

--region 音频设置
do
    ---@class lstg.Setting.Audio 音频设置
    local audio = {}
    lib.Audio = audio

    ---音乐音量大小(0~100)
    local music = 100
    ---音效音量大小(0~100)
    local sound = 100

    ---设置音乐音量
    ---@param level number
    local function setMusicVolume(level)
        assert(type(level) == "number")
        music = max(0, min(100, level))
        SetBGMVolume(music / 100)
    end
    audio.SetMusicVolume = setMusicVolume

    ---获取音乐音量
    ---@return number
    local function getMusicVolume()
        return music
    end
    audio.GetMusicVolume = getMusicVolume

    ---设置音效音量
    ---@param level number
    local function setSoundVolume(level)
        assert(type(level) == "number")
        sound = max(0, min(100, level))
        SetSEVolume(sound / 100)
    end
    audio.SetSoundVolume = setSoundVolume

    ---获取音效音量
    ---@return number
    local function getSoundVolume()
        return sound
    end
    audio.GetSoundVolume = getSoundVolume
end
--endregion

--region 操作设置
do
    ---@class lstg.Setting.Control 操作设置
    local control = {}
    lib.Control = control

    ---@type table<string, lstg.Setting.Control.Key>
    local gameKeys = {}

    ---@type table<string, lstg.Setting.Control.Key>
    local systemKeys = {}

    ---注册按键
    ---@param name string @键名
    ---@param default table<number, number> @键默认值
    local function registerKey(name, default)
        ---@class lstg.Setting.Control.Key
        local key = {
            ---当前按键值
            value = { unpack(default) },
            ---默认按键值
            default = { unpack(default) }
        }
        gameKeys[name] = key
    end
    control.RegisterKey = registerKey

    ---获取按键键值
    ---@param name string @键名
    ---@return table<number, number>
    local function getKey(name)
        return gameKeys[name] and gameKeys[name].value or { NULL }
    end
    control.GetKey = getKey

    ---获取按键默认键值
    ---@param name string @键名
    ---@return table<number, number>
    local function getKeyDefault(name)
        return gameKeys[name] and gameKeys[name].default or { NULL }
    end
    control.GetKeyDefault = getKeyDefault

    ---设置按键键值
    ---@param name string @键名
    ---@param key table<number, number> @键值
    local function setKey(name, key)
        assert(gameKeys[name], i18n:GetLanguageString("Core.Setting.Error.UnregisteredKey"):format(name))
        key = key and #key > 0 or { NULL }
        for _, k in ipairs(key) do
            assert(type(k) == "number" and k >= 0,
                    i18n:GetLanguageString("Core.Setting.Error.IllegalKeyValue"):format(k, name))
        end
        gameKeys[name].value = key
    end
    control.SetKey = setKey

    ---重置按键键值
    ---@param name string @键名
    local function resetKey(name)
        assert(gameKeys[name], i18n:GetLanguageString("Core.Setting.Error.UnregisteredKey"):format(name))
        gameKeys[name].value = { unpack(gameKeys[name].default) }
    end
    control.ResetKey = resetKey

    ---注册系统按键
    ---@param name string @键名
    ---@param default table<number, number> @键默认值
    local function registerSystemKey(name, default)
        ---@type lstg.Setting.Control.Key
        local key = {
            ---当前按键值
            value = { unpack(default) },
            ---默认按键值
            default = { unpack(default) }
        }
        systemKeys[name] = key
    end
    control.RegisterSystemKey = registerSystemKey

    ---获取按键键值
    ---@param name string @键名
    ---@return table<number, number>
    local function getSystemKey(name)
        return systemKeys[name] and systemKeys[name].value or { NULL }
    end
    control.GetSystemKey = getSystemKey

    ---获取按键默认键值
    ---@param name string @键名
    ---@return table<number, number>
    local function getSystemKeyDefault(name)
        return systemKeys[name] and systemKeys[name].default or { NULL }
    end
    control.GetSystemKeyDefault = getSystemKeyDefault

    ---设置按键键值
    ---@param name string @键名
    ---@param key table<number, number> @键值
    local function setSystemKey(name, key)
        assert(systemKeys[name], i18n:GetLanguageString("Core.Setting.Error.UnregisteredSystemKey"):format(name))
        key = key and #key > 0 or { NULL }
        for _, k in ipairs(key) do
            assert(type(k) == "number" and k >= 0,
                    i18n:GetLanguageString("Core.Setting.Error.IllegalKeyValue"):format(k, name))
        end
        systemKeys[name].value = key
    end
    control.SetSystemKey = setSystemKey

    ---重置系统按键键值
    ---@param name string @键名
    local function resetSystemKey(name)
        assert(systemKeys[name], i18n:GetLanguageString("Core.Setting.Error.UnregisteredSystemKey"):format(name))
        systemKeys[name].value = { unpack(systemKeys[name].default) }
    end
    control.ResetSystemKey = resetSystemKey

    ---构建当前按键映射表
    ---@return table<string, table<number, number>>
    local function buildKeyMap()
        ---@type table<string, table<number, number>>
        local map = {}
        for key, data in pairs(gameKeys) do
            map[key] = { unpack(data.value) }
        end
        return map
    end
    control.BuildKeyMap = buildKeyMap

    ---读取按键映射表
    ---@param map table<string, table<number, number>>
    local function loadKeyMap(map)
        for k, v in pairs(map) do
            setKey(k, v)
        end
    end
    control.LoadKeyMap = loadKeyMap

    ---构建当前系统按键映射表
    ---@return table<string, table<number, number>>
    local function buildSystemKeyMap()
        ---@type table<string, table<number, number>>
        local map = {}
        for key, data in pairs(systemKeys) do
            map[key] = { unpack(data.value) }
        end
        return map
    end
    control.BuildSystemKeyMap = buildSystemKeyMap

    ---读取系统按键映射表
    ---@param map table<string, table<number, number>>
    local function loadSystemKeyMap(map)
        for k, v in pairs(map) do
            setSystemKey(k, v)
        end
    end
    control.LoadSystemKeyMap = loadSystemKeyMap
end
--endregion

---构建配置表
---@return lstg.Setting.Configuration
local function buildConfiguration()
    ---@class lstg.Setting.Configuration
    local config = {
        ---用户名
        UserName = lib.GetName(),
        ---渲染设置
        Graphics = {
            ---是否启用垂直同步
            Vsync = lib.Graphics.GetVsync(),
            ---是否为窗口化
            Windowed = lib.Graphics.GetWindowed(),
            ---宽度
            Width = lib.Graphics.GetResolutionWidth(),
            ---高度
            Height = lib.Graphics.GetResolutionHeight(),
        },
        ---音频设置
        Audio = {
            ---音乐音量大小(0~100)
            Music = lib.Audio.GetMusicVolume(),
            ---音效音量大小(0~100)
            Sound = lib.Audio.GetSoundVolume()
        },
        ---操作设置
        Control = {
            ---游戏按键列表
            Keys = lib.Control.BuildKeyMap(),
            ---系统按键列表
            SystemKeys = lib.Control.BuildSystemKeyMap()
        }
    }
    return config
end
lib.BuildConfiguration = buildConfiguration

---读取配置表
---@param cfg lstg.Setting.Configuration
local function loadConfiguration(cfg)
    if cfg.UserName then
        lib.SetName(cfg.UserName)
    end
    if cfg.Graphics then
        if cfg.Graphics.Vsync ~= nil then
            lib.Graphics.SetVsync(cfg.Graphics.Vsync)
        end
        if cfg.Graphics.Windowed ~= nil then
            lib.Graphics.SetWindowed(cfg.Graphics.Windowed)
        end
        if cfg.Graphics.Width ~= nil and cfg.Graphics.Height ~= nil then
            lib.Graphics.SetResolution(cfg.Graphics.Width, cfg.Graphics.Height)
        end
        lib.Graphics.ApplyConfig()
    end
    if cfg.Audio then
        if cfg.Audio.Music ~= nil then
            lib.Audio.SetMusicVolume(cfg.Audio.Music)
        end
        if cfg.Audio.Sound ~= nil then
            lib.Audio.SetSoundVolume(cfg.Audio.Sound)
        end
    end
    if cfg.Control then
        if cfg.Control.Keys then
            lib.Control.LoadKeyMap(cfg.Control.Keys)
        end
        if cfg.Control.SystemKeys then
            lib.Control.LoadSystemKeyMap(cfg.Control.SystemKeys)
        end
    end
end
lib.LoadConfiguration = loadConfiguration

---保存配置
local function saveConfig()
    local f, msg
    f, msg = open(targetFile, "w")
    if f == nil then
        error(msg)
    else
        f:write(Encode(buildConfiguration()))
        f:close()
    end
end
lib.Save = saveConfig

---保存配置
local function readConfig()
    local f, msg
    f, msg = open(targetFile, "r")
    if f == nil then
        loadConfiguration(buildConfiguration())
    else
        loadConfiguration(Decode(f:read("*a")))
        f:close()
    end
end
lib.Read = readConfig

lstg.eventDispatcher:addListener("core.init", readConfig, 0, "core.setting.init")

return lib