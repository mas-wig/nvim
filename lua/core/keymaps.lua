local map, tg = vim.keymap.set, require("utils.toggle")

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
	"n",
	"<leader>ur",
	"<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
	{ desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>wall<cr>", { desc = "Save file", silent = true })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- Terminal Mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
map("n", "<A-1>", "1gt", { desc = "Go to tab 1" })
map("n", "<A-2>", "2gt", { desc = "Go to tab 2" })
map("n", "<A-3>", "3gt", { desc = "Go to tab 3" })
map("n", "<A-4>", "4gt", { desc = "Go to tab 4" })
map("n", "<A-5>", "5gt", { desc = "Go to tab 5" })
map("n", "<A-6>", "6gt", { desc = "Go to tab 6" })
map("n", "<A-7>", "7gt", { desc = "Go to tab 7" })
map("n", "<A-8>", "8gt", { desc = "Go to tab 8" })
map("n", "<A-9>", "9gt", { desc = "Go to tab 9" })

map("n", "]z", function()
	local cur_line = vim.fn.line(".")
	local line_count = vim.fn.line("$")
	while vim.fn.foldclosed(cur_line) > 0 do
		cur_line = cur_line + 1
		if cur_line > line_count then
			break
		end
	end
	for i = cur_line, line_count do
		if vim.fn.foldclosed(i) > 0 then
			vim.cmd(tostring(i))
			return
		end
	end
end, { desc = "Go to Next Fold" })

map("n", "[z", function()
	local cur_line = vim.fn.line(".")
	while vim.fn.foldclosed(cur_line) > 0 do
		cur_line = cur_line - 1
		if cur_line < 1 then
			return
		end
	end
	local in_closed_fold = false
	for i = cur_line, 1, -1 do
		if vim.fn.foldclosed(i) > 0 then
			in_closed_fold = true
		elseif in_closed_fold then
			vim.cmd(tostring(i + 1))
			return
		end
	end
end, { desc = "Go to Prev Fold" })

map("n", "<leader>bx", function()
	local visible_bufs = {}
	for _, w in pairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(w)
		table.insert(visible_bufs, buf)
	end
	local deleted_count = 0
	for _, bufnr in pairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) and not vim.tbl_contains(visible_bufs, bufnr) then
			local force = vim.api.nvim_get_option_value("buftype", { buf = bufnr }) == "terminal"
			local ok = pcall(vim.api.nvim_buf_delete, bufnr, { force = force })
			if ok then
				deleted_count = deleted_count + 1
			end
		end
	end
	vim.notify(string.format("%s %d %s", "Deleted", deleted_count, "buffers"), 2)
end, { desc = "Close Non-Visible Buffers" })

-- stylua: ignore start
map("n", "<leader>us", function() tg("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>uw", function() tg("wrap") end, { desc = "Toggle Word Wrap" })
map("n", "<leader>uL", function() tg("relativenumber") end, { desc = "Toggle Relative Line Numbers" })
map("n", "<leader>ul", function() tg.number() end, { desc = "Toggle Line Numbers" })
map("n", "<leader>ud", function() tg.diagnostics() end, { desc = "Toggle Diagnostics" })

local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() tg("conceallevel", false, { 0, conceallevel }) end, { desc = "Toggle Conceal" })

if vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint then
	map("n", "<leader>uh", function() tg.inlay_hints() end, { desc = "Toggle Inlay Hints" })
end
map("n", "<leader>uT", function() if vim.b.ts_highlight then vim.treesitter.stop() else vim.treesitter.start() end end, { desc = "Toggle Treesitter Highlight" })
-- stylua: ignore start
