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

        # clipboard support
        xclip
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; [

        # LSP
        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./nvim/plugin/lsp.lua;
        }
        neodev-nvim

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
          ]));
          config = toLuaFile ./nvim/plugin/treesitter.lua;
        }

        vim-nix

      ];

      extraLuaConfig = ''
        ${builtins.readFile ./nvim/options.lua}
      '';

    };

  programs.ripgrep.enable = true;

}
