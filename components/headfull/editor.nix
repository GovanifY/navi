{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.editor;
  # contains some patches for syntastic and Tagbar support since upstream is
  # abandonned
  workspace = pkgs.vimPlugins.vim-obsession.overrideAttrs (
    oldAttrs: rec {
      src = pkgs.fetchFromGitHub {
        owner = "GovanifY";
        repo = "vim-session";
        rev = "13b906f18ad0fa88f0be038237a71aa34b3335da";
        sha256 = "1hf8gzh42iq46z6b471w6bl44nhwa9h8s02pmg1w482bvhc621w4";
      };
      version = "2020-12-16";
      pname = "vim-session";
    }
  );
  vimConf = {
    programs.neovim = {
      enable = true;
      withPython3 = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        # aesthetics
        gruvbox
        airline
        # productivity
        fzf-vim
        vim-visual-multi
        # dev
        tagbar
        fugitive
        nerdtree
        nerdcommenter
        # dev - syntax
        vim-clang-format
        # dev - language specific
        rust-vim
        meson
        Coqtail
        vim-fish
        vim-nix
        # spell check
        #vim-DetectSpellLang
      ] ++ optionals cfg.ide_features [
        coc-snippets
        vim-snippets
        coc-nvim
        coc-python
        coc-ltex
      ] ++ optionals cfg.sessions [ vim-misc workspace ];
      extraConfig = ''
        " This should be enabled by default
        set number
        set incsearch
        set smartcase
        set expandtab

        " Making the clipboard use the + register(aka common system clipboard)
        " wayland requires neovim currently
        set clipboard=unnamedplus

        " Ignore common file types
        set wildignore=*.o
        let NERDTreeIgnore=['.o$[[file]]', '\~$']
        " Display airline bar
        set laststatus=2
        set title
        set lazyredraw
        set wildmenu
        set showmatch

        " show existing tab with 4 spaces width
        set tabstop=4
        " when indenting with '>', use 4 spaces width
        set shiftwidth=4

        " Enable folding
        set foldenable
        " Open all default fold at level <= 10
        set foldlevelstart=10
        " Nested folding level max = 10
        set foldnestmax=10
        " Folding by indentation
        set foldmethod=indent

        " Prevent Vim slowness with very long lines
        set synmaxcol=300

        " good compromise between plain numbers and standard 78
        set textwidth=80

        "let mapleader = "\<Space>"
        exec 'set tags+=' . findfile('.git/tags', ';')

        " Hack supports this so let's use it
        let g:airline_powerline_fonts = 1
        " ...but doesn't support the E0A3 symbol yet, so let's do that
        let g:airline_symbols = {}
        let g:airline_symbols.colnr = "㏇"

        set t_Co=256
        set termguicolors

        " allow vim to read shift-jis files
        set fileencodings=ucs-bom,utf-8,sjis,default


        " This is only necessary if you use "set termguicolors".
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        " Use this for solarized
        " set background=dark
        " colorscheme solarized
        " Use this for Gruvbox
        set background=dark
        colorscheme gruvbox

        " automatic spell check
        autocmd BufRead /tmp/neomutt-* setlocal spell
        autocmd FileType gitcommit setlocal spell
        autocmd FileType markdown setlocal spell
        let g:guesslang_langs = [ 'en_US', 'fr_FR', 'ja_JP' ]
        " TODO: incremental grammar checks in vim when spelllang is enabled would be neat in the future

        " fzf using ctrl+p, also avoiding focus on nerdtree
        nnoremap <silent> <expr> <C-P> (expand('%') =~ 'NERD_tree' ? "\<c-w>\<c-w>" : ''').":FZF\<cr>"

        " automatic clang-format pickup
        let g:clang_format#detect_style_file = 1
        let g:clang_format#auto_format=1
      '' + optionalString cfg.sessions ''
        " auto create sessions per folder and restore them
        set sessionoptions+=blank
        let g:session_autoload = 'yes'
        let g:session_autosave = 'yes'
        let g:session_autosave_periodic = 1
        let g:session_directory = '~/.local/share/nvim/sessions'
        let g:session_default_name = getcwd()
        let g:session_default_overwrite = 1
      '' + optionalString cfg.ide_features ''
        function! CheckBackspace() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        inoremap <silent><expr> <TAB>
              \ coc#pum#visible() ? coc#pum#next(1) :
              \ CheckBackspace() ? "\<Tab>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

        " Make <CR> to accept selected completion item or notify coc.nvim to format
        " <C-g>u breaks current undo, please make your own choice
        inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
        set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\''')}
      '';

      coc = {
        enable = true;
        settings = {
          preferences.useQuickfixForLocations = true;
          ltex.ltex-ls.path = "${pkgs.ltex-ls}";
          ltex.java.path = "${pkgs.jre_headless}";
          ltex.dictionary = {
            "en-US" = [ ":~/.config/nvim/spell/dictionary.txt" ];
            "fr" = [ ":~/.config/nvim/spell/dictionary.txt" ];
          };
          languageserver = {
            nix = {
              command = "${pkgs.nil}/bin/nil";
              filetypes = [ "nix" ];
            };
            ltex = {
              command = "${pkgs.ltex-ls}/bin/ltex-ls";
              filetypes = [ "markdown" "text" "latex" ];
            };
            clangd = {
              command = "${pkgs.llvmPackages.libclang.out}/bin/clangd";
              rootPatterns = [ "compile_flags.txt" "compile_commands.json" ".git/" ];
              filetypes = [ "c" "cc" "cpp" "c++" "objc" "objcpp" "h" ];
            };
            rust = {
              command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
              rootPatterns = [ "Cargo.toml" ];
              filetypes = [ "rust" "rs" ];
            };
            haskell = {
              command = "${pkgs.haskellPackages.haskell-language-server.out}/bin/haskell-language-server-wrapper";
              args = [ "--lsp" ];
              rootPatterns = [
                "*.cabal"
                "stack.yaml"
                "cabal.project"
                "package.yaml"
                "hie.yaml"
              ];
              filetypes = [ "haskell" "lhaskell" "hs" ];
            };
          };
        };
      };

    };
  };

in
{
  options.navi.components.editor = {
    enable = mkEnableOption "Enable navi's text editor";
    ide_features = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Adds some IDE-like features to the text editor.
        Please note that some language server are very fragile (eg C/C++)
        or straight up don't work. I personally recommand against adding
        IDE features to the text editor, as this has hurt my productivity,
        but you choose your setup!
      '';
    };
    sessions = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Adds some automatic session saving and resuming functionality.
      '';
    };
  };
  config = mkIf cfg.enable {
    home-manager.users.${config.navi.username} = vimConf;
    home-manager.users.root = vimConf;
    environment.variables = {
      EDITOR = "vim";
    };
    environment.systemPackages = with pkgs; [
      neovim
      fzf
      ctags
    ] ++ optionals cfg.ide_features [ nodejs ltex-ls ];
  };
}
