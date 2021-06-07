local grazer = require("player.PlayerGrazer")
local system = require("player.PlayerSystem")
local controller = require("player.PlayerController")

---@class lstg.Player.Class : lstg.Object
PlayerClass = Class()

function PlayerClass:init()
    self.group = GROUP_PLAYER
    self.layer = LAYER_PLAYER
    self.bound = false
end

function PlayerClass:frame()
end

function PlayerClass:render()
end

function PlayerClass:colli(other)
end

function PlayerClass:kill()
end

function PlayerClass:del()
end