#!/bin/sh
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

# Define a timestamp 
timestamp() {
  date +"%F %T" # current time
}

echo "<html><h1 style="color:lightgreen">Hello from Reply! $(timestamp) </h1></html>"> /var/www/html/index.html
