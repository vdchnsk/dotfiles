-- basic settings -- vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- disable highlight when done searching
vim.opt.hlsearch = true
vim.opt.incsearch = true

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
	-- file explorer
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
			vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
			vim.keymap.set(
				"n",
				"<C-b>",
				":NvimTreeToggle<CR>",
				{ desc = "Toggle NvimTree", noremap = true, silent = true }
			)
		end,
	},

	-- statusline
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					component_separators = "",
					section_separators = "",
					globalstatus = true,
					disabled_filetypes = { "NvimTree" },
				},
				sections = {
					lualine_a = {},
					lualine_b = { "branch" },
					lualine_c = {},
					lualine_x = {},
					lualine_y = {},
					lualine_z = {},
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
				go = { icon = "", color = "#00ADD8", name = "Go" },
				["go.mod"] = { icon = "", color = "#FF79C6", name = "Mod" },
				["go.sum"] = { icon = "", color = "#FF79C6", name = "Sum" },
				py = { icon = "", color = "#6A8EAE", cterm_color = "74", name = "Py" },
			})
		end,
	},

	-- telescope
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup()
			vim.keymap.set("n", "<C-p>", require("telescope.builtin").find_files, { desc = "Find files" })
			vim.keymap.set("n", "<C-f>", function()
				require("telescope.builtin").live_grep({
					additional_args = function()
						return { "--smart-case" }
					end,
				})
			end, { desc = "Telescope: Live grep (smart-case)" })
		end,
	},

	-- theme
	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
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
				dim_inactive = false,
				transparent_mode = false,
			})
			vim.o.background = "dark"
			vim.cmd("colorscheme gruvbox")
		end,
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
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
				map("n", "<F2>", vim.lsp.buf.rename, "LSP Rename (F2)")
			end

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

			lspconfig.clangd.setup({
				cmd = { "clangd" },
				filetypes = { "c", "cpp", "objc", "objcpp" },
				root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
				on_attach = on_attach,
			})

			lspconfig.lua_ls.setup({})
		end,
	},

	-- completion
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
				sources = { { name = "nvim_lsp" } },
			})
		end,
	},

	-- formatter
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					go = { "gofmt", "goimports" },
					lua = { "stylua" },
					python = { "black", "isort", "ruff_format" },
					cpp = { "clang_format" },
					c = { "clang_format" },
				},
				format_on_save = {
					lsp_fallback = true,
					timeout_ms = 500,
				},
			})
		end,
	},

	-- copilot
	{
		"github/copilot.vim",
		event = "InsertEnter",
	},

	-- bufferline (vscode tabs)
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("bufferline").setup({})
			vim.opt.termguicolors = true
		end,
	},

	-- gitlense
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "▎" },
					change = { text = "▎" },
					delete = { text = "▎" },
					topdelete = { text = "▎" },
					changedelete = { text = "▎" },
				},
				current_line_blame = true, -- show inline Git blame like GitLens
				current_line_blame_opts = {
					delay = 300,
					virt_text_pos = "eol",
				},
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					local function map(mode, l, r, desc)
						vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
					end

					-- Git hunk navigation
					map("n", "]g", gs.next_hunk, "Next Git hunk")
					map("n", "[g", gs.prev_hunk, "Prev Git hunk")

					-- Git actions
					map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
					map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
					map("n", "<leader>hb", gs.blame_line, "Blame line (full)")
				end,
			})
		end,
	},

	-- neogit
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional, but adds great diff UI
		},
		config = function()
			require("neogit").setup({
				kind = "split", -- or "vsplit" or "tab"
				signs = {
					section = { "", "" },
					item = { "", "" },
				},
				integrations = {
					diffview = true,
				},
			})
		end,
	},
})

vim.keymap.set("n", "<leader>gg", ":Neogit<CR>", { desc = "Open Neogit" })

-- Copilot: Accept suggestion on F1
vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<F1>", 'copilot#Accept("")', {
	expr = true,
	silent = true,
	replace_keycodes = false,
})

-- Buffer switching
vim.keymap.set("n", "<C-]>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<C-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })

-- Buffer close
vim.keymap.set("n", "<C-w>", ":bp | bd! #<CR>", { desc = "Close buffer" })

-- Run `make test`
vim.keymap.set("n", "<leader>mt", function()
	vim.cmd("belowright split | terminal make test")
end, { desc = "Make: test" })

-- clear search results
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
