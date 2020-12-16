{ config, pkgs, ... }:
let 
  workspace = pkgs.vimPlugins.vim-obsession.overrideAttrs (oldAttrs: rec {
        src = pkgs.fetchFromGitHub {
            owner = "xolox";
            repo = "vim-session";
            rev = "9e9a6088f0554f6940c19889d0b2a8f39d13f2bb";
            sha256 = "0r6k3fh0qpg95a02hkks3z4lsjailkd5ddlnn83w7f51jj793v3b";
          };
         version = "2020-12-16";
         pname = "vim-session";
      });
in
  let
    vimConf = {
      programs.neovim = {
        enable = true;
        withPython3 = true;
        viAlias = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [ tagbar gruvbox nerdtree fugitive
        airline ctrlp multiple-cursors surround
        nerdcommenter easymotion vim-misc #workspace TODO: one day fix this
        syntastic ultisnips vim-snippets deoplete-nvim
        deoplete-rust deoplete-clang deoplete-jedi vim-nix
        rust-vim meson Jenkinsfile-vim-syntax Coqtail vim-grammarous
        vim-DetectSpellLang
      ];
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

          " make syntastic actually useful
          let g:syntastic_always_populate_loc_list = 1
          let g:syntastic_auto_loc_list = 1
          let g:syntastic_check_on_open = 1
          let g:syntastic_check_on_wq = 0
          " clang_check can use a compile db which greps all includes
          let g:syntastic_cpp_checkers = ['clang_check', 'clang_tidy']
          let g:syntastic_cpp_clang_check_post_args = ""


          " ultisnips keybinds
          let g:UltiSnipsExpandTrigger="<tab>"
          let g:UltiSnipsJumpForwardTrigger="<c-x>"
          let g:UltiSnipsJumpBackwardTrigger="<c-z>"

          " If you want :UltiSnipsEdit to split your window.
          let g:UltiSnipsEditSplit="vertical"
          set sessionoptions+=blank
          set t_Co=256
          set termguicolors

          let g:session_autoload = 'yes'
          let g:session_autosave = 'yes'
          " This should be per folder
          let g:session_autosave_to = 'default'
          let g:session_verbose_messages = 0
          let g:session_directory = '~/.local/share/nvim/sessions'

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
          let g:guesslang_langs = [ 'en_US', 'fr_FR' 'ja_JP' ]
          let g:grammarous#languagetool_cmd = 'languagetool'
          " TODO: incremental grammar checks in vim when spelllang is enabled would be neat in the future
        '';


      };
    };
    in
    {
        home-manager.users.govanify = vimConf; 
        home-manager.users.root = vimConf; 

        environment.variables = {
          EDITOR = "vim";
        };
      }
