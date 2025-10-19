--[[
  paramjit"s minimal config
  design goals:
    - single file
    - use native nvim features (>= v0.12)
    - only include what is actually used / configure only when necessary
]]
local o = vim.opt
o.tabstop = 2
o.shiftwidth = 2   -- new line indents should be 2
o.softtabstop = 2
o.expandtab = true -- spaces instead of tabs
o.autoread = true
o.number = true
o.relativenumber = true     -- to help with jumping
o.list = true               -- show trailing characters
o.clipboard = "unnamedplus" -- sync clipboard bw OS & nvim
o.signcolumn = "auto"
o.inccommand = "split"
o.cursorline = true
o.scrolloff = 10
o.confirm = true
o.backspace = "indent,eol,start"
o.shell = "/opt/homebrew/bin/fish"
o.colorcolumn = "80"
o.completeopt = { "menuone", "noselect", "popup" }
o.pumheight = 15
o.laststatus = 3 -- have ONE statusline for all buffers per neovim instance
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.swapfile = false
o.foldmethod = "indent"
o.foldlevel = 99
o.foldnestmax = 1
o.grepprg = "rg --vimgrep --smart-case --hidden"
o.grepformat = "%f:%l:%c:%m"

local g = vim.g
g.mapleader = " "
g.maplocalleader = " "

vim.diagnostic.config({ virtual_text = true })

vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/folke/trouble.nvim",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/nvim-lua/plenary.nvim", -- dependency of telescope.nvim
  "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/pmizio/typescript-tools.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/rebelot/kanagawa.nvim",

  "https://github.com/rmagatti/auto-session",


  -- ios stuff
  "https://github.com/wojciech-kulik/xcodebuild.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/mfussenegger/nvim-dap",
  "https://github.com/rcarriga/nvim-dap-ui",

  "https://github.com/dmtrKovalenko/fold-imports.nvim",
  "https://github.com/lukas-reineke/indent-blankline.nvim",
})

-- https://www.mitchellhanberg.com/modern-format-on-save-in-neovim/
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp", { clear = true }),
  callback = function(args)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = args.data.client_id }
      end,
    })
  end
})

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP Actions',
  callback = function()
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true })
  end,
})

require("mini.completion").setup({
  mappings = {
    -- Scroll info/signature window down/up. When overriding, check for
    -- conflicts with built-in keys for popup menu (like `<C-u>`/`<C-o>`
    -- for 'completefunc'/'omnifunc' source function; or `<C-n>`/`<C-p>`).
    scroll_down = '<Tab>',
    scroll_up = '<Shift-Tab>',
  },
})
require("mini.statusline").setup()

-- Lua config
vim.lsp.config["luals"] = {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  -- Sets the "workspace" to the directory where any of these files is found.
  -- Files that share a root directory will reuse the LSP server connection.
  -- Nested lists indicate equal priority, see |vim.lsp.Config|.
  root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
  -- Specific settings to send to the server. The schema is server-defined.
  -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } }
    }
  }
}
vim.lsp.enable("luals")


-- Cpp config
vim.lsp.enable("clangd")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

require("which-key").setup({ delay = 2000 }) -- delay of 2sec


-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- setup with some options
require("nvim-tree").setup({
  sort = {
    sorter = "case_sensitive",
  },
  view = {
    width = 30,
    relativenumber = true,
    signcolumn = "no",
  },
  renderer = {
    root_folder_label = ":t",
    group_empty = true,
    icons = {
      show = {
        folder_arrow = false,
      }
    }
  },
  filters = {
    dotfiles = true,
    custom = { "*.png", "*.svg", "*.pdf" },
  },
})

vim.api.nvim_set_keymap("n", "<leader>t", ":NvimTreeFindFileToggle<cr>",
  { silent = true, noremap = true, desc = "Open file Tree" })

vim.opt.fillchars = { eob = " " }

vim.api.nvim_set_keymap("n", "<leader>x", ":XcodebuildPicker<cr>",
  { silent = true, noremap = true, desc = "Open Xcode options" })




require("render-markdown").setup({
  link = {
    enabled = true,
    render_modes = false,
    footnote = {
      enabled = true,
      icon = "󰯔 ",
      superscript = true,
      prefix = "",
      suffix = "",
    },
    image = "󰥶 ",
    email = "󰀓 ",
    hyperlink = "󰌹 ",
    highlight = "RenderMarkdownLink",
    wiki = {
      icon = "󱗖 ",
      body = function()
        return nil
      end,
      highlight = "RenderMarkdownWikiLink",
      scope_highlight = nil,
    },
    custom = {
      web = { pattern = "^http", icon = "󰖟 " },
      discord = { pattern = "discord%.com", icon = "󰙯 " },
      github = { pattern = "github%.com", icon = "󰊤 " },
      gitlab = { pattern = "gitlab%.com", icon = "󰮠 " },
      google = { pattern = "google%.com", icon = "󰊭 " },
      neovim = { pattern = "neovim%.io", icon = " " },
      reddit = { pattern = "reddit%.com", icon = "󰑍 " },
      stackoverflow = { pattern = "stackoverflow%.com", icon = "󰓌 " },
      wikipedia = { pattern = "wikipedia%.org", icon = "󰖬 " },
      youtube = { pattern = "youtube%.com", icon = "󰗃 " },
    },
  },
})

require("fold_imports").setup()

require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "typescript", "markdown", "markdown_inline", "swift" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  -- ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    -- disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(_, buf)
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require("ibl").setup()

-- also see https://www.swift.org/documentation/articles/zero-to-swift-nvim.html
vim.lsp.config["sourcekit"] = {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
}
vim.lsp.enable("sourcekit")

require("xcodebuild").setup()


require 'kanagawa'.setup({
  colors = {
    theme = { all = { ui = { bg_gutter = 'none' } } }
  }
})

vim.cmd("colorscheme kanagawa-dragon")

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local invalid_win = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("NvimTree_") ~= nil then
        table.insert(invalid_win, w)
      end
    end
    if #invalid_win == #wins - 1 then
      -- Should quit, so we close all invalid windows.
      for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
    end
  end
})

require("auto-session").setup({})
