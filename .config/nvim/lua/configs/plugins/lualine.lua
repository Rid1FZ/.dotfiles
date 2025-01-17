local colors = {
    bg = "#11111b",
    fg = "#cdd6f4",
    yellow = "#f9e2af",
    cyan = "#94e2d5",
    green = "#a6e3a1",
    orange = "#fab387",
    violet = "#cba6f7",
    magenta = "#f5c2e7",
    blue = "#89b4fa",
    red = "#f38ba8",
}

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand("%:p:h")
        local gitdir = vim.fn.finddir(".git", filepath .. ";")
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
}

local breadcrumb = function()
    local breadcrumb_status_ok, breadcrumb = pcall(require, "breadcrumb")
    if not breadcrumb_status_ok then
        return
    end
    return breadcrumb.get_breadcrumb()
end

-- Reset
local M = {
    options = {
        component_separators = "",
        section_separators = "",
        globalstatus = true,
        theme = {
            normal = { c = { fg = colors.fg, bg = colors.bg } },
            inactive = { c = { fg = colors.fg, bg = colors.bg } },
        },
    },
    sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_y = {},
        lualine_z = {},
        lualine_c = {},
        lualine_x = {},
    },

    winbar = {
        lualine_a = { breadcrumb },
    },
    inactive_winbar = {
        lualine_a = { breadcrumb },
    },
}

-- Inserts a component in lualine_c at left section
local function ins_left(component)
    table.insert(M.sections.lualine_c, component)
end

-- Inserts a component in lualine_x at right section
local function ins_right(component)
    table.insert(M.sections.lualine_x, component)
end

ins_left({
    function()
        return "█"
    end,
    color = { fg = colors.blue },
    padding = { left = 0, right = 1 },
})

ins_left({
    function()
        -- return ""
        local mode_icon = {
            n = "N",
            i = "I",
            v = "V",
            V = "V",
            c = "C",
            s = "S",
            S = "S",
            R = "R",
            Rv = "R",
            cv = "C",
            r = "R",
            t = "T",
        }
        return mode_icon[vim.fn.mode()] or "N"
    end,
    color = function()
        local mode_color = {
            n = colors.red,
            i = colors.green,
            v = colors.blue,
            V = colors.blue,
            c = colors.violet,
            no = colors.red,
            s = colors.orange,
            S = colors.orange,
            [""] = colors.orange,
            ic = colors.yellow,
            R = colors.magenta,
            Rv = colors.magenta,
            cv = colors.red,
            ce = colors.red,
            r = colors.cyan,
            rm = colors.cyan,
            ["r?"] = colors.cyan,
            ["!"] = colors.red,
            t = colors.red,
        }
        return { fg = mode_color[vim.fn.mode()] }
    end,
    padding = { right = 1 },
})

ins_left({
    "filesize",
    cond = conditions.buffer_not_empty,
})

ins_left({
    "branch",
    icon = "",
    color = { fg = colors.magenta, gui = "bold" },
})

ins_left({
    "filename",
    cond = conditions.buffer_not_empty,
    color = { fg = colors.violet, gui = "bold" },
})

ins_left({
    "diagnostics",
    sources = { "nvim_diagnostic" },
    symbols = { error = " ", warn = " ", info = " ", hint = " " },
    diagnostics_color = {
        error = { fg = colors.red },
        warn = { fg = colors.yellow },
        info = { fg = colors.cyan },
        hint = { fg = colors.cyan },
    },
})

ins_right({
    "diff",
    symbols = { added = " ", modified = " ", removed = " " },
    diff_color = {
        added = { fg = colors.green },
        modified = { fg = colors.orange },
        removed = { fg = colors.red },
    },
    cond = conditions.hide_in_width,
})

ins_right({
    function()
        local msg = ""
        local buf_ft = vim.bo.filetype
        local clients = vim.lsp.get_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 and client.name ~= "null-ls" then
                return client.name
            end
        end
        return msg
    end,
    icon = " ",
    color = { fg = colors.fg, gui = "bold" },
})

ins_right({
    function()
        local buf = vim.api.nvim_get_current_buf()
        local highlighter = require("vim.treesitter.highlighter")
        if highlighter.active[buf] then
            return " "
        else
            return ""
        end
    end,
    color = { fg = colors.green },
})

ins_right({ "location" })

ins_right({ "progress", color = { fg = colors.fg, gui = "bold" } })

ins_right({
    function()
        return "█"
    end,
    color = { fg = colors.blue },
    padding = { left = 1 },
})

return M
