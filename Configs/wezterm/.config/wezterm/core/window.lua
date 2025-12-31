local window = {
    window_background_opacity = 0.99,
    -- macos_window_background_blur = 10,
    window_padding = { left = 10, right = 10, top = 10, bottom = 10 },
    window_decorations = "RESIZE", -- "TITLE | RESIZE | NONE"
    window_frame = {
        border_left_width = 1,
        border_right_width = 1,
        border_top_height = 1,
        border_bottom_height = 1,
        active_titlebar_bg = '#090909'
    },
    front_end = "WebGpu", -- WebGpu | OpenGL
    animation_fps = 30,
    max_fps = 30,
    cursor_blink_ease_in = 'EaseInOut',
    cursor_blink_ease_out = 'EaseInOut',
    tab_max_width = 100,
    show_tab_index_in_tab_bar = false,

    initial_cols = 180,
    initial_rows = 50,
    window_close_confirmation = 'NeverPrompt',
    skip_close_confirmation_for_processes_named = {
      'bash',
      'sh',
      'zsh',
      'fish',
      'tmux',
      'nu',
      'cmd.exe',
      'pwsh.exe',
      'powershell.exe',
      'wsl',
      'wslhost',
      'ubuntu', 'wezterm-ssh'
    },
    window_background_gradient = {
      -- Can be "Vertical" or "Horizontal".  Specifies the direction
      -- in which the color gradient varies.  The default is "Horizontal",
      -- with the gradient going from left-to-right.
      -- Linear and Radial gradients are also supported; see the other
      -- examples below
      orientation = 'Vertical',

      -- Specifies the set of colors that are interpolated in the gradient.
      -- Accepts CSS style color specs, from named colors, through rgb
      -- strings and more
      colors = {
        '#0f0c29',
        '#302b63',
        '#24243e',
      },

      -- Instead of specifying `colors`, you can use one of a number of
      -- predefined, preset gradients.
      -- A list of presets is shown in a section below.
      -- preset = "Warm",

      -- Specifies the interpolation style to be used.
      -- "Linear", "Basis" and "CatmullRom" as supported.
      -- The default is "Linear".
      interpolation = 'CatmullRom',

      -- How the colors are blended in the gradient.
      -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
      -- The default is "Rgb".
      blend = 'LinearRgb',

      -- To avoid vertical color banding for horizontal gradients, the
      -- gradient position is randomly shifted by up to the `noise` value
      -- for each pixel.
      -- Smaller values, or 0, will make bands more prominent.
      -- The default value is 64 which gives decent looking results
      -- on a retina macbook pro display.
      -- noise = 64,

      -- By default, the gradient smoothly transitions between the colors.
      -- You can adjust the sharpness by specifying the segment_size and
      -- segment_smoothness parameters.
      -- segment_size configures how many segments are present.
      -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
      -- 1.0 is a soft edge.

      segment_size = 11,
      -- segment_smoothness = 0.0,
    },

    inactive_pane_hsb = {
        saturation = 0.85,
        brightness = 0.75
    },

    enable_scroll_bar = true,
    tab_bar_at_bottom = false,
    use_fancy_tab_bar = true,
    hide_tab_bar_if_only_one_tab = true,
}

return window
