#!/bin/sh

# Make pacman colorful, concurrent downloads and Pacman eye-candy.
sudo grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sudo sed -i "s/^#ParallelDownloads = 8$/ParallelDownloads = 5/;s/^#Color$/Color/" /etc/pacman.conf

PCKGS="base-devel clang xorg xorg-xinit xclip xbindkeys polkit man-db pipewire pipewire-pulse pamixer pavucontrol udiskie alacritty firefox dunst libnotify feh zsh zsh-autosuggestions zsh-syntax-highlighting scrot slock vim neovim picom lxappearance arc-gtk-theme arc-icon-theme ranger pcmanfm zathura zathura-pdf-mupdf exa ripgrep fd"
for PCKG in $PCKGS; do
    sudo pacman --needed --noconfirm -S "$PCKG" || echo "Error installing $PCKG" >> ~/.install-errors
done

# Use all cores for compilation.
sudo sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# yay
git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay && makepkg --noconfirm -si || echo "Error installing yay" >> ~/.install-errors

# neovim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# dotfiles
git clone --bare https://github.com/Saghya/dotfiles ~/.dotfiles && /usr/bin/git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" checkout || echo "Error installing dotfiles" >> ~/.install-errors

# dwm
git clone https://github.com/Saghya/dwm ~/.config/dwm && cd ~/.config/dwm && make && sudo make install || echo "Error installing dwm" >> ~/.install-errors

# dwmblocks
git clone https://github.com/ashish-yadav11/dwmblocks ~/.config/dwmblocks && cd ~/.config/dwmblocks && make && sudo make install && cp ~/.scripts/blocks ~/.config/dwmblocks/blocks || echo "Error installing dwmblocks" >> ~/.install-errors

# dmenu
git clone https://github.com/Saghya/dmenu ~/.config/dmenu && cd ~/.config/dmenu && make && sudo make install || echo "Error installing dmenu" >> ~/.install-errors

# st
git clone https://github.com/Saghya/st ~/.config/st && cd ~/.config/st && make && sudo make install || echo "Error installing st" >> ~/.install-errors

# dwm login session
sudo mkdir -p /usr/share/xsessions
sudo touch /usr/share/xsessions/dwm.desktop
echo '[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=startdwm
Icon=dwm
Type=XSession' | sudo tee /usr/share/xsessions/dwm.desktop

AUR_PCKGS="pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono htop-vim ly batsignal"
for PCKG in $AUR_PCKGS; do
    yay --needed --noconfirm -S "$PCKG" || echo "Error installing $PCKG" >> ~/.install-errors
done

sudo systemctl enable ly.service

chsh -s /usr/bin/zsh

reboot

