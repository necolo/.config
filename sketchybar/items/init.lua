local colors = require("colors")

-- 加载组件
require("items.workspaces")
require("items.calendar")

-- 在时间岛屿和右侧插件岛屿之间添加一个 20px 的透明间距 (Spacer)
sbar.add("item", "island_spacer", {
    position = "right",
    width = 12,
    background = { drawing = false },
    icon = { drawing = false },
    label = { drawing = false },
})

-- require("items.vpn") -- 已移除
require("items.widgets")

-- 分离岛屿设置
sbar.exec([[
  # 左侧岛屿：模式和工作区
  sketchybar --add bracket left_island '/workspace\..*/' aerospace.mode \
             --set left_island background.color=0xff313244 \
                               background.height=30 \
                               background.corner_radius=12 \
                               background.drawing=on

  # 右侧大岛屿：包含所有 widgets（不包含 spacer 和 calendar）
  sketchybar --add bracket right_island '/widgets\..*/' \
             --set right_island background.color=0xff313244 \
                                background.height=30 \
                                background.corner_radius=12 \
                                background.drawing=on

  # 时间岛屿：单独包裹 calendar
  sketchybar --add bracket calendar_island calendar \
             --set calendar_island background.color=0xff313244 \
                                   background.height=30 \
                                   background.corner_radius=12 \
                                   background.drawing=on
]])
