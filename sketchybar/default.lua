local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
    background = {
        border_width = 0,
        color = colors.transparent, -- 默认元素透明
        corner_radius = 12,        -- 圆角 12
    },
    icon = {
        font = {
            family = settings.font_icon.text,
            style = settings.font_icon.style_map["Bold"],
            size = settings.font_icon.size
        },
        color = colors.white,
        padding_left = settings.paddings,
        padding_right = 0,
    },
    label = {
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Semibold"],
            size = settings.font.size
        },
        color = colors.white,
        padding_left = settings.paddings,
        padding_right = settings.paddings,
    },
    popup = {
        align = "center",
        background = {
            border_width = 1,
            border_color = colors.surface1,
            corner_radius = 12,
            color = colors.popup.bg,
            shadow = { drawing = true },
        },
        blur_radius = 50,
        y_offset = 10
    },
    padding_left = 2,
    padding_right = 2,
    updates = "on",
})
