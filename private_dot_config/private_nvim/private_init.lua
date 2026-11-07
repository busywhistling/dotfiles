--[[
  paramjit's minimal config
  design goals:
    - single file
    - native nvim features (>= 0.12), plugins via `vim.pack` (no third-party manager)
    - only include what is actually used / configure only when necessary
    - usage convenience and comfort over config simplicity
]]

-- Set to false if you don't use a Nerd Font.
vim.g.have_nerd_font = true

-- [[ Options ]]
local o = vim.opt

o.tabstop = 2
o.shiftwidth = 2 -- new line indents should be 2
o.softtabstop = 2
o.expandtab = true -- spaces instead of tabs
o.autoread = true
o.number = true
o.relativenumber = true -- to help with jumping
o.signcolumn = "auto"
o.inccommand = "split" -- preview substitutions live, as you type
o.splitright = true
o.splitbelow = true
o.cursorline = true
o.scrolloff = 10
o.confirm = true
o.backspace = "indent,eol,start"
o.colorcolumn = "80" -- yes this needs to be a string
o.textwidth = 80
o.completeopt = { "menuone", "noselect", "popup" }
o.pumheight = 15
o.laststatus = 3 -- have ONE statusline for all buffers per neovim instance
o.cmdheight = 0 -- looks visually nice but requires extra enter for each command
o.showmode = false -- has no effect due to cmdheight=0
o.undofile = true
o.ignorecase = false
o.smartcase = true
o.swapfile = false
o.grepprg = "rg --vimgrep --smart-case --hidden"
o.grepformat = "%f:%l:%c:%m"

o.spell = true
o.spelllang = "en_gb"
o.fillchars = { eob = " " }

o.clipboard = "unnamedplus" -- sync clipboard between OS & nvim
o.shell = vim.env.SHELL

local g = vim.g
g.mapleader = " "
g.maplocalleader = " "

vim.diagnostic.config({ virtual_text = true })

-- [[ Keymaps ]]

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover.
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- to be able to use WisprFlow or similar dictation apps
vim.keymap.set("i", "<F5>", "<Nop>", { noremap = true, silent = true })

-- [[ Plugins: vim.pack ]]
--
-- Plugins are installed to `stdpath("data") .. "/site/pack/core/opt"`.
-- Revisions are pinned in `stdpath("config") .. "/nvim-pack-lock.json"`.
--
--   :lua vim.pack.update()   -- review + apply updates
--   :lua vim.pack.get()      -- list managed plugins
--   :lua vim.pack.del(...)   -- remove plugins from disk
--
-- NOTE: vim.pack has no lazy-loading. Everything is on the runtimepath after
-- `vim.pack.add()`. Expensive `setup()` calls are deferred with autocmds below.
local gh = function(repo)
	return "https://github.com/" .. repo
end

-- Build steps (what `build = "..."` did in lazy.nvim).
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
			return
		end

		local name, path = ev.data.spec.name, ev.data.path
		if name == "telescope-fzf-native.nvim" and vim.fn.executable("make") == 1 then
			vim.system({ "make" }, { cwd = path }):wait()
		elseif name == "LuaSnip" and vim.fn.executable("make") == 1 then
			vim.system({ "make", "install_jsregexp" }, { cwd = path }):wait()
		elseif name == "nvim-treesitter" then
			-- parsers must be rebuilt whenever the plugin changes
			pcall(vim.cmd, "packadd nvim-treesitter")
			pcall(vim.cmd, "TSUpdate")
		end
	end,
})

local plugins = {
	-- colorscheme first, so it is available early
	{ src = gh("rebelot/kanagawa.nvim") },

	-- editing
	{ src = gh("lewis6991/gitsigns.nvim") },
	{ src = gh("windwp/nvim-autopairs") },
	{ src = gh("rmagatti/auto-session") },
	{ src = gh("folke/zen-mode.nvim") },
	{ src = gh("chomosuke/typst-preview.nvim"), version = vim.version.range("1.*") },
	{ src = gh("folke/which-key.nvim") },
	{ src = gh("lukas-reineke/indent-blankline.nvim") },
	{ src = gh("echasnovski/mini.nvim") },
	{ src = gh("dmtrKovalenko/fold-imports.nvim") },
	{ src = gh("sontungexpt/url-open"), version = "mini" },

	-- search / navigation
	{ src = gh("nvim-telescope/telescope.nvim") },
	{ src = gh("nvim-lua/plenary.nvim") },
	{ src = gh("nvim-telescope/telescope-fzf-native.nvim") },
	{ src = gh("nvim-telescope/telescope-ui-select.nvim") },
	{ src = gh("nvim-tree/nvim-web-devicons") },
	{ src = gh("nvim-tree/nvim-tree.lua") },
	{ src = gh("folke/trouble.nvim") },

	-- completion
	{ src = gh("saghen/blink.cmp"), version = vim.version.range("1.*") },
	{ src = gh("L3MON4D3/LuaSnip"), version = vim.version.range("2.*") },

	-- lsp / formatting
	{ src = gh("neovim/nvim-lspconfig") },
	{ src = gh("mason-org/mason.nvim") },
	{ src = gh("mason-org/mason-lspconfig.nvim") },
	{ src = gh("WhoIsSethDaniel/mason-tool-installer.nvim") },
	{ src = gh("j-hui/fidget.nvim") },
	{ src = gh("folke/lazydev.nvim") },
	{ src = gh("stevearc/conform.nvim") },

	-- treesitter
	{ src = gh("nvim-treesitter/nvim-treesitter") },
	{ src = gh("nvim-treesitter/nvim-treesitter-context") },

	-- misc
	{ src = gh("folke/todo-comments.nvim") },
}

