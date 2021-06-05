local unpack = table.unpack or unpack

--region View3d
do
    ---@class lstg.View3d
    local lib = {}
    View3d = lib
    lstg.View3d = lib

    ---@class lstg.View3d.View.Default
    local defaultView = {
        eye = { 0, 0, -1 },
        at = { 0, 0, 0 },
        up = { 0, 1, 0 },
        fovy = PI_2,
        z = { 0, 2 },
        fog = { 0, 0, Color(0x00000000) }
    }

    ---@type lstg.View3d.View
    local currentView

    ---获取当前视角
    ---@return lstg.View3d.View
    local function getCurrentView3d()
        return currentView
    end
    lib.GetCurrentView3d = getCurrentView3d

    ---@class lstg.View3d.View : lstg.View3d.View.Default
    ---@return lstg.View3d.View
    local view = plus.Class()

    ---重置视角
    local function resetView()
        currentView = view()
    end
    lib.ResetView3d = resetView

    function view:init()
        self:Reset()
    end

    ---重置视角
    function view:Reset()
        self:SetEye(unpack(defaultView.eye))
        self:SetAt(unpack(defaultView.at))
        self:SetUp(unpack(defaultView.up))
        self:SetFovy(defaultView.fovy)
        self:SetZ(unpack(defaultView.z))
        self:SetFog(unpack(defaultView.fog))
    end

    ---设置眼睛位置
    ---@param x number
    ---@param y number
    ---@param z number
    function view:SetEye(x, y, z)
        self.eye = self.eye or {}
        self.eye[1] = x
        self.eye[2] = y
        self.eye[3] = z
    end

    ---设置视线目标位置
    ---@param x number
    ---@param y number
    ---@param z number
    function view:SetAt(x, y, z)
        self.at = self.at or {}
        self.at[1] = x
        self.at[2] = y
        self.at[3] = z
    end

    ---设置正上方向
    ---@param x number
    ---@param y number
    ---@param z number
    function view:SetUp(x, y, z)
        self.up = self.up or {}
        self.up[1] = x
        self.up[2] = y
        self.up[3] = z
    end

    ---设置视角
    ---@param fovy number @视角
    function view:SetFovy(fovy)
        self.fovy = fovy
    end

    ---设置Z范围
    ---@param zMin number @Z最小值
    ---@param zMax number @Z最大值
    function view:SetZ(zMin, zMax)
        self.z = self.z or {}
        self.z[1] = zMin
        self.z[2] = zMax
    end

    ---设置雾
    ---@param from number @雾起始距离
    ---@param to number @雾结束距离
    ---@param color lstg.Color @雾颜色
    function view:SetFog(from, to, color)
        self.fog = self.fog or {}
        self.fog[1] = from
        self.fog[2] = to
        self.fog[3] = color
    end

    resetView()
end
--endregion

