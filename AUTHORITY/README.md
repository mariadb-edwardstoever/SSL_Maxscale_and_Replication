### Files by Edward Stoever for Mariadb Support
This directory includes myCA.key and myCA.pem which can be used as
a certificate authority for self-signing new certificates. The passphrase 
for the keyfile is mariadb. The certificate myCA.pem will expire on Jun 29, 2052.

If you use this CA certificate to create self-signed certificates for https, 
you will need to import the myCA.pem as a trused CA into the browsers that you use.

Each browser, such as Chrome, Firefox and Opera, has slightly different 
instructions for importing CA certificates. Use a search engine to find instructions 
for importing CA certificates that are specific for your browser(s).
