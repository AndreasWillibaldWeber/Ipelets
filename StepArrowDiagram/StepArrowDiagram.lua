label = "Step Arrow Diagram"

about = [[
Implementation of a Step Arrow Diagram Tool

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

------------------ Local Functions -----------------

--------------------- Box Draw ---------------------
STEPARROWDIAGRAMM = {}
STEPARROWDIAGRAMM.__index = STEPARROWDIAGRAMM

function STEPARROWDIAGRAMM:new(model)
    local tool = {}
    _G.setmetatable(tool, STEPARROWDIAGRAMM)
    tool.model = model
    tool.page = model:page()
    model.ui:shapeTool(tool)
    tool.path = { type = "curve", closed = false }
    tool.p1 = nil
    tool.p2 = nil
    return tool
end

function STEPARROWDIAGRAMM:finish()
    self.model.ui:finishTool()
end

function STEPARROWDIAGRAMM:compute()
end

function STEPARROWDIAGRAMM:mouseButton(button, modifiers, press)
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
            local dialog = ipeui.Dialog(self.model.ui:win(), "Select a Textsize.")
            local textsizes = {"small", "normal", "large", "Large", "LARGE", "huge", "Huge"}
            local colors = {"gray", "red", "green", "blue"}
            local opacity = {"opaque", "75%", "50%", "30%", "10%"}
            dialog:add("text", "input", {}, 1, 1, 1, 2)
            dialog:add("textsize", "combo", textsizes, 2, 1, 1, 2)
            dialog:add("colors", "combo", colors, 3, 1, 1, 2)
            dialog:add("opacity", "combo", opacity, 4, 1, 1, 2)
            dialog:add("ok", "button", { label="&Ok", action="accept" }, 5, 2)
            dialog:add("cancel", "button", { label="&Cancel", action="reject" }, 5, 1)
            local r = dialog:execute()
            if not r then return end
            local ts = textsizes[dialog:get("textsize")]
            local c = colors[dialog:get("colors")]
            local o = opacity[dialog:get("opacity")]
            local t = dialog:get("text")
            local h = self.p2.y - self.p1.y
            local b = self.p2.x - self.p1.x
            local ba = h * 0.2
            local mh = h / 2
            local mb = b / 2
            --ipeui.messageBox(self.model.ui:win(), "information", "[" .. t .. "]")
            local shape = { type="curve", closed=true;
                    { type="segment"; V(self.p1.x - ba, self.p1.y), V(self.p1.x, self.p1.y + mh) },
                    { type="segment"; V(self.p1.x, self.p1.y + mh), V(self.p1.x - ba, self.p2.y) },
                    { type="segment"; V(self.p1.x - ba, self.p2.y), V(self.p2.x - ba, self.p2.y) },
                    { type="segment"; V(self.p2.x - ba, self.p2.y), V(self.p2.x, self.p1.y + mh ) },
                    { type="segment"; V(self.p2.x, self.p1.y + mh), V(self.p2.x - ba, self.p1.y) },
                    { type="segment"; V(self.p2.x - ba, self.p1.y), V(self.p1.x, self.p1.y) } }
            local path = ipe.Path(self.model.attributes, {shape})
            path:set("pathmode", "strokedfilled")
            path:set("fill", c)
            path:set("opacity", o)
            path:set("stroke", "black")
            path:set("pen", "fat")
            local text = ipe.Text(self.model.attributes, t, V(self.p1.x + mb, self.p1.y + mh))
            text:set("textsize", ts)
            text:set("horizontalalignment", "hcenter")
            text:set("verticalalignment", "vcenter")
            local group = ipe.Group({path, text})
            self.model:creation("create box", group)
            self.page:deselectAll()
            self.model:runLatex()
        end
    else -- Abort if any other button is pressed
        self:finish()
        return
    end
end

function STEPARROWDIAGRAMM:mouseMove()
    if self.p1 then
        p = self.model.ui:pos()
        self.path = { type="curve", closed=false; { type="segment"; self.p1, p } }
        self.setShape({ self.path })
        self.model.ui:update(false)
    end
end

function STEPARROWDIAGRAMM:key(text, modifiers)
    if text == "\027" then -- Esc
        self:finish()
        return true
    else -- Not consumed
        return false
    end
end

function STEPARROWDIAGRAMM:explain()
    local s = "Left: Add vertex"
    self.model.ui:explain(s, 0)
end

------------------------------------------------------

function run(model)
    STEPARROWDIAGRAMM:new(model)
end
