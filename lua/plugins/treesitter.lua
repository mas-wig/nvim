return {
	{
		"nvim-treesitter/nvim-treesitter",
		version = false,
		build = ":TSUpdate",
		event = { "FileType" },
		init = function(plugin)
			require("lazy.core.loader").add_to_rtp(plugin)
			require("nvim-treesitter.query_predicates")
		end,
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"diff",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"yaml",
				"go",
				"gomod",
				"gowork",
				"gosum",
				"ron",
				"rust",
				"toml",
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = { query = "@function.outer", desc = "Around Func" },
						["if"] = { query = "@function.inner", desc = "Inside Func" },
						["al"] = { query = "@loop.outer", desc = "Around Loop" },
						["il"] = { query = "@loop.inner", desc = "Inside Loop" },
						["ak"] = { query = "@class.outer", desc = "Around Class" },
						["ik"] = { query = "@class.inner", desc = "Inside Class" },
						["ap"] = { query = "@parameter.outer", desc = "Around Param" },
						["ip"] = { query = "@parameter.inner", desc = "Inside Param" },
						["a/"] = { query = "@comment.outer", desc = "Around Comment" },
						["ab"] = { query = "@block.outer", desc = "Around Block" },
						["ib"] = { query = "@block.inner", desc = "Inside Block" },
						["ac"] = { query = "@conditional.outer", desc = "Around Cond" },
						["ic"] = { query = "@conditional.inner", desc = "Inside Cond" },
					},
				},
				move = {
					enable = true,
					goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
					goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
					goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
					goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
				},
			},
		},
		config = function(_, opts)
			local ts_locals = require("nvim-treesitter.locals")
			local ts_utils = require("nvim-treesitter.ts_utils")
			local references = {}
			local function before(r1, r2)
				if not r1 or not r2 then
					return false
				end
				if r1.start.line < r2.start.line then
					return true
				end
				if r2.start.line < r1.start.line then
					return false
				end
				if r1.start.character < r2.start.character then
					return true
				end
				return false
			end

			local function goto_adjecent_reference(opt)
				opt = vim.tbl_extend("force", { forward = true, wrap = true }, opt or {})
				local bufnr = vim.api.nvim_get_current_buf()
				local refs = references[bufnr]
				if not refs or #refs == 0 then
					return nil
				end

				local next, nexti = nil, nil
				local crow, ccol = unpack(vim.api.nvim_win_get_cursor(0))
				local crange = { start = { line = crow - 1, character = ccol } }

				for i, ref in ipairs(refs) do
					local range = ref.range
					if opt.forward then
						if before(crange, range) and (not next or before(range, next)) then
							next = range
							nexti = i
						end
					else
						if before(range, crange) and (not next or before(next, range)) then
							next = range
							nexti = i
						end
					end
				end
				if not next and opt.wrap then
					nexti = opt.reverse and #refs or 1
					next = refs[nexti].range
				end
				vim.api.nvim_win_set_cursor(0, { next.start.line + 1, next.start.character })
				return next
			end

			local function index_of(tbl, obj)
				for i, o in ipairs(tbl) do
					if o == obj then
						return i
					end
				end
			end

			local function goto_adjacent_usage(bufnr, delta)
				local opt, en = { forward = delta > 0 }, true
				if type(en) == "table" then
					en = vim.tbl_contains(en, vim.o.ft)
				end
				if en == false then
					return goto_adjecent_reference(opt)
				end

				bufnr = bufnr or vim.api.nvim_get_current_buf()
				local node_at_point = ts_utils.get_node_at_cursor()
				if not node_at_point then
					goto_adjecent_reference(opt)
					return
				end

				local def_node, scope = ts_locals.find_definition(node_at_point, bufnr)
				local usages = ts_locals.find_usages(def_node, scope, bufnr)

				local index = index_of(usages, node_at_point)
				if not index then
					goto_adjecent_reference(opt)
					return
				end

				local target_index = (index + delta + #usages - 1) % #usages + 1
				ts_utils.goto_node(usages[target_index])
			end

			vim.keymap.set({ "n", "x" }, "]]", function()
				goto_adjacent_usage(vim.api.nvim_get_current_buf(), 1)
			end, { desc = "Next Usage" })

			vim.keymap.set({ "n", "x" }, "[[", function()
				goto_adjacent_usage(vim.api.nvim_get_current_buf(), -1)
			end, { desc = "Prev Usage" })

			if type(opts.ensure_installed) == "table" then
				local added = {}
				opts.ensure_installed = vim.tbl_filter(function(lang)
					if added[lang] then
						return false
					end
					added[lang] = true
					return true
				end, opts.ensure_installed)
			end
			require("nvim-treesitter.configs").setup(opts)
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-context", event = "BufRead", opts = { mode = "cursor", max_lines = 3 } },
	{ "windwp/nvim-ts-autotag", config = true, ft = { "html", "javascriptreact", "typescriptreact", "templ" } },
	{ "nvim-treesitter/nvim-treesitter-textobjects", event = "BufRead" },
}
