#/bin/sh

read name

pacman -S --needed base-devel xorg polkit firefox dunst feh zsh zsh-autosuggestions zsh-syntax-highlighting scrot vim neovim xbindkeys picom alacritty lxappearance arc-gtk-theme arc-icon-theme xterm ranger pcmanfm polkit pavucontrol exa

# yay
git clone https://aur.archlinux.org/yay.git /home/$name && cd /home/$name/yay && makepkg -si
# dotfiles
git clone https://github.com/Saghya/dotfiles /home/$name/
# dwm
git clone https://github.com/Saghya/dwm /home/$name/.config/dwm && cd /home/$name/.config/dwm && make && make install
# dmenu
git clone https://github.com/Saghya/dmenu /home/$name/.config/dmenu && cd /home/$name/.config/dmenu && make && make install
# st
git clone https://github.com/Saghya/st /home/$name/.config/st && cd /home/$name/.config/st && make && make install

# yay -S pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono ly
# sytemctl enable ly.service

