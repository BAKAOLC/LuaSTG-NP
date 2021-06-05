--region Group
---幽灵碰撞组（正常无任何判定）
GROUP_GHOST = 0
---敌机碰撞组
GROUP_ENEMY = 1
---敌机无体术碰撞组
GROUP_NONTJT = 2
---敌机弹幕碰撞组
GROUP_ENEMY_BULLET = 3
---敌机不可消弹弹幕碰撞组
GROUP_INDES = 4
---自机碰撞组
GROUP_PLAYER = 5
---自机弹幕碰撞组
GROUP_PLAYER_BULLET = 6
---道具碰撞组
GROUP_ITEM = 7
---符卡碰撞组
GROUP_SPELL = 8
---自机捕获碰撞组
GROUP_CPLAYER = 9
---全体碰撞组（不可修改）
GROUP_ALL = 16
---碰撞组上限数量（不可修改）
GROUP_NUM_OF_GROUP = 16
--endregion

--region LAYER
---背景渲染层
LAYER_BG = -700
---敌机渲染层
LAYER_ENEMY = -600
---自机弹幕渲染层
LAYER_PLAYER_BULLET = -500
---自机渲染层
LAYER_PLAYER = -400
---道具渲染层
LAYER_ITEM = -300
---敌机弹幕渲染层
LAYER_ENEMY_BULLET = -200
---敌机弹幕特效渲染层
LAYER_ENEMY_BULLET_EF = -100
---通常渲染顶层
LAYER_TOP = 0
--endregion

--region Math
PI = math.pi
PIx2 = math.pi * 2
PI_2 = math.pi * 0.5
PI_4 = math.pi * 0.25
SQRT2 = math.sqrt(2)
SQRT3 = math.sqrt(3)
SQRT2_2 = math.sqrt(0.5)
GOLD = 360 * (math.sqrt(5) - 1) / 2
--endregion