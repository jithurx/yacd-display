# Setup Instructions

This repository contains the interactive setup utility. It can be run on minimal command-line systems as well as within a fully configured desktop environment.

## Installation

1. Clone this repository to your local machine and navigate into the directory:
   ```bash
   cd yacd-display
   ```

2. Make sure the setup script has execution permissions:
   ```bash
   chmod +x setup.sh
   ```

3. Run the interactive setup application as root:
   ```bash
   sudo ./setup.sh
   ```

## Setup Options

When you run the script, you will be prompted with three configuration options. Type the number corresponding to your choice and press Enter:

1. **Full Mode**  
   Installs the display server, a lightweight desktop environment, and configures the system to autostart into the desktop before applying the hardware configurations. (Recommended if starting from a fresh minimal image).

2. **Minimal Mode**  
   Bypasses the desktop installation completely and *only* applies the hardware configurations and drivers. (Recommended if you already have a desktop environment running, or if you strictly only want the drivers).

3. **Calibration**  
   Installs the optional touch calibration tools and dependencies so they can be executed manually.

4. **Revert All**  
   Completely reverts all changes made by this script. It uninstalls the desktop environment and display server (if installed via Full Mode), resets the autostart to the default console, and restores the original hardware configuration.

5. **DRM Mode**  
   Configures the display to run natively as a Linux DRM (Direct Rendering Manager) card using the `tinyDRM` KMS subsystem, bypassing the legacy framebuffer drivers entirely.

*Note: Depending on the mode selected, the system may reboot automatically after configuration is complete.*
