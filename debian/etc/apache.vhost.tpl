<VirtualHost *:80>
      ServerName __SERVER_NAME__
      #ServerAlias www.example.com

      ServerAdmin __SERVER_ADMIN__

			DocumentRoot /var/lib/airtime/public
      DirectoryIndex index.php

			SetEnv APPLICATION_ENV "development"

      <Directory /var/lib/airtime/public>
              Options -Indexes FollowSymLinks MultiViews
              AllowOverride All
              Order allow,deny
              Allow from all
      </Directory>
</VirtualHost> 
