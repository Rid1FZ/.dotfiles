return {
    filetype = { "sh", "bash" },
    priority = 1,
    command = "shfmt",
    args = function(_, ctx)
        local args = { "-filename", "$FILENAME" }
        local has_editorconfig = vim.fs.find(".editorconfig", { path = ctx.dirname, upward = true })[1] ~= nil
        if not has_editorconfig and vim.bo[ctx.buf].expandtab then
            vim.list_extend(args, { "-i", tostring(ctx.shiftwidth) })
        end
        return args
    end,
}
