#!/bin/bash


# Prompt the user to choose a PHP version
echo "Choose a PHP version to install:"
echo "1. PHP 7.4"
echo "2. PHP 8.0"

read -p "Enter the number corresponding to your choice: " php_version_choice

# Prompt user to select a Node.js version
echo "Select a Node.js version:"
echo "1. Node.js 18"
echo "2. Node.js 20"
read -p "Enter your choice (1 or 2): " node_version_choice


# Check if the /etc/os-release file exists
if [ -e /etc/os-release ]; then
    # Source the file to get variables
    . /etc/os-release


# Function to install Nginx
    sudo apt update
    sudo apt-get remove apache2 -y --purge
    sudo apt install -y nginx
    sudo systemctl start nginx
    echo "Nginx installed successfully."

    # Function to add a custom Nginx configuration

    sudo cat > /etc/nginx/sites-available/default << EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;


        root /var/www/html;


        index index.php index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {

                try_files \$uri \$uri/ =404;
        }



        location ~ \.php\$ {

                fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
                 include fastcgi_params;
                fastcgi_index index.php;
               fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        }
}
EOF

    # Test Nginx configuration and restart
    sudo nginx -t && sudo systemctl restart nginx

    echo "Custom Nginx configuration added successfully."


# Install MySQL 8.0
     echo "Installing MySQL 8.0..."
     sudo apt-get update
     sudo apt-get install -y mysql-server-8.0


# Set root password
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'


# Update the package list
sudo apt update

# Install PHP based on the user's choice
case $php_version_choice in
    1)
        sudo apt install php7.4 php7.4-fpm php7.4-mysql php-common php7.4-cli php7.4-common php7.4-json php7.4-opcache php7.4-readline php7.4-mbstring php7.4-xml php7.4-gd php7.4-curl --no-install-recommends -y
        sudo systemctl start php7.4-fpm
        sudo systemctl enable php7.4-fpm

        ;;
    2)
        sudo apt install php8.0 php8.0-fpm php8.0-mysql php-common php8.0-cli php8.0-common php8.0-opcache php8.0-readline php8.0-mbstring php8.0-xml php8.0-gd php8.0-curl --no-install-recommends -y
        sudo systemctl start php8.0-fpm
        sudo systemctl enable php8.0-fpm
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac


# Install Node.js based on user choice
case $node_version_choice in
    1)
        echo "Installing Node.js 18..."
        # Commands to install Node.js 18
        ;;
    2)
        echo "Installing Node.js 20..."
        # Commands to install Node.js 20
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

case $node_version_choice in
    1)
        echo "Installing Node.js 18..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        ;;
    2)
        echo "Installing Node.js 20..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Install phpMyAdmin
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean true'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/app-password-confirm password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/admin-pass password root'
sudo debconf-set-selections <<< 'phpmyadmin phpmyadmin/mysql/app-pass password root'
sudo apt install phpmyadmin -y

# Enable phpMyAdmin Nginx configuration (create a symbolic link)
    sudo ln -sf /etc/phpmyadmin/nginx.conf /etc/nginx/conf.d/phpmyadmin.conf
    sudo a2enconf phpmyadmin
    # Reload Nginx to apply changes
    sudo systemctl reload nginx

# Create a new MySQL user and database for phpMyAdmin
MYSQL_ROOT_PASSWORD="root"
PHPMYADMIN_PASSWORD="root"

# Check if the database already exists before creating it
if ! mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE phpmyadmin"; then
    sudo mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<MYSQL_SCRIPT
    CREATE DATABASE IF NOT EXISTS phpmyadmin;
    CREATE USER IF NOT EXISTS 'phpmyadmin'@'localhost' IDENTIFIED BY '$PHPMYADMIN_PASSWORD';
    GRANT ALL PRIVILEGES ON phpmyadmin.* TO 'phpmyadmin'@'localhost';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT
else
    echo "phpmyadmin database already exists."
fi

# Print the information of os
    echo "Operating System: $PRETTY_NAME"
    echo "Version: $VERSION"
else
    echo "Error: /etc/os-release not found. This script is intended for Ubuntu 20.04."
fi

