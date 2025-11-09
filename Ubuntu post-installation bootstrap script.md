# 🚀 Ubuntu Post-Install Setup

This repository automates the setup of a new Ubuntu installation with all essential tools, gestures, and fonts — in one command.

---

## 🧩 What It Installs

| Script | Purpose |
|---------|----------|
| `devops-setup.sh` | Installs Docker, VS Code, Git, and other DevOps tools |
| `enable-gestures.sh` | Enables 3/4-finger trackpad gestures (via libinput-gestures) |
| `install-ubuntu-nf-font.sh` | Installs Ubuntu Mono Nerd Font system-wide for terminal/editor use |

---

## ⚙️ How to Use

After a fresh Ubuntu install:

```bash
sudo apt install git -y
git clone https://github.com/aadilahammad86/LinuxRelated.git
cd LinuxRelated
chmod +x post-install.sh
sudo bash post-install.sh
````

That’s it — this will:

* Update your system
* Install base utilities
* Run all setup scripts automatically
* Offer to reboot after completion

---

## 🧠 What It Does

* Configures full DevOps environment
* Enables smooth multi-touch gestures
* Installs patched Nerd Fonts system-wide
* Sets up autostart and cache refresh automatically

---

## 🧰 Recommended First Actions After Setup

1. Reboot once to apply gesture and input group permissions
2. Open terminal → confirm font: **UbuntuMono Nerd Font**
3. Swipe test → check gestures working
4. Launch VS Code → your DevOps environment is ready

---

## 🧑‍💻 Author

**Aadil Ahmad**
Automated Ubuntu setup for personal and DevOps workflow.

````

---

## ✅ How to use after fresh Ubuntu install
After your first login, open a terminal and run:

```bash
sudo apt install git -y
git clone https://github.com/aadilahammad86/LinuxRelated.git
cd LinuxRelated
chmod +x post-install.sh
sudo bash post-install.sh
````

Done. It’ll update, install dependencies, clone your repo, and run all three scripts automatically.

---

