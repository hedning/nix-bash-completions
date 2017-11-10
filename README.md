# nix-bash-completions
Bash completion for the nix command line tools.

A lot of the boilerplate (options etc.) comes from [nix-zsh-completions](https://github.com/spwhitt/nix-zsh-completions).

## Usage

At that point you can just source the `_nix` file: `. _nix`, and start tabbing.

You need [bash-completion](https://github.com/scop/bash-completion) for it to work (which is the case if most commands already provides completions). On NixOS this is done by setting `programs.bash.enableCompletion`.

The script also depends on `sed` being in the path.

## Attribute path completion

Completion of attribute paths is context aware, so supplying eg. `-f some/path/` will make `-A ` complete paths in `some/path/default.nix`, and will pick up `default.nix` or `shell.nix` in the current directory for `nix-build` and `nix-shell`.

## Implementation

The script runs on top of `_parser` which is a bare bones implementation of zsh's [`_arguments`](http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Completion-Functions) with some minor modifications to the syntax, and a bunch of stuff not implemented.

## Issues

- Only the first short option is completed, but eg. `nix-env -iA` is recognized, and `-i` won't be offered on any new option completion. Completing stacked options is probably not easily doable in bash.
