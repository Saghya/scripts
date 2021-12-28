#!/bin/sh

[ -f ~/.install-errors.log ] && rm ~/.install-errors.log
# Make pacman colorful, concurrent downloads and Pacman eye-candy.
sudo grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sudo sed -i "s/^#ParallelDownloads = 8$/ParallelDownloads = 5/;s/^#Color$/Color/" /etc/pacman.conf

## PACKAGES

PCKGS="base-devel xorg-server xorg-xwininfo xorg-xinit xorg-xprop xclip xorg-xdpyinfo xorg-xbacklight xbindkeys
    man-db polkit acpid pipewire pipewire-pulse pamixer pavucontrol udiskie alacritty noto-fonts noto-fonts-emoji
    firefox libnotify dunst feh dash zsh zsh-autosuggestions zsh-syntax-highlighting scrot slock vim neovim picom
    lxappearance gtk-engine-murrine gnome-themes-extra arc-gtk-theme arc-icon-theme ueberzug ranger pcmanfm zathura
    zathura-pdf-mupdf exa inetutils ripgrep fd clang pyright tlp"
for PCKG in $PCKGS; do
    sudo pacman --needed --noconfirm -S "$PCKG" || echo "Error installing $PCKG" >> ~/.install-errors.log
done

# Use all cores for compilation.
sudo sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

## AUR PACKAGES

# yay
git clone https://aur.archlinux.org/yay.git ~/yay && cd ~/yay && makepkg --noconfirm -si ||
    echo "Error installing yay" >> ~/.install-errors.log

AUR_PCKGS="pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono nerd-fonts-ubuntu-mono htop-vim ly
    batsignal dashbinsh networkmanager-dmenu-git tlpui"
for PCKG in $AUR_PCKGS; do
    yay --needed --noconfirm -S "$PCKG" || echo "Error installing $PCKG" >> ~/.install-errors.log
done

## GIT PACKAGES

# dotfiles
git clone --bare https://github.com/Saghya/dotfiles ~/.dotfiles && /usr/bin/git --git-dir="$HOME"/.dotfiles/ \
    --work-tree="$HOME" checkout || echo "Error installing dotfiles" >> ~/.install-errors.log

# dwm
git clone https://github.com/Saghya/dwm ~/.config/dwm && cd ~/.config/dwm && make && sudo make install ||
    echo "Error installing dwm" >> ~/.install-errors.log

# dwmblocks
git clone https://github.com/ashish-yadav11/dwmblocks ~/.config/dwmblocks && cd ~/.config/dwmblocks && make &&
    sudo make install && cp ~/.scripts/blocks/* ~/.config/dwmblocks/blocks && sed -i "20,22d" config.h && 
    sed -i "$(( $(wc -l <~/.config/dwmblocks/config.h)-8+1 )),$ d" ~/.config/dwmblocks/config.h &&
    echo "static const char delimiter[] = { ' ', '|', ' ', DELIMITERENDCHAR };
#include \"block.h\"
static Block blocks[] = {
/*      pathu                           pathc                           interval        signal */
        { PATH(\"volume\"),               PATH(\"volume-button\"),          0,              1},
        { PATH(\"memory\"),               PATH(\"memory-button\"),          5,              2},
        { PATH(\"cpu\"),                  PATH(\"cpu-button\"),             5,              3},
        { PATH(\"battery\"),              NULL,                          30,              4},
        { PATH(\"network\"),              PATH(\"network-button\"),        15,              5},
        { PATH(\"date\"),                 NULL,                           5,              6},
        { PATH(\"powermenu_icon\"),       PATH(\"powermenu\"),              0,              7},
        { NULL } /* just to mark the end of the array */
};" >> config.h && sudo make install ||
    echo "Error installing dwmblocks" >> ~/.install-errors.log

# dmenu
git clone https://github.com/Saghya/dmenu ~/.config/dmenu && cd ~/.config/dmenu && make && sudo make install ||
    echo "Error installing dmenu" >> ~/.install-errors.log

# touchpad
sudo touch /etc/X11/xorg.conf.d/30-touchpad.conf
echo "Section \"InputClass\"
    Identifier \"devname\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"NaturalScrolling\" \"true\"
EndSection" | sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf

# acpi events
sudo systemctl enable acpid.service || echo "Error enabling acpid.service" >> ~/.install-errors.log
sudo touch /etc/acpi/events/jack &&
echo "event=jack*
action=pkill -RTMIN+1 dwmblocks" | sudo tee /etc/acpi/events/jack ||
echo "Error creating jack event" >> ~/.install-errors.log
sudo touch /etc/acpi/events/ac_adapter &&
echo "event=ac_adapter
action=pkill -RTMIN+4 dwmblocks" | sudo tee /etc/acpi/events/ac_adapter ||
echo "Error creating ac_adapter event" >> ~/.install-errors.log

# allow changing brightness for users in video group
sudo touch /etc/udev/rules.d/backlight.rules &&
echo "ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="acpi_video0", GROUP="video", MODE="0664"" |
sudo tee /etc/udev/rules.d/backlight.rules ||
echo "Error allowing brightness changing" >> ~/.install-erros.log

# dwm login session
sudo mkdir -p /usr/share/xsessions &&
sudo touch /usr/share/xsessions/dwm.desktop &&
echo "[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=startdwm
Icon=dwm
Type=XSession" | sudo tee /usr/share/xsessions/dwm.desktop ||
echo "Error creating dwm login session" >> ~/.install-errors.log

# display manager
sudo systemctl enable ly.service || echo "Error enabling display manager" >> ~/.install-errors.log

# default shell
chsh -s /usr/bin/zsh || echo "Error changing default shell" >> ~/.install-errors.log
# relinking /bin/sh
sudo ln -sfT dash /usr/bin/sh || echo "Error relinking /bin/sh" >> ~/.install-errors.log

# errors
[ -f ~/.install-errors.log ] && echo "
######################
ERRORS:" && cat ~/.install-errors.log && echo "######################"

