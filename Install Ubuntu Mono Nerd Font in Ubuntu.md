# 🧠 Install Ubuntu Mono Nerd Font (System-wide on Ubuntu)

This guide automates installing the **Ubuntu Mono Nerd Font** — a developer-friendly version of Ubuntu Mono patched with **Powerline**, **Devicons**, and **Nerd symbols**.  
Perfect for terminals, editors (VS Code, Neovim, JetBrains), and CLI tools that use iconography.

---

## 🪄 What This Script Does

1. **Creates a system font directory** for Nerd Fonts under `/usr/local/share/fonts/NerdFonts`.
2. **Downloads** the latest `UbuntuMono.zip` release from the official Nerd Fonts repository.
3. **Unzips** the font files (Regular, Bold, Italic, Bold Italic).
4. **Refreshes the font cache** system-wide.
5. **Verifies installation** via `fc-list`.

---

## ⚙️ How to Use

Clone this repo and run the script:

```bash
git clone https://github.com/<your-username>/ubuntu-nerd-fonts-setup.git
cd ubuntu-nerd-fonts-setup
chmod +x install-ubuntu-nerd-fonts.sh
./install-ubuntu-nerd-fonts.sh
````

That’s it. The fonts are now installed system-wide for all users.

---

## 🔍 Verification

To confirm the installation, run:

```bash
fc-list | grep -i "UbuntuMonoNerdFont"
```

Expected output:

```
/usr/local/share/fonts/NerdFonts/UbuntuMono/UbuntuMonoNerdFont-Regular.ttf: UbuntuMono Nerd Font:style=Regular
```

---

## 💻 How to Apply

### 🧱 GNOME Terminal

* Open **Terminal → Preferences → Profiles → Text → Custom Font**
* Choose **UbuntuMono Nerd Font**

### 🧰 VS Code

Edit your settings:

```json
"editor.fontFamily": "UbuntuMono Nerd Font"
```

### 🧙‍♂️ Neovim or JetBrains IDEs

Select `UbuntuMono Nerd Font` in editor font preferences.

---

## ⚡ Uninstall

To remove the fonts completely:

```bash
sudo rm -rf /usr/local/share/fonts/NerdFonts/UbuntuMono
sudo fc-cache -fv
```

---

## 🧑‍💻 Author

**Aadil Ahmad**
System-wide installer for Ubuntu Mono Nerd Fonts on Ubuntu.

````
#!/bin/bash
# Ubuntu Mono Nerd Font System-wide Installer
# Author: Aadil Ahmad

set -e

FONT_DIR="/usr/local/share/fonts/NerdFonts/UbuntuMono"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip"

echo "🧠 Installing Ubuntu Mono Nerd Font system-wide..."

# Step 1: Create directory
sudo mkdir -p "$FONT_DIR"
cd /tmp

# Step 2: Download latest font package
echo "📥 Downloading latest UbuntuMono Nerd Font..."
sudo wget -q "$FONT_URL" -O UbuntuMono.zip

# Step 3: Extract font files
echo "📦 Extracting font files to $FONT_DIR..."
sudo unzip -oq UbuntuMono.zip -d "$FONT_DIR"
sudo rm -f UbuntuMono.zip

# Step 4: Refresh font cache
echo "🔄 Updating font cache..."
sudo fc-cache -fv >/dev/null

# Step 5: Verify installation
if fc-list | grep -qi "UbuntuMonoNerdFont"; then
    echo "✅ Ubuntu Mono Nerd Font installed successfully!"
    echo "➡️  You can now select 'UbuntuMono Nerd Font' in your terminal or editor."
else
    echo "❌ Installation failed — font not detected in cache."
fi
````

---
