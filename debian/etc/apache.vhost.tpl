<VirtualHost *:443>
      SSLEngine on
      SSLProtocol all -SSLv2
      SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
      SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
      SSLCACertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem

      ServerName __SERVER_NAME__
      #ServerAlias www.example.com

      ServerAdmin __SERVER_ADMIN__

      DocumentRoot /usr/share/airtime/public
      DirectoryIndex index.php

      <Directory /usr/share/airtime/public>
              Options -Indexes FollowSymLinks MultiViews
              AllowOverride all
              Order allow,deny
              Allow from all
      </Directory>
</VirtualHost>

<VirtualHost *:80>
      ServerName __SERVER_NAME__
      #ServerAlias www.example.com

      ServerAdmin __SERVER_ADMIN__

      DocumentRoot /usr/share/airtime/public
      DirectoryIndex index.php

      SetEnv APPLICATION_ENV "production"

      <Directory /usr/share/airtime/public>
              Options -Indexes FollowSymLinks MultiViews
              AllowOverride All
              Order deny,allow
              Deny from all
              Allow from 127.0.0.1
      </Directory>
</VirtualHost> 
