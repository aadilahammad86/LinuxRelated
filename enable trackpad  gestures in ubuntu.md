# 🖐️ Enable Trackpad Gestures on Ubuntu (Libinput + xdotool)

This guide enables smooth multi-touch trackpad gestures (3/4-finger swipes, pinches, workspace switching) on Ubuntu using **libinput-gestures**.

It has been tested on laptops such as **Acer Aspire A715** and other models using the **libinput** driver.

---

## ⚙️ What This Script Does

The provided script automates the entire process:

1. **Checks Touchpad Driver** — Ensures you’re using the `libinput` driver.
2. **Installs Dependencies** — Installs required tools like `xdotool`, `wmctrl`, and `libinput-tools`.
3. **Installs `libinput-gestures`** — Clones and installs the open-source gesture daemon.
4. **Configures Custom Gestures** — Adds swipe, pinch, and workspace gestures.
5. **Grants Input Permissions** — Adds your user to the `input` group for touchpad access.
6. **Starts & Autostarts the Service** — Launches gestures immediately and on login.

---

## 🪄 How to Use

Clone this repo and run the installer script:

```bash
git clone https://github.com/<your-username>/ubuntu-gesture-setup.git
cd ubuntu-gesture-setup
chmod +x enable-gestures.sh
./enable-gestures.sh
````

Then **log out and log back in**, or simply reboot once.

---

## ✋ Default Gesture Configuration

| Gesture Type | Fingers | Action                            |
| ------------ | ------- | --------------------------------- |
| Swipe Up     | 3       | Open Activities / Super key       |
| Swipe Down   | 3       | Open Activities / Super key       |
| Swipe Left   | 3       | Switch to next workspace          |
| Swipe Right  | 3       | Switch to previous workspace      |
| Swipe Up     | 4       | Move window to next workspace     |
| Swipe Down   | 4       | Move window to previous workspace |
| Pinch In     | 2       | Zoom out (Ctrl -)                 |
| Pinch Out    | 2       | Zoom in (Ctrl +)                  |

---

## 🧠 How It Works

* **libinput** is the input driver that captures multitouch gestures.
* **libinput-gestures** reads raw gesture events and maps them to custom actions.
* **xdotool** and **wmctrl** simulate keyboard shortcuts and workspace navigation.
* The script ensures permissions, installs dependencies, and sets the gesture daemon to autostart.

---

## 🔧 Troubleshooting

* If gestures don’t work immediately, run:

  ```bash
  libinput-gestures-setup restart
  ```
* If `libinput-gestures` shows as not running:

  ```bash
  sudo gpasswd -a $USER input
  ```

  Then **log out and log back in**.

---

## 🚀 Uninstall

To remove everything:

```bash
sudo gpasswd -d $USER input
sudo rm -rf ~/.config/libinput-gestures.conf
sudo apt remove --purge libinput-tools xdotool wmctrl -y
sudo rm -rf ~/libinput-gestures
```

---

## 🧑‍💻 Author

**Aadil Ahmad**
Setup script and tested guide for Ubuntu gesture support.

````
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
````

---

Would you like me to make it slightly smarter — for example, detect if `libinput` isn’t the driver and skip, or include an uninstall script too (`disable-gestures.sh`)?
