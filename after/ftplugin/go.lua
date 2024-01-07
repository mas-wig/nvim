local map = vim.keymap.set

if vim.lsp.get_clients({ name = "gopls" }) then
	map("n", "<leader>jg", "<cmd>GoGet<cr>", { desc = "`go get`" })
	map("n", "<leader>jw", "<cmd>GoFillSwitch<cr>", { desc = "Fill Switch" })
	map("n", "<leader>jf", "<cmd>GoFillStruct<cr>", { desc = "Auto Sill Struct" })
	map("n", "<leader>je", "<cmd>GoIfErr<cr>", { desc = "Add If Err" })
	map("n", "<leader>jp", "<cmd>GoFixPlurals<cr>", { desc = "Fix Plurals Func" })
	map("n", "<leader>jo", "<cmd>GoPkgOutline<cr>", { desc = "Symbols Outline" })
	map("n", "<leader>jC", "<cmd>GoClearTag<cr>", { desc = "Clear All Tags" })
	map("n", "<leader>jc", "<cmd>GoCmt<cr>", { desc = "Add comment" })
	map("n", "<leader>ja", "<cmd>GoModInit<cr>", { desc = "`go mod init`" })
	map("n", "<leader>jv", "<cmd>GoModVendor<cr>", { desc = "`go mod vendor`" })
	map("n", "<leader>jy", "<cmd>GoModTidy<cr>", { desc = "`go mod tidy`" })
	map("n", "<leader>jt", function()
		vim.ui.input({ prompt = "Add Tag : " }, function(tag)
			if tag ~= "" then
				return vim.cmd("GoAddTag " .. tag)
			end
		end)
	end, { desc = "Add Tags" })
	map("n", "<leader>jr", function()
		vim.ui.input({ prompt = "Remove Tag : " }, function(tag)
			if tag ~= "" then
				return vim.cmd("GoRmTag " .. tag)
			end
		end)
	end, { desc = "Remove Tags" })

	map("n", "<leader>ji", function()
		vim.ui.input({ prompt = "Implementation (struct) -> (interface) : " }, function(tag)
			if tag ~= "" then
				return vim.cmd("GoImpl " .. tag)
			end
		end)
	end, { desc = "Implementation" })

	map("n", "<leader>jb", function()
		vim.ui.select({ prompt = "Go Build (args) : " })
	end, { desc = "Go Build" })
end