--region Viewport
do
    local Screen = Screen
    local getCurrentWorld = World.GetCurrentWorld
    local getCurrentWorldOffset = WorldOffset.GetCurrentWorldOffset
    local getCurrentView3d = View3d.GetCurrentView3d
    local CurrentGraphicsSetting = Setting.Graphics

    ---@class lstg.View
    local lib = {}
    View = lib
    lstg.View = View

    ---@type table<string, lstg.View.Type>
    local viewType = {}

    ---@type string
    local currentViewTypeName

    ---获取当前视口类型
    ---@return string
    local function getCurrentViewTypeName()
        return currentViewTypeName
    end
    lib.GetCurrentViewTypeName = getCurrentViewTypeName

    ---获取当前视口定义
    ---@return fun(screen:lstg.Screen, world:lstg.World, offset:lstg.WorldOffset, view3d:lstg.View3d.View)
    local function getCurrentViewType()
        if viewType[currentViewTypeName] then
            return viewType[currentViewTypeName]
        else
            error("Invalid arguement.")
        end
    end
    lib.GetCurrentViewType = getCurrentViewType

    ---设置当前视口
    ---@param name string @视口名称
    ---@param force boolean @是否强制刷新视口
    ---@overload fun(name:string)
    local function setCurrentViewType(name, force)
        if force or currentViewTypeName ~= name then
            currentViewTypeName = name
            getCurrentViewType()(Screen, getCurrentWorld(), getCurrentWorldOffset(), getCurrentView3d())
        end
    end
    lib.SetCurrentViewType = setCurrentViewType

    ---添加一个视口定义
    ---@param name string @视口名称
    ---@param view fun(screen:lstg.Screen, world:lstg.World, offset:lstg.WorldOffset, view3d:lstg.View3d.View) @视口定义
    local function addViewType(name, view)
        viewType[name] = view
    end
    lib.AddViewType = addViewType

    ---设置渲染矩形（会被setCurrentViewType覆盖）
    ---@param l number @坐标系左边界
    ---@param r number @坐标系右边界
    ---@param b number @坐标系下边界
    ---@param t number @坐标系上边界
    ---@param scrl number @渲染系左边界
    ---@param scrr number @渲染系右边界
    ---@param scrb number @渲染系下边界
    ---@param scrt number @渲染系上边界
    ---@overload fun(info:table):nil @坐标系信息
    local function setRenderRect(l, r, b, t, scrl, scrr, scrb, scrt)
        local scale = Screen.GetScale()
        local dx = Screen.GetDx()
        local dy = Screen.GetDy()
        if l and r and b and t and scrl and scrr and scrb and scrt then
            --设置坐标系
            SetOrtho(l, r, b, t)
            --设置视口
            SetViewport(
                    scrl * scale + dx,
                    scrr * scale + dx,
                    scrb * scale + dy,
                    scrt * scale + dy
            )
            --清空fog
            SetFog()
            --设置图像缩放比
            SetImageScale(1)
        elseif type(l) == "table" then
            --设置坐标系
            SetOrtho(l.l, l.r, l.b, l.t)
            --设置视口
            SetViewport(
                    l.scrl * scale + dx,
                    l.scrr * scale + dx,
                    l.scrb * scale + dy,
                    l.scrt * scale + dy
            )
            --清空fog
            SetFog()
            --设置图像缩放比
            SetImageScale(1)
        else
            error("Invalid arguement.")
        end
    end
    lib.SetRenderRect = setRenderRect

    local function worldToUI(x, y)
        local w = getCurrentWorld()
        return w.scrl + w:GetScreenWidth() * (x - w.l) / w:GetWidth(), w.scrb + w:GetScreenHeight() * (y - w.b) / w:GetHeight()
    end
    lib.WorldToUI = worldToUI

    local function worldToScreen(x, y)
        local w = getCurrentWorld()
        local settingWidth = CurrentGraphicsSetting.GetWidth()
        local settingHeight = CurrentGraphicsSetting.GetHeight()
        local screenWidth = Screen.GetWidth()
        local screenHeight = Screen.GetHeight()
        local scale = Screen.GetScale()
        if settingWidth > settingHeight then
            return (settingWidth - settingHeight * screenWidth / screenHeight) / 2 / scale +
                    w.scrl + w:GetScreenWidth() * (x - w.l) / w:GetWidth(), w.scrb + w:GetScreenHeight() * (y - w.b) / w:Height()
        else
            return w.scrl + w:GetScreenWidth() * (x - w.l) / (w.r - w.l),
            (settingHeight - settingWidth * screenHeight / screenWidth) / 2 / scale + w.scrb + w:GetScreenHeight() * (y - w.b) / w:GetHeight()
        end
    end
    lib.WorldToScreen = worldToScreen

    local function screenToWorld(x, y)
        --该功能并不完善
        local dx, dy = WorldToScreen(0, 0)
        return x - dx, y - dy
    end
    lib.ScreenToWorld = screenToWorld

    addViewType("3d", function(screen, world, offset, view3d)
        local scale = screen.GetScale()
        local dx = screen.GetDx()
        local dy = screen.GetDy()
        SetViewport(world.scrl * scale + dx, world.scrr * scale + dx,
                world.scrb * scale + dy, world.scrt * scale + dy)
        SetPerspective(
                view3d.eye[1], view3d.eye[2], view3d.eye[3],
                view3d.at[1], view3d.at[2], view3d.at[3],
                view3d.up[1], view3d.up[2], view3d.up[3],
                view3d.fovy, world:GetWidth() / world:GetHeight(),
                view3d.z[1], view3d.z[2]
        )
        SetFog(view3d.fog[1], view3d.fog[2], view3d.fog[3])
        SetImageScale(1)
    end)
    addViewType("world", function(screen, world, offset, view3d)
        local width = world:GetWidth() * (1 / offset.hscale)--缩放后的宽度
        local height = world:GetHeight() * (1 / offset.vscale)--缩放后的高度
        local dx = offset.dx * (1 / offset.hscale)--水平整体偏移
        local dy = offset.dy * (1 / offset.vscale)--垂直整体偏移
        --计算world最终参数
        local l = offset.x - (width / 2) + dx
        local r = offset.x + (width / 2) + dx
        local b = offset.y - (height / 2) + dy
        local t = offset.y + (height / 2) + dy
        --应用参数
        setRenderRect(l, r, b, t, world.scrl, world.scrr, world.scrb, world.scrt)
    end)
    addViewType("ui", function(screen, world, offset, view3d)
        local width = screen.GetWidth()
        local height = screen.GetHeight()
        setRenderRect(0, width, 0, height, 0, width, 0, height)
    end)

    setCurrentViewType("ui")
end
--endregion