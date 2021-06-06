-- luastg+ 专用强化脚本库
-- 该脚本库完全独立于lstg的老lua代码
-- 所有功能函数暴露在全局plus表中
-- by CHU

plus = plus or {}

lstg.DoFile("core/plus/Utility.lua")
lstg.DoFile("core/plus/NativeAPI.lua")
lstg.DoFile("core/plus/IO.lua")