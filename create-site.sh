#!/bin/bash

if [ -z "$1" ]; then
	echo "Error: Please specify the site name! Example: ./create-site.sh mysite"
	exit 1
fi

DOMAIN=$1
SITE_DIR="/var/www/$DOMAIN"

echo "1. Creating directory for the site: ${SITE_DIR}..."
sudo mkdir -p $SITE_DIR

echo "2. Creating test index.html..."
echo "<h1>This is an auto-created site: ${DOMAIN}</h1>" | sudo tee $SITE_DIR/index.html > /dev/null

echo "3. Setting permissions for www-data..."
sudo chown -R www-data:www-data $SITE_DIR

echo "4. Creating Nginx configuration file..."
sudo bash -c "cat << 'EOF' > /etc/nginx/sites-available/$DOMAIN
server {
	listen 80;
	server_name $DOMAIN.local;
	
	root /var/www/$DOMAIN;
	index index.html;

	location / {
		try_files \$uri \$uri/ =404;
	}
}
EOF"

echo "5. Creating symbolic link in sites-enabled..."
sudo rm -f /etc/nginx/sites-enabled/$DOMAIN
sudo ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/

echo "6. Testing configuration and restarting Nginx..."
sudo nginx -t && sudo systemctl restart nginx

echo "Success! Site http://${DOMAIN}.local has been successfully created!"
