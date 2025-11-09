#!/bin/bash
# Ubuntu Gesture Setup Script
# Author: Aadil Ahmad

set -e

echo "🔍 Checking for libinput driver..."
xinput list | grep -i touchpad || { echo "❌ Touchpad not detected!"; exit 1; }

echo "🧩 Installing dependencies..."
sudo apt update -y
sudo apt install -y xdotool wmctrl libinput-tools git make gnome-shell-extension-prefs python3-libevdev python3-pyudev

echo "📥 Installing libinput-gestures..."
cd ~
if [ ! -d ~/libinput-gestures ]; then
    git clone https://github.com/bulletmark/libinput-gestures.git
fi
cd libinput-gestures
sudo make install

echo "👥 Adding user to input group..."
sudo gpasswd -a $USER input

echo "⚙️ Enabling autostart..."
libinput-gestures-setup autostart

echo "📝 Creating gesture config..."
mkdir -p ~/.config
cat <<EOF > ~/.config/libinput-gestures.conf
gesture swipe up    3 xdotool key super
gesture swipe down  3 xdotool key super
gesture swipe left  3 xdotool key ctrl+alt+Right
gesture swipe right 3 xdotool key ctrl+alt+Left
gesture swipe up    4 xdotool key ctrl+alt+Down
gesture swipe down  4 xdotool key ctrl+alt+Up
gesture pinch in    2 xdotool key ctrl+minus
gesture pinch out   2 xdotool key ctrl+plus
EOF

echo "🔁 Starting gesture daemon..."
libinput-gestures-setup restart

echo "✅ Setup complete!"
echo "➡️  Log out and back in, or reboot once to apply input group permissions."
echo "➡️  Test gestures with 3 or 4 fingers after login."
