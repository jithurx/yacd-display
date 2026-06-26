#!/bin/bash
# Install Lightweight Desktop Environment (LXDE) and X.Org on DietPi
# for Waveshare 3.5 LCD Display
# Run with: sudo ./install_dietpi_lcd.sh

set -e

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo."
  exit 1
fi

echo "========================================================="
echo " DietPi OS - LCD35 Display Installer"
echo "========================================================="
echo "Please select an installation mode:"
echo " 1) Full Mode    : Install X.Org, LXDE Desktop, configure Autostart, and install LCD drivers."
echo " 2) Minimal Mode : Install LCD drivers only (skip desktop installation)."
echo " 3) Calibration  : Install Touch Calibration tools (xinput-calibrator, PyMouse, Mouse_Key.py)"
echo " 4) Revert All   : Completely revert all changes (uninstall desktop, reset drivers)"
echo " 5) DRM Mode     : Configure display natively as a DRM card (tinyDRM/KMS)"
echo "========================================================="
read -p "Enter your choice (1-5): " mode_choice

if [ "$mode_choice" = "1" ]; then
    echo "========================================================="
    echo " Starting Full Mode Installation..."
    echo "========================================================="
    sleep 2

    # 1. Install X.Org (ID 6) and LXDE (ID 23) via dietpi-software
    echo "[1/3] Installing X.Org and LXDE Desktop Environment..."
    /boot/dietpi/dietpi-software install 6
    /boot/dietpi/dietpi-software install 23

    # 2. Set Autostart to Desktop (Index 16 in dietpi-autostart)
    echo "[2/3] Setting Autostart to Desktop (Autologin)..."
    /boot/dietpi/dietpi-autostart 16
    
    echo "[3/3] Running LCD35-show to install drivers..."
elif [ "$mode_choice" = "2" ]; then
    echo "========================================================="
    echo " Starting Minimal Mode Installation (Drivers only)..."
    echo "========================================================="
    sleep 2
elif [ "$mode_choice" = "3" ]; then
    echo "========================================================="
    echo " Installing Touch Calibration Tools..."
    echo "========================================================="
    
    # Check architecture
    hardware_arch=32
    if [ $(getconf WORD_BIT) = '32' ] && [ $(getconf LONG_BIT) = '64' ] ; then
        hardware_arch=64
    fi

    # Install xinput-calibrator
    echo "[1/4] Installing xinput-calibrator..."
    if [ $hardware_arch -eq 32 ]; then
        dpkg -i -B ./xinput-calibrator_0.7.5-1_armhf.deb || apt-get install -f -y
    elif [ $hardware_arch -eq 64 ]; then
        dpkg -i -B ./xinput-calibrator_0.7.5+git20140201-1+b2_arm64.deb || apt-get install -f -y
    fi

    # Install python dependencies for Mouse_Key.py
    echo "[2/4] Installing Python requirements..."
    apt-get update
    apt-get install -y python3-pip python3-setuptools python3-xlib

    # The python-xlib package in repo is usually python2. If it's needed, we install it.
    echo "[3/4] Installing python-xlib (from local deb)..."
    dpkg -i -B ./python-xlib_0.23-2_all.deb || apt-get install -f -y

    # Install PyMouse
    echo "[4/4] Extracting and installing PyMouse..."
    tar xvzf ./PyMouse-1.0.tar.gz
    cd PyMouse-1.0
    python3 setup.py install || python setup.py install
    cd ..

    echo "========================================================="
    echo " Calibration Tools Installation Complete!"
    echo " You can now run 'python3 Mouse_Key.py' or 'python Mouse_Key.py' to launch it."
    echo "========================================================="
    exit 0
elif [ "$mode_choice" = "4" ]; then
    echo "========================================================="
    echo " Reverting all changes made to the system..."
    echo "========================================================="
    echo "[1/3] Uninstalling X.Org and LXDE..."
    /boot/dietpi/dietpi-software uninstall 23 || true
    /boot/dietpi/dietpi-software uninstall 6 || true
    
    echo "[2/3] Resetting Autostart to Console..."
    /boot/dietpi/dietpi-autostart 0 || true

    echo "[3/3] Restoring original hardware configuration..."
    if [ -f "./system_restore.sh" ]; then
        chmod +x ./system_restore.sh
        ./system_restore.sh
    else
        echo "Error: system_restore.sh not found."
    fi
    exit 0
elif [ "$mode_choice" = "5" ]; then
    echo "========================================================="
    echo " Configuring Display as Native DRM Card..."
    echo "========================================================="
    sleep 2
    
    echo "[1/3] Enabling SPI in boot config..."
    if ! grep -q "^dtparam=spi=on" /boot/config.txt; then
        echo "dtparam=spi=on" >> /boot/config.txt
    fi
    
    echo "[2/3] Adding piscreen DRM overlay..."
    # Remove old DRM overrides if they exist
    sed -i '/^dtoverlay=piscreen,drm/d' /boot/config.txt
    echo "dtoverlay=piscreen,drm" >> /boot/config.txt
    
    echo "[3/3] Cleaning up legacy X11 driver overrides..."
    rm -f /etc/X11/xorg.conf.d/99-fbturbo.conf
    rm -f /etc/X11/xorg.conf.d/99-calibration.conf
    
    echo "========================================================="
    echo " DRM Configuration Complete!"
    echo " Rebooting now to apply native kernel drivers..."
    echo "========================================================="
    sleep 2
    reboot
    exit 0
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Run the original LCD35-show script to configure hardware and X11
if [ -f "./LCD35-show" ]; then
    chmod +x ./LCD35-show
    # We call it directly, it will perform the final reboot.
    ./LCD35-show
else
    echo "Error: LCD35-show script not found in the current directory."
    echo "Make sure you run this script from the cloned repository root."
    exit 1
fi
