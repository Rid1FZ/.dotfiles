local M = {}

function M.get_filepath()
    local fpath = vim.fn.fnamemodify(vim.fn.expand("%"), ":~:.:h")
    local fname = vim.fn.expand("%:t")

    if fname == "" then
        return string.format("%s", " ")
    end

    local fullpath = ""
    if fpath == "" or fpath == "." then
        fullpath = " " .. fname .. " "
    else
        fullpath = " " .. fpath .. "/" .. fname .. " "
    end

    -- If longer than 32, truncate from left with ...
    if #fullpath > 32 then
        fullpath = "..." .. string.sub(fullpath, -(32 - 3))
    end

    return string.format("%s", fullpath)
end

function M.get_modified_status()
    local status = ""
    if vim.bo.modified then
        status = status .. "[+] "
    end
    if vim.bo.readonly or not vim.bo.modifiable then
        status = status .. "[-] "
    end
    if status ~= "" then
        return status
    end
    return "    "
end

return M
