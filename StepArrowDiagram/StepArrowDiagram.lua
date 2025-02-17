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

local TEXTSIZES = {"small", "normal", "large", "Large", "LARGE", "huge", "Huge"}
local COLORS = {"gray", "red", "green", "blue", "orange"}
local OPACITY = {"opaque", "75%", "50%", "30%", "10%"}

------------------ Local Functions -----------------

--------------------- Box Draw ---------------------
STEPARROWDIAGRAM = {}
STEPARROWDIAGRAM.__index = STEPARROWDIAGRAM

function STEPARROWDIAGRAM:new(model)
    local tool = {}
    _G.setmetatable(tool, STEPARROWDIAGRAM)
    tool.model = model
    tool.page = model:page()
    model.ui:shapeTool(tool)
    tool.path = { type = "curve", closed = false }
    tool.p1 = nil
    tool.p2 = nil
    return tool
end

function STEPARROWDIAGRAM:finish()
    self.model.ui:finishTool()
end

function STEPARROWDIAGRAM:compute(p1, p2)
    local h = p2.y - p1.y
    local b = p2.x - p1.x
    local ba = h * 0.2
    local mh = h / 2
    local mb = b / 2
    return h, b, ba, mh, mb
end

function STEPARROWDIAGRAM:createArrowShape(p1, p2)
    local _, _, ba, mh, mb = self:compute(p1, p2)
    return { type="curve", closed=true;
        { type="segment"; V(p1.x - ba, p1.y), V(p1.x, p1.y + mh) },
        { type="segment"; V(p1.x, p1.y + mh), V(p1.x - ba, p2.y) },
        { type="segment"; V(p1.x - ba, p2.y), V(p2.x - ba, p2.y) },
        { type="segment"; V(p2.x - ba, p2.y), V(p2.x, p1.y + mh ) },
        { type="segment"; V(p2.x, p1.y + mh), V(p2.x - ba, p1.y) },
        { type="segment"; V(p2.x - ba, p1.y), V(p1.x, p1.y) } }
end

function STEPARROWDIAGRAM:createArrowPath(p1, p2, options)
    local shape = self:createArrowShape(p1, p2)
    local path = ipe.Path(self.model.attributes, {shape})
    path:set("pathmode", "strokedfilled")
    path:set("fill", options.color)
    path:set("opacity", options.opacity)
    path:set("stroke", "black")
    path:set("pen", "fat")
    return path
end

function STEPARROWDIAGRAM:createArrowText(p1, p2, options)
    local _, _, _, mh, mb = self:compute(p1, p2)
    local text = ipe.Text(self.model.attributes, options.text, V(p1.x + mb, p1.y + mh))
    text:set("textsize", options.textsize)
    text:set("horizontalalignment", "hcenter")
    text:set("verticalalignment", "vcenter")
    return text
end

function STEPARROWDIAGRAM:createArrowGroup(p1, p2)
    local result, options = self:getUserInput(self:createUi())
    if not result then return end
    local path = self:createArrowPath(p1, p2, options)
    local text = self:createArrowText(p1, p2, options)
    return ipe.Group({path, text})
end

function STEPARROWDIAGRAM:createUi()
    local dialog = ipeui.Dialog(self.model.ui:win(), "Select a Textsize.")
    dialog:add("text", "input", {}, 1, 1, 1, 2)
    dialog:add("textsize", "combo", TEXTSIZES, 2, 1, 1, 2)
    dialog:add("colors", "combo", COLORS, 3, 1, 1, 2)
    dialog:add("opacity", "combo", OPACITY, 4, 1, 1, 2)
    dialog:add("ok", "button", { label="&Ok", action="accept" }, 5, 2)
    dialog:add("cancel", "button", { label="&Cancel", action="reject" }, 5, 1)
    return dialog
end

function STEPARROWDIAGRAM:getUserInput(dialog)
    local result = dialog:execute()
    if not result then return result, nil, nil, nil, nil end
    local textsize = TEXTSIZES[dialog:get("textsize")]
    local color = COLORS[dialog:get("colors")]
    local opacity = OPACITY[dialog:get("opacity")]
    local text = dialog:get("text")
    return result, {textsize = textsize, color = color, opacity = opacity, text = text}
end

function STEPARROWDIAGRAM:mouseButton(button, modifiers, press)
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
            self.model:creation("create box", self:createArrowGroup(self.p1, self.p2))
            self.page:deselectAll()
            self.model:runLatex()
        end
    else -- Abort if any other button is pressed
        self:finish()
        return
    end
end

function STEPARROWDIAGRAM:mouseMove()
    if self.p1 then
        p = self.model.ui:pos()
        self.path = self:createArrowShape(self.p1, p)
        self.setShape({ self.path })
        self.model.ui:update(false)
    end
end

function STEPARROWDIAGRAM:key(text, modifiers)
    if text == "\027" then -- Esc
        self:finish()
        return true
    else -- Not consumed
        return false
    end
end

function STEPARROWDIAGRAM:explain()
    local s = "Left: Add vertex"
    self.model.ui:explain(s, 0)
end

------------------------------------------------------

function run(model)
    STEPARROWDIAGRAM:new(model)
end
