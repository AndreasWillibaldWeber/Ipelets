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

local TEXTSIZES = { "Huge", "huge", "LARGE", "Large", "large", "normal", "small" }
local COLORS = { "white", "gray", "darkgray", "black", "red", "darkred", "green", "darkgreen", "blue", "darkblue", "orange", "darkorange", "cyan", "darkcyan" }
local TEXTCOLORS = { "black", "darkgray", "gray", "white" }
local OPACITIES = { "opaque", "75%", "50%", "30%", "10%" }
local PENS = { "ultrafat", "fat", "heavier", "normal"}

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
    path:set("pen", options.pen)
    return path
end

function STEPARROWDIAGRAM:createArrowText(p1, p2, options)
    local _, _, _, mh, mb = self:compute(p1, p2)
    local text = ipe.Text(self.model.attributes, options.text, V(p1.x + mb, p1.y + mh))
    text:set("textsize", options.textsize)
    text:set("horizontalalignment", "hcenter")
    text:set("verticalalignment", "vcenter")
    text:set("stroke", options.textcolor)
    return text
end

function STEPARROWDIAGRAM:createArrowGroup(p1, p2, options)
    local path = self:createArrowPath(p1, p2, options)
    local text = self:createArrowText(p1, p2, options)
    return ipe.Group({path, text})
end

function STEPARROWDIAGRAM:createUi()
    local dialog = ipeui.Dialog(self.model.ui:win(), "Select a Textsize.")
    dialog:add("text_label", "label", {label="Text:"}, 1, 1)
    dialog:add("text", "input", {}, 1, 2, 1, 3)
    dialog:add("textsize_label", "label", {label="Textsize:"}, 2, 1)
    dialog:add("textsize", "combo", TEXTSIZES, 2, 2, 1, 3)
    dialog:add("textcolor_label", "label", {label="Textcolor:"}, 3, 1)
    dialog:add("textcolor", "combo", TEXTCOLORS, 3, 2, 1, 3)
    dialog:add("color_label", "label", {label="Color:"}, 4, 1)
    dialog:add("color", "combo", COLORS, 4, 2, 1, 3)
    dialog:add("opacity_label", "label", {label="Opacity:"}, 5, 1)
    dialog:add("opacity", "combo", OPACITIES, 5, 2, 1, 3)
    dialog:add("pen_label", "label", {label="Pen:"}, 6, 1)
    dialog:add("pen", "combo", PENS, 6, 2, 1, 3)
    dialog:add("ok", "button", { label="&Ok", action="accept" }, 7, 3, 1, 2)
    dialog:add("cancel", "button", { label="&Cancel", action="reject" }, 7, 1, 1, 2)
    return dialog
end

function STEPARROWDIAGRAM:getUserInput(dialog)
    local result = dialog:execute()
    if not result then return result, {} end
    local text = dialog:get("text")
    local textsize = TEXTSIZES[dialog:get("textsize")]
    local textcolor = TEXTCOLORS[dialog:get("textcolor")]
    local color = COLORS[dialog:get("color")]
    local opacity = OPACITIES[dialog:get("opacity")]
    local pen = PENS[dialog:get("pen")]
    return result, { text = text, textsize = textsize, textcolor = textcolor, color = color, opacity = opacity, pen = pen }
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
            local result, options = self:getUserInput(self:createUi())
            if not result then return end
            self.model:creation("create box", self:createArrowGroup(self.p1, self.p2, options))
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
