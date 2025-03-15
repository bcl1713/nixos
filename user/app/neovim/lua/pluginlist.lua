-- user/app/neovim/lua/pluginlins.lua

return {

    "neovim/nvim-lspconfig",

    'folke/neodev.nvim',

    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets',
            'hrsh7th/cmp-nvim-lsp',
        },
    },

    { 
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' } 
    },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = {
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require("lualine").setup({
                icons_enabled = true,
                theme = 'onedark',
            })
        end,
    },

		{
			'echasnovski/mini.nvim',
			version = false
		},

}
