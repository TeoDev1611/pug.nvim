# pug.nvim

A wrapper for vim packager with Vim Plug Experience 

# Installation

## MacOS | Linux

> Neovim
```sh
git clone https://github.com/kristijanhusak/vim-packager ~/.config/nvim/pack/packager/opt/vim-packager
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/pug.vim --create-dirs \
       https://raw.githubusercontent.com/TeoDev1611/pug.nvim/main/pug.vim'
```
> Vim

```
git clone https://github.com/kristijanhusak/vim-packager ~/.vim/pack/packager/opt/vim-packager
curl -fLo ~/.vim/autoload/pug.vim --create-dirs \
    https://raw.githubusercontent.com/TeoDev1611/pug.nvim/main/pug.vim
```

# Windows

> Neovim
```ps1
git clone https://github.com/kristijanhusak/vim-packager ~/AppData/Local/nvim/pack/packager/opt/vim-packager
iwr -useb https://raw.githubusercontent.com/TeoDev1611/pug.nvim/main/pug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/pug.vim" -Force
```

> Vim

```
git clone https://github.com/kristijanhusak/vim-packager ~/vimfiles/pack/packager/opt/vim-packager
iwr -useb https://raw.githubusercontent.com/TeoDev1611/pug.nvim/main/pug.vim |`
    ni $HOME/vimfiles/autoload/pug.vim -Force
```

---
Made with :heart: in Ecuador
