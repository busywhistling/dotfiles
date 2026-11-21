--[[
  paramjit's minimal config
  design goals:
    - single file
    - native nvim features (>= 0.12), plugins via `vim.pack` (no third-party manager)
    - only include what is actually used / configure only when necessary
    - usage convenience and comfort over config simplicity
]]

-- Byte-compile Lua modules. Off by default in 0.12; call before anything is required.
vim.loader.enable()

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
o.signcolumn = "yes" -- never shift text when diagnostics appear
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
o.ignorecase = true -- `smartcase` only matters when this is on
o.smartcase = true
o.swapfile = false
o.updatetime = 250 -- default is 4000ms; keeps CursorHold (LSP/gitsigns) fresh
o.grepprg = "rg --vimgrep --smart-case --hidden"
o.grepformat = "%f:%l:%c:%m"

-- spell is enabled per filetype (see the autocmd at the bottom; currently disabled)
o.spelllang = "en_gb"
o.fillchars = { eob = " " }

o.clipboard = "unnamedplus" -- sync clipboard between OS & nvim
o.shell = vim.env.SHELL
o.termguicolors = true
o.winborder = "rounded" -- border for every floating window (hover, signature, ...)

local g = vim.g
g.mapleader = " "
g.maplocalleader = " "
-- disable netrw, nvim-tree takes over
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

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

-- [[ Helpers ]]
-- lazy.nvim used to `pcall` every plugin's config. A plain init.lua aborts on
-- the first error, so report instead of throwing and keep loading the rest.
local function try(fn, what)
	local ok, err = pcall(fn)
	if not ok then
		vim.notify(("[init] %s: %s"):format(what or "error", err), vim.log.levels.ERROR)
	end
	return ok and err or nil
end

local function setup(module, opts)
	local ok, mod = pcall(require, module)
	if not ok then
		vim.notify(("[init] require(%q): %s"):format(module, mod), vim.log.levels.ERROR)
		return
	end
	local ok2, err = pcall(mod.setup, opts)
	if not ok2 then
		vim.notify(("[init] %s.setup(): %s"):format(module, err), vim.log.levels.ERROR)
	end
end

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
try(function()
	require("kanagawa").setup({
		colors = {
			theme = { all = { ui = { bg_gutter = "none" } } },
		},
	})
	vim.cmd.colorscheme("kanagawa-dragon")
end, "colorscheme")

-- [[ gitsigns ]]
setup("gitsigns")

-- [[ autopairs ]] (deferred to keep startup lean)
vim.api.nvim_create_autocmd("InsertEnter", {
	once = true,
	callback = function()
		setup("nvim-autopairs", {})
	end,
})

-- [[ auto-session ]]
setup("auto-session", {
	suppressed_dirs = { "~/", "~/Downloads", "/" },
})

-- [[ zen-mode ]]
setup("zen-mode", {})

-- [[ typst-preview ]]
setup("typst-preview", {})

-- [[ which-key ]]
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		setup("which-key", {
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
setup("ibl", {})

-- [[ telescope ]]
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		setup("telescope", {
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
		setup("lazydev", {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		})
	end,
})

-- [[ LSP ]]

-- Automatically install LSPs and related tools to stdpath for Neovim
setup("mason", {})

-- `fidget` shows useful status updates for LSP.
setup("fidget", {})

-- This function gets run when an LSP attaches to a particular buffer.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		-- Define mappings specific for LSP related items.
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Built-in defaults already cover: grn (rename), gra (code action),
		-- grr (references), gri (implementation), grt (type definition),
		-- grx, gO (document symbol) and K (hover). Only add what differs.

		-- Jump to the definition of the word under your cursor (Telescope).
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

		-- Deliberately override Vim's `gd` (local declaration) with the LSP.
		map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition (LSP)")

		-- Goto declaration (e.g. the header in C).
		map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

		-- Fuzzy find all the symbols in your current workspace.
		map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

		-- Highlight references of the word under your cursor when it rests there.
		-- Only register for servers that actually support documentHighlight:
		-- harper_ls (markdown/typst) does not, and asking it to would notify
		-- 'method "textDocument/documentHighlight" is not supported' on every CursorHold.
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client then
			local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
			-- Guard against double registration when a second supporting server attaches.
			local already_registered = #vim.api.nvim_get_autocmds({
				group = highlight_augroup,
				event = "CursorHold",
				buffer = event.buf,
			}) > 0
			if client:supports_method("textDocument/documentHighlight", event.buf) and not already_registered then
				vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = function()
						-- Re-check at fire time: the supporting server may have gone away.
						if
							#vim.lsp.get_clients({ bufnr = event.buf, method = "textDocument/documentHighlight" }) == 0
						then
							return
						end
						vim.lsp.buf.document_highlight()
					end,
				})

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = event.buf,
					group = highlight_augroup,
					callback = vim.lsp.buf.clear_references,
				})
			end

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
	-- Only show diagnostics for the cursor line, on their own line.
	-- (Use `virtual_text = { ... }` instead if you prefer inline messages.)
	virtual_lines = { current_line = true },
})

