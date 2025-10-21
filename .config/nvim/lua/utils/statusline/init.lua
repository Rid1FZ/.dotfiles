local M = {}

_G.Statusline = {}

local highlights = require("utils.statusline.highlights")
local autocommands = require("utils.statusline.autocommands")

local border = require("utils.statusline.components.border")
local mode = require("utils.statusline.components.mode")
local file = require("utils.statusline.components.file")
local diagnostics = require("utils.statusline.components.diagnostics")
local git = require("utils.statusline.components.git")
local location = require("utils.statusline.components.location")

Statusline.active = function()
    return table.concat({
        border.get_left_border(),
        "%#StatusLine#",
        mode.get_mode(),
        "%#StatusLine# ",
        file.get_filepath(),
        file.get_modified_status(),
        "%#StatusLine#",
        diagnostics.get_diagnostics(),
        "%=",
        git.get_gitbranch(),
        "%#StatusLineExtra#",
        location.get_location(),
        border.get_right_border(),
    })
end

Statusline.inactive = function()
    return "%#StatusLineNC# %F"
end

M.setup = function()
    highlights.setup_highlights()
    autocommands.setup_autocommands()
end

return M
