#!/bin/bash

RC='\e[0m'
RED='\e[31m'
YELLOW='\e[33m'
GREEN='\e[32m'

# Check if the home directory and linuxtoolbox folder exist, create them if they don't
LINUXTOOLBOXDIR="$HOME/linuxtoolbox"

if [[ ! -d "$LINUXTOOLBOXDIR" ]]; then
    echo -e "${YELLOW}Creating linuxtoolbox directory: $LINUXTOOLBOXDIR${RC}"
    mkdir -p "$LINUXTOOLBOXDIR"
    echo -e "${GREEN}linuxtoolbox directory created: $LINUXTOOLBOXDIR${RC}"
fi

if [[ ! -d "$LINUXTOOLBOXDIR/neovim" ]]; then
    echo -e "${YELLOW}Cloning neovim repository into: $LINUXTOOLBOXDIR/neovim${RC}"
    git clone https://github.com/DerryPlaysXd/nvim-cfg "$LINUXTOOLBOXDIR/neovim"
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Successfully cloned neovim repository${RC}"
    else
        echo -e "${RED}Failed to clone neovim repository${RC}"
        exit 1
    fi
fi

cd "$LINUXTOOLBOXDIR/neovim"

# Initial Setup file for new systems
gitpath=$(pwd)

# Backup existing neovim config and install new one
mkdir -p "$LINUXTOOLBOXDIR/backup/nvim"
[ -d ~/.config/nvim ] && cp -r ~/.config/nvim "$LINUXTOOLBOXDIR/backup/nvim/config"
[ -d ~/.local/share/nvim ] && cp -r ~/.local/share/nvim "$LINUXTOOLBOXDIR/backup/nvim/local_share"
[ -d ~/.cache/nvim ] && cp -r ~/.cache/nvim "$LINUXTOOLBOXDIR/backup/nvim/cache"
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.cache/nvim

# Setup Neovim config and link to linuxtoolbox
mkdir -p "$HOME/.vim/undodir"
mkdir -p "$HOME/.scripts"
ln -s "$gitpath/derry-kickstart" "$HOME/.config/nvim"

# Share system clipboard with unnamedplus
if [ -f /etc/os-release ]; then
    . /etc/os-release
    # Determine if Wayland or Xorg is being used
    if [[ $XDG_SESSION_TYPE == "wayland" ]]; then
        CLIPBOARD_PKG="wl-clipboard"
    else
        CLIPBOARD_PKG="xclip"
    fi

    case "${ID_LIKE:-$ID}" in
        debian|ubuntu)
            sudo apt install ripgrep fd-find $CLIPBOARD_PKG python3-venv luarocks golang-go shellcheck -y
            ;;
        fedora)
            sudo dnf install ripgrep fzf $CLIPBOARD_PKG neovim python3-virtualenv luarocks golang ShellCheck -y
            ;;
        arch|manjaro)
            sudo pacman -S ripgrep fzf $CLIPBOARD_PKG neovim python-virtualenv luarocks go shellcheck --noconfirm
            ;;
        opensuse)
            sudo zypper install ripgrep fzf $CLIPBOARD_PKG neovim python3-virtualenv luarocks go ShellCheck -y
            ;;
        *)
            echo -e "${YELLOW}Unsupported OS. Please install the following packages manually:${RC}"
            echo "ripgrep, fzf, $CLIPBOARD_PKG, neovim, python3-virtualenv (or equivalent), luarocks, go, shellcheck"
            ;;
    esac
else
    echo -e "${RED}Unable to determine OS. Please install required packages manually.${RC}"
fi
