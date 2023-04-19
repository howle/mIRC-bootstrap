#!/bin/bash

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y build-essential openssl libssl-dev zlib1g zlib1g-dev wget

# Download UnrealIRCd
wget https://www.unrealircd.org/downloads/UnrealIRCd-latest.tar.gz

# Extract the archive
tar -xvf UnrealIRCd-latest.tar.gz

# Change to the extracted directory
cd UnrealIRCd*

# Run the configuration script
./Config

# Compile and install
make && sudo make install

# Copy the default configuration files
cp doc/conf/examples/example.conf ~/unrealircd/conf/unrealircd.conf
cp doc/conf/examples/help.conf ~/unrealircd/conf/help.conf
cp doc/conf/examples/badwords.message.example.conf ~/unrealircd/conf/badwords.message.conf
cp doc/conf/examples/badwords.channel.example.conf ~/unrealircd/conf/badwords.channel.conf

# Start the IRC server
~/unrealircd/unrealircd start

# Configure iptables
sudo iptables -A INPUT -p tcp --dport 6667 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 6697 -j ACCEPT

# Save iptables rules
sudo sh -c 'iptables-save > /etc/iptables/rules.v4'

# Create a systemd service
sudo bash -c "cat > /etc/systemd/system/unrealircd.service << EOL
[Unit]
Description=UnrealIRCd IRC Server
After=network.target

[Service]
User=$(whoami)
Group=$(id -gn)
Type=forking
ExecStart=$(realpath ~/unrealircd)/unrealircd start
ExecStop=$(realpath ~/unrealircd)/unrealircd stop
ExecReload=$(realpath ~/unrealircd)/unrealircd reload
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL"

# Enable and start the service
sudo systemctl enable unrealircd.service
sudo systemctl start unrealircd.service

echo "The mIRC server has been installed, configured, and started. Please edit the configuration files in ~/unrealircd/conf/ as needed."