vim.pack.add(plugins)

-- [[ Colorscheme ]]
require("kanagawa").setup({
	colors = {
		theme = { all = { ui = { bg_gutter = "none" } } },
	},
})
vim.cmd.colorscheme("kanagawa-dragon")

-- [[ gitsigns ]]
require("gitsigns").setup()

-- [[ autopairs ]] (deferred to keep startup lean)
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		require("nvim-autopairs").setup({})
	end,
})

-- [[ auto-session ]]
require("auto-session").setup({
	suppressed_dirs = { "~/", "~/Downloads", "/" },
})

-- [[ zen-mode ]]
require("zen-mode").setup({})

-- [[ typst-preview ]]
require("typst-preview").setup({})

-- [[ which-key ]]
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("which-key").setup({
			-- delay between pressing a key and opening which-key (milliseconds)
			delay = 2000,
			icons = {
				-- set icon mappings to true if you have a Nerd Font
				mappings = vim.g.have_nerd_font,
				-- If you are using a Nerd Font: set icons.keys to an empty table which will use the
				-- default which-key.nvim defined Nerd Font icons, otherwise define a string table
				keys = vim.g.have_nerd_font and {} or {
					Up = "<Up> ",
					Down = "<Down> ",
					Left = "<Left> ",
					Right = "<Right> ",
					C = "<C-…> ",
					M = "<M-…> ",
					D = "<D-…> ",
					S = "<S-…> ",
					CR = "<CR> ",
					Esc = "<Esc> ",
					ScrollWheelDown = "<ScrollWheelDown> ",
					ScrollWheelUp = "<ScrollWheelUp> ",
					NL = "<NL> ",
					BS = "<BS> ",
					Space = "<Space> ",
					Tab = "<Tab> ",
					F1 = "<F1>",
					F2 = "<F2>",
					F3 = "<F3>",
					F4 = "<F4>",
					F5 = "<F5>",
					F6 = "<F6>",
					F7 = "<F7>",
					F8 = "<F8>",
					F9 = "<F9>",
					F10 = "<F10>",
					F11 = "<F11>",
					F12 = "<F12>",
				},
			},

			-- Document existing key chains
			spec = {
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>t", group = "[T]oggle" },
				{ "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
			},
		})
	end,
})

-- [[ indent-blankline ]]
require("ibl").setup({})

-- [[ telescope ]]
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("telescope").setup({
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		-- Enable Telescope extensions if they are installed
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		-- See `:help telescope.builtin`
		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
		vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
		vim.keymap.set("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
		vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
		vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
		vim.keymap.set("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
		vim.keymap.set("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
		vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		-- Slightly advanced example of overriding default behavior and theme
		vim.keymap.set("n", "<leader>/", function()
			-- You can pass additional configuration to Telescope to change the theme, layout, etc.
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		-- It's also possible to pass additional configuration options.
		--  See `:help telescope.builtin.live_grep()` for information about particular keys
		vim.keymap.set("n", "<leader>s/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[S]earch [/] in Open Files" })

		-- Shortcut for searching your Neovim configuration files
		vim.keymap.set("n", "<leader>sn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[S]earch [N]eovim files" })
	end,
})

-- [[ lazydev ]]
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	once = true,
	callback = function()
		require("lazydev").setup({
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		})
	end,
})

-- [[ LSP ]]

-- Automatically install LSPs and related tools to stdpath for Neovim
require("mason").setup({})

-- `fidget` shows useful status updates for LSP.
require("fidget").setup({})

