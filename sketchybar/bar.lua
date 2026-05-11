local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
    height = 40,
    color = colors.transparent,
    border_color = colors.transparent,
    shadow = false,
    blur_radius = 0, -- 关闭毛玻璃
    topmost = "window",
    padding_left = 10,
    padding_right = 10,
})

