if vim.g.vscode then
	-- VSCode extension
else
	-- usual environment
	require "paq" {
			"savq/paq-nvim", -- let Paq manage itself
			"rebelot/kanagawa.nvim", -- theme
			"nvim-lualine/lualine.nvim", -- status line
			"Vonr/align.nvim", -- for aligning lines
			"junegunn/vim-easy-align", -- for aligning symbols
			"junegunn/limelight.vim", -- for highlighting current paragraph
			"folke/todo-comments.nvim",
			"Pocco81/true-zen.nvim", -- for distraction free reading
			"skwee357/nvim-prose",
			"ntpeters/vim-better-whitespace", -- for highlighting and removing whitespace
	}
	vim.cmd("colorscheme kanagawa")
	require("lualine").setup()
	vim.cmd("set number cursorline tabstop=2 shiftwidth=2")
	vim.cmd("hi LineNr guibg=None")

	vim.g.mapleader = " "

	require('true-zen').setup {
    integrations = {
      lualine = true  -- TrueZen will handle hiding Lualine if true
    },
  }

  -- Define custom autocommands to toggle Limelight together with TrueZen.
  -- We'll use the "truezen_mode_changed" User event for best results
  vim.api.nvim_create_autocmd("User", {
    pattern = "TrueZenTrue",
    callback = function()
      -- Disable lualine manually if TrueZen's integration is not enough:
      -- require('lualine').hide({unhide = false})

      -- Enable Limelight when entering TrueZenMode
      vim.cmd("Limelight")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "TrueZenOff",
    callback = function()
      -- Enable lualine if handled manually:
      -- require('lualine').hide({unhide = true})

      -- Disable Limelight when exiting TrueZenMode
      vim.cmd("Limelight!")
    end,
  })

  -- OPTIONAL: Map a key to quickly toggle Ataraxis/Minimal mode
  vim.keymap.set('n', '<leader>zz', ':TZAtaraxis<CR>')


	-- Setup true-zen (customize as needed)
  require('true-zen').setup {}
  
  -- Autocommand group to handle markdown TrueZen/Limelight
  vim.api.nvim_create_augroup('MarkdownZen', { clear = true })
  
  -- Enable on entering markdown buffer
  vim.api.nvim_create_autocmd('FileType', {
    group = 'MarkdownZen',
    pattern = 'markdown',
    callback = function()
      -- Start Ataraxis mode (edit: could also use TZMinimal)
      vim.schedule(function()
        vim.cmd('TZAtaraxis')
        vim.cmd('Limelight')
      end)
    end,
  })
  
--  -- Optionally: Disable when leaving the buffer/window
--  vim.api.nvim_create_autocmd({ 'BufLeave', 'BufWinLeave' }, {
--    group = 'MarkdownZen',
--    pattern = '*.md',
--    callback = function()
--      -- Only exit if we're not switching to another markdown
--      vim.schedule(function()
--        -- Disable Ataraxis and Limelight
--        vim.cmd('TZAtaraxis')   -- Toggle off
--        vim.cmd('Limelight!')   -- Turn off Limelight
--      end)
--    end,
--  })
--