-- This function gets run when an LSP attaches to a particular buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		-- Define mappings specific for LSP related items.
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Rename the variable under your cursor.
		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

		-- Execute a code action, usually your cursor needs to be on top of an error
		-- or a suggestion from your LSP for this to activate.
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

		-- Find references for the word under your cursor.
		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

		-- Jump to the implementation of the word under your cursor.
		map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

		-- Jump to the definition of the word under your cursor.
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

		-- Goto declaration (e.g. the header in C).
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Fuzzy find all the symbols in your current document.
		map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

		-- Fuzzy find all the symbols in your current workspace.
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

		-- Jump to the type of the word under your cursor.
		map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

		-- Highlight references of the word under your cursor when it rests there.
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.document_highlight,
			})

			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				buffer = event.buf,
				group = highlight_augroup,
				callback = vim.lsp.buf.clear_references,
			})

			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
				callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({
						group = "kickstart-lsp-highlight",
						buffer = event2.buf,
					})
				end,
			})

			-- Toggle inlay hints, if the language server supports them.
			map("<leader>th", function()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})

-- Diagnostic Config
-- See :help vim.diagnostic.Opts
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

-- Extra capabilities provided by blink.cmp, broadcast to all servers.
local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

-- Enable the following language servers. They are installed by Mason.
--
-- Available keys are:
--  - cmd (table): Override the default command used to start the server
--  - filetypes (table): Override the default list of associated filetypes for the server
--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
--  - settings (table): Override the default settings passed when initializing the server.
local servers = {
	clangd = {},
	harper_ls = {
		filetypes = { "markdown", "typst" },
	},
	-- gopls = {},
	-- pyright = {},
	rust_analyzer = {},
	-- ts_ls = {},
	lua_ls = {
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				-- diagnostics = { disable = { "missing-fields" } },
			},
		},
	},
}

for name, server in pairs(servers) do
	vim.lsp.config(name, server)
end

-- Ensure the servers and tools above are installed.
-- To check the current status of installed tools and/or manually install
-- other tools, run `:Mason`.
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
	"stylua", -- Used to format Lua code
})
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

-- `mason-lspconfig` enables every server installed by Mason (`vim.lsp.enable`).
require("mason-lspconfig").setup({
	ensure_installed = {}, -- installs are handled by mason-tool-installer
	automatic_enable = true,
})

-- Cpp config
vim.lsp.enable("clangd")

-- [[ conform: autoformat ]]
require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		-- Disable "format_on_save lsp_fallback" for languages that don't
		-- have a well standardized coding style.
		local disable_filetypes = { lang = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		else
			return {
				timeout_ms = 500,
				lsp_format = "fallback",
			}
		end
	end,
	formatters = {
		customtypstyle = {
			command = "typstyle",
			args = { "--wrap-text", "--line-width", "80" },
		},
		remove_extra_newlines = {
			command = "sd",
			args = { "-p", "--across", "\n\n\n*", "\n\n" },
		},
	},
	formatters_by_ft = {
		lua = { "stylua" },
		typst = { "customtypstyle", "remove_extra_newlines", "trim_newlines" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		html = { "biome-check" },
		javascript = { "biome-check" },
		typescript = { "biome-check" },
		json = { "biome-check" },
		jsonc = { "biome-check" },
		css = { "biome-check" },
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
	},
})

vim.keymap.set("", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- [[ blink.cmp: autocompletion ]]
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "default",
			},

			appearance = {
				-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				nerd_font_variant = "mono",
			},

			completion = {
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},

			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},

			snippets = { preset = "luasnip" },

			fuzzy = { implementation = "lua" },

			-- Shows a signature help window while you type arguments for a function
			signature = { enabled = true },
		})
	end,
})

-- [[ todo-comments ]]
require("todo-comments").setup({ signs = false })

-- [[ mini.nvim ]]
require("mini.ai").setup({ n_lines = 500 })
require("mini.surround").setup()

local devicons = require("nvim-web-devicons")
devicons.setup()

