# user/app/neovim/neovim.nix

{  pkgs, ... }:

{
  programs.neovim =
    let
      #toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in
      {
      enable = true;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      extraPackages = with pkgs; [
        # language servers
        lua-language-server
        nil
        nixd  # Adding nixd for improved Nix LSP support
        nodePackages.yaml-language-server  # For YAML files including Home Assistant

        # clipboard support
        xclip
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; [

        # LSP
        # neodev must be loaded before lspconfig
        neodev-nvim
        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./nvim/plugin/lsp.lua;
        }

        # Completion
        nvim-cmp 
        {
          plugin = nvim-cmp;
          config = toLuaFile ./nvim/plugin/cmp.lua;
        }
        cmp_luasnip
        cmp-nvim-lsp
        luasnip
        friendly-snippets

        # Navigation
        {
          plugin = telescope-nvim;
          config = toLuaFile ./nvim/plugin/telescope.lua;
        }
        
        # Adding oil.nvim for file navigation
        {
          plugin = oil-nvim;
          config = toLuaFile ./nvim/plugin/oil.lua;
        }

        # Utility
        {
          plugin = lualine-nvim;
          config = toLuaFile ./nvim/plugin/lualine.lua;
        }
        nvim-web-devicons

        {
          plugin = (nvim-treesitter.withPlugins (p: [
            p.tree-sitter-nix
            p.tree-sitter-vim
            p.tree-sitter-bash
            p.tree-sitter-lua
            p.tree-sitter-python
            p.tree-sitter-json
            p.tree-sitter-markdown
            p.tree-sitter-markdown-inline
          ]));
          config = toLuaFile ./nvim/plugin/treesitter.lua;
        }

        vim-nix

        {
          plugin = catppuccin-nvim;
          config = toLuaFile ./nvim/plugin/catppuccin.lua;
        }

      ];

      extraLuaConfig = ''
        ${builtins.readFile ./nvim/options.lua}
      '';

    };

  programs.ripgrep.enable = true;

}
