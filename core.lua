---=====================================
---core
---所有基础的东西都会在这里定义
---=====================================

---@class lstg @内建函数库
lstg = lstg or {}

----------------------------------------
---各个模块

local DoFile = lstg.DoFile

local baseModule = {
    "plus/plus", --plus支持库
    "sp/sp", --sp支持库
    "KeyCode", --按键码列表
    "Const", --常量定义
    "Math", --数学库
    "Task", --协程任务库
    "Global", --全局变量库
    "Serialize", --序列化库
    "Setting", --配置库
    "Input", --输入库
    "Screen", --屏幕渲染库
    "World", --世界渲染库
    "View", --视角渲染库
    "Scene", --场景库
    "Object", --对象定义库
    "Resources", --资源加载库
    "Text", --文本渲染库
    --"ScoreData" --数据记录库
}

for _, target in ipairs(baseModule) do
    DoFile(("core/%s.lua"):format(target))
end


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
    DoFile("scene/title.lua")
    --Score.InitScoreData()
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
