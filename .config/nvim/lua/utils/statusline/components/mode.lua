local M = {}

local modes = {
    ["n"] = "N",
    ["no"] = "N",
    ["v"] = "V",
    ["V"] = "V",
    [""] = "V",
    ["s"] = "S",
    ["S"] = "S",
    [""] = "S",
    ["i"] = "I",
    ["ic"] = "I",
    ["R"] = "R",
    ["Rv"] = "R",
    ["c"] = "C",
    ["cv"] = "C",
    ["ce"] = "C",
    ["r"] = "P",
    ["rm"] = "P",
    ["r?"] = "P",
    ["!"] = "!",
    ["t"] = "T",
}

local function update_mode_colors()
    local current_mode = vim.api.nvim_get_mode().mode
    local mode_color = "%#StatuslineAccent#"

    if current_mode == "n" then
        mode_color = "%#StatuslineAccent#"
    elseif current_mode == "i" or current_mode == "ic" then
        mode_color = "%#StatuslineInsertAccent#"
    elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
        mode_color = "%#StatuslineVisualAccent#"
    elseif current_mode == "R" then
        mode_color = "%#StatuslineReplaceAccent#"
    elseif current_mode == "c" then
        mode_color = "%#StatuslineCmdLineAccent#"
    elseif current_mode == "t" then
        mode_color = "%#StatuslineTerminalAccent#"
    end

    return mode_color
end

function M.get_mode()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format("%s %s ", update_mode_colors(), modes[current_mode])
end

return M
