local e = lstg.eventDispatcher

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
    e:dispatchEvent("onTitleUpdate", ext)
end

---行为帧动作(和游戏循环的帧更新分开)
function DoFrame()
    --设置标题
    ChangeGameTitle()
    --场景帧逻辑
    e:dispatchEvent("onFrameUpdate")
end
e:addListener("onFrameFunc", DoFrame, 0, "core.updateFrame")

---游戏退出事件
function GameExit()
    e:dispatchEvent("onGameExit")
end

---场景帧逻辑前
function BeforeFrame()
    e:dispatchEvent("onBeforeFrame")
end

---场景帧逻辑后
function AfterFrame()
    e:dispatchEvent("onAfterFrame")
end

---场景渲染逻辑前
function BeforeRender()
    e:dispatchEvent("onBeforeRender")
end

---场景渲染逻辑后
function AfterRender()
    e:dispatchEvent("onAfterRender")
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
    BeforeFrame()
    e:dispatchEvent("onFrameFunc")
    AfterFrame()
    local flag = SceneSystem:GetQuitFlag()
    if flag then
        GameExit()
    end
    return flag
end

---游戏渲染逻辑循环
function RenderFunc()
    BeginScene()
    BeforeRender()
    e:dispatchEvent("onRenderFunc")
    AfterRender()
    EndScene()
end
e:addListener("onRenderFunc", function()
    SceneSystem:beforeRender()
    SceneSystem:render()
    if not (SceneSystem.inChange) then
        ObjRender()
    end
    SceneSystem:afterRender()
end, 0, "core.updateRender")

---焦点丢失事件
function FocusLoseFunc()
    lstg.pause = true
    e:dispatchEvent("onFocusLose")
end

---焦点重获事件
function FocusGainFunc()
    lstg.pause = false
    e:dispatchEvent("onFocusGain")
end
