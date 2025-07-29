#!/bin/bash

TARGET=/opt
PAYARA_DIR=$TARGET/payara41
TESTBED_APP=eidsrv-testbed-application-1.0-beta-4.ear

# -- changes below this line may require further changes in the script --
asadmin=$PAYARA_DIR/bin/asadmin
required="$TESTBED_APP domain.xml h2-1.4.191.jar"
_user=`id -un`

# Check if required files exist
if ! ls $required &>/dev/null; then
  echo "-- the script needs the following files in the current directory:"
  echo "  $required --"
  exit 1
fi

# Check if Payara is already running
if pgrep -f payara >/dev/null; then
  echo "-- Payara is already running --"
  echo "-- Attempting to access the application --"
  curl 'http://localhost:8080/eID-Server-Testbed/' &>/dev/null && \
    echo "-- The Server-Testbed should be accessible at: http://localhost:8080/eID-Server-Testbed/ --"
  exit 0
fi

# Check if Payara is already installed
if [ -d "$PAYARA_DIR" ]; then
  echo "-- Payara is already installed at $PAYARA_DIR --"
else
  echo "-- Installing Payara --"
  # Create backup of existing installation if it exists
  if [ -d "$PAYARA_DIR" ]; then
    sudo mv $PAYARA_DIR $PAYARA_DIR.bak.`date +%s`
  fi
  
  # Extract Payara
  sudo unzip payara-4.1.2.174.zip -d $TARGET
  sudo chown -R $_user:$_user $PAYARA_DIR
  
  # Copy configuration files
  cp domain.xml $PAYARA_DIR/glassfish/domains/domain1/config/
  cp h2-1.4.191.jar $PAYARA_DIR/glassfish/lib/
fi

# Start the domain
echo "-- Starting Payara domain --"
$asadmin start-domain

# Check if application is already deployed
if $asadmin list-applications | grep -q "$TESTBED_APP"; then
  echo "-- Application is already deployed --"
else
  # Deploy the application
  echo "-- Deploying application --"
  $asadmin deploy $TESTBED_APP
fi

# Check if the application is accessible
echo "-- Checking if the application is accessible --"
curl 'http://localhost:8080/eID-Server-Testbed/' &>/dev/null && \
  echo "-- The Server-Testbed should now be accessible at: http://localhost:8080/eID-Server-Testbed/ --"

echo "-- Setup complete --"