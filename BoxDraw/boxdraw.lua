label = "BoxDraw"

about = [[
Implementation of a BoxDraw Tool

By Andreas W. Weber
]]


------------ Global constants/functions ----------
_, _, MAJOR, MINOR, PATCH = string.find(config.version, "(%d+).(%d+).(%d+)")
IPELIB_VERSION = 10000*MAJOR + 100*MINOR + PATCH
V = ipe.Vector
R = ipe.Rect
M = ipe.Matrix
S = ipe.Segment
B = ipe.Bezier
EYE = M()

--------------------- Box Draw ---------------------
BOXDRAW = {}
BOXDRAW.__index = BOXDRAW

function BOXDRAW:new(model)
    local tool = {}
    _G.setmetatable(tool, BOXDRAW)
    tool.model = model
    tool.page = model:page()
    model.ui:shapeTool(tool)
    tool.path = { type = "curve", closed = false }
    tool.p1 = nil
    tool.p2 = nil
    return tool
end

function BOXDRAW:finish()
    self.model.ui:finishTool()
end

function BOXDRAW:compute()
end

function BOXDRAW:mouseButton(button, modifiers, press)
    if not press then return end
    if button == 1 then
        if not self.p1 then
            self.p1 = self.model.ui:pos()
            return
        end
        if not self.p2 then
            self.p2 = self.model.ui:pos()
        end
        if self.p1 and self.p2 then
            self:finish()
            -- one need to be carefule about naming global variables name, path, dllname, _G, ipe, ipeui, math, string
            -- table, assert, shortcuts, prefs, config, mouse, ipairs, pairs, print, tonumber, tostring
            -- they are reconfigure the variables for loading/reloading iplets!!!
            local shape = { type="curve", closed=true;
                    { type="segment"; V(self.p1.x, self.p1.y), V(self.p1.x, self.p2.y) },
                    { type="segment"; V(self.p1.x, self.p2.y), V(self.p2.x, self.p2.y) },
                    { type="segment"; V(self.p2.x, self.p2.y), V(self.p2.x, self.p1.y) },
                    { type="segment"; V(self.p2.x, self.p1.y), V(self.p1.x, self.p1.y) } }
            local path = ipe.Path(self.model.attributes, {shape})
            self.model:creation("create rect", path)
        end
    else -- Abort if any other button is pressed
        self:finish()
        return
    end
end

function BOXDRAW:mouseMove()
    if self.p1 then
        p = self.model.ui:pos()
        self.path = { type="curve", closed=false; { type="segment"; self.p1, p } }
        self.setShape({ self.path })
        self.model.ui:update(false)
    end
end

function BOXDRAW:key(text, modifiers)
    if text == "\027" then -- Esc
        self:finish()
        return true
    else -- Not consumed
        return false
    end
end

function BOXDRAW:explain()
    local s = "Left: Add vertex"
    self.model.ui:explain(s, 0)
end

------------------------------------------------------

function run(model)
    BOXDRAW:new(model)
end
