---These functions are taken from an opensource project: https://github.com/stevearc/conform.nvim
---@class Diff
local M = {}

local vim_diff = vim.text.diff
local api = vim.api

local function common_prefix_len(a, b)
    if not a or not b then
        return 0
    end
    local n = math.min(#a, #b)
    for i = 1, n do
        if a:byte(i) ~= b:byte(i) then
            return i - 1
        end
    end
    return n
end

local function common_suffix_len(a, b)
    local al, bl = #a, #b
    local n = math.min(al, bl)
    for i = 0, n - 1 do
        if a:byte(al - i) ~= b:byte(bl - i) then
            return i
        end
    end
    return n
end

local function tbl_slice(tbl, s, e)
    local ret = {}
    for i = s, e do
        ret[#ret + 1] = tbl[i]
    end
    return ret
end

local function make_edit(orig, repl, is_insert, is_replace, ls, le, eol)
    local sc, ec = 0, 0
    if is_replace then
        sc = common_prefix_len(orig[ls], repl[1])
        if sc > 0 then
            repl[1] = repl[1]:sub(sc + 1)
        end
        if orig[le] then
            local last = repl[#repl]
            local suffix = common_suffix_len(orig[le], last)
            if le == ls then
                suffix = math.min(suffix, #orig[le] - sc)
            end
            ec = #orig[le] - suffix
            if suffix > 0 then
                repl[#repl] = last:sub(1, #last - suffix)
            end
        end
    end
    if is_insert and ls - 1 < #orig then
        repl[#repl + 1] = ""
    end
    return {
        newText = table.concat(repl, eol),
        range = {
            start = { line = ls - 1, character = sc },
            ["end"] = { line = le - 1, character = ec },
        },
    }
end

---Diff original vs new_lines and apply minimal LSP TextEdits to the buffer.
---Preserves cursor position, folds, extmarks, and undo history.
---@param bufnr integer
---@param original string[]
---@param new_lines string[]
---@return boolean did_edit
M.apply_format = function(bufnr, original, new_lines)
    if not api.nvim_buf_is_valid(bufnr) then
        return false
    end

    local orig_text = table.concat(original, "\n") .. "\n"
    local new_text = table.concat(new_lines, "\n") .. "\n"

    if new_text:match("^%s*$") and not orig_text:match("^%s*$") then
        vim.notify("[fmt] Formatter returned empty output — refusing to wipe buffer", vim.log.levels.ERROR)
        return false
    end

    ---@diagnostic disable-next-line: missing-fields
    local indices = vim_diff(orig_text, new_text, { result_type = "indices", algorithm = "histogram" })
    assert(type(indices) == "table")

    local eol = require("utils").buf_line_ending(bufnr)
    local edits = {}

    for _, idx in ipairs(indices) do
        local orig_start, orig_count, new_start, new_count = unpack(idx)
        local is_insert = orig_count == 0
        local is_replace = not is_insert and new_count ~= 0
        local orig_end = orig_start + orig_count
        local repl = tbl_slice(new_lines, new_start, new_start + new_count - 1)

        if is_replace then
            orig_end = orig_end - 1
        end
        if is_insert then
            orig_start = orig_start + 1
            orig_end = orig_end + 1
        end

        edits[#edits + 1] = make_edit(original, repl, is_insert, is_replace, orig_start, orig_end, eol)
    end

    if not vim.tbl_isempty(edits) then
        vim.lsp.util.apply_text_edits(edits, bufnr, "utf-8")
    end
    return not vim.tbl_isempty(edits)
end

return M
