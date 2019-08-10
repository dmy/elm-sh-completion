complete -e -c elm

complete -c elm -x -l help
complete -c elm -l version

complete -c elm -f -c elm -n '__fish_use_subcommand' -a repl
complete -c elm -x -c elm -n '__fish_seen_subcommand_from repl' -l help
complete -c elm -x -c elm -n '__fish_seen_subcommand_from repl' -l interpreter
complete -c elm -x -c elm -n '__fish_seen_subcommand_from repl' -l no-colors

complete -c elm -f -c elm -n '__fish_use_subcommand' -a init

complete -c elm -f -c elm -n '__fish_use_subcommand' -a reactor
complete -c elm -f -c elm -n '__fish_seen_subcommand_from reactor' -l help
complete -c elm -f -c elm -n '__fish_seen_subcommand_from reactor' -l port

complete -c elm -f -c elm -n '__fish_use_subcommand' -a make
complete -c elm -f -c elm -n '__fish_seen_subcommand_from make' -l help
complete -c elm -f -c elm -n '__fish_seen_subcommand_from make' -l debug
complete -c elm -f -c elm -n '__fish_seen_subcommand_from make' -l optimize
complete -c elm -f -c elm -n '__fish_seen_subcommand_from make' -l report=json
complete -c elm -f -c elm -n '__fish_seen_subcommand_from make' -l output
complete -c elm -f -c elm -n '__fish_seen_subcommand_from make' -l docs


complete -c elm -f -c elm -n '__fish_use_subcommand' -a install
complete -c elm -f -c elm -n '__fish_seen_subcommand_from install' -l help

complete -c elm -f -c elm -n '__fish_use_subcommand' -a bump

complete -c elm -f -c elm -n '__fish_use_subcommand' -a diff
complete -c elm -f -c elm -n '__fish_seen_subcommand_from diff' -l help

complete -c elm -f -c elm -n '__fish_use_subcommand' -a publish
complete -c elm -f -c elm -n '__fish_seen_subcommand_from publish' -l help
