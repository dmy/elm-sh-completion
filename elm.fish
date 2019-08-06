complete -e -c elm

complete -c elm -s h -l help
complete -c elm -l version

set -l __fish_elm_subcommands repl init reactor make install bump diff publish
complete -c elm -f -c elm -n '__fish_use_subcommand' -a '$__fish_elm_subcommands'
complete -c elm -x -c elm -n '__fish_seen_subcommand_from help' -a '$__fish_elm_subcommands'
