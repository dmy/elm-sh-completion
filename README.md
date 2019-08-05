# Bash/Zsh completion scripts for Elm binary and tools

## Supported tools
* elm
* elm-json
* elm-test

## Install
To install, two options:
 
### 1. Add the file in /etc/bash_completion.d/ if it exists on your system:

```sh
sudo curl -o /etc/bash_completion.d/elm https://raw.githubusercontent.com/dmy/elm-sh-completion/master/elm-completion.sh
```

### 2. Source the file from your ~/.bashrc

For example:
```sh
mkdip -p ~/.bash
cd ~/.bash
git clone https://github.com/dmy/elm-sh-completion.git
echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bashrc
```

## Notes
* packages are auto-completed from the local cache for efficiency, 
so this does not work for new packages
* zsh completion uses bashcompinit
* it should theorically work on cygwin, but it has not been tested yet
