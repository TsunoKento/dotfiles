local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- フォント設定
-- JetBrains Mono は CJK を含まないため、明示しないと macOS のフォールバックが
-- Apple SD Gothic Neo (韓国語) を掴み、新字体・国字 (学/体/枠/込 等) が tofu になる
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
  "Hiragino Sans",
})
config.font_size = 12.0

-- 日本語IME設定
config.use_ime = true
config.macos_forward_to_ime_modifier_mask = 'SHIFT|CTRL'

-- 背景設定
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

-- タイトルバーの削除
config.window_decorations = "RESIZE"

----------------------------------------------------
-- Tab
----------------------------------------------------
config.hide_tab_bar_if_only_one_tab = true
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}
config.window_background_gradient = {
   colors = { "#000000" },
}
config.show_new_tab_button_in_tab_bar = false
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

return config
