local map = vim.keymap.set

if vim.lsp.get_clients({ name = "clangd" }) then
	map("n", "<leader>js", "<cmd>ClangdSwitchSourceHeader<cr>", { desc = "Switch Source Header" })
	map("n", "<leader>ja", "<cmd>ClangdAST<cr>", { desc = "AST Grep" })
	map("n", "<leader>ji", "<cmd>ClangdSymbolInfo<cr>", { desc = "Symbol Info" })
	map("n", "<leader>jh", "<cmd>ClangdTypeHierarchy<cr>", { desc = "Type Hierrarchy" })
end
