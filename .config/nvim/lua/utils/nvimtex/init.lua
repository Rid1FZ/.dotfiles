---@class NvimTex
local M = {}

local api = vim.api
local lsp = vim.lsp

local function buf_build(client, bufnr)
    local win = api.nvim_get_current_win()
    local params = lsp.util.make_position_params(win, client.offset_encoding)
    client:request("textDocument/build", params, function(err, result)
        if err then
            error(tostring(err))
        end
        local status = { [0] = "Success", [1] = "Error", [2] = "Failure", [3] = "Cancelled" }
        vim.notify("Build " .. status[result.status], vim.log.levels.INFO)
    end, bufnr)
end

local function buf_search(client, bufnr)
    local win = api.nvim_get_current_win()
    local params = lsp.util.make_position_params(win, client.offset_encoding)
    client:request("textDocument/forwardSearch", params, function(err, result)
        if err then
            error(tostring(err))
        end
        local status = { [0] = "Success", [1] = "Error", [2] = "Failure", [3] = "Unconfigured" }
        vim.notify("Search " .. status[result.status], vim.log.levels.INFO)
    end, bufnr)
end

local function buf_cancel_build(client, bufnr)
    return client:exec_cmd({ title = "cancel", command = "texlab.cancelBuild" }, { bufnr = bufnr })
end

local function dependency_graph(client)
    client:exec_cmd({ command = "texlab.showDependencyGraph" }, { bufnr = 0 }, function(err, result)
        if err then
            return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
        end
        vim.notify("The dependency graph has been generated:\n" .. result, vim.log.levels.INFO)
    end)
end

local function make_clean_cmd(cmd_name, command)
    return function(client, bufnr)
        return client:exec_cmd({
            title = ("clean_%s"):format(cmd_name),
            command = command,
            arguments = { { uri = vim.uri_from_bufnr(bufnr) } },
        }, { bufnr = bufnr }, function(err)
            if err then
                vim.notify(("Failed to clean %s files: %s"):format(cmd_name, err.message), vim.log.levels.ERROR)
            else
                vim.notify(("Clean %s executed successfully"):format(cmd_name), vim.log.levels.INFO)
            end
        end)
    end
end

local function buf_find_envs(client, bufnr)
    local win = api.nvim_get_current_win()
    client:exec_cmd({
        command = "texlab.findEnvironments",
        arguments = { lsp.util.make_position_params(win, client.offset_encoding) },
    }, { bufnr = bufnr }, function(err, result)
        if err then
            return vim.notify(err.code .. ": " .. err.message, vim.log.levels.ERROR)
        end
        local env_names = {}
        local max_length = 1
        for _, env in ipairs(result) do
            table.insert(env_names, env.name.text)
            max_length = math.max(max_length, #env.name.text)
        end
        for i, name in ipairs(env_names) do
            env_names[i] = string.rep(" ", i - 1) .. name
        end
        lsp.util.open_floating_preview(env_names, "", {
            height = #env_names,
            width = math.max(max_length + #env_names - 1, #"Environments"),
            focusable = false,
            focus = false,
            title = "Environments",
        })
    end)
end

local function buf_change_env(client, bufnr)
    vim.ui.input({ prompt = "New environment name: " }, function(input)
        if not input or input == "" then
            return vim.notify("No environment name provided", vim.log.levels.WARN)
        end
        local pos = api.nvim_win_get_cursor(0)
        return client:exec_cmd({
            title = "change_environment",
            command = "texlab.changeEnvironment",
            arguments = {
                {
                    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
                    position = { line = pos[1] - 1, character = pos[2] },
                    newName = tostring(input),
                },
            },
        }, { bufnr = bufnr })
    end)
end

---@type {name: string, fn: fun(client: vim.lsp.Client, bufnr: integer), desc: string}[]
local commands = {
    {
        name = "Build",
        fn = buf_build,
        desc = "Build the current buffer",
    },
    {
        name = "Forward",
        fn = buf_search,
        desc = "Forward search from current position",
    },
    {
        name = "CancelBuild",
        fn = buf_cancel_build,
        desc = "Cancel the current build",
    },
    {
        name = "DependencyGraph",
        fn = dependency_graph,
        desc = "Show the dependency graph",
    },
    {
        name = "CleanArtifacts",
        fn = make_clean_cmd("Artifacts", "texlab.cleanArtifacts"),
        desc = "Clean the artifacts",
    },
    {
        name = "CleanAuxiliary",
        fn = make_clean_cmd("Auxiliary", "texlab.cleanAuxiliary"),
        desc = "Clean the auxiliary files",
    },
    {
        name = "FindEnvironments",
        fn = buf_find_envs,
        desc = "Find environments at current position",
    },
    {
        name = "ChangeEnvironment",
        fn = buf_change_env,
        desc = "Change environment at current position",
    },
}

---Register texlab buffer commands on LspAttach
---@return nil
M.setup = function()
    api.nvim_create_autocmd("LspAttach", {
        group = api.nvim_create_augroup("TexlabCommands", { clear = true }),
        callback = function(args)
            local client = lsp.get_client_by_id(args.data.client_id)
            if not client or client.name ~= "texlab" then
                return
            end
            local bufnr = args.buf
            for _, cmd in ipairs(commands) do
                api.nvim_buf_create_user_command(
                    bufnr,
                    "Tex" .. cmd.name,
                    function() cmd.fn(client, bufnr) end,
                    { desc = cmd.desc }
                )
            end
        end,
    })
end

return M
