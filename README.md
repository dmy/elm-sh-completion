# Bash/Zsh completion script for Elm binary and tools

## Supported tools
* [elm 0.19](https://guide.elm-lang.org/install.html)
* [elm-json](https://www.npmjs.com/package/elm-json)
* [elm-test](https://www.npmjs.com/package/elm-test)


## Example
```sh
elm ins[TAB]
elm install

elm install elm-ex[TAB]
elm install elm-explorations/

elm install elm-explorations/w[TAB]
elm install elm-explorations/webgl
```

Non-prefix matches are supported with Bash:
```
elm install webgl[TAB]
elm install elm-explorations/webgl
```

## Install
To install, there are two options:
* using `bash_completion.d`
* using `.bashrc`

**Whatever the method, be sure that the script is sourced after
potential `$PATH` settings that allow to find the `elm` command
as the completion script needs to be able to run `elm --version`.**

If `elm` command is not available when the completion script is loaded,
you will get the following error when starting your shell:
```
elm-sh-completion error: cannot run 'elm --version'
Please check that elm command is available from PATH.
```

It might be easier using `.bashrc` if you install `elm` globally using `npm`
or `nvm`, because node paths are often defined by default after completion
scripts are loaded.

 
### Option 1: Add the file to `bash_completion.d`
If `/etc/bash_completion.d` exists on your system:

```sh
sudo curl -o /etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
```

On MacOS X with brew, you can do:
```
brew install bash-completion
sudo curl -o /usr/local/etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
```

### Option 2: Source the file from your `~/.bashrc`

For example:
```sh
mkdir -p ~/.bash
cd ~/.bash
git clone https://github.com/dmy/elm-sh-completion.git
echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bashrc
```

## Updating the packages list
Because packages are completed from elm local registry, any `elm` command using
it will update the list automatically, including `elm init`, `elm install`,
`elm diff`.

You will therefore usually not need to worry about updating the list.

If you want anyway a command to force the update of the packages list, you can
for example define the following bash alias in your `~/.bashrc`:
```sh
alias elm-update-packages='elm diff elm/core 1.0.0 1.0.1 > /dev/null'
```

## Notes
* To get case insensitive bash completion, add `set completion-ignore-case on`
in user `~/.inputrc` (which should start by `$include /etc/inputrc`) or
system wide `/etc/inputrc`.
* Zsh completion uses bashcompinit.
* Cygwin is theorically supported, but this has not been tested yet.
* `elm-json` also comes with basic auto-generated completion scripts for bash,
zsh and fish.  
See `elm-json completions --help`.
