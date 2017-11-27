# bash: v0.6, zsh: 0.3.6

The quest for an awesome completion system continues.

The main bulk of changes apply to both ZSH and Bash, with explicit notes otherwise.

## -I/--include <PATH> support

Attribute path completion now takes `-I` and `--include` into account. This makes completion work correctly when doing things like this:
```bash
nix-shell -I nixpkgs=. --packages <tab>
```

When the completion system executes any nix code it will first resolve all URLS in the `NIX_PATH`, and in `-I` input, to a local store path if present. This protects against triggering an intrusive download while completing. `channel:` syntax is correctly translated to its `https://` form and resolved to a cache too.

ZSH will tell you when it can't find a local cache of any URL.

## --arg and --argstr support

Argument names are now offered as completions using `builtins.functionArgs`. Names already supplied on the command line is excluded from completions. 

Attribute path completion will also take --arg and --argstr into account, which means things like this work:
```bash
nix-instantiate --eval default.nix --argstr bar foo -A <tab>
```
If the content of `default.nix` is `{bar}: {foo = bar;}` then completing will result in `foo`.

## --expr and -E support

Attribute path completion now works for `--expr` input, including argument name completion.

Note, URLs in the expression body is not yet resolved to a local cache so might trigger a download. This should ideally be fixed.

In ZSH `--expr` now behaves properly, allowing completion of options after it has been entered (bash already did the correct thing here).

## Other small fixes and improvements

- Most arguments which expects a `.nix` file will now only offer up those and directories, reducing clutter
- `--file` will now complete more than once, the last one being used to generate attribute matches. In ZSH this allows aliasing `nix-env` to `nix-env -f '<nixpkgs>'` while still getting further `--file` completion which can be used to override the default.
- nix-env now offer `--file` completion together with main operation completion by default. This is a compromise between discover-ability of main operations and the want to specify common options quickly.
- `--add-root` will now off up `/nix/var/nix/gcroots/` by default, if `--indirect` is specified it will give normal directory completion.
- Add missing `--help` and `--version` completion to many commands
- nix-env: `--filter-system` will complete possible systems.
- nix-instantiate: `--find-file` will no longer offer misleading file completion

And a bunch of other small changes and fixes.

# v0.4

Minor fixes:
- Fix `nix-build -A nixUn` completion.
- Fix `nix-build some/path -A`, the script didn't take realpath of `some/path`

# v0.3

Some bug fixes and improvements:
- All commands should now complete attribute paths when supplying `'<nixpkgs>` as file input
- nix-env: `-A` only worked for `-i`/`--install`, now works for all main operations
- nix-env will now only complete main operations until one has been supplied
- nix-env --switch-generation will now complete generations
- nix-channel: completes channel names properly now

And a few other minor improvements.
