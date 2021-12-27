#/bin/sh

programs=(base-devel clang xorg xorg-xinit xclip xbindkeys man-db pipewire pipewire-pulse pamixer pavucontrol alacritty firefox polkit dunst libnotify feh zsh zsh-autosuggestions zsh-syntax-highlighting scrot slock vim neovim picom lxappearance arc-gtk-theme arc-icon-theme ranger pcmanfm zathura zathura-pdf-mupdf exa ripgrep fd)

for program in ${programs[@]}; do
    sudo pacman --needed --noconfirm -S $program
done

# yay
git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay && makepkg -si

# neovim-plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# dotfiles
git clone --bare https://github.com/Saghya/dotfiles ~/.dotfiles
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME checkout

# dwm
git clone https://github.com/Saghya/dwm ~/.config/dwm && cd ~/.config/dwm && make && sudo make install

# dwmblocks
git clone https://github.com/ashish-yadav11/dwmblocks ~/.config/dwmblocks && cd ~/.config/dwmblocks && make && sudo make install && cp ~/.scripts/blocks ~/.config/dwmblocks/blocks

# dmenu
git clone https://github.com/Saghya/dmenu ~/.config/dmenu && cd ~/.config/dmenu && make && sudo make install

# st
git clone https://github.com/Saghya/st ~/.config/st && cd ~/.config/st && make && sudo make install

yay -S --needed pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono htop-vim

sudo mkdir /usr/share/xsessions
sudo touch /usr/share/xsessions/dwm.desktop
echo '[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=startdwm
Icon=dwm
Type=XSession' | sudo tee /usr/share/xsessions/dwm.desktop

yay -S --needed ly && systemctl enable ly.service

chsh -s /usr/bin/zsh

