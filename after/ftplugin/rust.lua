local map = vim.keymap.set

if vim.lsp.get_clients({ name = "rust-analyzer" }) then
	map("n", "<leader>ju", "<cmd>RustLsp moveItem up<cr>", { desc = "Move Item Up" })
	map("n", "<leader>jd", "<cmd>RustLsp moveItem down<cr>", { desc = "Move Item Down" })
	map("n", "<leader>jm", "<cmd>RustLsp expandMacro<cr>", { desc = "Expand Macros Recursively" })
	map("n", "<leader>jp", "<cmd>RustLsp rebuildProcMacros<cr>", { desc = "Rebuild proc macros" })
	map("n", "<leader>jx", "<cmd>RustLsp explainError<cr>", { desc = "Explain errors" })
	map("n", "<leader>jc", "<cmd>RustLsp openCargo<cr>", { desc = "Open Cargo.toml" })
	map("n", "<leader>ja", "<cmd>RustLsp parentModule<cr>", { desc = "Parent Module" })
	map("n", "<leader>jl", "<cmd>RustLsp joinLines<cr>", { desc = "Join Lines" })
	map("n", "<leader>js", "<cmd>RustLsp syntaxTree <cr>", { desc = "Syntax Tree" })
end
