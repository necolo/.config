local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local input = sbar.add("item", "widgets.input", {
  position = "right",
  update_freq = 1,
  icon = {
    string = icons.language,
    font = {
      family = settings.font_icon.text,
      style = settings.font_icon.style_map["Bold"],
      size = settings.icon_size
    },
    padding_left = settings.padding.icon_label_item.icon.padding_left,
    padding_right = settings.padding.icon_label_item.icon.padding_right,
  },
  label = {
    string = "??",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = settings.label_size,
    },
    align = "right",
    padding_right = settings.padding.icon_label_item.label.padding_right,
  },
})

local current_label = ""
local function update_input()
  sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | grep -E '\"Input Mode\"|KeyboardLayout Name' | grep -v 'InputSourceKind' | tail -1 | sed -E 's/^.+ = \"?([^\\\";]+).*/\\1/'", function(output)
    local source = output:gsub("\n", "")
    local label = source

    if source == "" then
      label = "??"
    elseif source == "ABC" or source == "U.S." then
      label = "EN"
    elseif source:find("pinyin") or source:find("Pinyin") or source:find("sogou") then
      label = "拼"
    elseif source:find("Japanese") or source:find("Kotoeri") or source:find("Hiragana") then
      label = "あ"
    end

    if current_label ~= label then
      current_label = label
      input:set({
        label = { string = label }
      })
    end
  end)
end

input:subscribe({ "routine", "input_change" }, function(env)
  update_input()
end)

input:subscribe("mouse.clicked", function(env)
  -- Optional: Open Keyboard Settings or switch input method
  sbar.exec("open /System/Library/PreferencePanes/Keyboard.prefPane")
end)

-- Padding after input item
sbar.add("item", "widgets.input.padding", {
  position = "right",
  width = settings.group_paddings,
  background = { drawing = false },
  icon = { drawing = false },
  label = { drawing = false }
})
