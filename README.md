# nix-bash-completions
Bash completion for the [Nix](https://nixos.org/nix/) and [NixOS](https://nixos.org/) command line tools.

The aim is full completion support for every argument, option and option argument, as long as everything that's needed is available locally. For instance when accessing a nixpkgs repo through an url, and it has been previously downloaded, completion should be offered using the local copy. Any behavior which doesn't agree with the actual execution of the command is considered a bug. Issues are very welcome as I primarily use zsh and therefor won't catch that many bugs through daily usage.

A thank you goes out to [Spencer Whitt](https://github.com/spwhitt) who started [nix-zsh-completions](https://github.com/spwhitt/nix-zsh-completions), as a lot of the boilerplate (options etc.) is taken from there.

## Usage

For quick testing just source the `_nix` file: `. _nix`, and start tabbing.

Some arguments support several types of input, but due to bash's limited completion system only exposes one type at a time. For instance `nix eval <tab>` will give you the default completion which is attribute paths, but `nix eval ./<tab>` will give you file completion (as store paths are valid input). If you aren't getting file completion on an option or argument which support it when starting off with `./`, `~/` or `/` please report it in an issue and it should be fixed promptly. Another example is `nix run --file channel:<tab>` which will complete channel names instead of files.

### Completing attribute paths to packages

The preferred way to reference a package in Nix is by attribute path, not by name. Attribute paths look like this `nixos.mplayer` or `nixos.gnome.gedit`, where `nixos` is a collection of all packages. If `<tab>` results in eg. something like `nixos` you'll need to manually add a `.` to access the packages available in `nixos`. 

When using `nix-env` it's best to always add the `--attr` or `-A` flag as `nix-env` defaults to looking up packages by name which aren't completed fully (this is a legacy problem, the new `nix` command only works on attribute paths by default).

Completion of attribute paths is context aware, so eg. `nix-env -i -f some/path/ -A <tab>` complete paths in `./some/path/default.nix`. It will also pick up `default.nix` or `shell.nix` in the current directory for `nix-build -A` and `nix-shell -A`. Things like `nix-shell -I nixpkgs=. -p <tab>` is also supported.

## Installation and dependencies

### NixOS 18.03 or newer

Setting `programs.bash.enableCompletion = true;` in `/etc/nixos/configuration.nix` should install and enable `nix-bash-completion` correctly.

### Other distros

You need [bash-completion](https://github.com/scop/bash-completion) setup correctly. Installing the `bash-completion` package with the native package manager should probably do the trick.

Then you can install `nix-bash-completions` from the cloned git repo with `nix-env -i -f default.nix`, or from nixpkgs eg. `nix-env -f '<nixpkgs>  -iA nix-bash-completions'`.

Make sure that `$XDG_DATA_DIRS` includes `~/.nix-profile/share`, which will tell `bash-completion` where to find the script when completion is done.  Be careful though: make sure that `$XDG_DATA_DIRS` also includes your distribution's defaults (like `/usr/local/share/:/usr/share/`), or you may not be able to launch some applications from the console. Adding this to your `.bashrc` should work in general:
```bash
export XDG_DATA_DIRS="$HOME/.nix-profile:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
```

### macOS

In addition to setting up [bash-completion](https://github.com/scop/bash-completion) and installing `nix-bash-completions` through nix-env, you'll need a newer version of Bash (version 4 or greater) as [Apple refuses to ship GPL v3 licensed software](http://meta.ath0.com/2012/02/05/apples-great-gpl-purge/).

You might also need to copy or link the installed files in `~/.nix-profile/share/bash-completion/completions/` to `~/.local/share/bash-completion/completions/` so `bash-completion` will know where to look for the completion script. Though I don't know if it's necessary or that it will work, as I don't have a mac. If someone is using this successfully on macOS and would like to share the necessary steps then I'll happily add it to the readme.

## Implementation

The script runs on top of `_parse` which is a bare bones implementation of zsh's [`_arguments`](http://zsh.sourceforge.net/Doc/Release/Completion-System.html#index-_005farguments) with some minor modifications to the syntax, and a bunch of stuff not implemented. A brief description of the `_parse` syntax follows, for anyone interested in reading the code, or using `_parse` for other completion scripts.

### `_parse` syntax
`_parse` takes as arguments specifications of options and normal arguments.

The spec looks like this at the moment (`[]` denotes optional syntax):

Argument spec:
- `:action`

Argument specs tell `_parse` how to handle normal arguments (arguments not required by options). The first argument will be handled by the first `:action` passed to `_parse`, the second by the second argument spec passed, and so on. Actions starting with a `*` will handle all further arguments. `_parse` puts all the encountered normal arguments in the array `$line` for easy lookup when handling further completion.

There's two types of actions:

- `[*]->string`
- `[*]_function`

When completing an argument with a `->string` action `_parse` will set `$state` to `string`, return `1` and hand over control to the calling function which then need to handle the actual completion.

The `[*]_function_` spec causes `_function` to be called, making it handle completion. At the moment this isn't that useful as passing options to `_function` isn't supported. `->string` actions together with a case statement is much more flexible.

An example using the different actions:
```shell
local state
local -a line
local -A opt_args opts
_parse ':_known_hosts' ':*->FILE' && return
case "$state" in
    FILE)
        COMPREPLY=($(compgen -f $cur))
esac
```
Here the function `_known_hosts` will handle completion for the first argument and then all further arguments will complete files through the `$state` case.

The options spec have a few more pieces on top of actions:
- `[(pattern|pattern ...)][*]--option[:action[:action2] ... ]`

The simplest case just being:
- `--option`

Which tells `_parse` to add `--option` when completing options.

If the option is present on the command line further option completion will exclude options matching any of the `pattern`s. By default `--option` will exclude itself. If we want an option to be repeatable we add the `*` prefix to the option.

Adding actions to an option spec tells `_parse` that the option takes arguments. These actions are specified in the exact same way as the argument spec. Option arguments can later be looked up in the `$opt_args` associative array using the option as a key. The presence of __any__ option can be checked with `${opts[option]}`.

A reduced version of `nix-shell` spec:
```shell
local state
local -a line
local -A opt_args opts
_parse ':*->FILE' '(--attr|-A)'{--attr,-A}':->ATTR_PATH' \
       '(--packages|-p|shell)'{--packages,-p}'' '':*->FILE-OR-PACKAGE') \
       && return
case "$state"
    FILE-OR-PACKAGE)
      if [[ "${opts[--packages]}" || "${opts[-p]}" ]];
        #Complete packages
      else
        COMPREPLY=($(compgen -f $cur))
      fi
esac
```

At the moment `_parse` only understands long options, eg. `--option`, and stackable short options, eg. `-f`. Syntax like `-some-option` is not supported.

## Issues

- Only the first short option is completed, but eg. `nix-env -iA` is recognized, and `-i` won't be offered on any new option completion. Completing stacked options is probably not easily doable in bash.
