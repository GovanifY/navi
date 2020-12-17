{ config, pkgs, ... }:
let
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
in
  let
    vimConf = {
      # TODO: document snips, surround and syntastic workarounds
      programs.neovim = {
        enable = true;
        withPython3 = true;
        viAlias = true;
        vimAlias = true;
        plugins = with pkgs.vimPlugins; [
          # aethetics
          gruvbox airline
          # productivity
          fzf-vim vim-visual-multi surround
          # dev
          tagbar fugitive nerdtree nerdcommenter nvim-gdb
          # dev - syntax
          syntastic ultisnips vim-snippets deoplete-nvim
          # dev - language specific
          rust-vim meson Jenkinsfile-vim-syntax Coqtail
          deoplete-rust deoplete-clang deoplete-jedi vim-nix
          # sessions
          vim-misc workspace
          # spell check
          vim-grammarous #vim-DetectSpellLang vim-operator-user unite vimproc
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

          " auto create sessions per folder and restore them
          let g:session_autoload = 'yes'
          let g:session_autosave = 'yes'
          let g:session_autosave_periodic = 1
          let g:session_directory = '~/.local/share/nvim/sessions'
          let g:session_default_name = getcwd()
          let g:session_default_overwrite = 1

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

          " fzf using ctrl+p
          nmap <C-P> :Files<CR>
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
