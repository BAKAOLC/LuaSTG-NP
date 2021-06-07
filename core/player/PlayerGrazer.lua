---@class lstg.Player.Grazer : lstg.Object
PlayerGrazer = Class()

function PlayerGrazer:init()
    self.layer = LAYER_ENEMY_BULLET_EF + 50
    self.group = GROUP_PLAYER
    self.grazed = false
end

function PlayerGrazer:frame()
end

function PlayerGrazer:render()
end

function PlayerGrazer:colli(other)
end

return PlayerGrazer