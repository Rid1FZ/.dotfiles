---@class Statusline
local M = {}

local highlights = require("utils.statusline.highlights")
local autocommands = require("utils.statusline.autocommands")

local border = require("utils.statusline.components.border")
local mode = require("utils.statusline.components.mode")
local file = require("utils.statusline.components.file")
local diagnostics = require("utils.statusline.components.diagnostics")
local git = require("utils.statusline.components.git")
local location = require("utils.statusline.components.location")

---Global statusline function
---@return string The statusline string
_G.Statusline = function()
    return table.concat({
        border.get_left_border(),
        "%#StatusLine#",
        mode.get_mode(),
        "%#StatusLine# ",
        file.get_fileicon(),
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

---Setup statusline
---@return nil
M.setup = function()
    highlights.setup_highlights()
    autocommands.setup_autocommands()
end

return M
