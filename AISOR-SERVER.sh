#!/bin/bash

# Function to display progress
show_progress() {
    local msg=$1
    local progress=$2
    echo -ne "${msg} ${progress}\r"
}

# Detect OS distribution
detect_os() {
    if [ -f /etc/debian_version ]; then
        echo "debian"
    elif [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/fedora-release ]; then
        echo "fedora"
    elif [ -f /etc/os-release ] && grep -q "Ubuntu" /etc/os-release; then
        echo "ubuntu"
    else
        echo "unknown"
    fi
}

# Function to install dependencies based on OS
install_dependencies() {
    os=$(detect_os)

    case $os in
        debian|ubuntu)
            echo "Detected Debian/Ubuntu system"
            progress="*"
            show_progress "Updating package list" "${progress}"
            sudo apt update -y > /dev/null 2>&1
            progress="**"
            show_progress "Updating package list" "${progress}"
            sleep 1
            progress="***"
            show_progress "Updating package list" "${progress}"
            sleep 1
            echo -e "Updating package list *** Done"

            # Install sudo and nginx-extras
            progress="#"
            show_progress "Installing sudo and nginx-extras" "${progress}"
            sudo apt install sudo nginx nginx-extras -y > /dev/null 2>&1
            progress="##"
            show_progress "Installing sudo and nginx-extras" "${progress}"
            sleep 1
            progress="###"
            show_progress "Installing sudo and nginx-extras" "${progress}"
            sleep 1
            echo -e "Installing sudo and nginx-extras ### Done"
            ;;
        arch)
            echo "Detected Arch Linux system"
            progress="*"
            show_progress "Updating package list" "${progress}"
            sudo pacman -Sy --noconfirm > /dev/null 2>&1
            progress="**"
            show_progress "Updating package list" "${progress}"
            sleep 1
            progress="***"
            show_progress "Updating package list" "${progress}"
            sleep 1
            echo -e "Updating package list *** Done"

            # Install sudo and nginx-mod-stream
            progress="#"
            show_progress "Installing sudo and nginx-mod-stream" "${progress}"
            sudo pacman -S --noconfirm sudo nginx nginx-mod-stream > /dev/null 2>&1
            progress="##"
            show_progress "Installing sudo and nginx-mod-stream" "${progress}"
            sleep 1
            progress="###"
            show_progress "Installing sudo and nginx-mod-stream" "${progress}"
            sleep 1
            echo -e "Installing sudo and nginx-mod-stream ### Done"
            ;;
        fedora)
            echo "Detected Fedora system"
            progress="*"
            show_progress "Updating package list" "${progress}"
            sudo dnf update -y > /dev/null 2>&1
            progress="**"
            show_progress "Updating package list" "${progress}"
            sleep 1
            progress="***"
            show_progress "Updating package list" "${progress}"
            sleep 1
            echo -e "Updating package list *** Done"

            # Install sudo and nginx-all-modules
            progress="#"
            show_progress "Installing sudo and nginx-all-modules" "${progress}"
            sudo dnf install -y sudo nginx nginx-all-modules > /dev/null 2>&1
            progress="##"
            show_progress "Installing sudo and nginx-all-modules" "${progress}"
            sleep 1
            progress="###"
            show_progress "Installing sudo and nginx-all-modules" "${progress}"
            sleep 1
            echo -e "Installing sudo and nginx-all-modules ### Done"
            ;;
        *)
            echo "Unsupported operating system"
            exit 1
            ;;
    esac
}

# Function to install AISOR
install_aisor() {
    # Install necessary dependencies
    install_dependencies

    # Change the port in the default nginx configuration file
    NGINX_DEFAULT_CONF="/etc/nginx/nginx.conf"
    if [ -f "$NGINX_DEFAULT_CONF" ]; then
        sudo sed -i 's/listen 80;/listen 48000;/g' "$NGINX_DEFAULT_CONF"
        echo "Port changed in default nginx configuration file."
    else
        echo "Default nginx configuration file not found."
        exit 1
    fi

    # Add stream block to nginx.conf
    STREAM_BLOCK="
# rdp to ssh
stream {
    server {
        listen 8855;
        proxy_pass 10.0.2.2:3389;
    }
}
"
    if ! grep -q "# rdp to ssh" "$NGINX_DEFAULT_CONF"; then
        echo "$STREAM_BLOCK" | sudo tee -a "$NGINX_DEFAULT_CONF" > /dev/null
        echo "Stream block added to nginx.conf."
    else
        echo "Stream block already exists in nginx.conf"
    fi

    # Test nginx configuration
    sudo nginx -t

    # Check if the configuration test was successful
    if [ $? -eq 0 ]; then
        echo "Configuration seems to be fine."
        # Restart nginx only if the configuration test passes
        sudo systemctl restart nginx
    else
        echo "Nginx configuration test failed. Please check the configuration."
    fi
}

# Function to remove AISOR
remove_aisor() {
    os=$(detect_os)

    case $os in
        debian|ubuntu)
            progress="*"
            show_progress "Removing nginx and extras" "${progress}"
            sudo apt-get remove --purge nginx nginx-extras -y > /dev/null 2>&1
            progress="**"
            show_progress "Removing nginx and extras" "${progress}"
            sleep 1
            progress="***"
            show_progress "Removing nginx and extras" "${progress}"
            sleep 1
            echo -e "Removing nginx and extras *** Done"

            sudo apt-get autoremove -y > /dev/null 2>&1
            sudo apt-get clean > /dev/null 2>&1
            ;;
        arch)
            progress="*"
            show_progress "Removing nginx and extras" "${progress}"
            sudo pacman -Rns --noconfirm nginx nginx-mod-stream > /dev/null 2>&1
            progress="**"
            show_progress "Removing nginx and extras" "${progress}"
            sleep 1
            progress="***"
            show_progress "Removing nginx and extras" "${progress}"
            sleep 1
            echo -e "Removing nginx and extras *** Done"
            ;;
        fedora)
            progress="*"
            show_progress "Removing nginx and extras" "${progress}"
            sudo dnf remove -y nginx nginx-all-modules > /dev/null 2>&1
            progress="**"
            show_progress "Removing nginx and extras" "${progress}"
            sleep 1
            progress="***"
            show_progress "Removing nginx and extras" "${progress}"
            sleep 1
            echo -e "Removing nginx and extras *** Done"
            ;;
        *)
            echo "Unsupported operating system"
            exit 1
            ;;
    esac

    echo "Cleanup done."

    # Optionally, remove this script itself after removal
    if [ -f "/usr/local/bin/aisor_installer" ]; then
        sudo rm /usr/local/bin/aisor_installer
        echo "Installer script removed."
    fi
}

# Prompt user for action
echo "Please choose an option:"
echo "1) Install AISOR"
echo "2) Remove AISOR"
read -p "Enter your choice [1 or 2]: " choice

case $choice in
    1)
        install_aisor
        ;;
    2)
        remove_aisor
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac
