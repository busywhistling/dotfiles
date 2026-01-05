--[[
  paramjit's minimal config
  design goals:
    - single file
    - use native nvim features (>= 0.11.5)
    - only include what is actually used / configure only when necessary
    - usage convenience and comfort over config simplicity
]]
local hostname = vim.loop.os_gethostname()

local o = vim.opt
o.tabstop = 2
o.shiftwidth = 2 -- new line indents should be 2
o.softtabstop = 2
o.expandtab = true -- spaces instead of tabs
o.autoread = true
o.number = true
o.relativenumber = true -- to help with jumping
-- schedule setting after `UiEnter` to avoid increasing startup-time
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
o.ignorecase = true
o.smartcase = true
o.swapfile = false
-- o.foldmethod = "indent"
-- o.foldlevel = 99
-- o.foldnestmax = 1
o.grepprg = "rg --vimgrep --smart-case --hidden"
o.grepformat = "%f:%l:%c:%m"

o.spell = true
o.spelllang = "en_gb"
-- local project_spells = require("utils").get_root_dir .. "/spell_en.utf-8.add"
o.fillchars = { eob = " " }

if hostname == "macbook" then
	vim.schedule(function()
		o.clipboard = "unnamedplus" -- sync clipboard between OS & nvim
	end)
	o.shell = "/opt/homebrew/bin/fish"
end

local g = vim.g
g.mapleader = " "
g.maplocalleader = " "

vim.diagnostic.config({ virtual_text = true })

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover.
--
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
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

-- [[ Install `lazy.nvim` plugin manager ]]
-- See `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--  To check the current status of your plugins, run `:Lazy`

-- NOTE: Here is where you install your plugins.
-- NOTE: Plugins can also be added by using a table,
-- with the first argument being the link and the following
-- keys can be used to configure plugin behavior/loading/etc.
--
-- Use `opts = {}` to automatically pass options to a plugin's `setup()` function, forcing the plugin to be loaded.
-- Alternatively, use `config = function() ... end` for full control over the configuration.
--
-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `opts` key (recommended), the configuration runs
-- after the plugin has been loaded as `require(MODULE).setup(opts)`.

require("lazy").setup({
	spec = {
		-- TODO: add your plugins here
		{
			"lewis6991/gitsigns.nvim",
		},
		{
			"windwp/nvim-autopairs",
			event = "InsertEnter",
			config = true,
		},
		{
			"rmagatti/auto-session",
			lazy = false,
			---enables autocomplete for opts
			---@module "auto-session"
			---@type AutoSession.Config
			opts = {
				suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
				-- log_level = 'debug',
			},
		},
		{
			"chomosuke/typst-preview.nvim",
			lazy = false, -- or ft = 'typst'
			version = "1.*",
			opts = {}, -- lazy.nvim will implicitly calls `setup {}`
		},
		{ -- Useful plugin to show you pending keybinds.
			"folke/which-key.nvim",
			event = "VimEnter", -- Sets the loading event to 'VimEnter'
			opts = {
				-- delay between pressing a key and opening which-key (milliseconds)
				-- this setting is independent of vim.o.timeoutlen
				delay = 2000, -- delay of 2sec
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
			},
		},

		{
			"lukas-reineke/indent-blankline.nvim",
			main = "ibl",
			opts = {},
		},

		-- NOTE: Plugins can specify dependencies.
		--
		-- The dependencies are proper plugin specifications as well - anything
		-- you do for a plugin at the top level, you can do for a dependency.
		--
		-- Use the `dependencies` key to specify the dependencies of a particular plugin

		{ -- Fuzzy Finder (files, lsp, etc)
			"nvim-telescope/telescope.nvim",
			event = "VimEnter",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ -- If encountering errors, see telescope-fzf-native README for installation instructions
					"nvim-telescope/telescope-fzf-native.nvim",

					-- `build` is used to run some command when the plugin is installed/updated.
					-- This is only run then, not every time Neovim starts up.
					build = "make",

					-- `cond` is a condition used to determine whether this plugin should be
					-- installed and loaded.
					cond = function()
						return vim.fn.executable("make") == 1
					end,
				},
				{ "nvim-telescope/telescope-ui-select.nvim" },

				-- Useful for getting pretty icons, but requires a Nerd Font.
				{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
			},
			config = function()
				-- Telescope is a fuzzy finder that comes with a lot of different things that
				-- it can fuzzy find! It's more than just a "file finder", it can search
				-- many different aspects of Neovim, your workspace, LSP, and more!
				--
				-- The easiest way to use Telescope, is to start by doing something like:
				--  :Telescope help_tags
				--
				-- After running this command, a window will open up and you're able to
				-- type in the prompt window. You'll see a list of `help_tags` options and
				-- a corresponding preview of the help.
				--
				-- Two important keymaps to use while in Telescope are:
				--  - Insert mode: <c-/>
				--  - Normal mode: ?
				--
				-- This opens a window that shows you all of the keymaps for the current
				-- Telescope picker. This is really useful to discover what Telescope can
				-- do as well as how to actually do it!

				-- [[ Configure Telescope ]]
				-- See `:help telescope` and `:help telescope.setup()`
				require("telescope").setup({
					-- You can put your default mappings / updates / etc. in here
					--  All the info you're looking for is in `:help telescope.setup()`
					--
					-- defaults = {
					--   mappings = {
					--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
					--   },
					-- },
					-- pickers = {}
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
				-- vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
				-- vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
				-- vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
				-- vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

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
		},

		-- LSP Plugins
		{
			-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
			-- used for completion, annotations and signatures of Neovim apis
			"folke/lazydev.nvim",
			ft = "lua",
			opts = {
				library = {
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
		},

		{
			-- Main LSP Configuration
			"neovim/nvim-lspconfig",
			dependencies = {
				-- Automatically install LSPs and related tools to stdpath for Neovim
				-- Mason must be loaded before its dependents so we need to set it up here.
				-- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
				{ "mason-org/mason.nvim", opts = {} },
				"mason-org/mason-lspconfig.nvim",
				"WhoIsSethDaniel/mason-tool-installer.nvim",

				-- Useful status updates for LSP.
				{ "j-hui/fidget.nvim", opts = {} },

				-- Allows extra capabilities provided by blink.cmp
				"saghen/blink.cmp",
			},
			config = function()
				-- Brief aside: **What is LSP?**
				--
				-- LSP is an initialism you've probably heard, but might not understand what it is.
				--
				-- LSP stands for Language Server Protocol. It's a protocol that helps editors
				-- and language tooling communicate in a standardized fashion.
				--
				-- In general, you have a "server" which is some tool built to understand a particular
				-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
				-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
				-- processes that communicate with some "client" - in this case, Neovim!
				--
				-- LSP provides Neovim with features like:
				--  - Go to definition
				--  - Find references
				--  - Autocompletion
				--  - Symbol Search
				--  - and more!
				--
				-- Thus, Language Servers are external tools that must be installed separately from
				-- Neovim. This is where `mason` and related plugins come into play.
				--
				-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
				-- and elegantly composed help section, `:help lsp-vs-treesitter`

				--  This function gets run when an LSP attaches to a particular buffer.
				--    That is to say, every time a new file is opened that is associated with
				--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
				--    function will be executed to configure the current buffer
				vim.api.nvim_create_autocmd("LspAttach", {
					group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
					callback = function(event)
						-- NOTE: Remember that Lua is a real programming language, and as such it is possible
						-- to define small helper and utility functions so you don't have to repeat yourself.
						--
						-- In this case, we create a function that lets us more easily define mappings specific
						-- for LSP related items. It sets the mode, buffer and description for us each time.
						local map = function(keys, func, desc, mode)
							mode = mode or "n"
							vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
						end

						-- Rename the variable under your cursor.
						--  Most Language Servers support renaming across files, etc.
						map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

						-- Execute a code action, usually your cursor needs to be on top of an error
						-- or a suggestion from your LSP for this to activate.
						map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

						-- Find references for the word under your cursor.
						map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

						-- Jump to the implementation of the word under your cursor.
						--  Useful when your language has ways of declaring types without an actual implementation.
						map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

						-- Jump to the definition of the word under your cursor.
						--  This is where a variable was first declared, or where a function is defined, etc.
						--  To jump back, press <C-t>.
						map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

						-- WARN: This is not Goto Definition, this is Goto Declaration.
						--  For example, in C this would take you to the header.
						map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

						-- Fuzzy find all the symbols in your current document.
						--  Symbols are things like variables, functions, types, etc.
						map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")

						-- Fuzzy find all the symbols in your current workspace.
						--  Similar to document symbols, except searches over your entire project.
						map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")

						-- Jump to the type of the word under your cursor.
						--  Useful when you're not sure what type a variable is and you want to see
						--  the definition of its *type*, not where it was *defined*.
						map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

						-- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
						---@param client vim.lsp.Client
						---@param method vim.lsp.protocol.Method
						---@param bufnr? integer some lsp support methods only in specific files
						---@return boolean
						local function client_supports_method(client, method, bufnr)
							if vim.fn.has("nvim-0.11") == 1 then
								return client:supports_method(method, bufnr)
							else
								return client.supports_method(method, { bufnr = bufnr })
							end
						end

						-- The following two autocommands are used to highlight references of the
						-- word under your cursor when your cursor rests there for a little while.
						--    See `:help CursorHold` for information about when this is executed
						--
						-- When you move your cursor, the highlights will be cleared (the second autocommand).
						local client = vim.lsp.get_client_by_id(event.data.client_id)
						if
							client
							and client_supports_method(
								client,
								vim.lsp.protocol.Methods.textDocument_documentHighlight,
								event.buf
							)
						then
							local highlight_augroup =
								vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
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
						end

						-- The following code creates a keymap to toggle inlay hints in your
						-- code, if the language server you are using supports them
						--
						-- This may be unwanted, since they displace some of your code
						if
							client
							and client_supports_method(
								client,
								vim.lsp.protocol.Methods.textDocument_inlayHint,
								event.buf
							)
						then
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

				-- LSP servers and clients are able to communicate to each other what features they support.
				--  By default, Neovim doesn't support everything that is in the LSP specification.
				--  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
				--  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
				local capabilities = require("blink.cmp").get_lsp_capabilities()

				-- Enable the following language servers
				--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
				--
				--  Add any additional override configuration in the following tables. Available keys are:
				--  - cmd (table): Override the default command used to start the server
				--  - filetypes (table): Override the default list of associated filetypes for the server
				--  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
				--  - settings (table): Override the default settings passed when initializing the server.
				--        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
				local servers = {
					-- clangd = {},
					-- gopls = {},
					-- pyright = {},
					-- rust_analyzer = {},
					-- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
					--
					-- Some languages (like typescript) have entire language plugins that can be useful:
					--    https://github.com/pmizio/typescript-tools.nvim
					--
					-- But for many setups, the LSP (`ts_ls`) will work just fine
					-- ts_ls = {},
					--

					lua_ls = {
						-- cmd = { ... },
						-- filetypes = { ... },
						-- capabilities = {},
						settings = {
							Lua = {
								completion = {
									callSnippet = "Replace",
								},
								-- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
								-- diagnostics = { disable = { 'missing-fields' } },
							},
						},
					},
					-- vim.lsp.config("lua_ls", {
					--   cmd = { "lua-language-server" },
					--   filetypes = { "lua" },
					--   -- Sets the "workspace" to the directory where any of these files is found.
					--   -- Files that share a root directory will reuse the LSP server connection.
					--   -- Nested lists indicate equal priority.
					--   root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
					--   -- Specific settings to send to the server. The schema is server-defined.
					--   -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
					--   settings = {
					--     Lua = {
					--       runtime = { version = "LuaJIT" },
					--       diagnostics = { globals = { "vim" } }
					--     }
					--   }
					-- })
				}

				-- Ensure the servers and tools above are installed
				--
				-- To check the current status of installed tools and/or manually install
				-- other tools, you can run
				--    :Mason
				--
				-- You can press `g?` for help in this menu.
				--
				-- `mason` had to be setup earlier: to configure its options see the
				-- `dependencies` table for `nvim-lspconfig` above.
				--
				-- You can add other tools here that you want Mason to install
				-- for you, so that they are available from within Neovim.
				local ensure_installed = vim.tbl_keys(servers or {})
				vim.list_extend(ensure_installed, {
					"stylua", -- Used to format Lua code
				})
				require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

				require("mason-lspconfig").setup({
					ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
					automatic_installation = false,
					handlers = {
						function(server_name)
							local server = servers[server_name] or {}
							-- This handles overriding only values explicitly passed
							-- by the server configuration above. Useful when disabling
							-- certain features of an LSP (for example, turning off formatting for ts_ls)
							server.capabilities =
								vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
							require("lspconfig")[server_name].setup(server)
						end,
					},
				})
			end,
		},

		{ -- Autoformat
			"stevearc/conform.nvim",
			event = { "BufWritePre" },
			cmd = { "ConformInfo" },
			keys = {
				{
					"<leader>f",
					function()
						require("conform").format({ async = true, lsp_format = "fallback" })
					end,
					mode = "",
					desc = "[F]ormat buffer",
				},
			},
			opts = {
				notify_on_error = false,
				format_on_save = function(bufnr)
					-- Disable "format_on_save lsp_fallback" for languages that don't
					-- have a well standardized coding style. You can add additional
					-- languages here or re-enable it for the disabled ones.
					local disable_filetypes = { c = true, cpp = true }
					if disable_filetypes[vim.bo[bufnr].filetype] then
						return nil
					else
						return {
							timeout_ms = 500,
							lsp_format = "fallback",
						}
					end
				end,
				formatters_by_ft = {
					lua = { "stylua" },
					-- Conform can also run multiple formatters sequentially
					-- python = { "isort", "black" },
					--
					-- You can use 'stop_after_first' to run the first available formatter from the list
					-- javascript = { "prettierd", "prettier", stop_after_first = true },
				},
			},
		},

		{ -- Autocompletion
			"saghen/blink.cmp",
			event = "VimEnter",
			version = "1.*",
			dependencies = {
				-- Snippet Engine
				{
					"L3MON4D3/LuaSnip",
					version = "2.*",
					build = (function()
						-- Build Step is needed for regex support in snippets.
						-- This step is not supported in many windows environments.
						-- Remove the below condition to re-enable on windows.
						if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
							return
						end
						return "make install_jsregexp"
					end)(),
					dependencies = {
						-- `friendly-snippets` contains a variety of premade snippets.
						--    See the README about individual language/framework/plugin snippets:
						--    https://github.com/rafamadriz/friendly-snippets
						-- {
						--   'rafamadriz/friendly-snippets',
						--   config = function()
						--     require('luasnip.loaders.from_vscode').lazy_load()
						--   end,
						-- },
					},
					opts = {},
				},
				"folke/lazydev.nvim",
			},
			--- @module 'blink.cmp'
			--- @type blink.cmp.Config
			opts = {
				keymap = {
					-- 'default' (recommended) for mappings similar to built-in completions
					--   <c-y> to accept ([y]es) the completion.
					--    This will auto-import if your LSP supports it.
					--    This will expand snippets if the LSP sent a snippet.
					-- 'super-tab' for tab to accept
					-- 'enter' for enter to accept
					-- 'none' for no mappings
					--
					-- For an understanding of why the 'default' preset is recommended,
					-- you will need to read `:help ins-completion`
					--
					-- No, but seriously. Please read `:help ins-completion`, it is really good!
					--
					-- All presets have the following mappings:
					-- <tab>/<s-tab>: move to right/left of your snippet expansion
					-- <c-space>: Open menu or open docs if already open
					-- <c-n>/<c-p> or <up>/<down>: Select next/previous item
					-- <c-e>: Hide menu
					-- <c-k>: Toggle signature help
					--
					-- See :h blink-cmp-config-keymap for defining your own keymap
					preset = "default",

					-- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
					--    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
				},

				appearance = {
					-- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
					-- Adjusts spacing to ensure icons are aligned
					nerd_font_variant = "mono",
				},

				completion = {
					-- By default, you may press `<c-space>` to show the documentation.
					-- Optionally, set `auto_show = true` to show the documentation after a delay.
					documentation = { auto_show = false, auto_show_delay_ms = 500 },
				},

				sources = {
					default = { "lsp", "path", "snippets", "lazydev" },
					providers = {
						lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
					},
				},

				snippets = { preset = "luasnip" },

				-- Blink.cmp includes an optional, recommended rust fuzzy matcher,
				-- which automatically downloads a prebuilt binary when enabled.
				--
				-- By default, we use the Lua implementation instead, but you may enable
				-- the rust implementation via `'prefer_rust_with_warning'`
				--
				-- See :h blink-cmp-config-fuzzy for more information
				fuzzy = { implementation = "lua" },

				-- Shows a signature help window while you type arguments for a function
				signature = { enabled = true },
			},
		},

		{ -- You can easily change to a different colorscheme.
			-- Change the name of the colorscheme plugin below, and then
			-- change the command in the config to whatever the name of that colorscheme is.
			--
			-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
			"rebelot/kanagawa.nvim",
			priority = 1000, -- Make sure to load this before all the other start plugins.
			config = function()
				---@diagnostic disable-next-line: missing-fields
				require("kanagawa").setup({
					colors = {
						theme = { all = { ui = { bg_gutter = "none" } } },
					},
				})

				-- Load the colorscheme here.
				vim.cmd.colorscheme("kanagawa-dragon")
			end,
		},

		-- Highlight todo, notes, etc in comments
		{
			"folke/todo-comments.nvim",
			event = "VimEnter",
			dependencies = { "nvim-lua/plenary.nvim" },
			opts = { signs = false },
		},

		{ -- Collection of various small independent plugins/modules
			"echasnovski/mini.nvim",
			config = function()
				-- Better Around/Inside textobjects
				--
				-- Examples:
				--  - va)  - [V]isually select [A]round [)]paren
				--  - yinq - [Y]ank [I]nside [N]ext [Q]uote
				--  - ci'  - [C]hange [I]nside [']quote
				require("mini.ai").setup({ n_lines = 500 })

				-- Add/delete/replace surroundings (brackets, quotes, etc.)
				--
				-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
				-- - sd'   - [S]urround [D]elete [']quotes
				-- - sr)'  - [S]urround [R]eplace [)] [']
				require("mini.surround").setup()

				-- Simple and easy statusline.
				--  You could remove this setup call if you don't like it,
				--  and try some other statusline plugin
				local devicons = require("nvim-web-devicons")
				devicons.setup()

				local statusline = require("mini.statusline")
				statusline.setup({
					use_icons = vim.g.have_nerd_font, -- set use_icons to true if you have a Nerd Font

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
									-- return '%F%m%r'
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
							local location = "%L" -- statusline.section_location({ trunc_width = 1000 })
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

				-- You can configure sections in the statusline by overriding their
				-- default behavior. For example, here we set the section for
				-- cursor location to LINE:COLUMN
				---@diagnostic disable-next-line: duplicate-set-field
				statusline.section_location = function()
					return "%2l:%-2v"
				end

				-- ... and there is more!
				--  Check out: https://github.com/echasnovski/mini.nvim
			end,
		},
		{
			"nvim-tree/nvim-tree.lua",
			config = function()
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

				vim.api.nvim_set_keymap(
					"n",
					"<leader>t",
					":NvimTreeFindFileToggle<cr>",
					{ silent = true, noremap = true, desc = "Open file Tree" }
				)

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
			end,
		},

		{ -- Highlight, edit, and navigate code
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
			opts = {
				ensure_installed = {
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
				},
				-- Autoinstall languages that are not installed
				auto_install = true,
				highlight = {
					enable = true,
					-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
					--  If you are experiencing weird indenting issues, add the language to
					--  the list of additional_vim_regex_highlighting and disabled languages for indent.
					additional_vim_regex_highlighting = { "ruby" },
				},
				indent = { enable = true, disable = { "ruby" } },
			},

			-- There are additional nvim-treesitter modules that you can use to interact
			-- with nvim-treesitter. You should go explore a few and see what interests you:
			--
			--    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
			--    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
		},
		{
			"nvim-treesitter/nvim-treesitter-context",
		},
	},
	{
		ui = {
			-- If you are using a Nerd Font: set icons to an empty table which will use the
			-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
			icons = vim.g.have_nerd_font and {} or {
				cmd = "⌘",
				config = "🛠",
				event = "📅",
				ft = "📂",
				init = "⚙",
				keys = "🗝",
				plugin = "🔌",
				runtime = "💻",
				require = "🌙",
				source = "📄",
				start = "🚀",
				task = "📌",
				lazy = "💤 ",
			},
		},
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "kanagawa-dragon" } },
	-- automatically check for plugin updates
	-- enabling the following will startup the plugin updates window upon opening
	-- neovim each time
	checker = { enabled = false },
})

-- vim.pack.add({
--   "https://github.com/ibhagwan/fzf-lua",
--   "https://github.com/folke/trouble.nvim",
--   "https://github.com/pmizio/typescript-tools.nvim",
--   "https://github.com/kawre/leetcode.nvim",
--   "https://github.com/folke/snacks.nvim",
--   "https://github.com/MunifTanjim/nui.nvim",
--   "https://github.com/mfussenegger/nvim-dap",
--   "https://github.com/rcarriga/nvim-dap-ui",
--   "https://github.com/wojciech-kulik/xcodebuild.nvim",
--   "https://github.com/dmtrKovalenko/fold-imports.nvim",
-- })
-- -- require("mini.completion").setup({
-- --   mappings = {
-- --     -- Scroll info/signature window down/up. When overriding, check for
-- --     -- conflicts with built-in keys for popup menu (like `<C-u>`/`<C-o>`
-- --     -- for 'completefunc'/'omnifunc' source function; or `<C-n>`/`<C-p>`).
-- --     scroll_down = '<Tab>',
-- --     scroll_up = '<Shift-Tab>',
-- --   },
-- -- })
--
--
-- -- Cpp config
-- vim.lsp.enable("clangd")
--
--
-- vim.api.nvim_set_keymap("n", "<leader>x", ":XcodebuildPicker<cr>",
--   { silent = true, noremap = true, desc = "Open Xcode options" })
--
-- require("fold_imports").setup({
--   auto_fold_after_code_action = true,
--   languages = {
--     typescript = {
--       enabled = true,
--       parsers = { "typescript", "tsx" },
--       queries = {
--         "(import_statement) @import",
--       },
--       filetypes = { "typescript", "typescriptreact" },
--       patterns = { "*.ts", "*.tsx" },
--     },
--     javascript = {
--       enabled = true,
--       parsers = { "javascript", "jsx" },
--       queries = {
--         "(import_statement) @import",
--       },
--       filetypes = { "javascript", "javascriptreact" },
--       patterns = { "*.js", "*.jsx", "*.mjs" },
--     },
--   }
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
--
--
--
-- require("typescript-tools").setup {}
-- vim.lsp.config["typescript"] = {}
-- vim.lsp.enable("typescript")
--
-- require("leetcode").setup({
--   lang = "python3",
--   injector = { --- @type table<lc.lang, lc.inject>
--     ["cpp"] = {
--       imports = function()
--         -- return a different list to omit default imports
--         return { "#include <vector>", "using namespace std;" }
--       end,
--       after = "int main() {}",
--     },
--   },
-- })

vim.lsp.config["tinymist"] = {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	settings = {
		formatterMode = "typstyle --wrap-text",
		semanticTokens = "disable",
	},
}
vim.lsp.enable("tinymist")

vim.api.nvim_create_autocmd("LspAttach", {
	desc = "LSP Actions",
	callback = function()
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { noremap = true, silent = true })
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { noremap = true, silent = true })
	end,
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
