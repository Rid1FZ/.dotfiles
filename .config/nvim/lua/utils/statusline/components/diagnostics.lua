local M = {}

local api = vim.api
local bo = vim.bo -- always use the index form: bo[something]
local diagnostic = vim.diagnostic
local tbl_count = vim.tbl_count
local format = string.format
local concat = table.concat

local severity = {
    errors = diagnostic.severity.ERROR,
    warnings = diagnostic.severity.WARN,
    info = diagnostic.severity.INFO,
    hints = diagnostic.severity.HINT,
}

local symbols = {
    errors = "",
    warnings = "",
    info = "",
    hints = "",
}

local highlights = {
    errors = "DiagnosticSignError",
    warnings = "DiagnosticSignWarn",
    info = "DiagnosticSignInfo",
    hints = "DiagnosticSignHint",
}

M.get_diagnostics = function()
    local bufnr = api.nvim_get_current_buf()

    if bo[bufnr].buftype ~= "" then
        return ""
    end

    local result = {}
    local total = 0

    for key, sev in pairs(severity) do
        local n = tbl_count(diagnostic.get(bufnr, { severity = sev }))
        if n > 0 then
            total = total + n
            result[#result + 1] = format("%%#%s#%s %d", highlights[key], symbols[key], n)
        end
    end

    if total == 0 then
        return ""
    end

    result[#result + 1] = "%#StatusLine#"
    return concat(result, " ")
end

return M
