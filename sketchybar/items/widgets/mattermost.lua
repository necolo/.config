local colors = require("colors")
local settings = require("settings")

-- Mattermost Item
local mattermost = sbar.add("item", "widgets.mattermost", {
  position = "right",
  update_freq = 10,
  icon = {
    font = "sketchybar-app-font:Regular:16.0",
    string = ":mattermost:",
    color = colors.white,
    padding_left = settings.padding.icon_label_item.icon.padding_left,
    padding_right = settings.padding.icon_label_item.icon.padding_right,
  },
  label = {
    string = "•",
    color = colors.red,
    drawing = false,
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 10.0,
    },
    y_offset = 6,
    padding_left = -6,
    padding_right = 8,
  },
})

mattermost:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec('lsappinfo info -only StatusLabel "Mattermost"', function(result)
    -- Check if label exists and has content (not just [ NULL ] or empty)
    local unread = result:find('label"="[^"]') ~= nil
    mattermost:set({
      icon = { color = unread and colors.yellow or colors.white },
      label = { drawing = unread }
    })
  end)
end)

mattermost:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a Mattermost")
end)