-- function HighlightCurrentSentence()
--   local bufnr = vim.api.nvim_get_current_buf()
--   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
--   row = row - 1
--   local line = vim.api.nvim_buf_get_lines(bufnr, row, row+1, false)[1]
-- 
--   if not line or #line == 0 then return end
-- 
--   -- Find sentence boundaries
--   local start_idx = 1
--   for i = col, 1, -1 do
--     local c = line:sub(i,i)
--     if c:match("[%.!?]") and (i == #line or line:sub(i+1,i+1):match("%s")) then
--       start_idx = i + 1
--       break
--     end
--   end
-- 
--   -- Skip spaces at the sentence start
--   while line:sub(start_idx, start_idx):match("%s") and start_idx < #line do
--     start_idx = start_idx + 1
--   end
-- 
--   local end_idx = #line
--   for i = col+1, #line do
--     local c = line:sub(i,i)
--     if c:match("[%.!?]") and (i == #line or line:sub(i+1,i+1):match("%s")) then
--       end_idx = i
--       break
--     end
--   end
-- 
--   -- Skip trailing spaces in the sentence
--   while line:sub(end_idx, end_idx):match("%s") and end_idx > start_idx do
--     end_idx = end_idx - 1
--   end
-- 
--   if end_idx < start_idx then return end
-- 
--   -- Insert '==' markers
--   local pre = line:sub(1, start_idx-1)
--   local sent = line:sub(start_idx, end_idx)
--   local post = line:sub(end_idx+1)
-- 
--   -- Avoid double marking (check for '==')
--   if sent:match("^==.*==$") then return end
-- 
--   local new_line = pre .. "==" .. sent .. "==" .. post
--   vim.api.nvim_buf_set_lines(bufnr, row, row+1, false, {new_line})
-- end
-- 
-- 	vim.api.nvim_create_autocmd("FileType", {
--     pattern = "markdown",
--     callback = function()
--       vim.keymap.set('n', '<leader>hs', HighlightCurrentSentence, {buffer=true, desc="Highlight sentence"})
--     end
--   })


-- function HighlightVisualSelection()
--   -- Only work in visual mode/selections
--   local mode = vim.fn.mode()
--   if not (mode == "v" or mode == "V" or mode == "\22") then
--     print("Not in visual mode!")
--     return
--   end
-- 
--   -- Get visual selection range
--   local bufnr = vim.api.nvim_get_current_buf()
--   local start_pos = vim.fn.getpos("'<")
--   local end_pos = vim.fn.getpos("'>")
-- 
--   local start_row, start_col = start_pos[2]-1, start_pos[3]-1
--   local end_row, end_col = end_pos[2]-1, end_pos[3]-1
-- 
--   -- Correct order if selected backwards
--   if start_row > end_row or (start_row == end_row and start_col > end_col) then
--     start_row, end_row = end_row, start_row
--     start_col, end_col = end_col, start_col
--   end
-- 
--   if start_row == end_row then
--     -- Single line selection
--     local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row+1, false)[1]
--     local before = line:sub(1, start_col)
--     local selected = line:sub(start_col+1, end_col)
--     local after = line:sub(end_col+1)
--     local new_line = before .. "==" .. selected .. "==" .. after
--     vim.api.nvim_buf_set_lines(bufnr, start_row, start_row+1, false, {new_line})
--   else
--     -- Multiline selection
--     local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row+1, false)
--     -- First line
--     lines[1] = lines[1]:sub(1, start_col) .. "==" .. lines[1]:sub(start_col+1)
--     -- Last line
--     lines[#lines] = lines[#lines]:sub(1, end_col) .. "==" .. lines[#lines]:sub(end_col+1)
--     vim.api.nvim_buf_set_lines(bufnr, start_row, end_row+1, false, lines)
--   end
-- end
-- 
-- 
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
--   callback = function()
--     vim.keymap.set('v', '<leader>h', HighlightVisualSelection, { buffer = true, desc = "Highlight visually selected text"})
--   end
-- })


local function highlight_visual_selection()
  vim.schedule(function()
    local bufnr = vim.api.nvim_get_current_buf()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    local start_row, start_col = start_pos[2]-1, start_pos[3]-1
    local end_row, end_col = end_pos[2]-1, end_pos[3]-1

    if start_row > end_row or (start_row == end_row and start_col > end_col) then
      start_row, end_row = end_row, start_row
      start_col, end_col = end_col, start_col
    end

    if start_row == end_row then
      -- Single line selection
      local line = vim.api.nvim_buf_get_lines(bufnr, start_row, start_row+1, false)[1]
      local before = line:sub(1, start_col)
      local selected = line:sub(start_col+1, end_col)
      local after = line:sub(end_col+1)
      local new_line = before .. "==" .. selected .. "==" .. after
      vim.api.nvim_buf_set_lines(bufnr, start_row, start_row+1, false, {new_line})
    else
      -- Multiline selection
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row+1, false)
      lines[1] = lines[1]:sub(1, start_col) .. "==" .. lines[1]:sub(start_col+1)
      lines[#lines] = lines[#lines]:sub(1, end_col) .. "==" .. lines[#lines]:sub(end_col+1)
      vim.api.nvim_buf_set_lines(bufnr, start_row, end_row+1, false, lines)
    end
  end)
end


vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set('v', '<leader>h', highlight_visual_selection, { buffer = true, desc = "Highlight visually selected text" })
  end
})
end
