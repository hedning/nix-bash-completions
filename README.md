# nix-bash-completions
Bash completion for the nix command line tools.

A lot of the boilerplate (options etc.) comes from [nix-zsh-completions](https://github.com/spwhitt/nix-zsh-completions).

## Usage

Just source the `_nix` file: `. _nix`, and start tabbing.

You also need [bash-completion](https://github.com/scop/bash-completion) for it work (which is the case if most commands already provides completions).

## Implementation

The script runs on top of `_parser` which is a bare bones implementation of zsh's [`_arguments`](http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Completion-Functions) with some modifications to the exclusion pattern syntax, and a bunch of stuff not implemented.

## Issues

- Only the first short option is completed, but eg. `nix-env -iA` is recognized. Completing stacked options is probably not easily doable in bash.
