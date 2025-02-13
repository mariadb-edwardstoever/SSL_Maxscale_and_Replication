## REDHAT README

To use SSL connections in Maxscale and Mariadb Server, you will need to decide the following:

1. Do you want to use a provided CA certificate or create your own? This project offers you a tested CA certificate that you can use if you wish. The provided CA cerficate expires on Jun 29, 2052. Using the provided CA Certificate will ensure there is no conflict between the CA and your certificate.
2. Do you want to use one certificate for Mariadb Server and a different certificate for client? You can simplify things by using the same certificate for both.
3. Do you want to use one certificate for everything? For example, you simplify things by creating a single certificate for Maxscale Admin GUI https, Maxscale server, database clients and database server
4. Do you want to use X509 extensions for clientAuth and serverAuth. Using these extensions is optional. Maxscale will honor these extensions if they are present in your certificates. You should use these extensions only if you require this strict level of security in Maxscale.

---
## Files You May Need to Edit

### vars.sh
Define the variable MY_ORGANIZATION to something that makes sense. The example is widgets-and-gadgets.com. Files will include this in their name.
Define the variable HOW_MANY_DAYS_VALID to the number of days you want your certificate to be valid. 

### CA_configuration.cfg
If you use the provided CA Certificate, you can ignore this file. Otherwise, you can edit it to create any Certificate Authority you want.

### OWN_org_details.cfg
This file is where you will put details about your own organization.

### OWN_extensions.cfg
Edit this file so that the DNS.1 equals a wildcard of your domain. For example, change `*.widgets-and-gadgets.com` to a wildcard for the domain that you will use for https browser connections. This will be useful for maxscale Admin GUI.

---
## Using the provided CA certificate
Follow these steps to generate a signed certificate using the provided CA. 
```
# If you are using Red Hat Enterprise Linux start in the REDHAT directory
cd REDHAT
# If you want to remove all generated files to start over, run the script start_over.sh
./start_over.sh
# Test that the necessary software is installed on the server.
./test_required_software.sh
# Run the script to use the provided CA certificate
./use_provided_CA.sh
# Create your own key file
./create_own_key.sh
# Edit OWN_org_details.cfg, change the details to make sense for you.
vim OWN_org_details.cfg
# Edit OWN_extensions.cfg, change the details to make sense for you.
vim OWN_extensions.cfg
# Create your own crt/pem file
./create_own_pem.sh
# Validate your generated pem file
./validate_own_pem.sh
```
---
## Generating and Using your own CA certificate
Follow these steps to generate your own CA certificate and use that to generate a signed certificate. 
```
# If you are using Red Hat Enterprise Linux start in the REDHAT directory
cd REDHAT
# If you want to remove all generated files to start over, run the script start_over.sh
./start_over.sh
# Test that the necessary software is installed on the server.
./test_required_software.sh
# Create a new CA key, input a passphrase and keep it in a safe place.
./create_new_CA_key.sh
# Edit the file CA_configuration.cfg
vim CA_configuration.cfg
# Create a new CA pem, you will need to enter the passphrase
./create_new_CA_pem.sh
# Validate the generated CA pem
./validate_CA_pem.sh
# Create your own key file
./create_own_key.sh
# Edit OWN_org_details.cfg, change the details to make sense for you.
vim OWN_org_details.cfg
# Edit OWN_extensions.cfg, change the details to make sense for you.
vim OWN_extensions.cfg
# Create your own crt/pem file
./create_own_pem.sh
# Validate your generated pem file
./validate_own_pem.sh
```