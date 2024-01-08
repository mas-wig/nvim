local function augroup(name)
	return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("CheckTime"),
	command = "checktime",
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("Highlight_Yank"),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("Resize_Splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("Last_Location"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_location then
			return
		end
		vim.b[buf].last_location = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("Close_With_q"),
	pattern = {
		"PlenaryTestPopup",
		"help",
		"lspinfo",
		"man",
		"notify",
		"qf",
		"query",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"neotest-output",
		"checkhealth",
		"neotest-summary",
		"neotest-output-panel",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("Wrap_Spell"),
	pattern = { "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("Auto_Create_Dir"),
	callback = function(event)
		if event.match:match("^%w%w+://") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "Set Treesiter Fold",
	group = vim.api.nvim_create_augroup("TSFolds", {}),
	callback = function(info)
		vim.schedule(function()
			return require("utils").ts_folds(info)
		end)
	end,
})

vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
	group = augroup("FoldRemember"),
	callback = function(event)
		if vim.b[event.buf].view_activated then
			vim.cmd.mkview({ mods = { emsg_silent = true } })
		end
	end,
})

vim.api.nvim_create_autocmd("BufWinEnter", {
	group = augroup("FoldRemember"),
	callback = function(event)
		if not vim.b[event.buf].view_activated then
			local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
			local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
			if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
				vim.b[event.buf].view_activated = true
				vim.cmd.loadview({ mods = { emsg_silent = true } })
			end
		end
	end,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(opts)
		local fname = vim.api.nvim_buf_get_name(opts.buf)
		if #fname <= 0 then
			return
		end
		local size = vim.fn.getfsize(fname) / 1024
		if size >= 1024 then
			vim.schedule(function()
				vim.lsp.buf_detach_client(opts.buf, opts.data.client_id)
			end)
		end
	end,
})

vim.api.nvim_create_autocmd("BufReadPre", {
	desc = "Set settings for large files.",
	callback = function(info)
		vim.b.midfile = false
		vim.b.bigfile = false
		local stat = vim.uv.fs_stat(info.match)
		if not stat then
			return
		end
		if stat.size > 48000 then
			vim.b.midfile = true
			vim.api.nvim_create_autocmd("BufReadPost", {
				buffer = info.buf,
				once = true,
				callback = function()
					vim.schedule(function()
						pcall(vim.treesitter.stop, info.buf)
					end)
					return true
				end,
			})
		end
		if stat.size > 1024000 then
			vim.b.bigfile = true
			vim.opt_local.spell = false
			vim.opt_local.swapfile = false
			vim.opt_local.undofile = false
			vim.opt_local.breakindent = false
			vim.opt_local.colorcolumn = ""
			vim.opt_local.statuscolumn = ""
			vim.opt_local.signcolumn = "no"
			vim.opt_local.foldcolumn = "0"
			vim.opt_local.winbar = ""
			vim.api.nvim_create_autocmd("BufReadPost", {
				buffer = info.buf,
				once = true,
				callback = function()
					vim.opt_local.syntax = ""
					return true
				end,
			})
		end
	end,
})
