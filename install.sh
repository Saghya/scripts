#/bin/sh

sudo pacman -S --needed base-devel xorg polkit firefox dunst feh zsh zsh-autosuggestions zsh-syntax-highlighting scrot vim neovim xbindkeys picom alacritty lxappearance arc-gtk-theme arc-icon-theme xterm ranger pcmanfm polkit pavucontrol exa

# yay
git clone https://aur.archlinux.org/yay.git ~/ && cd ~/yay && makepkg -si
# dotfiles
git clone https://github.com/Saghya/dotfiles ~/
# dwm
git clone https://github.com/Saghya/dwm ~/.config/dwm && cd ~/.config/dwm && make && sudo make install
# dwmblocks
git clone https://github.com/ashish-yadav11/dwmblocks ~/.config/dwmblocks && cd ~/.config/dwmblocks && make && sudo make install
# dmenu
git clone https://github.com/Saghya/dmenu ~/.config/dmenu && cd ~/.config/dmenu && make && sudo make install
# st
git clone https://github.com/Saghya/st ~/.config/st && cd ~/.config/st && make && sudo make install

yay -S --needed pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono slock

sudo /usr/share/xsessions/dwm.desktop < "[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=startdwm
Icon=dwm
Type=XSession"

chsh -s $(which zsh)

git clone --recurse-submodules https://github.com/nullgemm/ly.git ~/ly && cd ~/ly && make && sudo make install && systemctl enable ly.service


