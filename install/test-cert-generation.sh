#!/bin/bash

# Test script for certificate generation

TARGET=/opt
PAYARA_DIR=$TARGET/payara41
TEST_DIR=/tmp/payara-cert-test

echo "-- Testing certificate generation --"

# Create test directory
mkdir -p $TEST_DIR

# Generate a self-signed certificate for Payara
echo "-- Generating self-signed certificates --"
openssl req -x509 -newkey rsa:4096 -keyout $TEST_DIR/payara-key.pem \
  -out $TEST_DIR/payara-cert.pem -days 365 -nodes \
  -subj "/C=DE/ST=Berlin/L=Berlin/O=eID-Server-Testbed/OU=Testing/CN=localhost"

# Combine the certificate and key into a single PEM file
cat $TEST_DIR/payara-cert.pem $TEST_DIR/payara-key.pem > $TEST_DIR/payara.pem

echo "-- Self-signed certificates generated and saved to $TEST_DIR/payara.pem --"

# Verify the certificate
echo "-- Verifying certificate --"
openssl x509 -in $TEST_DIR/payara-cert.pem -text -noout | head -15

echo "-- Test completed --"