local statusline = require("mini.statusline")
statusline.setup({
	use_icons = vim.g.have_nerd_font,

	content = {
		active = function()
			local mode, mode_hl = statusline.section_mode({ trunc_width = 1000 })
			local git = statusline.section_git({ trunc_width = 40 })
			local diff = statusline.section_diff({ trunc_width = 75 })
			local diagnostics = statusline.section_diagnostics({ trunc_width = 75 })
			local filename = function()
				-- In terminal always use plain name
				if vim.bo.buftype == "terminal" then
					return "%t"
				else
					-- File name with 'truncate', 'modified', 'readonly' flags
					-- Use relative path
					return string.format(
						"%s %s",
						devicons.get_icon(vim.fn.expand("%:t"), nil, { default = true }),
						"%f%m%r"
					)
				end
			end
			local fileinfo = function()
				-- Construct output string with extra file info
				local get_size = function()
					local size = math.max(vim.fn.line2byte(vim.fn.line("$") + 1) - 1, 0)
					if size < 1024 then
						return string.format("%dB", size)
					elseif size < 1048576 then
						return string.format("%.2fKiB", size / 1024)
					else
						return string.format("%.2fMiB", size / 1048576)
					end
				end

				return string.format("%s", get_size())
			end
			local location = "%L"
			local search = statusline.section_searchcount({ trunc_width = 75 })

			return statusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git, diff, diagnostics } },
				"%<", -- Mark general truncate point
				{ hl = "MiniStatuslineFilename", strings = { filename() } },
				"%=", -- End left alignment
				{ hl = "MiniStatuslineFileinfo", strings = { fileinfo() } },
				{ hl = mode_hl, strings = { search, location } },
			})
		end,
	},
})

-- Sections can be overridden, e.g. cursor location as LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return "%2l:%-2v"
end

-- [[ fold-imports ]]
vim.api.nvim_create_autocmd("BufRead", {
	once = true,
	callback = function()
		require("fold_imports").setup({})
	end,
})

-- [[ nvim-tree ]]
-- disable netrw at the very start
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

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
			},
		},
	},
	filters = {
		dotfiles = true,
		custom = { "*.png", "*.svg", "*.pdf" },
	},
})

vim.keymap.set("n", "<leader>t", ":NvimTreeFindFileToggle<cr>", { silent = true, desc = "Open file Tree" })

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
			for _, w in ipairs(invalid_win) do
				vim.api.nvim_win_close(w, true)
			end
		end
	end,
})

-- [[ trouble ]]
require("trouble").setup({})

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>xX",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Buffer Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>cl",
	"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
	{ desc = "LSP Definitions / references / ... (Trouble)" }
)
vim.keymap.set("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
vim.keymap.set("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })

-- [[ url-open ]]
local status_ok, url_open = pcall(require, "url-open")
if status_ok then
	url_open.setup({})
end

-- [[ treesitter ]]
-- NOTE: nvim-treesitter's `main` branch is a rewrite: parsers are installed
-- explicitly and highlighting/indent are enabled per filetype.
require("nvim-treesitter").setup({})
require("nvim-treesitter").install({
	"bash",
	"c",
	"diff",
	"html",
	"lua",
	"luadoc",
	"typescript",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
	"swift",
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function(event)
		if not pcall(vim.treesitter.start, event.buf) then
			return -- no parser for this filetype
		end
		-- vim regex indenting works better for ruby
		if vim.bo[event.buf].filetype ~= "ruby" then
			vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})

-- [[ treesitter-context ]]
require("treesitter-context").setup({})

-- [[ tinymist (typst) ]]
vim.lsp.config("tinymist", {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	settings = {
		formatterMode = "customtypstyle",
		semanticTokens = "disable",
	},
})
vim.lsp.enable("tinymist")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	callback = function()
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
	end,
})

-- [[ Notes / scratch ]]
-- Plugins that are not installed (yet). Add `{ src = gh("...") }` to `plugins`
-- above when you want them.
--
-- vim.pack.add({
--   gh("ibhagwan/fzf-lua"),
--   gh("pmizio/typescript-tools.nvim"),
--   gh("kawre/leetcode.nvim"),
--   gh("folke/snacks.nvim"),
--   gh("MunifTanjim/nui.nvim"),
--   gh("mfussenegger/nvim-dap"),
--   gh("rcarriga/nvim-dap-ui"),
--   gh("wojciech-kulik/xcodebuild.nvim"),
-- })
--
-- require("typescript-tools").setup({})
-- vim.lsp.config("typescript", {})
-- vim.lsp.enable("typescript")
--
-- require("leetcode").setup({
--   lang = "python3",
--   injector = {
--     ["cpp"] = {
--       imports = function()
--         return { "#include <vector>", "using namespace std;" }
--       end,
--       after = "int main() {}",
--     },
--   },
-- })
--
-- -- also see https://www.swift.org/documentation/articles/zero-to-swift-nvim.html
-- vim.lsp.config["sourcekit"] = {
--   capabilities = {
--     workspace = {
--       didChangeWatchedFiles = {
--         dynamicRegistration = true,
--       },
--     },
--   },
-- }
-- vim.lsp.enable("sourcekit")
-- require("xcodebuild").setup()
-- vim.api.nvim_set_keymap("n", "<leader>x", ":XcodebuildPicker<cr>", { silent = true, noremap = true })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
