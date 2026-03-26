---@class Fs
local M = {}
local uv = vim.uv

--- True when running on Windows.
---@type boolean
M.is_windows = uv.os_uname().version:match("Windows") ~= nil

--- OS path separator.
---@type string
M.sep = M.is_windows and "\\" or "/"

---Join path segments with the OS separator.
---@param ... string
---@return string
M.join = function(...) return table.concat({ ... }, M.sep) end

---True if `path` is absolute.
---@param path string
---@return boolean
M.is_absolute = function(path) return M.is_windows and path:lower():match("^%a:") ~= nil or vim.startswith(path, "/") end

---Return the absolute form of `path` (expands relative paths via fnamemodify).
---@param path string
---@return string
M.abspath = function(path) return M.is_absolute(path) and path or vim.fn.fnamemodify(path, ":p") end

---True if `candidate` is equal to `root` or is a descendent of it.
---Both paths are normalised before comparison.
---@param root string
---@param candidate string
---@return boolean
M.is_subpath = function(root, candidate)
    if candidate == "" then
        return false
    end
    root = vim.fs.normalize(M.abspath(root))
    candidate = vim.fs.normalize(M.abspath(candidate))

    -- Trim trailing slash from root.
    if root:sub(-1) == "/" then
        root = root:sub(1, -2)
    end

    if M.is_windows then
        root = root:lower()
        candidate = candidate:lower()
    end

    if root == candidate then
        return true
    end
    if candidate:sub(1, #root) ~= root then
        return false
    end

    -- Ensure the match is at a directory boundary.
    return candidate:sub(#root + 1, #root + 1) == "/"
end

---Build a path from `source` to `target` using `..` traversal.
---Returns `target` unchanged if a relative path cannot be constructed
---(e.g. cross-drive on Windows).
---@param source string
---@param target string
---@return string
M.relative_path = function(source, target)
    source = M.abspath(source)
    target = M.abspath(target)

    local parts = {}
    while not M.is_subpath(source, target) do
        parts[#parts + 1] = ".."
        local up = vim.fs.dirname(source)
        if up == source then
            -- Reached filesystem root — cross-drive path on Windows.
            return target
        end
        source = up
    end

    local offset = source:sub(-1) == M.sep and 1 or 2
    parts[#parts + 1] = target:sub(#source + offset)
    return M.join(unpack(parts))
end

return M
