#!/bin/bash
echo "Starting Stremio installation with dependency fix"
sudo apt update
sudo apt install -y wget dpkg-dev
WORK_DIR=$(mktemp -d)
cd "$WORK_DIR"
echo "Working in temporary directory: $WORK_DIR"

# Download Stremio Package
echo "Downloading Stremio package..."
wget https://dl.strem.io/shell-linux/v4.4.168/stremio_4.4.168-1_amd64.deb

# Extract the package
echo "Extracting package..."
mkdir stremio_extract
dpkg-deb -R stremio_4.4.168-1_amd64.deb stremio_extract

# Modify the control file to change dependency from libmpv1 to libmpv2
echo "Modifying dependencies..."
sed -i 's/libmpv1 (>=0.30.0)/libmpv2/g' stremio_extract/DEBIAN/control
sed -i 's/\x6C\x69\x62\x6D\x70\x76\x2E\x73\x6F\x2E\x31/\x6C\x69\x62\x6D\x70\x76\x2E\x73\x6F\x2E\x32/g' stremio_extract/opt/stremio/stremio

# Display the change for verification
echo "Modified dependencies:"
grep "libmpv" stremio_extract/DEBIAN/control

# Rebuild the package
echo "Rebuilding package..."
dpkg-deb -b stremio_extract stremio_modified.deb

# Install the modified package
echo "Installing modified Stremio package..."
sudo dpkg -i stremio_modified.deb

# Fix any remaining dependencies
echo "Resolving any additional dependencies..."
sudo apt install -f -y
wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb
sudo dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb 

echo "Stremio installation completed!"

echo "Cleaning up temporary files..."
cd ..
rm -rf "$WORK_DIR"

echo "Thank you! If you found this useful, please leave a Star."
