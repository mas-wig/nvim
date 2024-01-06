local map = vim.keymap.set

if vim.lsp.get_clients({ name = "typescript-tools" }) then
	map("n", "<leader>jo", "<cmd>TSToolsOrganizeImports<cr>", { desc = "Organize Imports" })
	map("n", "<leader>js", "<cmd>TSToolsSortImports<cr>", { desc = "Sort Imports" })
	map("n", "<leader>jr", "<cmd>TSToolsRemoveUnusedImports<cr>", { desc = "Remove Unused Imports" })
	map("n", "<leader>jx", "<cmd>TSToolsRemoveUnused<cr>", { desc = "Remove Unused" })
	map("n", "<leader>jm", "<cmd>TSToolsAddMissingImports<cr>", { desc = "Add Missing Imports" })
	map("n", "<leader>jf", "<cmd>TSToolsFixAll<cr>", { desc = "Fix All" })
	map("n", "<leader>jd", "<cmd>TSToolsGoToSourceDefinition<cr>", { desc = "GoTo Source Definition " })
	map("n", "<leader>jn", "<cmd>TSToolsRenameFile<cr>", { desc = "Rename File" })
	map("n", "<leader>jr", "<cmd>TSToolsFileReferences<cr>", { desc = "File References" })
end
