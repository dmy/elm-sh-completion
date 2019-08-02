# Bash/Zsh completion scripts for Elm binary and tools

## Supported tools
* elm
* elm-json
* elm-test

## Install
To install, two options:
 
1. Source the file from your ~/.bashrc

For example:
```sh
$ mkdip -p ~/.bash
$ cd ~/.bash
$ git clone https://github.com/dmy/elm-sh-completion.git
$ echo 'source ~/.bash/elm-sh-completion/elm-completion.sh' >> ~/.bashrc
```

2. Add the file in /etc/bash_completion.d/ if it exists on your system:

```sh
$ cd /tmp
$ git clone https://github.com/dmy/elm-sh-completion.git
$ sudo cp elm-sh-completion/elm-completion.sh /etc/bash_completion.d/
```
