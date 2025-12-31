-- Load configuration modules
local colors = require("core.common.colors")
local font = require("core.common.font")
local layout = require("core.common.layout")
local tabs = require("core.common.tabs")
local utils = require("core.common.utils")

return {
    utils = utils,
    colors = colors,
    font = font,
    window = layout,
    tab_title = tabs
}
