vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.loaded_2html_plugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_matchit = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_fzf_file_explorer = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.cmdheight = 0
vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.clipboard = "unnamedplus"
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.conceallevel = 3
vim.opt.confirm = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.formatoptions = "jcroqlnt"
vim.opt.ignorecase = true
vim.opt.inccommand = "nosplit"
vim.opt.laststatus = 3
vim.opt.list = true
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.pumblend = 0
vim.opt.pumheight = 10
vim.opt.relativenumber = true
vim.opt.scrolloff = 4
vim.opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
vim.opt.shiftround = true
vim.opt.shiftwidth = 4
vim.opt.shortmess:append({ W = true, I = true, c = true, C = true })
vim.opt.showmode = false
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.spelllang = { "en" }
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.undolevels = 10000
vim.opt.updatetime = 150
vim.opt.virtualedit = "block"
vim.opt.wildmode = "longest:full,full"
vim.opt.winminwidth = 5
vim.opt.wrap = false
vim.opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
vim.opt.smoothscroll = true
vim.opt.foldlevel = 99
vim.opt.switchbuf = "useopen,uselast"
vim.opt.synmaxcol = 300
vim.opt.whichwrap = "h,l"
vim.opt.visualbell = true
vim.opt.diffopt:append("algorithm:histogram")
vim.opt.wildignore:append(
	"*.png,*.jpg,*.jpeg,*.gif,*.wav,*.aiff,*.dll,*.pdb,*.mdb,*.so,*.swp,*.zip,*.gz,*.bz2,*.meta,*.svg,*.cache,*/.git/*"
)
vim.opt.cursorcolumn = true
vim.opt.cursorlineopt = "both"

if vim.fn.executable("rg") == 1 then
	vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
	vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
elseif vim.fn.executable("ag") == 1 then
	vim.opt.grepprg = "ag --vimgrep"
	vim.opt.grepformat = "%f:%l:%c:%m"
elseif vim.fn.executable("ack") == 1 then
	vim.opt.grepprg = "ack --nogroup --nocolor"
elseif vim.fn.finddir(".git", ".;") ~= "" then
	vim.opt.grepprg = "git --no-pager grep --no-color -n"
	vim.opt.grepformat = "%f:%l:%m,%m %f match%ts,%f"
else
	vim.opt.grepprg = "grep -nIR $* /dev/null"
end

vim.wo.colorcolumn = "80,120"

vim.g.border = "single"
vim.g.markdown_recommended_style = 0
