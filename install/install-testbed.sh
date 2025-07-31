#!/bin/bash

TARGET=/opt
PAYARA_DIR=$TARGET/payara41
TESTBED_APP=eidsrv-testbed-application-1.0-beta-4.ear
# TESTCA=ca1.war (commented out as file is not available)

# -- changes below this line may require further changes in the script --
asadmin=$PAYARA_DIR/bin/asadmin
required="$TESTBED_APP domain.xml h2-1.4.191.jar" # Removed $TESTCA as it's not available
_user=`id -un`


if ! ls $required &>/dev/null; then
  echo "-- the install-script needs the following files in the current directory:"
  echo "  $required --"
  exit 1
fi

if pgrep -f payara >/dev/null; then
  echo "-- please stop running payara instances and restart install --"
  echo "e.g. PAYARA_DIR/bin/asadmin stop-domain"
  exit 1
fi

sudo mv $PAYARA_DIR $PAYARA_DIR.bak.`date +%s`
sudo unzip payara-4.1.2.174.zip -d $TARGET
sudo chown -R $_user:$_user $PAYARA_DIR

cp domain.xml $PAYARA_DIR/glassfish/domains/domain1/config/
cp h2-1.4.191.jar $PAYARA_DIR/glassfish/lib/

$asadmin start-domain
# Deployment of ca1.war is commented out as the file is not available
# $asadmin deploy --contextroot ca1 --name ca1 $TESTCA
$asadmin deploy $TESTBED_APP

curl 'http://localhost:8080/eID-Server-Testbed/' &>/dev/null && \
  echo "-- The Server-Testbed should now be accessible at: http://localhost:8080/eID-Server-Testbed/ --"

# Note: Certificate services from ca1.war are not available
# Implementing the original TODO: download server certificates from: https://localhost:8181/ca1/DVCA_CertDescriptionService?Tester to payara.pem

# Since ca1.war is not available, we'll generate self-signed certificates for Payara
echo "-- Generating self-signed certificates for Payara --"

# Create directory for certificates if it doesn't exist
mkdir -p $PAYARA_DIR/glassfish/domains/domain1/config/certificates

# Generate a self-signed certificate for Payara
openssl req -x509 -newkey rsa:4096 -keyout $PAYARA_DIR/glassfish/domains/domain1/config/certificates/payara-key.pem \
  -out $PAYARA_DIR/glassfish/domains/domain1/config/certificates/payara-cert.pem -days 365 -nodes \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=eID-Server-Testbed/OU=Testing/CN=localhost"

# Combine the certificate and key into a single PEM file
cat $PAYARA_DIR/glassfish/domains/domain1/config/certificates/payara-cert.pem \
    $PAYARA_DIR/glassfish/domains/domain1/config/certificates/payara-key.pem > $PAYARA_DIR/glassfish/domains/domain1/config/certificates/payara.pem

echo "-- Self-signed certificates generated and saved to $PAYARA_DIR/glassfish/domains/domain1/config/certificates/payara.pem --"
