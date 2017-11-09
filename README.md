# nix-bash-completions
Bash completion for the nix command line tools.

A lot of the boilerplate (options etc.) comes from [nix-zsh-completions](https://github.com/spwhitt/nix-zsh-completions).

## Usage

Just source the `_nix` file: `. _nix`, and start tabbing.

You also need [bash-completion](https://github.com/scop/bash-completion) for it work (which is the case if most commands already provides completions).

## Implementation

The script runs on top of `_parser` which is a bare bones implementation of zsh's `_arguments` with some modifications to the exclusion pattern syntax, and a bunch of stuff not implemented.

## Issues

- Option exclusion isn't fully implemented, so some options will complete even when they're already entered on the command line. The plan is to implement default self exclusion and add `*` to repeatable options.
- Option stacking doesn't work, so eg. `nix-env -iA nix|` won't complete. The plan is to support option stacking.
