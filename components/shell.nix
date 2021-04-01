{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.shell;
  fish_config = ''
    set fish_greeting
    set -U fish_color_normal normal
    set -U fish_color_command a1b56c
    set -U fish_color_quote f7ca88
    set -U fish_color_redirection d8d8d8
    set -U fish_color_end ba8baf
    set -U fish_color_error ab4642
    set -U fish_color_param d8d8d8
    set -U fish_color_selection white --bold --background=brblack
    set -U fish_color_search_match bryellow --background=brblack
    set -U fish_color_history_current --bold
    set -U fish_color_operator 7cafc2
    set -U fish_color_escape 86c1b9
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_valid_path --underline
    set -U fish_color_autosuggestion 585858
    set -U fish_color_user brgreen
    set -U fish_color_host normal
    set -U fish_color_cancel -r
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D yellow
    set -U fish_pager_color_prefix white --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
    set -U fish_color_match 7cafc2
    set -U fish_color_command a1b56c
    set -U fish_color_quote f7ca88
    set -U fish_color_comment f7ca88
    set -U fish_color_end ba8baf
    set -U fish_color_error ab4642
    set -U fish_color_param d8d8d8
    set -U fish_color_redirection d8d8d8
    set -U fish_color_match 7cafc2
    set -U fish_color_selection white --bold --background=brblack
    set -U fish_color_search_match bryellow --background=brblack
    set -U fish_color_history_current --bold
    set -U fish_color_operator 7cafc2
    set -U fish_color_escape 86c1b9
    set -U fish_color_cwd green
    set -U fish_color_cwd_root red
    set -U fish_color_valid_path --underline
    set -U fish_color_autosuggestion 585858
    set -U fish_color_user brgreen
    set -U fish_color_host normal
    set -U fish_color_cancel -r
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D yellow
    set -U fish_pager_color_prefix white --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
    set -U fish_color_comment f7ca88
    set -U fish_color_normal normal
  '';
  fish_prompt = ''
    function fish_prompt
        set -l __last_command_exit_status $status

        if not set -q -g __fish_robbyrussell_functions_defined
            set -g __fish_robbyrussell_functions_defined
            function _git_branch_name
                set -l branch (git symbolic-ref --quiet HEAD 2>/dev/null)
                if set -q branch[1]
                    echo (string replace -r '^refs/heads/' ''' $branch)
                else
                    echo (git rev-parse --short HEAD 2>/dev/null)
                end
            end

            function _is_git_dirty
                echo (git status -s --ignore-submodules=dirty 2>/dev/null)
            end

            function _is_git_repo
                type -q git
                or return 1
                git rev-parse --git-dir >/dev/null 2>&1
            end

            function _hg_branch_name
                echo (hg branch 2>/dev/null)
            end

            function _is_hg_dirty
                echo (hg status -mard 2>/dev/null)
            end

            function _is_hg_repo
                fish_print_hg_root >/dev/null
            end

            function _repo_branch_name
                _$argv[1]_branch_name
            end

            function _is_repo_dirty
                _is_$argv[1]_dirty
            end

            function _repo_type
                if _is_hg_repo
                    echo 'hg'
                    return 0
                else if _is_git_repo
                    echo 'git'
                    return 0
                end
                return 1
            end
        end

        set -l cyan (set_color -o cyan)
        set -l yellow (set_color -o yellow)
        set -l red (set_color -o red)
        set -l green (set_color -o green)
        set -l blue (set_color -o blue)
        set -l normal (set_color normal)

        set -l nix_shell_info (
          if test -n "$IN_NIX_SHELL"
            echo -n " $green(nix-shell)"
          end
        )

        set -l arrow_color "$green"
        if test $__last_command_exit_status != 0
            set arrow_color "$red"
        end

        set -l arrow "$arrow_color➜ "
        if test "$USER" = 'root'
            set arrow "$arrow_color# "
        end

        set -l cwd $cyan(basename (prompt_pwd))

        if set -l repo_type (_repo_type)
            set -l repo_branch $red(_repo_branch_name $repo_type)
            set repo_info "$blue $repo_type:($repo_branch$blue)"

            set -l dirty (_is_repo_dirty $repo_type)
            if test -n "$dirty"
                set -l dirty "$yellow ✗"
                set repo_info "$repo_info$dirty"
            end
        end

        echo -n -s $arrow ' '$cwd $repo_info $normal $nix_shell_info ' '
    end
  '';
in
{
  options.navi.components.shell = {
    enable = mkEnableOption "Enable navi's custom shell";
  };
  config = mkIf cfg.enable {
    users.defaultUserShell = pkgs.fish;
    programs.fish = {
      promptInit = ''
        any-nix-shell fish --info-right | source
      '';
      enable = true;
      shellAliases.nbuild = "nix-build /nix/var/nix/profiles/per-user/root/channels/nixos/ --run fish --run-env -A";
    };
    # TODO: make it for all users?
    home-manager.users.${config.navi.username} = {
      home.file.".config/fish/config.fish".text = fish_config;
      home.file.".config/fish/functions/fish_prompt.fish".text = fish_prompt;
    };
    home-manager.users.root = {
      home.file.".config/fish/config.fish".text = fish_config;
      home.file.".config/fish/functions/fish_prompt.fish".text = fish_prompt;
    };
  };
}
