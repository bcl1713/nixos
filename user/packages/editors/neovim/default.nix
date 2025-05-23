# user/packages/editors/neovim/default.nix

{ config, lib, pkgs, ... }:

with lib;

let 
  cfg = config.userPackages.editors.neovim;
  toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
in {
  options.userPackages.editors.neovim = {
    plugins = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable Neovim plugins";
      };

      lsp = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable LSP support";
        };
      };

      git = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable Git integration";
        };
      };

      markdown = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to enable Markdown support";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;

      defaultEditor = true;

      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;

      extraLuaConfig = ''
        ${builtins.readFile ./lua/options.lua}
        ${builtins.readFile ./lua/plugin/markdown-snippets.lua}
      '';

      extraPackages = with pkgs; [
        # language servers
        lua-language-server # Lua
        nil # Nix 
        nixd  # Nix
        nodePackages.yaml-language-server  # YAML
        marksman # Markdown

        # clipboard support
        xclip
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; 
        # Base plugins always included
        [
          # LSP
          neodev-nvim
          {
            plugin = nvim-lspconfig;
            config = toLuaFile ./lua/plugin/lsp.lua;
          }

          # Completion
          nvim-cmp 
          {
            plugin = nvim-cmp;
            config = toLuaFile ./lua/plugin/cmp.lua;
          }
          cmp_luasnip
          cmp-nvim-lsp
          luasnip
          friendly-snippets

          # Navigation
          {
            plugin = telescope-nvim;
            config = toLuaFile ./lua/plugin/telescope.lua;
          }
          
          # File navigation
          {
            plugin = oil-nvim;
            config = toLuaFile ./lua/plugin/oil.lua;
          }

          # Utility
          {
            plugin = lualine-nvim;
            config = toLuaFile ./lua/plugin/lualine.lua;
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
            config = toLuaFile ./lua/plugin/treesitter.lua;
          }

          vim-nix

          {
            plugin = catppuccin-nvim;
            config = toLuaFile ./lua/plugin/catppuccin.lua;
          }
          
          {
            plugin = which-key-nvim;
            config = toLuaFile ./lua/plugin/which-key.lua;
          }
          
          plenary-nvim
        ] 
        # Conditionally add markdown plugins
        ++ (optionals cfg.plugins.markdown.enable [
          {
            plugin = markdown-preview-nvim;
            config = toLuaFile ./lua/plugin/markdown-preview.lua;
          }
          {
            plugin = vim-table-mode;
            config = toLuaFile ./lua/plugin/table-mode.lua;
          }
          {
            plugin = headlines-nvim;
            config = toLuaFile ./lua/plugin/headlines.lua;
          }
          {
            plugin = zen-mode-nvim;
            config = toLuaFile ./lua/plugin/zen-mode.lua;
          }
        ])
        # Conditionally add git plugins
        ++ (optionals cfg.plugins.git.enable [
          {
            plugin = gitsigns-nvim;
            config = toLuaFile ./lua/plugin/git.lua;
          }
          vim-fugitive
          diffview-nvim
        ]);
    };

    programs.ripgrep.enable = true;
  };
}
