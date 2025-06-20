local M = {}

M.defaults = {
    stderr_to_stdout = false,
    silent = true,
}

M.winopts = {
    border = "rounded",
    backdrop = 100,
    title_flags = false,
    treesitter = {
        enabled = true,
    },
    preview = {
        border = "rounded",
        layout = "flex",
        title = false,
        winopts = {
            number = true,
            relativenumber = false,
            cursorline = true,
            cursorlineopt = "both",
            cursorcolumn = false,
            signcolumn = "no",
            list = false,
            foldenable = false,
            foldmethod = "manual",
        },
    },
}

M.fzf_opts = {
    ["--ansi"] = true,
    ["--info"] = "hidden",
    ["--height"] = "100%",
    ["--layout"] = "reverse",
    ["--border"] = "none",
    ["--highlight-line"] = true,
    ["--separator"] = "⎯",
}

M.grep = {
    prompt = " ",
    input_prompt = "regex: ",
    multiprocess = true,
    git_icons = true,
    file_icons = "devicons",

    color_icons = true,
    grep_opts = [[--binary-files=without-match --line-number --recursive --color=auto --perl-regexp --exclude .git --exclude .svn --exclude .hg -e]],
    rg_opts = [[--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob='!{.git,.svn,.hg}' -e]],
    hidden = true,
    follow = false,
    no_ignore = false,
    rg_glob = true,
    glob_flag = "--iglob",
    glob_separator = "%s%-%-",
    multiline = 2,
    no_header = true,
    no_header_i = true,
}

M.files = {
    prompt = " ",
    multiprocess = true,
    git_icons = false,
    file_icons = "devicons",
    color_icons = true,
    find_opts = [[-type f \! -path '*/.git/*']],
    rg_opts = [[--color=never --hidden --files --glob='!{.git,.svn,.hg}']],
    fd_opts = [[--color=never --hidden --type f --type l --exclude .git --exclude .svn --exclude .hg]],
    dir_opts = [[/s/b/a:-d]],
    cwd_prompt = false,
    toggle_ignore_flag = "--no-ignore",
    toggle_hidden_flag = "--hidden",
    toggle_follow_flag = "-L",
    hidden = true,
    follow = false,
    no_ignore = false,
}

M.oldfiles = {
    prompt = "󱋡 ",
    cwd_only = false,
    stat_file = true,
    include_current_session = false,
}

M.buffers = {
    prompt = " ",
    file_icons = true,
    color_icons = true,
    sort_lastused = true,
    show_unloaded = true,
    cwd_only = false,
    cwd = nil,
    no_header = true,
    no_header_i = true,
}

M.git = {
    files = {
        prompt = "GitFiles❯ ",
        cmd = "git ls-files --exclude-standard",
        multiprocess = true,
        git_icons = true,
        file_icons = true,
        color_icons = true,
    },
    status = {
        prompt = "󱇼 ",
        cmd = "git -c color.status=false --no-optional-locks status --porcelain=v1 -u",
        multiprocess = true,
        file_icons = true,
        color_icons = true,
        previewer = "git_diff",
    },
    diff = {
        cmd = "git --no-pager diff --name-only {ref}",
        ref = "HEAD",
        preview = "git diff {ref} {file}",
        file_icons = true,
        color_icons = true,
        fzf_opts = {
            ["--multi"] = true,
        },
    },
    hunks = {
        cmd = "git --no-pager diff --color=always {ref}",
        ref = "HEAD",
        file_icons = true,
        color_icons = true,
        fzf_opts = {
            ["--multi"] = true,
            ["--delimiter"] = ":",
            ["--nth"] = "3..",
        },
    },
    commits = {
        prompt = "Commits❯ ",
        cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
            .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset"]],
        preview = "git show --color {1}",
    },
    bcommits = {
        prompt = "BCommits❯ ",
        cmd = [[git log --color --pretty=format:"%C(yellow)%h%Creset ]]
            .. [[%Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset" {file}]],
        preview = "git show --color {1} -- {file}",
        actions = {},
    },
    blame = {
        prompt = "Blame> ",
        cmd = [[git blame --color-lines {file}]],
        preview = "git show --color {1} -- {file}",
        actions = {},
    },
    branches = {
        prompt = "Branches❯ ",
        cmd = "git branch --all --color",
        preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
        remotes = "local",
        actions = {},
        cmd_add = { "git", "branch" },
        cmd_del = { "git", "branch", "--delete" },
    },
}

M.diagnostics = {
    prompt = "󱌣 ",
    cwd_only = false,
    file_icons = false,
    git_icons = false,
    color_headings = true,
    diag_icons = true,
    diag_source = true,
    diag_code = true,
    icon_padding = "",
    multiline = 2,
}

M.lsp = {
    prompt_postfix = " ",
    cwd_only = false,
    async_or_timeout = 5000,
    file_icons = true,
    git_icons = true,
    jump1 = true,
    includeDeclaration = true,
    symbols = {
        async_or_timeout = true,
        symbol_style = 1,
        symbol_hl = function(s)
            return "@" .. s:lower()
        end,
        symbol_fmt = function(s, opts)
            return "[" .. s .. "]"
        end,
        child_prefix = true,
        fzf_opts = { ["--tiebreak"] = "begin" },
    },
    code_actions = {
        prompt = "󰁨 ",
        async_or_timeout = 5000,
        previewer = "codeaction_native",
    },
    finder = {
        prompt = "LSP Finder> ",
        file_icons = true,
        color_icons = true,
        async = true,
        silent = true,
        separator = "| ",
        includeDeclaration = true,
    },
}

return M
