return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{
				"rcarriga/nvim-dap-ui",
				opts = {
					floating = { border = "solid" },
					layouts = {
						{
							elements = {
								{ id = "scopes", size = 0.2 },
								{ id = "breakpoints", size = 0.2 },
								{ id = "stacks", size = 0.2 },
								{ id = "watches", size = 0.2 },
								{ id = "console", size = 0.2 },
							},
							position = "right",
							size = 55,
						},
						{
							elements = { { id = "repl", size = 1 } },
							position = "bottom",
							size = 8,
						},
					},
				},
				keys = function()
                         -- stylua: ignore start
					local function dapui(name)
						return require("dapui").float_element( name, { width = vim.o.columns, height = vim.o.lines, enter = true, position = "center" })
					end
					return {
						{ "<leader>dfs",function() dapui("scopes") end, desc = "Scope Float" },
						{ "<leader>dfr",function() dapui("repl") end, desc = "Repl Float" },
						{ "<leader>dfc",function() dapui("console") end, desc = "Console Float" },
						{ "<leader>dfb",function() dapui("breakpoints") end, desc = "Breakpoint Float" },
						{ "<leader>dfS",function() dapui("stacks") end, desc = "Stacks Float" },
						{ "<leader>dfw",function() dapui("watches") end, desc = "Watches Float" },
						-- stylua: ignore end
					}
				end,
			},
			{ "theHamsta/nvim-dap-virtual-text" },
		},
		config = function()
			local dap, dapui, icons = require("dap"), require("dapui"), require("utils.icons").dap
			vim.fn.sign_define("DapBreakpoint", { text = icons.Breakpoint, texthl = "DiagnosticSignHint" })
			vim.fn.sign_define(
				"DapBreakpointCondition",
				{ text = icons.BreakpointCondition, texthl = "DiagnosticSignInfo" }
			)
			vim.fn.sign_define(
				"DapBreakpointRejected",
				{ text = icons.BreakpointRejected, texthl = "DiagnosticSignWarn" }
			)
			vim.fn.sign_define("DapLogPoint", { text = icons.LogPoint, texthl = "DiagnosticSignOk" })
			vim.fn.sign_define("DapStopped", { text = icons.Stopped, texthl = "DiagnosticSignError" })
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
				require("nvim-dap-virtual-text").refresh()
			end
			dap.listeners.after.disconnect["dapui_config"] = function()
				require("dap.repl").close()
				require("dapui").close()
				require("nvim-dap-virtual-text").refresh()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function(e)
				vim.notify(string.format("program '%s' was terminated.", vim.fn.fnamemodify(e.config.program, ":t")), 2)
				require("nvim-dap-virtual-text").refresh()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
				require("nvim-dap-virtual-text").refresh()
			end
			dap.adapters = require("plugins.coding.adapters")
			dap.configurations = require("plugins.coding.configurations")
		end,
		keys = function()
			local dap, dapui, dap_widgets = require("dap"), require("dapui"), require("dap.ui.widgets")
			return {
                -- stylua: ignore start
				{ "<leader>dC", function() dap.set_breakpoint(vim.fn.input("[Condition] > ")) end, desc = "Conditional Breakpoint" },
				{ "<leader>dE", function() dapui.eval(vim.fn.input("[Expression] > ")) end, desc = "Evaluate Input" },
				{ "<leader>dR", function() dap.run_to_cursor() end, desc = "Run to Cursor" },
				{ "<leader>dS", function() dap_widgets.scopes() end, desc = "Scopes" },
				{ "<leader>dU", function() dapui.toggle() end, desc = "Toggle UI" },
				{ "<leader>dX", function() dap.close() end, desc = "Quit" },
				{ "<leader>db", function() dap.step_back() end, desc = "Step Back" },
				{ "<leader>dc", function() dap.continue() end, desc = "Continue" },
				{ "<leader>dd", function() dap.disconnect() end, desc = "Disconnect" },
				{ "<leader>de", function() dapui.eval() end, mode = { "n", "v"}, desc = "Evaluate", },
				{ "<leader>dg", function() dap.session() end, desc = "Get Session" },
				{ "<leader>dh", function() dap_widgets.hover() end, desc = "Hover Variables" },
				{ "<leader>di", function() dap.step_into() end, desc = "Step Into" },
				{ "<leader>do", function() dap.step_over() end, desc = "Step Over" },
				{ "<leader>dp", function() dap.pause.toggle() end, desc = "Pause" },
				{ "<leader>dr", function() dap.repl.toggle() end, desc = "Toggle REPL" },
				{ "<leader>ds", function() dap.continue() end, desc = "Start" },
				{ "<leader>dt", function() dap.toggle_breakpoint() end, desc = "Toggle Breakpoint" },
				{ "<leader>du", function() dap.step_out() end, desc = "Step Out" },
				{ "<leader>dx", function() dap.terminate() end, desc = "Terminate" },
				-- stylua: ignore end
			}
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = { "antoinemadec/FixCursorHold.nvim", "nvim-neotest/neotest-go", "llllvvuu/neotest-foundry" },
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-go")({
						experimental = { test_table = true },
						args = { "-count=1", "-timeout=60s" },
					}),
					require("neotest-foundry")({
						foundryCommand = "forge test",
						foundryConfig = nil,
						env = {}, -- table | function
						cwd = function()
							return require("utils.dir").cwd()
						end,
						filterDir = function(name)
							return not vim.tbl_contains(
								{ "node_modules", "cache", "out", "artifacts", "docs", "doc" },
								name
							)
						end,
					}),
				},
				default_strategy = "integrated",
				status = { enabled = true, signs = true, virtual_text = true },
				icons = {
					failed = " ",
					passed = " ",
					running = " ",
					skipped = " ",
					unknown = " ",
					watching = "󰈈 ",
				},
				run = { enabled = true },
				running = { concurrent = true },
				state = { enabled = true },
				output = { open_on_run = true },
				quickfix = {
					open = function()
						if require("lazy.core.config").spec.plugins["trouble.nvim"] ~= nil then
							vim.cmd("Trouble quickfix")
						else
							vim.cmd("copen")
						end
					end,
				},
			})
		end,
		keys = function()
			local n = require("neotest")
			return {
            -- stylua: ignore start
			{ "<leader>tF", function() n.run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Test Debug File" },
			{ "<leader>tL", function() n.run.run_last({ strategy = "dap" }) end, desc = "Debug Last Test" },
			{ "<leader>ta", function() n.run.attach() end, desc = "Test Attach" },
			{ "<leader>tf", function() n.run.run(vim.fn.expand("%")) end, desc = "Test File" },
			{ "<leader>tl", function() n.run.run_last() end, desc = "Run Last" },
			{ "<leader>tn", function() n.run.run() end, desc = "Nearest Test" },
			{ "<leader>tN", function() n.run.run({ strategy = "dap" }) end, desc = "Debug Nearest" },
			{ "<leader>to", function() n.output_panel.toggle() end, desc = "Output Panel" },
			{ "<leader>tx", function() n.run.stop() end, desc = "Test Stop" },
			{ "<leader>ts", function() n.summary.toggle() end, desc = "Test Summary" },
				-- stylua: ignore end
			}
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = "LspAttach",
		opts = {
			linters_by_ft = {},
			linters = {
				selene = {
					condition = function(ctx)
						return vim.fs.find({ "selene.toml" }, { path = ctx.filename, upward = true })[1]
					end,
				},
			},
		},
		config = function(_, opts)
			local Util = require("lazy.core.util")
			local M = {}
			local lint = require("lint")
			for name, linter in pairs(opts.linters) do
				if type(linter) == "table" and type(lint.linters[name]) == "table" then
					lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
				else
					lint.linters[name] = linter
				end
			end
			lint.linters_by_ft = opts.linters_by_ft
			function M.debounce(ms, fn)
				local timer = vim.uv.new_timer()
				return function(...)
					local argv = { ... }
					timer:start(ms, 0, function()
						timer:stop()
						vim.schedule_wrap(fn)(table.unpack(argv))
					end)
				end
			end

			function M.lint()
				local names = lint._resolve_linter_by_ft(vim.bo.filetype)
				if #names == 0 then
					vim.list_extend(names, lint.linters_by_ft["_"] or {})
				end
				-- Add global linters.
				vim.list_extend(names, lint.linters_by_ft["*"] or {})
				-- Filter out linters that don't exist or don't match the condition.
				local ctx = { filename = vim.api.nvim_buf_get_name(0) }
				ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
				names = vim.tbl_filter(function(name)
					local linter = lint.linters[name]
					if not linter then
						Util.warn("Linter not found: " .. name, { title = "nvim-lint" })
					end
					return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
				end, names)

				-- Run linters.
				if #names > 0 then
					lint.try_lint(names)
				end
			end
			vim.keymap.set("n", "<A-l>", function()
				M.debounce(100, M.lint)
			end, { desc = "Lint this files", buffer = vim.api.nvim_get_current_buf() })
		end,
	},
}
