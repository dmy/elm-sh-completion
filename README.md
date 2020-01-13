# Bash/Zsh completion script for Elm binary and tools

## Supported tools
* [elm 0.19](https://guide.elm-lang.org/install.html)
* [elm-json](https://www.npmjs.com/package/elm-json)
* [elm-test](https://www.npmjs.com/package/elm-test)

## Install
To install, there are two options:
* using `/etc/bash_completion.d`
* using `.bashrc`

Whatever the method, be sure that the script is sourced after
potential `$PATH` settings that allow to find the `elm` command
as the completion script needs to be able to run `elm --version`.

It might be easier using `.bashrc` if you install `elm` using `npm`.

 
### Option 1: Add the file to /etc/bash_completion.d/
If `/etc/bash_completion.d` exists on your system:

```sh
sudo curl -o /etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
```

### Option 2: Source the file from your ~/.bashrc

For example:
```sh
mkdir -p ~/.bash
cd ~/.bash
git clone https://github.com/dmy/elm-sh-completion.git
echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bashrc
```

## Notes
* Packages are also matched from partial match, so you can complete packages
by using the package name or part of it, for example:
```
elm ins[TAB]
elm install regex[TAB]
elm install elm/regex
```
If there are several matches, the common prefix of all matches will be completed.
* Packages are auto-completed from the local cache for efficiency,
so packages that have never been installed are not completed.
* Zsh completion uses bashcompinit.
* Cygwin is theorically supported, but this has not been tested yet.
* `elm-json` comes with its own auto-generated completion scripts for bash, zsh and fish.  
See `elm-json completions --help`.
