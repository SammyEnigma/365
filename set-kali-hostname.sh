# Update Hostname successfully to **HP-PRINTER** and apply across system configuration files.

## sudo hostnamectl set-hostname HP-PRINTER
echo "HP-PRINTER" | sudo tee /etc/hostname
sudo sed -i 's/127.0.1.1.*/127.0.1.1\tHP-PRINTER/g' /etc/hosts
sudo hostnamectl
