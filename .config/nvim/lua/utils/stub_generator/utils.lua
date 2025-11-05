local M = {}

local fn = vim.fn

M.mkdir_p = function(path)
    if fn.isdirectory(path) == 0 then
        fn.mkdir(path, "p")
    end
end

M.uniq_sorted = function(tbl)
    local set = {}
    for _, v in ipairs(tbl) do
        set[v] = true
    end

    local out = {}
    for k in pairs(set) do
        table.insert(out, k)
    end

    table.sort(out)
    return out
end

M.safe_pairs_of_table = function(tbl)
    local out = {}

    if type(tbl) ~= "table" then
        return out
    end

    for k, _ in pairs(tbl) do
        if type(k) == "string" and #k > 0 then
            table.insert(out, k)
        end
    end

    return out
end

M.is_identifier = function(s)
    if type(s) ~= "string" then
        return false
    end

    return s:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

return M
