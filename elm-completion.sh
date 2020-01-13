##
#
# bash/zsh-bashcompinit elm completion script
#
# Copyright (C) 2019 Rémi Lefèvre
# 
# https://github.com/dmy/elm-sh-completion
#
# To install, two options:
#   
#   Option 1: Add the file in /etc/bash_completion.d/ if it exists on your system
#       $ sudo curl -o /etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
#
#   Option 2: Source the file from your ~/.bashrc
#       For example:
#       $ mkdir -p ~/.bash
#       $ cd ~/.bash
#       $ git clone https://github.com/dmy/elm-sh-completion.git
#       $ echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bashrc
#
##

##
#
# Elm home and packages directory
#
##
elm_version="$(elm --version 2>/dev/null)"
if [ $? -ne 0 ]; then
    echo "elm-sh-completion error: cannot run 'elm --version'"
    echo "Please check that elm command is available from PATH."
    return 1
fi
elm_home="${ELM_HOME:-$HOME/.elm}/${elm_version}"
if [ "${elm_version}" = "0.19.0" ]; then
    packages_dir="${elm_home}/package"
    registry="${packages_dir}/versions.dat"
else
    packages_dir="${elm_home}/packages"
    registry="${packages_dir}/registry.dat"
fi
 
##
#
# elm
#
##
_elm ()
{
    if [ ! -d "$packages_dir" ]; then
        return 0;
    fi

    local word="$2"
    local previous_arg="$3"
    case "${COMP_WORDS[1]}" in
        --help)
            ;;
        repl)
            flags "$@" '--help --interpreter --no-colors'
            ;;
        init)
            ;;
        reactor)
            flags "$@" '--help --port'
            ;;
        make)
            flags "$@" '--help --debug --optimize --report=json' '--output --docs'
            ;;
        install)
            if [ "$previous_arg" = "install" ]; then
                packages "$word" "--help"
            fi
            ;;
        bump)
            flags "$@" 
            ;;
        diff)
            if [ "$previous_arg" = "diff" ]; then
                packages "$word" "--help"
            elif [ -d "${packages_dir}/${previous_arg}" ]; then
                package_versions "${previous_arg}" "$word"
            elif [ -d "${packages_dir}/${COMP_WORDS[-3]}/${previous_arg}" ]; then
                package_versions "${COMP_WORDS[-3]}" "$word"
            fi
            ;;
        publish)
            flags "$@" '--help'
            ;;
        *)
            flags "$@" '--help repl init reactor make install bump diff publish'
            ;;
    esac
}

##
#
# elm-json
#
##
_elm_json ()
{
    if [ ! -d "$packages_dir" ]; then
        return 0;
    fi

    local word="$2"
    local previous_arg="$3"

    local command=""
    find_command help install new tree uninstall upgrade solve completions
    if find_command -h --help -V --version; then
        return 0
    fi

    case "$command" in
        help)
            flags "$@" 'install new tree uninstall upgrade solve completions'
            ;;
        install)
            packages "$word" '--help --test --yes'
            ;;
        new)
            ;;
        tree)
            flags "$@" '' '--test'
            ;;
        uninstall)
            packages "$word" '--help --yes'
            ;;
        upgrade)
            flags "$@" "--help --unsafe --yes"
            ;;
        solve)
            case "$previous_arg" in
                -e|--extra)
                    packages "$word"
                    ;;
                *)
                    flags "$@" '--help --minimize --test --extra'
                    ;;
            esac
            ;;
        completions)
            flags "$@" 'bash zsh fish'
            ;;
        *)
            flags "$@" 'help --help --version --verbose install new tree uninstall upgrade solve completions'
            ;;
    esac
}

##
#
# elm-test
#
##
_elm_test ()
{
    if [ ! -d "$packages_dir" ]; then
        return 0;
    fi

    local word="$2"
    local previous_arg="$3"
    case "${previous_arg}" in
        install)
            packages "$word" "--help"
            ;;
        --seed)
            COMPREPLY=($(compgen -W "0" -- "$word"))
            ;;
        --fuzz)
            COMPREPLY=($(compgen -W "100 500" -- "$word"))
            ;;
        --report)
            COMPREPLY=($(compgen -W "json junit console" -- "$word"))
            ;;
        *)
            flags "$@" \
                "--help install --seed --fuzz --report --version --watch" \
                "--compiler"
            ;;
    esac
}

##
#
# Helpers
#
##

# Set command variable to the command found if any
# $@: list of commands
find_command ()
{
    for w in ${COMP_WORDS[@]:1};do
        for cmd in "$@"; do
            if [ "$w" = "$cmd" ]; then
                command="$cmd";
                return 0
            fi
        done
    done
    return 1
}

# $@: all complete arguments + list of completion results
flags ()
{
    local word="$2"
    local lastarg="$3"
    local flags="$4"
    local flags_with_files="$5"

    # Let the shell complete files for these options
    for flag in $flags_with_files; do
        if [ "$lastarg" = "$flag" ]; then
            COMPREPLY=()
            return 0
        fi
    done

    if [ -z "$word" ]; then
        # Return all flags for empty word
        COMPREPLY=($flags $flags_with_files)
    else
        # Return flags matching the word
        COMPREPLY=($(compgen -W "$flags $flags_with_files" -- "$word"))
    fi
}

# $1: pattern word
# $2: additional completion results to add to packages
packages ()
{
    local word="$1"
    local additional_matches="$2"
    local packages=""
    case "$word" in
        */*@*)
            # Match packages with version after @
            packages=$(cd "${packages_dir}" && echo */*/* | sed 's/\/\([0-9]\)/@\1/g')
            packages="${packages} ${additional_matches}"
            COMPREPLY=($(compgen -W "$packages" -- "$word"))
            ;;
        *)
            # Match packages with author names, without elm-lang/ ones
            packages=$(grep -Eao '[A-Za-z0-9-]{2,}' ${registry} | paste -d "/" - - | grep -v 'elm-lang/' | uniq)
            packages="${packages} ${additional_matches}"
            COMPREPLY=($(compgen -W "$packages" -- "$word"))
            if [ ${#COMPREPLY[@]} -eq 0 ]; then
                # Match packages from partial matches
                COMPREPLY=($(echo "$packages" | grep -- "$word"))
            fi
            ;;
    esac
}

# $1: package
# $2: pattern word
# $3: additional completion results to add to versions
package_versions ()
{
    local package="$1"
    local word="$2"
    local additional_matches="$3"
    local versions=$(cd "${packages_dir}/${package}" && echo *)
    versions="${versions} ${additional_matches}"
    COMPREPLY=($(compgen -W "$versions" -- "$word"))
}

##
#
# Setup
#
##

# zsh compat
if [ -n "$ZSH_VERSION" ]; then
    autoload bashcompinit
    bashcompinit
fi

complete -o bashdefault -o default -F _elm elm
complete -o bashdefault -o default -F _elm_json elm-json
complete -o bashdefault -o default -F _elm_test elm-test

# Cygwin compat
if [ Cygwin = "$(uname -o 2>/dev/null)" ]; then
    complete -o bashdefault -o default -F _elm elm.exe
    complete -o bashdefault -o default -F _elm_json elm-json.exe
fi