-- Use the chezmoi-managed taplo config regardless of the buffer cwd.
vim.env.TAPLO_CONFIG = vim.fn.expand("~/.config/taplo/taplo.toml")

-- Extra capabilities provided by blink.cmp, broadcast to all servers.
local capabilities = try(function()
	return require("blink.cmp").get_lsp_capabilities()
end) or {}
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
	-- harper_ls = {
	-- 	filetypes = { "markdown", "typst" },
	-- 	-- harper-ls pulls its config with workspace/configuration and reads
	-- 	-- client.settings. Without this it received `[]` and logged
	-- 	-- "Settings must be an object." on every change.
	-- 	settings = { ["harper-ls"] = vim.empty_dict() },
	-- },
	-- gopls = {},
	-- pyright = {},
	ruff = {},
	rust_analyzer = {
		settings = {
			["rust-analyzer"] = {
				-- Surface clippy lints, not only `cargo check` errors.
				check = { command = "clippy" },
			},
		},
	},
	taplo = {},
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

-- Enable explicitly. `mason-lspconfig`'s automatic_enable only sees servers
-- Mason installed, so a compiler-provided server (e.g. rustup's
-- rust-analyzer) would otherwise never start.
vim.lsp.enable({
	"clangd",
	-- "harper_ls",
	"lua_ls",
	"ruff",
	"rust_analyzer",
	"taplo",
})

-- Ensure the servers and tools above are installed.
-- To check the current status of installed tools and/or manually install
-- other tools, run `:Mason`.
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
	"stylua", -- Used to format Lua code
	"ruff", -- python formatter/linter (conform)
	"biome", -- js/ts/json/css formatter (conform)
	"clang-format", -- c/cpp formatter (conform)
})
setup("mason-tool-installer", { ensure_installed = ensure_installed })

setup("mason-lspconfig", {
	ensure_installed = {}, -- installs are handled by mason-tool-installer
	automatic_enable = false, -- handled by the explicit `vim.lsp.enable()` above
})

-- fishfmt is installed by chezmoi into ~/.local/bin, which a GUI-launched
-- nvim does not always have on PATH.
local fishfmt = vim.fn.exepath("fishfmt")
if fishfmt == "" then
	fishfmt = vim.fn.expand("~/.local/bin/fishfmt")
end

-- [[ conform: autoformat ]]
setup("conform", {
	notify_on_error = false,
	format_on_save = function(bufnr)
		-- Opt out of format-on-save per filetype by adding e.g. `cpp = true`.
		-- (The old table had a `lang` key, which is not a real filetype.)
		local disable_filetypes = {}
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
		fishfmt = {
			-- fishfmt edits files in place, so conform gives it a temp copy.
			command = fishfmt,
			args = { "--skip-vendored", "$FILENAME" },
			stdin = false,
		},
	},
	formatters_by_ft = {
		fish = { "fishfmt" },
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
		toml = { "taplo" },
		python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
		rust = { "rustfmt" },
	},
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "[F]ormat buffer" })

-- [[ blink.cmp: autocompletion ]]
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		setup("blink.cmp", {
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
setup("todo-comments", { signs = false })

-- [[ mini.nvim ]]
try(function()
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
end, "mini.nvim")

-- [[ fold-imports ]]
vim.api.nvim_create_autocmd("BufRead", {
	once = true,
	callback = function()
		setup("fold_imports", {})
	end,
})

-- [[ nvim-tree ]]
setup("nvim-tree", {
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
setup("trouble", {})

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
setup("url-open", {})

-- [[ treesitter ]]
-- NOTE: nvim-treesitter's `main` branch is a rewrite: parsers are installed
-- explicitly and highlighting/indent are enabled per filetype.
try(function()
	local ts = require("nvim-treesitter")
	ts.setup({})
	ts.install({
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
end, "treesitter")

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
setup("treesitter-context", {})

-- [[ tinymist (typst) ]]
vim.lsp.config("tinymist", {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	settings = {
		-- tinymist only accepts "disable", "typstyle" or "typstfmt".
		-- ("customtypstyle" made every start log a bad-configuration error.)
		formatterMode = "typstyle",
		semanticTokens = "disable",
	},
})
vim.lsp.enable("tinymist")

-- [[ Quality of life ]]

-- Spell only where prose is expected (the old config enabled it globally).
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "gitcommit", "markdown", "text", "typst" },
-- 	callback = function()
-- 		vim.opt_local.spell = true
-- 	end,
-- })

-- Restore the cursor to where it was when the file was last open.
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function(event)
		local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
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
