---=====================================
---core
---所有基础的东西都会在这里定义
---=====================================

package.path = package.path .. ";core/?.lua"

---@class lstg @内建函数库
lstg = lstg or {}

----------------------------------------
---各个模块

local DoFile = lstg.DoFile

--额外独立支持库
require("plus.plus") --plus支持库
require("sp.sp") --plus支持库
require("x.std.init") --x std支持库
lstg.eventDispatcher = require("x.EventDispatcher").create() --事件调度器

--功能性扩展库
require("util.ArchiveFile") --储存用文件库
require("util.StringExtend") --字符串扩展
local i18n = require("util.Internationalization") --i18n
lstg.eventDispatcher:addListener("core.init", function()
    i18n:LoadFromData(require("lang.eng"))
    i18n:LoadFromData(require("lang.chs"))
    i18n:SetDefaultLanguage("eng")
    i18n:SetLanguage("chs")
end, 100, "core.i18n.init")

--常态基础定义库
require("KeyCode") --按键码列表
require("Const") --常量定义
require("Math") --数学库
require("Task") --协程任务库
require("Serialize") --序列化库
require("Setting") --配置库
require("Input") --输入库
require("Screen") --屏幕渲染库
require("World") --世界渲染库
require("WorldOffset") --世界偏移渲染库
require("View") --视角渲染库
require("View3d") --3d视角渲染库
require("Resources") --资源加载库
require("Scene") --场景库
require("Object") --对象定义库
require("Text") --文本渲染库

lstg.eventDispatcher:dispatchEvent("core.init")

---测试场景
DoFile("scene/title.lua")

----------------------------------------
---用户定义的一些函数

---设置标题
function ChangeGameTitle()
    local ext = table.concat({
        ("FPS=%.1f"):format(GetFPS()),
        "Objects=" .. GetnObj(),
        "LuaSTG-NP"
    }, " | ")
    SetTitle(ext)
end

---行为帧动作(和游戏循环的帧更新分开)
function DoFrame()
    --设置标题
    ChangeGameTitle()
    --场景帧逻辑
    BeforeFrame()
    SceneSystem:beforeFrame()
    local flag = SceneSystem:frame()
    SceneSystem:afterFrame()
    AfterFrame()
    return flag
end

---游戏退出事件
function GameExit()
end

---场景帧逻辑前
function BeforeFrame()
end

---场景帧逻辑后
function AfterFrame()
end

---场景渲染逻辑前
function BeforeRender()
end

---场景渲染逻辑后
function AfterRender()
end

----------------------------------------
---全局回调函数，底层调用

---游戏初始化
function GameInit()
    if not (SceneSystem:GetNextScene()) then
        error("Entrance stage not set.")
    end
    SetResourceStatus("stage")
end

---游戏帧逻辑循环
function FrameFunc()
    local flag = DoFrame()
    if flag then
        GameExit()
    end
    return flag
end

---游戏渲染逻辑循环
function RenderFunc()
    BeginScene()
    BeforeRender()
    SceneSystem:beforeRender()
    SceneSystem:render()
    if not (SceneSystem.inChange) then
        ObjRender()
    end
    SceneSystem:afterRender()
    AfterRender()
    EndScene()
end

---焦点丢失事件
function FocusLoseFunc()
    lstg.pause = true
end

---焦点重获事件
function FocusGainFunc()
    lstg.pause = false
end
