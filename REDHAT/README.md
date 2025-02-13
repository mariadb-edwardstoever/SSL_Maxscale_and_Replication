## REDHAT README

To use SSL connections in Maxscale and Mariadb Server, you will need to decide the following:

1. Do you want to use a provided CA certificate or create your own? This project offers you a tested CA certificate that you can use if you wish. The provided CA cerficate expires on Jun 29, 2052. Using the provided CA Certificate will ensure there is no conflicts between the CA and your certificate.
2. Do you want to use one certificate for Mariadb Server and a different certificate for client? You can simplify things by using the same certificate for both.
3. Do you want to use one certificate for everything? For example, you simplify things by creating a single certificate for Maxscale Admin GUI https, Maxscale server, database clients and database server
4. Do you want to use X509 extensions for clientAuth and serverAuth. Using these extensions is optional. Maxscale will honor these extensions if they are present in your certificates. You should use these extensions only if you require this strict level of security in Maxscale.

---
## Files You May Need to Edit

### CA_configuration.cfg
If you use the provided CA Certificate, you can ignore this file. Otherwise, you can edit it to create any Certificate Authority you want.

### OWN_org_details.cfg
This file is where you will put details about your own organization.

### OWN_extensions.cfg
Edit this file so that the DNS.1 equals a wildcard of your domain. For example, change `*.widgets-and-gadgets.com` to a wildcard for the domain that you will use for https browser connections. This will be useful for maxscale Admin GUI.