# configs
Config files for various applications

Clone using the submodule command:
```sh
git clone --recurse-submodules git@github.com:aloknigam247/dotfiles.git
```

OR

```sh
git clone --recurse-submodules https://github.com/aloknigam247/dotfiles.git
```

OR

```sh
gh repo clone https://github.com/aloknigam247/dotfiles.git -- --recurse-submodules
```

## Scoop executables

Use `autosetup.ps1` for Scoop installs and updates. It replaces path-only executable shims with symbolic links and
keeps other launchers unchanged.

Do not run `scoop reset` on converted shims; it can overwrite the application executable through the link.
