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
