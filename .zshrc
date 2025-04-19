-- basic settings --
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- auto-install lazy.nvim --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- plugins --
require("lazy").setup({
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({})
			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = "", -- remove symbols between components
					section_separators = "", -- no funky arrows
					globalstatus = true, -- one statusline for the whole screen
					disabled_filetypes = { "NvimTree" },
				},
				sections = {
					lualine_a = {}, -- remove mode (NORMAL/INSERT)
					lualine_b = { "branch" }, -- only show Git branch
					lualine_c = {}, -- no filename/path
					lualine_x = {}, -- no encoding or filetype
					lualine_y = {}, -- no progress
					lualine_z = {}, -- no cursor position
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
				},
			})
		end,
	},

	-- icons
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-web-devicons").setup({ default = true })

			require("nvim-web-devicons").set_icon({
				go = {
					icon = "",
					color = "#00ADD8",
					name = "Go",
				},
				py = {
					icon = "",
					color = "#6A8EAE",
					cterm_color = "74",
					name = "Py",
				},
			})
		end,
	},

	-- vscode ctrl + P
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup()
			vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, { desc = "Find files" })
		end,
	},

	-- tree
	{
		"nvim-tree/nvim-tree.lua",
		config = function()
			require("nvim-tree").setup({
				view = {
					side = "right",
					width = 30,
				},
				renderer = {
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
					},
				},
			})

			-- Remap Ctrl+B to toggle file explorer
			vim.keymap.set(
				"n",
				"<C-b>",
				":NvimTreeToggle<CR>",
				{ desc = "Toggle NvimTree", noremap = true, silent = true }
			)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("lspconfig").lua_ls.setup({})
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = {
					{ name = "nvim_lsp" },
				},
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					go = { "gofmt", "goimports" },
					lua = { "stylua" },
					python = { "black", "isort", "ruff_format" },
				},
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 500,
				},
			})
		end,
	},

	-- theme
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = true,
		config = function()
			require("gruvbox").setup({
				terminal_colors = true,
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = false,
					emphasis = false,
					comments = false,
					operators = false,
					folds = false,
				},
				strikethrough = true,
				invert_selection = false,
				invert_signs = false,
				invert_tabline = false,
				invert_intend_guides = false,
				inverse = true,
				contrast = "hard",
				palette_overrides = {},
				overrides = {},
				dim_inactive = false,
				transparent_mode = false,
			})

			vim.o.background = "dark"
			vim.cmd("colorscheme gruvbox")
		end,
	},
})

-- vscode ctrl + shift + F
vim.keymap.set("n", "<C-f>", require("telescope.builtin").live_grep, { desc = "Live grep" })

-- LSP --
local lspconfig = require("lspconfig")

local function on_attach(_, bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	map("n", "gd", vim.lsp.buf.definition, "[G]o to [D]efinition")
	map("n", "gr", vim.lsp.buf.references, "[G]o to [R]eferences")
	map("n", "gi", vim.lsp.buf.implementation, "[G]o to [I]mplementation")
	map("n", "K", vim.lsp.buf.hover, "Hover documentation")
	map("n", "<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame symbol")
end

-- go
lspconfig.gopls.setup({
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
	on_attach = on_attach,
	settings = {
		gopls = {
			analyses = {
				unusedparams = true,
				shadow = true,
			},
			staticcheck = true,
		},
	},
})

-- python
lspconfig.pyright.setup({
	on_attach = on_attach,
	settings = {
		python = {
			analysis = {
				autoSearchPaths = true,
				useLibraryCodeForTypes = true,
				diagnosticMode = "workspace",
			},
		},
	},
})
