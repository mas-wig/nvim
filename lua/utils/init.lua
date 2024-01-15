local M = {}

local function is_active(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	local ok = pcall(vim.treesitter.get_parser, buf, vim.b[buf].ft)
	return ok and true or false
end

function M.fold_text()
	local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
	local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
	if not ret or type(ret) == "string" then
		ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
	end
	local line_count = vim.v.foldend - vim.v.foldstart + 1
	table.insert(ret, { string.rep(" ", 4) .. tostring(line_count) .. " lines folded" })

	if not vim.treesitter.foldtext then
		return table.concat(
			vim.tbl_map(function(line)
				return line[1]
			end, ret),
			" "
		)
	end
	return ret
end

function M.ts_folds(info)
	if is_active(info.buf) and vim.opt_local.foldmethod:get() ~= "diff" then
		vim.opt_local.foldmethod = "expr"
		vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
	end
	if is_active(info.buf) then
		vim.opt_local.foldtext = "v:lua.require('utils').fold_text()"
	end
end

function M.fzf(builtin, opts)
	local params = { builtin = builtin, opts = opts }
	return function()
		builtin = params.builtin
		opts = params.opts
		opts = vim.tbl_deep_extend("force", {
			cwd = require("utils.dir").root(),
			fzf_opts = {
				["--no-scrollbar"] = "",
				["--color"] = "separator:cyan",
				["--info"] = "right",
				["--marker"] = "󰍎 ",
				["--pointer"] = " ",
				["--padding"] = "0,1",
				["--margin"] = "0",
			},
		}, opts or {})
		if
			builtin == "files"
			and not vim.fs.find(
				{ ".obsidian" },
				{ path = require("utils.dir").root(), upward = true, type = "directory" }
			)[1]
		then
			if vim.uv.fs_stat(string.format("%s/.git", (opts.cwd or vim.uv.cwd()))) then
				builtin = "git_files"
			else
				builtin = "files"
			end
		end
		require("fzf-lua")[builtin](opts)
	end
end

local diagIcons = require("utils.icons").diagnostics
M.diagnostic_conf = {
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagIcons.Error,
			[vim.diagnostic.severity.WARN] = diagIcons.Warn,
			[vim.diagnostic.severity.INFO] = diagIcons.Hint,
			[vim.diagnostic.severity.HINT] = diagIcons.Info,
		},
		numhl = {
			[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
			[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
			[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
			[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
		},
	},
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "",
		format = function(d)
			local icons = {}
			for key, value in pairs(diagIcons) do
				icons[key:upper()] = value
			end
			return string.format(" %s : %s ", icons[vim.diagnostic.severity[d.severity]], d.message)
		end,
	},
	float = {
		format = function(d)
			return string.format(" [%s] : %s ", d.source, d.message)
		end,
		source = "if_many",
		severity_sort = true,
		wrap = true,
		border = vim.g.border,
		max_width = math.floor(vim.o.columns / 2),
		max_height = math.floor(vim.o.lines / 3),
	},
}

return M
