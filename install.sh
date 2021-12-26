#/bin/sh

pacman -S --needed base-devel git xorg dunst feh zsh zsh-autosuggestions zsh-syntax-highlighting scrot vim neovim xbindkeys picom alacritty lxappearance arc-gtk-theme arc-icon-theme xterm ranger pcmanfm polkit pavucontrol exa 

# yay
git clone https://aur.archlinux.org/yay.git ~/ && cd ~/yay && makepkg -si
# dotfiles
git clone https://github.com/Saghya/dotfiles ~/
# dwm
git clone https://github.com/Saghya/dwm ~/.config && cd ~/.config/dwm && make && make install
# dmenu
git clone https://github.com/Saghya/dmenu ~/.config && cd ~/.config/dmenu && make && make install
# st
git clone https://github.com/Saghya/st ~/.config && cd ~/.config/st && make && make install

yay -S pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono

