local getmetatable = getmetatable

local RemoveResource = RemoveResource
local ResetPool = ResetPool
local ObjFrame = ObjFrame
local BoundCheck = BoundCheck
local CollisionCheck = CollisionCheck
local UpdateXY = UpdateXY

local World = require("World")
local WorldOffset = require("WorldOffset")
local View3d = require("View3d")
local Input = require("Input")

local ResetWorld = World.ResetWorld
local ResetWorldOffset = WorldOffset.ResetWorldOffset
local ResetView3d = View3d.ResetView3d
local UpdateGameInput = Input.UpdateGameInput
local UpdateSystemInput = Input.UpdateSystemInput

local e = lstg.eventDispatcher

---@class lstg.SceneSystem
local lib = {}
SceneSystem = lib
lstg.SceneSystem = lib

---当前场景
---@type lstg.Scene
local currentScene

---下一个场景
---@type lstg.Scene
local nextScene

---是否正在切换场景
---@type boolean
local inChange = false

---是否退出游戏
---@type boolean
local quitFlag = false

---场景前帧回调
function lib:beforeFrame()
    self.inChange = false
    e:dispatchEvent("scene.onBeforeFrame", self)
end
---@param self lstg.SceneSystem
e:addListener("scene.onBeforeFrame", function(self)
    local cs = self:GetCurrentScene()
    if cs then
        cs.timer = cs.timer + 1
        cs:beforeFrame()
    end
end, 0, "scene.beforeFrame")

---场景帧回调
function lib:frame()
    e:dispatchEvent("scene.onFrame", self)
end
---@param self lstg.SceneSystem
e:addListener("scene.onFrame", function(self)
    if not (self:GetNextScene()) then
        local cs = self:GetCurrentScene()
        if cs then
            cs:frame()
        end
    end
end, 0, "scene.frame")

---场景后帧回调
function lib:afterFrame()
    e:dispatchEvent("scene.onAfterFrame", self)
    e:dispatchEvent("scene.onSceneChange", self)
end
---@param self lstg.SceneSystem
e:addListener("scene.onAfterFrame", function(self)
    local cs = self:GetCurrentScene()
    if cs then
        cs:afterFrame()
    end
end, 0, "scene.afterFrame")
---@param self lstg.SceneSystem
e:addListener("scene.onSceneChange", function(self)
    if self:GetNextScene() then
        local cs = self:GetCurrentScene()
        if cs then
            cs:del()
            if not (cs.preserve_res) then
                RemoveResource "stage"
            end
            ResetPool()
        end
        ResetWorld()
        ResetWorldOffset()
        ResetView3d()
        self:ChangeSceneState()
    end
end, 0, "scene.sceneChange")

---场景前渲染回调
function lib:beforeRender()
    e:dispatchEvent("scene.onBeforeRender", self)
end
---@param self lstg.SceneSystem
e:addListener("scene.onBeforeRender", function(self)
    local cs = self:GetCurrentScene()
    if cs then
        cs:beforeRender()
    end
end, 0, "scene.beforeRender")

---场景渲染回调
function lib:render()
    e:dispatchEvent("scene.onRender", self)
end
---@param self lstg.SceneSystem
e:addListener("scene.onRender", function(self)
    local cs = self:GetCurrentScene()
    if cs then
        cs:render()
    end
end, 0, "scene.render")

---场景后渲染回调
function lib:afterRender()
    e:dispatchEvent("scene.onAfterRender", self)
end
---@param self lstg.SceneSystem
e:addListener("scene.onAfterRender", function(self)
    local cs = self:GetCurrentScene()
    if cs then
        cs:afterRender()
    end
end, 0, "scene.afterRender")

---获取当前场景
---@return lstg.Scene
function lib:GetCurrentScene()
    return currentScene
end

---获取要切换到的场景
---@return lstg.Scene
function lib:GetNextScene()
    return nextScene
end

---设置场景切换
---@param scene lstg.Scene
function lib:SetNextScene(scene)
    nextScene = scene
end

---切换场景
function lib:ChangeSceneState()
    currentScene = self:GetNextScene()()
    self:SetNextScene(nil)
    inChange = true
end

---退出游戏
function lib:QuitGame()
    quitFlag = true
end

---获取是否退出游戏
---@return boolean
function lib:GetQuitFlag()
    return quitFlag
end

---基础Frame事件
function lib:NormalFrame()
    --对象帧逻辑
    ObjFrame()
    --碰撞检测
    BoundCheck()
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY_BULLET)
    CollisionCheck(GROUP_PLAYER, GROUP_ENEMY)
    CollisionCheck(GROUP_PLAYER, GROUP_INDES)
    CollisionCheck(GROUP_ENEMY, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_NONTJT, GROUP_PLAYER_BULLET)
    CollisionCheck(GROUP_ITEM, GROUP_PLAYER)
    --后更新
    UpdateXY()
end

---定义新的场景
---@param name string @场景名称
---@param is_menu boolean @是否为菜单
---@param as_entrance boolean @是否为入口点场景
---@return lstg.Scene
function lib:NewScene(name, is_menu, as_entrance)
    ---@class lstg.Scene : plus.Class
    ---@return lstg.Scene
    local scene = plus.Class()

    ---是否为菜单
    ---@type boolean
    scene.is_menu = is_menu

    ---场景名称
    ---@type string
    scene.name = name

    ---场景计时器
    ---@type number
    scene.timer = 0

    ---场景初始化回调
    function scene:init()
    end

    ---场景前帧回调
    function scene:beforeFrame()
        UpdateSystemInput()
        UpdateGameInput()
    end

    ---场景帧回调
    function scene:frame()
        Task.Do(self)
    end

    ---场景后帧回调
    function scene:afterFrame()
        lib:NormalFrame()
    end

    ---场景前渲染回调
    function scene:beforeRender()
    end

    ---场景渲染回调
    function scene:render()
    end

    ---场景后渲染回调
    function scene:afterRender()
    end

    ---场景销毁回调
    function scene:del()
    end

    function scene:SetTimer(t)
        self.timer = t
    end

    function scene:Set()
        lib:SetNextScene(getmetatable(self).__original or self)
    end

    function scene:Reset()
        lib:SetNextScene(getmetatable(self).__original or self)
    end

    if as_entrance then
        scene:Set()
    end

    return scene
end

e:addListener("onFrameUpdate", function()
    lib:beforeFrame()
    lib:frame()
    lib:afterFrame()
end, 0, "scene.updateFrame")
e:addListener("onRenderUpdate", function()
    lib:beforeRender()
    lib:render()
    lib:afterRender()
end, 0, "scene.updateRender")

return lib