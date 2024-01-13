local map, method, fzf = vim.keymap.set, vim.lsp.protocol.Methods, require("utils").fzf

local function count_wrap(fn, count)
	return function()
		if count == 0 and vim.v.count0 == 0 then
			return {}
		end
		local result = {}
		for _ = 1, vim.v.count1 do
			vim.list_extend(result, { fn() })
		end
		return table.unpack(result)
	end
end

local function goto_diag(direction, level)
	return function()
		vim.diagnostic["goto_" .. direction]({ severity = vim.diagnostic.severity[level] })
	end
end

local function lsp_rename()
	local originHandler = vim.lsp.handlers[method.textDocument_rename]
	vim.lsp.handlers[method.textDocument_rename] = function(err, result, ctx, config)
		originHandler(err, result, ctx, config)
		if err or not result then
			return
		end
		local changes = result.changes or result.documentChanges or {}
		local changedFiles = vim.tbl_keys(changes)
		changedFiles = vim.tbl_filter(function(file)
			return #changes[file] > 0
		end, changedFiles)
		changedFiles = vim.tbl_map(function(file)
			return "- " .. vim.fs.basename(file)
		end, changedFiles)
		local changeCount = 0
		for _, change in pairs(changes) do
			changeCount = changeCount + #(change.edits or change)
		end
		local msg = string.format("%s instance%s", changeCount, (changeCount > 1 and "s" or ""))
		if #changedFiles > 1 then
			msg = msg .. (" in %s files:\n"):format(#changedFiles) .. table.concat(changedFiles, "\n")
		end
		return vim.notify_once(string.format("Renamed with LSP %s", msg), 2)
	end
end

local function lsp_interface(client, bufnr)
	if vim.g.inlay_hints then
		if client.supports_method(method.textDocument_inlayHint) then
			require("utils.toggle").inlay_hints(bufnr, true)
		else
			return vim.notify_once("Method [textDocument/inlayHint] not\n supported winbar will be disabled!", 2)
		end
	end

	if client.server_capabilities.documentSymbolProvider then
		vim.g.navic_silence = true
		require("nvim-navic").attach(client, bufnr)
	else
		return vim.notify_once("Method document symbol provider not\n supported winbar will be disabled!", 2)
	end

	if client.supports_method(method.textDocument_codeLens) then
		vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("CodeLensRefersh", { clear = true }),
			callback = vim.lsp.codelens.refresh,
		})
	else
		return vim.notify_once("Method [textDocument/codeLens] not\n supported!", 2)
	end

	if client.supports_method(method.textDocument_documentHighlight) then
		local cursor_hl = vim.api.nvim_create_augroup("cursor_highlights", { clear = false })
		vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave", "BufEnter" }, {
			group = cursor_hl,
			desc = "Highlight references under the cursor",
			buffer = bufnr,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
			group = cursor_hl,
			desc = "Clear highlight references",
			buffer = bufnr,
			callback = vim.lsp.buf.clear_references,
		})
	else
		vim.notify_once("Method [textDocument/documentHighlight] not\n supported!", 2)
		return
	end
end

return {
	on_attach = function(client, bufnr)
		lsp_interface(client, bufnr)
		lsp_rename()
        -- stylua: ignore start
		map("n", "gd", "<cmd>Trouble lsp_definitions<cr>", { desc = "Definition", buffer = bufnr })
		map("n", "gD", "<cmd>Trouble lsp_type_definitions<cr>", { desc = "Type Definitions", buffer = bufnr })
		map("n", "<leader>ga", vim.lsp.codelens.run, { desc = "Run CodeLens", buffer = bufnr })
		map("n", "<leader>gr", "<cmd>Trouble lsp_references<cr>", { desc = "References", buffer = bufnr })
		map("n", "<leader>ge", "<cmd>Trouble lsp_implementations<cr>", { desc = "Implementation", buffer = bufnr })
		map("n", "<leader>gd", fzf("lsp_declarations", { prompt = "Declaration : " }), { desc = "Declaration", buffer = bufnr })
		map("n", "<leader>gs", fzf("lsp_document_symbols", { prompt = "Document Symbols : " }), { desc = "Document Symbols", buffer = bufnr })
		map("n", "<leader>gS", fzf("lsp_workspace_symbols", { prompt = "Workspace Symbols : " }), { desc = "Workspace Symbols", buffer = bufnr })
		map("n", "<leader>gL", fzf("lsp_live_workspace_symbols"), { desc = "Live Workspace Symbols", buffer = bufnr })
		map("n", "<leader>gc", fzf("lsp_code_actions", { prompt = "Code Action : " }), { desc = "Code Action", buffer = bufnr })
		map("n", "<leader>gi", fzf("lsp_incoming_calls", { prompt = "Incoming Calls : " }), { desc = "Incoming Calls", buffer = bufnr })
		map("n", "<leader>go", fzf("lsp_outgoing_calls", { prompt = "Outgoing Calls : " }), { desc = "Outgoing Calls", buffer = bufnr })
		map("n", "<leader>gf", fzf("lsp_finder", { prompt = "Lsp Finder : " }), { desc = "Lsp Finder", buffer = bufnr })
		map("n", "<leader>gx", fzf("diagnostics_document", { prompt = "Diagnostics Document : " }), { desc = "Current Bufer Diagnostics", buffer = bufnr })
		map("n", "<leader>gX", fzf("diagnostics_workspace", { prompt = "Diagnostics Workspace : " }), { desc = "Workspace Diagnostics", buffer = bufnr })
		map("n", "<leader>gw", vim.lsp.buf.add_workspace_folder, { desc = "Add Folder to Workspace", buffer = bufnr })
		map("n", "<leader>gW", vim.lsp.buf.remove_workspace_folder, { desc = "Remove Folder from Workspace", buffer = bufnr })
		map("n", "<leader>gl", vim.lsp.buf.list_workspace_folders, { desc = "List Workspace Folder", buffer = bufnr })
		map("n", "<leader>gn", vim.lsp.buf.rename, { desc = "Rename", buffer = bufnr })
		map("n", "K", vim.lsp.buf.hover, { desc = "Hover Document", buffer = bufnr })
		map({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help", buffer = bufnr })
		map("n", "[d", count_wrap(vim.diagnostic.goto_prev), { desc = "Next Diagnostic", buffer = bufnr })
		map("n", "]d", count_wrap(vim.diagnostic.goto_next), { desc = "Prev Diagnostic", buffer = bufnr })
		map("n", "[e", count_wrap(goto_diag("prev", "ERROR")), { desc = "Prev Error", buffer = bufnr })
		map("n", "]e", count_wrap(goto_diag("next", "ERROR")), { desc = "Next Error", buffer = bufnr })
		map("n", "[w", count_wrap(goto_diag("prev", "WARN")), { desc = "Prev Warn", buffer = bufnr })
		map("n", "]w", count_wrap(goto_diag("next", "WARN")), { desc = "Next Warn", buffer = bufnr })
		map("n", "[i", count_wrap(goto_diag("prev", "INFO")), { desc = "Prev Info", buffer = bufnr })
		map("n", "]i", count_wrap(goto_diag("next", "INFO")), { desc = "Next Info", buffer = bufnr })
		map("n", "[h", count_wrap(goto_diag("prev", "HINT")), { desc = "Prev Hint", buffer = bufnr })
		map("n", "]h", count_wrap(goto_diag("next", "HINT")), { desc = "Next Hint", buffer = bufnr })
		-- stylua: ignore end
	end,
	capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("cmp_nvim_lsp").default_capabilities()
	),
}
