# /bin/bash
rootuser () {
  if [[ "$EUID" = 0 ]]; then
    continue
  else
    echo "Please Run As Root"
    sleep 2
    exit
  fi
}

install_mate () {
    sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes mate-desktop-environment mate-desktop-environment-extras desktop-base dbus-x11 xscreensaver
    echo "exec /etc/X11/Xsession /usr/bin/mate-session" > /etc/chrome-remote-desktop-session
    prompt_browser
}

install_xfce () {
    sudo DEBIAN_FRONTEND=noninteractive \
    apt install --assume-yes xfce4 xfce4-goodies desktop-base dbus-x11 xscreensaver
    echo "exec /etc/X11/Xsession /usr/bin/xfce4-session" > /etc/chrome-remote-desktop-session
    prompt_browser
}

install_rdp () {
apt install -y xvfb xserver-xorg-video-dummy xbase-clients python3-psutil python3-packaging python3-xdg libutempter0 pkexec
wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
dpkg -i chrome-remote-desktop_current_amd64.deb
rm -f chrome-remote-desktop_current_amd64.deb
}

prompt_browser () {
dialog --title "Cloud Shell Desktop Installer" --yesno "Install Mozilla Firefox?" 0 0 && install_browser
}

install_browser () {
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
apt update && sudo apt install -y firefox
}

finish () {
echo "You are almost finished! Go to https://remotedesktop.google.com/headless and copy the Authorization command for Debian."
exit 0
}

rootuser

echo "Installing required dependencies..."
apt update && apt install dialog wget -y

DESK=$(dialog --title "Cloud Shell Desktop Installer" --menu "Please choose a desktop" 0 0 0 1 "MATE Desktop" 2 "XFCE Desktop" 3>&1 1>&2 2>&3 3>-)

if [[ "$DESK" = 1 ]]; then
    echo "Installing MATE..."
    install_rdp
    install_mate
    finish
elseif [[ "$DESK" = 2 ]];
    echo "Installing XFCE..."
    install_rdp    
    install_xfce
    finish
else
    echo "Cancelled."
    exit 1
  fi
