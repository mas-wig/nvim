local map = vim.keymap.set

if vim.lsp.get_clients({ name = "marksman" }) then
	map("n", "<leader>jn", "<cmd>MkdnEnter<cr>", { desc = "Create New Note" })
end
