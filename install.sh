#!/bin/sh

[ -f ~/.install-errors.log ] && rm ~/.install-errors.log
error() { printf "%s\n" "$1" >> ~/.install-errors.log; }

# Make pacman colorful, concurrent downloads and Pacman eye-candy.
sudo grep -q "ILoveCandy" /etc/pacman.conf || sudo sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sudo sed -i "s/^#ParallelDownloads = 8$/ParallelDownloads = 5/;s/^#Color$/Color/" /etc/pacman.conf

## PACKAGES

PCKGS="base-devel xorg-server xorg-xwininfo xorg-xinit xorg-xprop xorg-xrandr xorg-xdpyinfo xorg-xbacklight
    xclip xdotool xbindkeys xdg-utils man-db polkit acpid pipewire pipewire-pulse pavucontrol wget udiskie alacritty
    noto-fonts noto-fonts-emoji chromium libnotify dunst feh dash zsh zsh-autosuggestions zsh-syntax-highlighting
    scrot vim neovim picom lxappearance gtk-engine-murrine gnome-themes-extra arc-gtk-theme arc-icon-theme ueberzug
    ranger pcmanfm zathura zathura-pdf-mupdf exa inetutils ripgrep fd clang pyright tlp tlp-rdw bluez bluez-utils"
sudo pacman --noconfirm -Syyu
for PCKG in $PCKGS; do
    sudo pacman --needed --noconfirm -S "$PCKG" || error "Error installing $PCKG"
done

# Use all cores for compilation.
sudo sed -i "s/-j2/-j$(nproc)/;s/^#MAKEFLAGS/MAKEFLAGS/" /etc/makepkg.conf

# directory for source files
mkdir -p ~/.local/src

## AUR PACKAGES

