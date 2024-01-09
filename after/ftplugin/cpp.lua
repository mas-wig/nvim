vim.opt_local.spell = false
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.commentstring = "// %s"
vim.opt_local.path:append("/usr/include/**,/usr/local/include/**")

local map = vim.keymap.set
if vim.lsp.get_clients({ name = "clangd" }) then
	map("n", "<leader>js", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch Source Header" })
	map("n", "<leader>ja", "<cmd>ClangdAST<cr>", { desc = "AST Grep" })
	map("n", "<leader>ji", "<cmd>ClangdSymbolInfo<cr>", { desc = "Symbol Info" })
	map("n", "<leader>jh", "<cmd>ClangdTypeHierarchy<cr>", { desc = "Type Hierrarchy" })
end

local cmp_ok, cmp = pcall(require, "cmp")
if cmp_ok then
	cmp.setup.filetype({ "c", "cpp" }, {
		sorting = {
			comparators = vim.list_extend(
				{ require("clangd_extensions.cmp_scores") },
				require("cmp.config").get().sorting.comparators
			),
		},
	})
end
