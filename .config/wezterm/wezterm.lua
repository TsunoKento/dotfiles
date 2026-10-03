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
-- 既定の 16 だと "✳ myapp-issue-12" のようなタブ名が途中で切れる
config.tab_max_width = 32
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

-- ペインの作業ディレクトリ名 (末尾の要素) を返す。ホームは "~"
local function cwd_basename(pane)
  local cwd = pane.current_working_dir
  if not cwd then
    return nil
  end

  local path
  if type(cwd) == "userdata" then
    path = cwd.file_path
  else
    path = tostring(cwd):gsub("^file://[^/]*", "")
  end
  path = path:gsub("/+$", "")

  if path == wezterm.home_dir then
    return "~"
  end
  return path:match("([^/]+)$")
end

-- 手入力したタブ名 > "✳ dotfiles" (Claude Code) > "nvim: blog" の順で表示する
local function tab_label(tab)
  if tab.tab_title ~= "" then
    return tab.tab_title
  end

  local pane = tab.active_pane
  local title = pane.title
  local dir = cwd_basename(pane)
  if not dir then
    return title
  end

  -- Claude Code はタイトルを "✳ Claude Code" や "◐ <会話のトピック>" に変えるので、
  -- 先頭の状態アイコンだけ残してディレクトリ名を出す
  -- ネイティブ版の実体は ~/.local/share/claude/versions/<バージョン> なのでパスで判定する
  local process = pane.foreground_process_name or ""
  local is_claude = process:find("/claude/versions/", 1, true)
    or process:match("([^/]+)$") == "claude"
  if is_claude or title:find("Claude Code$") then
    local icon = title:match("^([\x80-\xFF]+) ")
    return icon and (icon .. " " .. dir) or dir
  end
  return title .. ": " .. dir
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#5c6d74"
  local foreground = "#FFFFFF"
  local edge_background = "none"

  if tab.is_active then
    background = "#ae8b2d"
    foreground = "#FFFFFF"
  end

  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab_label(tab), max_width - 1) .. "   "

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
