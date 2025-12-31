local window = {
    window_background_opacity = 0.90,
    macos_window_background_blur = 10,
    window_padding = { left = 20, right = 20, top = 20, bottom = 20 },
    window_decorations = "RESIZE",
    window_frame = {
        border_left_width = 2,
        border_right_width = 2,
        border_top_height = 2,
        border_bottom_height = 2,
        active_titlebar_bg = '#090909'
    },
    animation_fps = 1,
    max_fps = 60,
    cursor_blink_ease_in = 'Constant',
    cursor_blink_ease_out = 'Constant',
    tab_max_width = 25,
    show_tab_index_in_tab_bar = false,

    -- initial_cols = 140, -- Number of columns
    -- initial_rows = 30,  -- Number of rows
    window_close_confirmation = 'NeverPrompt',

    inactive_pane_hsb = {
        saturation = 0.9,
        brightness = 0.65
    },

    enable_scroll_bar = true,
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
}

return window
