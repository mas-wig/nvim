local map, method, fmt, trouble, fzf =
	vim.keymap.set, vim.lsp.protocol.Methods, string.format, require("trouble").toggle, require("fzf-lua")

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

return {
	on_attach = function(client, bufnr)
		vim.lsp.handlers[method.textDocument_references] = function()
			trouble("lsp_references")
		end
		vim.lsp.handlers[method.textDocument_implementation] = function()
			trouble("lsp_implementations")
		end
		vim.lsp.handlers[method.textDocument_definition] = function()
			trouble("lsp_definitions")
		end
		vim.lsp.handlers[method.textDocument_typeDefinition] = function()
			trouble("lsp_type_definitions")
		end
		vim.lsp.handlers[method.callHierarchy_incomingCalls] = fzf.lsp_incoming_calls
		vim.lsp.handlers[method.callHierarchy_outgoingCalls] = fzf.lsp_outgoing_calls
		vim.lsp.handlers[method.textDocument_codeAction] = fzf.code_actions
		vim.lsp.handlers[method.textDocument_declaration] = fzf.declarations
		vim.lsp.handlers[method.textDocument_documentSymbol] = fzf.lsp_document_symbols
		vim.lsp.handlers[method.workspace_symbol] = fzf.lsp_live_workspace_symbols

		local renameHandler = vim.lsp.handlers[method.textDocument_rename]
		vim.lsp.handlers[method.textDocument_rename] = function(err, result, ctx, config)
			renameHandler(err, result, ctx, config)
			if err or not result then
				return
			end
			vim.cmd.wall()
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
			vim.notify(string.format("Renamed with LSP %s", msg), 2)
		end

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
				callback = function()
					return vim.lsp.codelens.refresh()
				end,
			})
		else
			return vim.notify_once("Method [textDocument/codeLens] not\n supported!", 2)
		end

		if client.supports_method(method.textDocument_documentHighlight) then
			local under_cursor_highlights_group = vim.api.nvim_create_augroup("cursor_highlights", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave", "BufEnter" }, {
				group = under_cursor_highlights_group,
				desc = "Highlight references under the cursor",
				buffer = bufnr,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
				group = under_cursor_highlights_group,
				desc = "Clear highlight references",
				buffer = bufnr,
				callback = vim.lsp.buf.clear_references,
			})
		else
			return vim.notify_once("Method [textDocument/documentHighlight] not\n supported!", 2)
		end

		--- end codelens autocmd --
		local function with_method(mt_name, fn_name, fallback)
			if client.supports_method(mt_name) then
				return function()
					return fmt('<cmd>lua vim.lsp.buf["%s"]()<CR>', vim.fn.escape(fn_name, '"\\'))
				end
			end
			vim.notify_once(fmt("Method [%s] not\n supported [%s] key cant be used!", mt_name, fallback), 2)
			return fallback or nil
		end

		map(
			{ "n", "x" },
			"<leader>gD",
			with_method(method.textDocument_documentSymbol, "document_symbol", "<leader>gD"),
			{ desc = "Document Symbols", buffer = bufnr, expr = true }
		)
		map(
			{ "n", "x" },
			"<leader>gw",
			with_method(method.workspace_symbol, "workspace_symbol", "<leader>gw"),
			{ desc = "Workspace Symbol", buffer = bufnr, expr = true }
		)

		map(
			{ "n", "x" },
			"<leader>gy",
			with_method(method.callHierarchy_incomingCalls, "incoming_calls", "<leader>gy"),
			{ desc = "Incoming Calls", buffer = bufnr, expr = true }
		)
		map(
			{ "n", "x" },
			"<leader>go",
			with_method(method.callHierarchy_outgoingCalls, "outgoing_calls", "<leader>go"),
			{ desc = "Outgoing Calls", buffer = bufnr, expr = true }
		)

		map(
			{ "n", "x" },
			"gD",
			with_method(method.textDocument_declaration, "declaration", "gD"),
			{ desc = "Goto Declaration", buffer = bufnr, expr = true }
		)

		map(
			{ "n", "x" },
			"gd",
			with_method(method.textDocument_definition, "definition", "gd"),
			{ desc = "Goto Definition", buffer = bufnr, expr = true }
		)
		map(
			{ "n", "x" },
			"<leader>gt",
			with_method(method.textDocument_typeDefinition, "type_definition", "<leader>gt"),
			{ desc = "Goto Type Definition", expr = true, buffer = bufnr }
		)
		map(
			{ "n", "x" },
			"<leader>gr",
			with_method(method.textDocument_references, "references", "<leader>gr"),
			{ desc = "Goto References", buffer = bufnr, expr = true }
		)
		map(
			{ "n", "x" },
			"<leader>gi",
			with_method(method.textDocument_implementation, "implementation", "<leader>gi"),
			{ desc = "Goto Implementation", buffer = bufnr }
		)
		map(
			{ "n", "x" },
			"<leader>gn",
			with_method(method.textDocument_rename, "rename", "<leader>gn"),
			{ desc = "Lsp Rename", buffer = bufnr, expr = true }
		)
		map(
			{ "i", "n" },
			"<C-k>",
			with_method(method.textDocument_signatureHelp, "signature_help", "<C-k>"),
			{ desc = "Signature Help", buffer = bufnr, expr = true }
		)
		map(
			{ "n", "x" },
			"<leader>gc",
			with_method(method.textDocument_codeAction, "code_action", "<leader>ca"),
			{ desc = "Lsp Code Action", buffer = bufnr, expr = true }
		)
		map({ "n", "x" }, "<leader>ga", function()
			if client.supports_method(method.textDocument_codeLens) then
				vim.lsp.codelens.run()
			else
				return vim.notify_once(fmt("Method [textDocument/codeLent] not\n supported!"), 2)
			end
		end, { desc = "Lsp Run codelens", buffer = bufnr })

		map({ "n", "x" }, "[d", count_wrap(vim.diagnostic.goto_prev), { desc = "Next Diagnostic", buffer = bufnr })
		map({ "n", "x" }, "]d", count_wrap(vim.diagnostic.goto_next), { desc = "Prev Diagnostic", buffer = bufnr })
		map({ "n", "x" }, "[e", count_wrap(goto_diag("prev", "ERROR")), { desc = "Prev Error", buffer = bufnr })
		map({ "n", "x" }, "]e", count_wrap(goto_diag("next", "ERROR")), { desc = "Next Error", buffer = bufnr })
		map({ "n", "x" }, "[w", count_wrap(goto_diag("prev", "WARN")), { desc = "Prev Warn", buffer = bufnr })
		map({ "n", "x" }, "]w", count_wrap(goto_diag("next", "WARN")), { desc = "Next Warn", buffer = bufnr })
		map({ "n", "x" }, "[i", count_wrap(goto_diag("prev", "INFO")), { desc = "Prev Info", buffer = bufnr })
		map({ "n", "x" }, "]i", count_wrap(goto_diag("next", "INFO")), { desc = "Next Info", buffer = bufnr })
		map({ "n", "x" }, "[h", count_wrap(goto_diag("prev", "HINT")), { desc = "Prev Hint", buffer = bufnr })
		map({ "n", "x" }, "]h", count_wrap(goto_diag("next", "HINT")), { desc = "Next Hint", buffer = bufnr })
	end,
	capabilities = vim.tbl_deep_extend(
		"force",
		vim.lsp.protocol.make_client_capabilities(),
		require("cmp_nvim_lsp").default_capabilities()
	),
}
