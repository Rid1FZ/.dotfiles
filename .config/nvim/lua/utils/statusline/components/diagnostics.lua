local M = {}

local diagnostic = vim.diagnostic
local tbl_count = vim.tbl_count

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
    if vim.bo.buftype ~= "" then
        return ""
    end

    local bufnr = 0
    local result = {}
    local total = 0

    for key, sev in pairs(severity) do
        local n = tbl_count(diagnostic.get(bufnr, { severity = sev }))
        if n > 0 then
            total = total + n
            result[#result + 1] = string.format("%%#%s#%s %d", highlights[key], symbols[key], n)
        end
    end

    if total == 0 then
        return ""
    end

    result[#result + 1] = "%#StatusLine#"
    return table.concat(result, " ")
end

return M
