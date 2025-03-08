#!/bin/bash

echo "Starting Ubuntu Post-Installation Setup..."

# Function to update and upgrade system
update_system() {
    echo "Updating and upgrading the system..."
    sudo apt update -y && sudo apt upgrade -y
}

# Function to add PPAs
add_ppas() {
    echo "Adding PPAs..."
    sudo add-apt-repository -y ppa:gns3/ppa
    sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    sudo add-apt-repository -y ppa:papirus/papirus
    sudo apt update -y
}

# Function to install APT packages
install_apt_packages() {
    echo "Installing required packages..."
    sudo apt install -y vim curl git qemu-kvm libvirt-daemon-system libvirt-clients \
        bridge-utils virt-manager flatpak timeshift neovim qdirstat qt5ct \
        qt5-style-kvantum qt5-style-kvantum-themes gns3-gui gns3-server libminizip1 \
        libxcb-xinerama0 tldr fastfetch lsd make gawk trash-cli fzf bash-completion \
        whois bat tree ripgrep gnome-tweaks plocate fail2ban papirus-icon-theme \
        epapirus-icon-theme
}

# Function to setup QT5 theme
setup_qt5_theme() {
    echo "Setting up theme (Fusion + GTK3 + darker) for KDE..."
    qt5ct
    sudo qt5ct
}

# Function to add i386 architecture and install GNS3 IOU
install_gns3_iou() {
    echo "Adding i386 architecture and updating packages..."
    sudo dpkg --add-architecture i386
    sudo apt update -y
    sudo apt install -y gns3-iou
}

# Function to install .deb packages
install_deb_packages() {
    echo "Downloading and installing Google Chrome & TeamViewer..."
    wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    wget -O /tmp/teamviewer.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
    sudo dpkg -i /tmp/google-chrome.deb /tmp/teamviewer.deb || sudo apt install -f -y
}

# Function to setup Flatpak
setup_flatpak() {
    echo "Setting up Flatpak..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo "Installing Flatpak apps..."
    flatpak install -y flathub com.rustdesk.RustDesk com.usebottles.bottles com.spotify.Client \
        io.github.shiftey.Desktop io.missioncenter.MissionCenter com.obsproject.Studio \
        com.obsproject.Studio.Plugin.DroidCam
    flatpak install --user -y https://sober.vinegarhq.org/sober.flatpakref
}

# Function to configure GNOME
configure_gnome() {
    echo "Configuring GNOME theme..."
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'google-chrome.desktop']/")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'com.spotify.Client.desktop']/")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/]$/, 'gns3.desktop']/")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'firefox_firefox.desktop'//" | sed "s/'firefox_firefox.desktop', //")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'libreoffice-writer.desktop'//" | sed "s/'libreoffice-writer.desktop', //")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'snap-store_snap-store.desktop'//" | sed "s/'snap-store_snap-store.desktop', //")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'thunderbird_thunderbird.desktop'//" | sed "s/'thunderbird_thunderbird.desktop', //")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'yelp.desktop'//" | sed "s/'yelp.desktop', //")"
    gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed "s/, 'org.gnome.Rhythmbox3.desktop'//" | sed "s/'org.gnome.Rhythmbox3.desktop', //")"
}

# Function to remove unwanted apps
remove_unwanted_apps() {
    echo "Removing unwanted apps..."
    sudo snap remove thunderbird firefox
    sudo apt autoremove -y
}

# Function to clone repositories
clone_repositories() {
    echo "Cloning configuration repository..."
    git clone https://github.com/ramin-samadi/Ubuntu /tmp/Ubuntu
    git clone https://github.com/orangci/walls-catppuccin-mocha.git ~/Wallpapers
    sudo mv /tmp/Ubuntu/usr/local/bin/change_wallpaper.sh /usr/local/bin/
}

