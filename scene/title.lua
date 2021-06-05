local scene = SceneSystem:NewScene("init", true, true)

function scene:init()
    self.res = Resources.PairsLoadResourcesList("misc", "global")
    self.flag = 1
end

function scene:frame()
    local flag = self.res()
    if not (flag) then
        self.flag = 2
    end
end

function scene:render()
    View.SetCurrentViewType("ui")
    if self.flag == 1 then
        RenderText("score", "Loading", 320, 260, 1, "center")
    else
        RenderText("score", "Complete", 320, 260, 1, "center")
    end
    RenderText("score", self.timer, 320, 220, 1, "center")
end

LoadTTF('boss_name', 'res/font/default_ttf', 20)
LoadTTF('sc_name', 'res/font/syst_heavy.otf', 26)
LoadTTF('sc_pr', 'res/font/default_ttf', 30)
LoadTTF('dialog', 'res/font/default_ttf', 30)
LoadTTF('menuttf', 'res/font/default_ttf', 20)
LoadFont('score', 'res/font/score_new.fnt', false)
LoadFont('item', 'res/font/item.fnt', true)
LoadFont('menu', 'res/font/menu.fnt', false)
LoadFont('bonus', 'res/font/bonus.fnt', true)
LoadFont('score1', 'res/font/score_new.fnt', false)
LoadFont('score2', 'res/font/score_new.fnt', false)
LoadFont('score3', 'res/font/score_new_score.fnt', false)
LoadFont('time', 'res/font/score_new_score.fnt', true)
LoadFont('replay', 'res/font/replay.fnt', false)

Resources.NewResourcesList("misc")
Resources.AddResources("misc", LoadTexture, "misc", "res/misc/misc.png")
Resources.AddResources("misc", LoadImage, "player_aura", "misc", 128, 0, 64, 64)
Resources.AddResources("misc", LoadImageGroup, "bubble", "misc", 192, 0, 64, 64, 1, 4)
Resources.AddResources("misc", LoadImage, "border", "misc", 128, 192, 64, 64)
Resources.AddResources("misc", LoadImage, "leaf", "misc", 0, 32, 32, 32)
Resources.AddResources("misc", LoadImage, "white", "misc", 56, 8, 16, 16)
Resources.AddResources("misc", LoadTexture, "particles", "res/misc/particles.png")
Resources.AddResources("misc", LoadImageGroup, "parimg", "particles", 0, 0, 32, 32, 4, 4)
Resources.AddResources("misc", LoadImageFromFile, "img_void", "res/misc/img_void.png")
Resources.AddResources("misc", CopyImage, "_rev_white", "white")
Resources.AddResources("misc", SetImageState, "_rev_white", "add+sub",
        Color(255, 255, 255, 255),
        Color(255, 255, 255, 255),
        Color(255, 0, 0, 0),
        Color(255, 0, 0, 0))
Resources.AddResources("misc", CopyImage, "_sub_white", "white")
Resources.AddResources("misc", SetImageState, "_sub_white", "mul+sub",
        Color(255, 100, 100, 100),
        Color(255, 255, 255, 255),
        Color(255, 0, 0, 0),
        Color(255, 0, 0, 0))
for i = 1, 300 do
    Resources.AddResources("misc", Print, i)
end