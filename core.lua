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
lstg.ArchiveFile = require("util.ArchiveFile") --储存用文件库
require("util.StringExtend") --字符串扩展
local i18n = require("util.Internationalization") --i18n
lstg.Internationalization = i18n
lstg.eventDispatcher:addListener("core.init", function()
    i18n:LoadFromData(require("lang.eng"))
    i18n:LoadFromData(require("lang.chs"))
    i18n:SetDefaultLanguage("eng")
    i18n:SetLanguage("chs")
end, 100, "core.i18n.init")
lstg.MathCalculation = require("util.MathCalculation") --数学计算库
lstg.WalkImageSystem = require("util.WalkImageSystem") --行走图系统

--常态基础定义库
require("KeyCode") --按键码列表
require("Const") --常量定义
require("Math") --数学库
require("Task") --协程任务库
require("TaskFactory") --协程任务库
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
require("enemy.HealthSystem") --血量系统
require("player.Player") --自机定义库

lstg.eventDispatcher:dispatchEvent("core.init")

require("GlobalFunc") --全局回调函数

---测试场景
DoFile("scene/title.lua")