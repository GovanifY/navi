{ config, lib, pkgs, ... } :
with lib;
let
  cfg = config.navi.components.headfull.editor;
  # contains some patches for syntastic and Tagbar support since upstream is
  # abandonned
  workspace = pkgs.vimPlugins.vim-obsession.overrideAttrs (oldAttrs: rec {
    src = pkgs.fetchFromGitHub {
       owner = "GovanifY";
       repo = "vim-session";
       rev = "13b906f18ad0fa88f0be038237a71aa34b3335da";
       sha256 = "1hf8gzh42iq46z6b471w6bl44nhwa9h8s02pmg1w482bvhc621w4";
     };
    version = "2020-12-16";
    pname = "vim-session";
  });
  vimConf = {
    programs.neovim = {
      enable = true;
      withPython3 = true;
      viAlias = true;
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        # aesthetics
        gruvbox airline
        # productivity
        fzf-vim vim-visual-multi
        # dev
        tagbar fugitive nerdtree nerdcommenter
        # dev - syntax
        vim-clang-format
        # dev - language specific
        rust-vim meson Coqtail vim-fish vim-nix
        # spell check
        #vim-DetectSpellLang
      ] ++ optionals cfg.ide_features [ 
        coc-snippets vim-snippets coc-nvim coc-python 
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
        " auto completion config
        set hidden
        set nobackup
        set nowritebackup
        set updatetime=300
        set shortmess+=c
        inoremap <silent><expr> <TAB>
             #\ pumvisible() ? coc#_select_confirm() :
             #\ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump','''])\<CR>" :
             #\ <SID>check_back_space() ? "\<TAB>" :
             #\ coc#refresh()

        function! s:check_back_space() abort
         #let col = col('.') - 1
         #return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        let g:coc_snippet_next = '<tab>'
        function! s:check_back_space() abort
         #let col = col('.') - 1
         #return !col || getline('.')[col - 1]  =~# '\s'
        endfunction
        inoremap <silent><expr> <c-space> coc#refresh()

        " Make <CR> auto-select the first completion item and notify coc.nvim to
        " format on enter, <cr> could be remapped by other vim plugin
        inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                     #\: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
        set statusline^=%{coc#status()}%{get(b:,'coc_current_function',''')}

        let g:coc_user_config = {
        \'preferences' : { "useQuickfixForLocations": 'true' },
        \'languageserver': {
        \     'bash': {
        \       "command": "${pkgs.nodePackages.bash-language-server}/bin/bash-language-server",
        \       "args": ["start"],
        \       "filetypes": ["sh"],
        \       "rootPatterns": [".vim/", ".git/", ".hg/"],
        \       "ignoredRootPaths": ["~"],
        \     },
        \     "nix": {
        \        "command": "${pkgs.rnix-lsp}/bin/rnix-lsp",
        \        "filetypes": ["nix"]
        \     },
        \     "clangd": {
        \        "command": "${pkgs.llvmPackages.libclang.out}/bin/clangd",
        \        "rootPatterns": ["compile_flags.txt", "compile_commands.json", ".git/"],
        \        "filetypes": ["c", "cc", "cpp", "c++", "objc", "objcpp", "h"]
        \     },
        \     "rust": {
        \       "command": "${pkgs.rust-analyzer}/bin/rust-analyzer",
        \       "filetypes": ["rust", "rs"],
        \       "rootPatterns": ["Cargo.toml"]
        \     },
        \     "haskell": {
        \       "command": "${pkgs.haskellPackages.haskell-language-server.out}/bin/haskell-language-server-wrapper",
        \       "args": ["--lsp"],
        \       "rootPatterns": ["*.cabal", "stack.yaml", "cabal.project", "package.yaml", "hie.yaml"],
        \       "filetypes": ["haskell", "lhaskell", "hs"]
        \     }
        \  }
        \}
      '';
    };
  };

in
{
  options.navi.components.headfull.editor = {
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
      default = true;
      description = ''
        Adds some automatic session saving and resuming functionality.
      '';
    };
  };
  config = mkIf cfg.enable {
    home-manager.users.govanify = vimConf;
    home-manager.users.root = vimConf;
    environment.variables = {
      EDITOR = "vim";
    };
    environment.systemPackages = with pkgs; mkIf cfg.ide_features [
      nodejs
    ];
  };
}
