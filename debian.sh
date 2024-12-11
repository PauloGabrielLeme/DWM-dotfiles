#!/bin/bash

# Atualizando o sistema
echo "Atualizando o sistema..."
sudo apt update && sudo apt upgrade -y

# Instalando dependências do dwm
echo "Instalando dependências do dwm..."
sudo apt install build-essential libx11-dev libxft-dev libxinerama-dev git picom xfce4-terminal libinput-tools pamixer -y

# Baixando e compilando o dwm
echo "Baixando e compilando o dwm..."
cd ~
git clone https://git.suckless.org/dwm
cd dwm
make
sudo make install

# Check if the system is using libinput or synaptics
if xinput list | grep -i "libinput" > /dev/null; then
    echo "Using libinput driver, configuring touchpad tapping..."
    
    # Create or modify the libinput configuration file
    sudo bash -c 'cat > /etc/X11/xorg.conf.d/30-touchpad.conf <<EOL
Section "InputClass"
    Identifier "touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
EOL'
    
    echo "Touchpad tapping enabled for libinput."
elif xinput list | grep -i "synaptics" > /dev/null; then
    echo "Using synaptics driver, configuring touchpad tapping..."
    
    # Enable tapping via synclient for synaptics driver
    if command -v synclient > /dev/null; then
        synclient TapButton1=1
        echo "Touchpad tapping enabled for synaptics."
    else
        echo "synclient command not found. Install the synaptics driver if you want to use it."
    fi
else
    echo "Neither libinput nor synaptics driver found. Please install one of these drivers."
fi

# Reload Xorg settings (optional)
echo "Restart the display manager to apply changes..."

echo "Touchpad tapping should now be enabled. Please log out and log back in to see the changes."


# Criando o arquivo de sessão do dwm para o GDM
echo "Configurando o GDM para usar o dwm..."
sudo mkdir -p /usr/share/xsessions
sudo touch /usr/share/xsessions/dwm.desktop
echo "[Desktop Entry]
Name=dwm
Comment=Dynamic Window Manager
Exec=dwm
TryExec=dwm
Type=Application
DesktopNames=dwm" | sudo tee /usr/share/xsessions/dwm.desktop > /dev/null

# Tornando o arquivo executável
sudo chmod +x /usr/share/xsessions/dwm.desktop

# Configurando o layout do teclado para português brasileiro (ABNT2)
echo "Configurando o layout do teclado para BR..."
sudo dpkg-reconfigure keyboard-configuration

# Adicionando a configuração do teclado no arquivo .xprofile (se necessário)
echo "setxkbmap br" >> ~/.xprofile

# Reiniciando o GDM para aplicar as mudanças
echo "Reiniciando o GDM..."
sudo systemctl restart gdm3


