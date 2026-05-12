local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")
local log = require("helpers.log").new("workspaces")

log.info("workspaces.lua loading...")

-- Load AeroSpaceLua
local Aerospace = require("helpers.aerospace")
local aerospace = nil
local max_retries = 30
local retry_count = 0

-- Wait for AeroSpace connection with retry logic
while retry_count < max_retries do
    local success, result = pcall(function()
        return Aerospace.new()
    end)

    if success and result:is_initialized() then
        aerospace = result
        break
    else
        os.execute("sleep 0.5")
        retry_count = retry_count + 1
    end
end

if not aerospace or not aerospace:is_initialized() then
    return
end

local mode_indicator = sbar.add("item", "aerospace.mode", {
    position = "left",
    icon = {
        string = "M",
        color = colors.green,
        font = { family = settings.font.text, style = "Bold", size = 14.0 },
        padding_left = 12,
        padding_right = 8,
    },
    label = { drawing = false },
    background = { drawing = false } -- 必须为 false
})

local workspaces = {}

local function update_mode_indicator()
    aerospace:list_modes(true, function(current_mode)
        current_mode = current_mode:match("^%s*(.-)%s*$")
        local icon_str = "M"
        local icon_color = colors.green
        if current_mode == "service" then
            icon_str = "S"
            icon_color = colors.yellow
        end
        mode_indicator:set({ icon = { string = icon_str, color = icon_color } })
    end)
end

mode_indicator:subscribe("aerospace_mode_change", update_mode_indicator)
update_mode_indicator()

local function withWindows(f)
    aerospace:list_all_windows(function(windows)
        if not windows or type(windows) ~= "table" then return end
        local open_windows = {}
        for _, window in ipairs(windows) do
            local workspace = window.workspace
            local app = window["app-name"]
            if open_windows[workspace] == nil then open_windows[workspace] = {} end
            table.insert(open_windows[workspace], app)
        end
        aerospace:list_current(function(focused_workspace)
            focused_workspace = focused_workspace:match("^%s*(.-)%s*$")
            aerospace:query_workspaces(function(workspace_info)
                local visible_workspaces = {}
                local workspace_monitors = {}
                for _, ws in ipairs(workspace_info) do
                    if ws["workspace-is-visible"] then table.insert(visible_workspaces, ws) end
                    local nsscreen_id_raw = ws["monitor-appkit-nsscreen-screens-id"]
                    if nsscreen_id_raw then
                        workspace_monitors[ws.workspace] = math.floor(nsscreen_id_raw)
                    end
                end
                f({ open_windows = open_windows, focused_workspace = focused_workspace, visible_workspaces = visible_workspaces, workspace_monitors = workspace_monitors })
            end)
        end)
    end)
end

local function updateWindow(workspace_index, args)
    local open_windows = args.open_windows[workspace_index] or {}
    local focused_workspace = args.focused_workspace
    local visible_workspaces = args.visible_workspaces
    local workspace_monitors = args.workspace_monitors

    local icon_line = ""
    local no_app = true
    for _, app in ipairs(open_windows) do
        no_app = false
        local lookup = app_icons[app]
        local icon = ((lookup == nil) and app_icons["Default"] or lookup)
        icon_line = icon_line .. " " .. icon
    end

    local is_focused = workspace_index == focused_workspace
    local target_display = workspace_monitors[workspace_index]
    
    local is_visible = false
    for _, visible_ws in ipairs(visible_workspaces) do
        if workspace_index == visible_ws.workspace then is_visible = true; break end
    end

    if no_app and not is_visible and workspace_index ~= focused_workspace then
        workspaces[workspace_index]:set({ drawing = false })
        return
    end

    local label_str = icon_line
    if no_app then label_str = " —" end

    workspaces[workspace_index]:set({
        drawing = true,
        display = target_display,
        icon = { highlight = is_focused },
        label = { string = label_str, highlight = is_focused },
        background = { drawing = false } -- 强制每一项背景都不绘制
    })
end

local function updateWindows()
    withWindows(function(args)
        for workspace_index, _ in pairs(workspaces) do
            updateWindow(workspace_index, args)
        end
    end)
end

-- Initialize workspaces and THE GLOBAL BRACKET
aerospace:query_workspaces(function(workspace_info)
    local workspace_names = { mode_indicator.name }
    
    for _, entry in ipairs(workspace_info) do
        local workspace_index = entry.workspace
        local workspace = sbar.add("item", "workspace." .. workspace_index, {
            position = "left",
            background = { drawing = false }, -- 必须为 false
            click_script = "aerospace workspace " .. workspace_index,
            icon = {
                color = colors.with_alpha(colors.white, 0.3),
                font = { family = settings.font.numbers },
                highlight_color = colors.white,
                string = workspace_index,
                padding_left = 8,
                padding_right = 4,
            },
            label = {
                color = colors.with_alpha(colors.white, 0.3),
                font = "sketchybar-app-font:Regular:16.0",
                highlight_color = colors.white,
                padding_left = 2,
                padding_right = 10,
            },
        })
        workspaces[workspace_index] = workspace
        table.insert(workspace_names, workspace.name)
    end

    updateWindows()

    local root = sbar.add("item", { drawing = false })
    root:subscribe("aerospace_workspace_change", updateWindows)
    root:subscribe("front_app_switched", updateWindows)
end)