# Function to copy configuration files
copy_config_files() {
    echo "Deploying user configurations..."
    sudo mv -f /tmp/Ubuntu/home/.config/* $HOME/.config/
    sudo mv -f /tmp/Ubuntu/home/.vimrc $HOME/
}

# Function to enable firewall and Fail2Ban
enable_firewall_fail2ban() {
    echo "Enabling firewall and Fail2Ban..."
    sudo ufw enable
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo systemctl enable --now fail2ban
}

# Function to add custom configurations to .bashrc
add_custom_bashrc() {
    echo "Adding custom configurations to .bashrc..."
    git clone --depth=1 https://github.com/ChrisTitusTech/mybash.git ~/mybash
    chmod +x ~/mybash/setup.sh
    ~/mybash/setup.sh
    git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
    make -C ble.sh install PREFIX=~/.local
    echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc
    cat << EOF >> ~/.bashrc
alias qdirstat='nohup sudo -E qdirstat'
export QT_QPA_PLATFORMTHEME=qt5ct
alias edit='nvim'
alias sedit='sudo nvim'
alias clear='clear; fastfetch'
alias cls='clear'
bind -x '"\C-l": clear'
alias update='sudo apt update -y; sudo apt upgrade -y; flatpak update -y; sudo snap refresh'
alias install='sudo apt install -y'
alias search='apt search'
alias uninstall='sudo apt remove -y'
alias clean='sudo apt autoremove -y && sudo apt autoclean -y'
alias packages='apt list --installed'
alias ping='ping -c 4'
alias ip='ip -c'
alias vi='\vi'
alias ?='tldr'
alias explain='tldr'
alias ~='cd $HOME'
alias -- -="cd -"
# Alias's for multiple directory listing commands
alias la='lsd -Alh'                # show hidden files
alias ls='lsd -aFh --color=always' # add colors and file type extension
alias lx='lsd -lXBh'               # sort by extension
alias lk='lsd -lSrh'               # sort by size
alias lc='lsd -ltcrh'              # sort by change time
alias lu='lsd -lturh'              # sort by access time
alias lr='lsd -lRh'                # recursive ls
alias lt='lsd -ltrh'               # sort by date
alias lm='lsd -alh |more'          # pipe through 'more'
alias lw='lsd -xAh'                # wide listing format
alias ll='lsd -Fl'                 # long listing format
alias labc='lsd -lap'              # alphabetical sort
alias lf="lsd -l | egrep -v '^d'"  # files only
alias ldir="lsd -l | egrep '^d'"   # directories only
alias lla='lsd -Al'                # List and Hidden Files
alias las='lsd -A'                 # Hidden Files
alias lls='lsd -l'                 # List
alias serial-number='sudo dmidecode -s system-serial-number'
alias bios-version='sudo dmidecode -s bios-version'
alias uefi='sudo systemctl reboot --firmware-setup'
EOF
}

# Function to set the theme
set_theme() {
    echo "Setting catppuccin mocha theme..."
    # gnome-terminal
    curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v1.0.0/install.py | python3 -
    gsettings set org.gnome.Terminal.ProfilesList default '95894cfd-82f7-430d-af6e-84d168bc34f5'
    gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGS Nerd Font 12'
    # batcat
    mkdir -p "$(batcat --config-dir)/themes"
    wget -P "$(batcat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Latte.tmTheme
    wget -P "$(batcat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Frappe.tmTheme
    wget -P "$(batcat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Macchiato.tmTheme
    wget -P "$(batcat --config-dir)/themes" https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme
    batcat cache --build
    # Papirus icons
    git clone https://github.com/catppuccin/papirus-folders.git
    cd papirus-folders
    sudo cp -r src/* /usr/share/icons/Papirus
    curl -LO https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders && chmod +x ./papirus-folders
    ./papirus-folders -C cat-mocha-lavender --theme Papirus-Dark
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    # GTK 3/4 theming
    cd $HOME
    curl -LsSO "https://raw.githubusercontent.com/catppuccin/gtk/v1.0.3/install.py"
    python3 install.py mocha lavender
    gsettings set org.gnome.desktop.interface gtk-theme 'catppuccin-mocha-lavender-standard+default'
}

# Reload .bashrc
source ~/.bashrc

# Function to clean up
clean_up() {
    echo "Cleaning up..."
    rm -rf /tmp/Ubuntu
    rm /tmp/google-chrome.deb /tmp/teamviewer.deb
}

# Function to add user to required groups
add_user_to_groups() {
    echo "Adding $USER to required groups..."
    sudo usermod -aG ubridge,libvirt,kvm,wireshark $(whoami)
}

# Function to reboot system
reboot_system() {
    echo "Post-installation setup complete!"
    sleep 5
    reboot
}

# Main execution flow
update_system
add_ppas
install_apt_packages
setup_qt5_theme
install_gns3_iou
install_deb_packages
setup_flatpak
configure_gnome
remove_unwanted_apps
clone_repositories
copy_config_files
enable_firewall_fail2ban
add_custom_bashrc
set_theme
clean_up
add_user_to_groups
reboot_system
