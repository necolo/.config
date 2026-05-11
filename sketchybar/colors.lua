local mocha = {
  rosewater = 0xfff5e0dc,
  flamingo  = 0xfff2cdcd,
  pink      = 0xfff5c2e7,
  mauve     = 0xffcba6f7,
  red       = 0xfff38ba8,
  maroon    = 0xffeba0ac,
  peach     = 0xfffab387,
  yellow    = 0xfff9e2af,
  green     = 0xffa6e3a1,
  teal      = 0xff94e2d5,
  sky       = 0xff89dceb,
  sapphire  = 0xff74c7ec,
  blue      = 0xff89b4fa,
  lavender  = 0xffb4befe,
  text      = 0xffcdd6f4,
  subtext1  = 0xffbac2de,
  subtext0  = 0xffa6adc8,
  overlay2  = 0xff9399b2,
  overlay1  = 0xff7f849c,
  overlay0  = 0xff6c7086,
  surface2  = 0xff585b70,
  surface1  = 0xff45475a,
  surface0  = 0xff313244,
  base      = 0xff1e1e2e,
  mantle    = 0xff181825,
  crust     = 0xff11111b,
}

local colors = {
  -- UI Colors
  bar = {
    bg = 0x00000000, -- 完全透明的主 Bar
    border = 0x00000000,
  },
  
  -- Island backgrounds (使用实色，不再透明)
  bg1 = 0xff313244, -- Surface0
  bg2 = 0xff45475a, -- Surface1
  
  popup = {
    bg = 0xff181825,     -- Mantle
    border = 0xff585b70, -- Surface2
  },

  -- Logic colors
  white = mocha.text,
  black = mocha.base,
  red   = mocha.red,
  green = mocha.green,
  blue  = mocha.blue,
  yellow = mocha.yellow,
  orange = mocha.peach,
  magenta = mocha.mauve,
  grey  = mocha.overlay0,
  transparent = 0x00000000,
  
  accent = mocha.mauve,
  accent_bright = mocha.lavender,
}

-- Add convenience functions
function colors.with_alpha(color, alpha)
  if alpha > 1.0 or alpha < 0.0 then return color end
  return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
end

-- Export both the main table and the mocha palette for flexibility
for k, v in pairs(mocha) do
  colors[k] = v
end

return colors