# yay
(git clone https://aur.archlinux.org/yay-bin.git ~/.local/src/yay-bin && cd ~/.local/src/yay-bin && makepkg --noconfirm -si) ||
    error "Error installing yay"

AUR_PCKGS="pfetch breeze-snow-cursor-theme nerd-fonts-jetbrains-mono nerd-fonts-ubuntu-mono htop-vim ly
    batsignal dashbinsh networkmanager-dmenu-git tlpui libinput-gestures"
for PCKG in $AUR_PCKGS; do
    yay --needed --noconfirm -S "$PCKG" || error "Error installing $PCKG"
done

## GIT PACKAGES

# dotfiles
(git clone --bare https://github.com/Saghya/dotfiles ~/.local/dotfiles && /usr/bin/git --git-dir="$HOME"/.local/dotfiles/ \
    --work-tree="$HOME" checkout) || error "Error installing dotfiles"

# dwm
(git clone https://github.com/Saghya/dwm ~/.local/src/dwm && cd ~/.local/src/dwm && make && sudo make install) ||
    error "Error installing dwm"

# dwmblocks
(git clone https://github.com/ashish-yadav11/dwmblocks ~/.local/src/dwmblocks && cd ~/.local/src/dwmblocks &&
cp -r ~/.local/scripts/blocks ~/.local/src/dwmblocks && make && sudo make install && sed -i "20,22d" config.h && 
sed -i "$(( $(wc -l <~/.local/src/dwmblocks/config.h)-8+1 )),$ d" ~/.local/src/dwmblocks/config.h &&
echo "static const char delimiter[] = { ' ', '|', ' ', DELIMITERENDCHAR };
#include \"block.h\"
static Block blocks[] = {
/*      pathu                           pathc                           interval        signal */
        { PATH(\"volume\"),               PATH(\"volume-button\"),          1,              1},
        { PATH(\"memory\"),               PATH(\"memory-button\"),          5,              2},
        { PATH(\"cpu\"),                  PATH(\"cpu-button\"),             5,              3},
        { PATH(\"battery\"),              NULL,                          30,              4},
        { PATH(\"network\"),              PATH(\"network-button\"),        15,              5},
        { PATH(\"bluetooth\"),            PATH(\"bluetooth-button\"),      15,              6},
        { PATH(\"date\"),                 PATH(\"date-button\"),            5,              7},
        { PATH(\"powermenu_icon\"),       PATH(\"powermenu\"),              0,              8},
        { NULL } /* just to mark the end of the array */
};" >> config.h && sudo make install) ||
    error "Error installing dwmblocks"

# dmenu
(git clone https://github.com/Saghya/dmenu ~/.local/src/dmenu && cd ~/.local/src/dmenu && make && sudo make install) ||
    error "Error installing dmenu"

# slock
(git clone https://git.suckless.org/slock ~/.local/src/slock && cd ~/.local/src/slock &&
wget https://tools.suckless.org/slock/patches/blur-pixelated-screen/slock-blur_pixelated_screen-1.4.diff &&
patch -p1 < slock-blur_pixelated_screen-1.4.diff &&
sed -i "s/nogroup/$USER/g" config.def.h &&
make && sudo make install &&
sudo touch /etc/systemd/system/slock@.service &&
echo "[Unit]
Description=Lock X session using slock for user %i
Before=sleep.target
Before=suspend.target

[Service]
User=%i
Environment=DISPLAY=:0
ExecStartPre=/usr/bin/xset dpms force suspend
ExecStart=/usr/local/bin/slock

[Install]
WantedBy=sleep.target
WantedBy=suspend.target" | sudo tee /etc/systemd/system/slock@.service &&
systemctl enable slock@"$USER".service) ||
    error "Error installing slock"

# grub-theme
(git clone https://github.com/vinceliuice/grub2-themes ~/.local/src/grub2-themes &&
sudo ~/.local/src/grub2-themes/install.sh -b -t tela) ||
    error "Error installing grub-theme"

# touchpad
(sudo touch /etc/X11/xorg.conf.d/30-touchpad.conf &&
echo "Section \"InputClass\"
    Identifier \"devname\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"NaturalScrolling\" \"true\"
EndSection" | sudo tee /etc/X11/xorg.conf.d/30-touchpad.conf) ||
    error "Error configuring touchpad"

# acpi events
sudo systemctl enable acpid.service || error "Error enabling acpid.service"
(sudo touch /etc/acpi/events/jack &&
echo "event=jack*
action=pkill -RTMIN+1 dwmblocks" | sudo tee /etc/acpi/events/jack) ||
    error "Error creating jack event"
(sudo touch /etc/acpi/events/ac_adapter &&
echo "event=ac_adapter
action=pkill -RTMIN+4 dwmblocks" | sudo tee /etc/acpi/events/ac_adapter) ||
    error "Error creating ac_adapter event"

# brightness and video group
sudo usermod -a -G video "$USER"
(sudo touch /etc/udev/rules.d/backlight.rules &&
echo "ACTION==\"add\", SUBSYSTEM==\"backlight\", KERNEL==\"acpi_video0\", GROUP=\"video\", MODE=\"0664\"" |
sudo tee /etc/udev/rules.d/backlight.rules) ||
    error "Error allowing brightness changing"

# tlp
(sudo systemctl enable tlp.service &&
sudo systemctl enable NetworkManager-dispatcher.service &&
sudo systemctl mask systemd-rfkill.service &&
sudo systemctl mask systemd-rfkill.socket) ||
    error "Error enabling tlp"

# bluetooth
sudo systemctl enable bluetooth.service || error "Error enabling bluetooth"

# dwm login session
(sudo mkdir -p /usr/share/xsessions &&
sudo touch /usr/share/xsessions/dwm.desktop &&
echo "[Desktop Entry]
Encoding=UTF-8
Name=dwm
Comment=Dynamic window manager
Exec=startdwm
Icon=dwm
Type=XSession" | sudo tee /usr/share/xsessions/dwm.desktop) ||
    error "Error creating dwm login session"

# display manager
(sudo systemctl enable ly.service &&
echo "term_reset_cmd = /usr/bin/tput reset; /usr/bin/printf '%b' '\e]P0222430\e]P769a2ff\ec'" |
sudo tee /etc/ly/config.ini &&
if [ "$(sed "8q;d" /lib/systemd/system/ly.service)" != "ExecStartPre=/usr/bin/printf '%%b' '\e]P0222430\e]P769a2ff\ec'" ]; then
    sudo sed -i "8i ExecStartPre=/usr/bin/printf '%%b' '\\\e]P0222430\\\e]P769a2ff\\\ec'" /lib/systemd/system/ly.service
fi) ||
    error "Error configuring ly"

# default shell
sudo usermod -s /usr/bin/zsh "$USER" || error "Error changing default shell"
# relinking /bin/sh
sudo ln -sfT dash /usr/bin/sh || error "Error relinking /bin/sh"

# errors
if [ -f ~/.install-errors.log ]; then
    echo "
######################
ERRORS:"
    cat ~/.install-errors.log
    echo "######################"
else
    sudo reboot
fi

