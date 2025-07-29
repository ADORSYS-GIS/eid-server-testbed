# eID-Server Testbed Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [System Requirements](#system-requirements)
3. [Installation](#installation)
4. [Running the Server](#running-the-server)
5. [Accessing the Web Interface](#accessing-the-web-interface)
6. [Troubleshooting](#troubleshooting)
7. [Additional Resources](#additional-resources)

## Introduction

The eID-Server is the technical component used by eServices to integrate Online-Authentication according to BSI TR-03124-1 and BSI TR-03130-1 between eServices and eID-Cards based on Extended Access Control v2 (e.g., the German ID card or the German residence Permit) into IT systems. eID-Servers can be implemented by different vendors. To ensure interoperability with other components of the system, the BSI specifies conformity tests.

The eID-Server-Testbed is a test tool that allows performing conformity tests according to BSI TR-03130-4 of eID-Servers based on BSI TR-03130-1. It helps verify that an eID-Server implementation meets the required standards and can interoperate with other components in the eID infrastructure.

## System Requirements

### Required Software
- **Oracle JDK 8** or compatible Java Development Kit
- **Java Cryptography Extensions** for JDK 8
- **curl** for testing connectivity

### Required Files
The following files are needed for installation and should be placed in the same directory:
- `eidsrv-testbed-application-1.0-beta-4.ear` (The application package)
- `domain.xml` (Payara domain configuration)
- `h2-1.4.191.jar` (H2 database driver)
- `payara-4.1.2.174.zip` (Payara application server)

## Installation

There are two ways to install the eID-Server Testbed:

### Method 1: Using the Installation Script

1. Ensure all required files are in the same directory as the installation script.

2. Make the installation script executable:
   ```bash
   chmod +x install-testbed.sh
   ```

3. Stop any running Payara instances:
   ```bash
   /opt/payara41/bin/asadmin stop-domain
   ```

4. Run the installation script with sudo:
   ```bash
   sudo ./install-testbed.sh
   ```

5. The script will:
   - Extract Payara to `/opt/payara41/`
   - Copy configuration files
   - Start the Payara domain
   - Deploy the application
   - Generate self-signed certificates
   - Confirm that the Server-Testbed is accessible

### Method 2: Manual Installation

1. Download and install Oracle JDK 8.

2. Download and install Java Cryptography Extensions for JDK 8.

3. Extract Payara Server:
   ```bash
   sudo unzip payara-4.1.2.174.zip -d /opt
   sudo chown -R $(id -un):$(id -un) /opt/payara41
   ```

4. Copy the configuration files:
   ```bash
   cp domain.xml /opt/payara41/glassfish/domains/domain1/config/
   cp h2-1.4.191.jar /opt/payara41/glassfish/lib/
   ```

5. Start the Payara domain:
   ```bash
   /opt/payara41/bin/asadmin start-domain
   ```

6. Deploy the application:
   ```bash
   /opt/payara41/bin/asadmin deploy eidsrv-testbed-application-1.0-beta-4.ear
   ```

7. Generate self-signed certificates:
   ```bash
   mkdir -p /opt/payara41/glassfish/domains/domain1/config/certificates
   openssl req -x509 -newkey rsa:4096 -keyout /opt/payara41/glassfish/domains/domain1/config/certificates/payara-key.pem -out /opt/payara41/glassfish/domains/domain1/config/certificates/payara-cert.pem -days 365 -nodes -subj "/C=DE/ST=Berlin/L=Berlin/O=eID-Server-Testbed/OU=Testing/CN=localhost"
   cat /opt/payara41/glassfish/domains/domain1/config/certificates/payara-cert.pem /opt/payara41/glassfish/domains/domain1/config/certificates/payara-key.pem > /opt/payara41/glassfish/domains/domain1/config/certificates/payara.pem
   ```

## Running the Server

### Starting the Server

If you've already installed the eID-Server Testbed, you can use the run-testbed.sh script to start the server:

1. Make the script executable:
   ```bash
   chmod +x run-testbed.sh
   ```

2. Run the script:
   ```bash
   ./run-testbed.sh
   ```

3. The script will:
   - Check if Payara is already running
   - Start Payara if it's not running
   - Deploy the application if it's not already deployed
   - Verify that the application is accessible

### Starting the Server Manually

If you prefer to start the server manually:

1. Start the Payara domain:
   ```bash
   /opt/payara41/bin/asadmin start-domain
   ```

2. Verify that the application is deployed:
   ```bash
   /opt/payara41/bin/asadmin list-applications
   ```

3. If the application is not deployed, deploy it:
   ```bash
   /opt/payara41/bin/asadmin deploy eidsrv-testbed-application-1.0-beta-4.ear
   ```

### Stopping the Server

To stop the server:

```bash
/opt/payara41/bin/asadmin stop-domain
```

## Accessing the Web Interface

Once the server is running, you can access the eID-Server Testbed web interface at:

[http://localhost:8080/eID-Server-Testbed/](http://localhost:8080/eID-Server-Testbed/)

### Administration Console

You can also access the Payara Administration Console at:

[http://localhost:4848/common/index.jsf](http://localhost:4848/common/index.jsf)

This console allows you to manage the Payara server and deployed applications.

## Troubleshooting

### Common Issues

1. **Application Not Accessible**
   - Verify that Payara is running: `pgrep -f payara`
   - Check if the application is deployed: `/opt/payara41/bin/asadmin list-applications`
   - Check Payara logs for errors: `tail -n 100 /opt/payara41/glassfish/domains/domain1/logs/server.log`

2. **Blank Page When Accessing the Web Interface**
   - Check browser console for JavaScript errors
   - Verify that all required files were deployed correctly
   - Check Payara logs for errors

3. **Deployment Fails**
   - Ensure that all required files are in the correct locations
   - Check if the application is already deployed and undeploy it first:
     ```bash
     /opt/payara41/bin/asadmin undeploy eidsrv-testbed-application-1.0-beta-4
     ```
   - Verify that the EAR file is not corrupted


### Redeploying the Application

If you need to redeploy the application:

1. Ensure the server is running:
   ```bash
   /opt/payara41/bin/asadmin start-domain
   ```

2. Undeploy the existing application:
   ```bash
   /opt/payara41/bin/asadmin undeploy eidsrv-testbed-application-1.0-beta-4
   ```

3. Deploy the new version:
   ```bash
   /opt/payara41/bin/asadmin deploy eidsrv-testbed-application-1.0-beta-4.ear
   ```

### Resetting the Database

If you need to reset the database:

1. Stop the server:
   ```bash
   /opt/payara41/bin/asadmin stop-domain
   ```

2. Remove the database files:
   ```bash
   rm -f ~/eidtestbed.mv.db ~/eidtestbed.trace.db ~/eidtestbed.lock.db
   ```

3. Start the server again:
   ```bash
   /opt/payara41/bin/asadmin start-domain
   ```

4. Deploy the application:
   ```bash
   /opt/payara41/bin/asadmin deploy eidsrv-testbed-application-1.0-beta-4.ear
   ```

## Additional Resources

- [eID-Server Testbed GitHub Repository](https://github.com/eID-Testbeds/server)
- [Payara Documentation](https://docs.payara.fish/)
- [BSI Technical Guidelines](https://www.bsi.bund.de/EN/Publications/TechnicalGuidelines/technicalGuidelines_node.html)
  - TR-03110: Advanced Security Mechanisms for Machine Readable Travel Documents
  - TR-03112: eCard-API-Framework
  - TR-03124-1: eID-Client
  - TR-03130-1: eID-Server
  - TR-03130-4: Conformity Tests for eID-Server