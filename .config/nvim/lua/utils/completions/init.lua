local M = {}

local highlights = require("utils.completions.highlights")

M.setup = function()
    -- Setup highlights
    highlights.setup_highlights()

    -- Setup completions
    vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("completions", {}),
        callback = function(args)
            local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

            if client:supports_method("textDocument/completion") then
                -- trigger autocompletion on EVERY keypress
                local chars = {}
                for i = 32, 126 do
                    table.insert(chars, string.char(i))
                end
                client.server_capabilities.completionProvider.triggerCharacters = chars

                vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
            end
        end,
    })
end

return M
