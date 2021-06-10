#!/bin/bash
sudo su
sudo apt-get -y install apache2 openssl
sudo rm /var/www/html/index.html
touch /var/www/html/index.html
echo '<p style="text-align: center;">Welcome to Terraform</p>' >> /var/www/html/index.html
echo '<p style="text-align: left;">This has been a rapid learning experience, there were a few hiccups along the way, specifically around the implementation of <a title="Terraform AWS Route Tables" href="https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table" target="_blank"rel="noopener">route tables</a>.</p>' >> /var/www/html/index.html
echo '<p style="text-align: left;">Source code for this little project can be found <a title="GitHub Source" href="https://github.com/zer019/learn_terraform" target="_blank" rel="noopener">here</a>.</p>' >> /var/www/html/index.html
echo '<p style="text-align: left;">&nbsp;</p>' >> /var/www/html/index.html
echo '<p style="text-align: center;"><iframe class="giphy-embed" src="https://giphy.com/embed/3orieM85kojJlOEYFy" width="480" height="366" frameborder="0" allowfullscreen="allowfullscreen" data-mce-fragment="1"></iframe></p>' >> /var/www/html/index.html
sudo systemctl enable apache2
sudo a2enmod ssl
sudo a2enmod rewrite
sudo sed -i '1s/^/ServerName terraform.null19.com \n /' /etc/apache2/apache2.conf
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo systemctl start apache2